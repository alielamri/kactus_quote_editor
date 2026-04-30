# Revue de code — perspective développeur senior

**Périmètre :** application Rails « éditeur de devis » (quotes / items, validation, audit, CI).  
**Objectif :** feedback honnête pour **relecture avant envoi** au recruteur — pas une liste de tâches obligatoires.

---

## Synthèse

Le dépôt montre une **intention « production »** claire : séparation des responsabilités (services), Postgres, audit avec `paper_trail`, conscience des N+1, pipeline CI réaliste (Linux + Postgres + `npm ci`). C’est au-dessus du strict minimum du brief.

En revanche, il reste au moins **un trou de logique métier sur la mise à jour des devis validés** (contournable via les paramètres), une **dérive entre schéma (`user_id`) et modèle**, et un **écart UI FR / messages flash EN**. Ce sont les points que je corrigerais ou mentionnerais explicitement dans un entretien (« je les connais, voici comment je les durcis »).

---

## Points forts

- **Service objects** avec résultats structurés pour les items : les controllers restent lisibles, les effets de bord métier sont regroupés.
- **`ItemManagementService`** : garde-fous `draft?`, transactions explicites, bang methods — bon réflexe pour documenter l’atomicité et préparer des évolutions.
- **Audit** : `paper_trail` + JSONB + événement `validate` sur la transition de statut — pertinent pour un domaine contractuel / billing.
- **N+1** : scope index sans `includes(:items)` ; `show` charge les items en une fois — cohérent avec l’usage réel des vues.
- **CI** : RuboCop Omakase, Brakeman, `bundler-audit`, tests sous Postgres, installation JS via `npm ci` — aligné avec un runner Ubuntu (plus honnête que de committer des `node_modules` macOS).
- **Monnaie** : `decimal` pour `unit_price` / `vat_rate` — choix défendable avec Postgres (arithmétique exacte).

---

## Risques et défauts (par gravité)

### Critique — Mise à jour d’un devis **validé** via paramètres

**Constat :** `QuotesController#check_validated_for_update` bloque surtout lorsque `quote_params[:status]` est vide. Si un client envoie une requête PATCH avec **`status` présent** (ex. `validated`) **et** un changement de **`name`**, le `before_action` peut laisser passer et **`update` applique le nouveau nom** alors que le métier affiché est « validé = figé ».

De même, **`QuoteValidationService.can_validate_for_update?`** renvoie `true` pour un devis validé dès que `status` n’est pas blank — ce qui **valide conceptuellement** des mises à jour alors que le brief impose l’irréversibilité après validation. Ce helper **n’est pas utilisé** dans le controller : la logique est dupliquée et fragile.

**Recommandation type :** pour un devis `validated`, **interdire toute mise à jour** sauf exception métier explicite (ex. webhook admin) ; en Ruby courant : `readonly!` quand `validated?`, ou filtrer les attributs autorisés à `[]` sur cet état, ou une commande dédiée « validate » sans passer par `update` générique.

### Majeur — Remontée des erreurs métier sur les items

En échec de validation item, le service renvoie un message générique (« Unable to add/update… ») sans exposer **`errors.full_messages`** au navigateur. Pour un outil interne partenaire, la **diagnosticabilité** (montant invalide, TVA hors bornes, etc.) manque.

### Moyen — Colonne `quotes.user_id` sans modèle associé

Le schéma et les migrations prévoient `user_id` / index, mais **`Quote` ne définit pas** `belongs_to :user`. Soit c’est un placeholder futur (à documenter), soit c’est une **dette schéma** qui peut surprendre en revue DB.

### Moyen — Incohérence linguistique UX

Les vues utilisent le français ; les **flash** et plusieurs libellés système restent en anglais. Pour Kactus France, je harmoniserais via **`I18n`** (au minimum des clés dédiées pour les flashes).

### Faible — Dépendance au navigateur « moderne »

`allow_browser versions: :modern` dans `ApplicationController` peut **exclure** des environnements corporate ou des outils de test anciens. À valider produit ; pour un test technique, un commentaire README suffit.

---

## Architecture et conventions

- **Bon usage** des `before_action` pour charger les enregistrements ; nested `items` bien limités aux routes nécessaires (`edit`, pas `new` séparé inline — cohérent avec le brief « tout sur l’écran devis »).
- **`Quote#total_*`** somme en mémoire : correct avec `includes(:items)` sur `show` ; si la même méthode était appelée sur une instance chargée sans items, le nombre de requêtes augmenterait — à garder en tête si réutilisation ailleurs (PDF, API).
- **`destroy` quote** : pas de transaction multi-tables explicite ; `dependent: :destroy` sur les items compense en général — acceptable pour ce périmètre.

---

## Tests

- **Bonne couche** sur les services et l’audit PaperTrail.
- Il manque des **tests d’intégration** (request/controller) pour les scénarios qui font foi en prod : tentative de modification d’un devis validé (y compris **contournements par paramètres**), chemins redirect + flash.
- Les tests sur `can_validate_for_update?` pour un devis validé avec `status: "draft"` **méritent une clarification métier** : si la transition validé → brouillon est interdite, ce cas doit échouer côté application **et** être couvert par un test qui l’attend.

---

## CI / ops

- Pipeline **pertinente** et réaliste après correction `npm ci` / suppression du vendoring macOS.
- Job **system tests** retiré tant qu’il n’y a pas de dossier `test/system` — **cohérent** pour ne pas rougir la CI pour rien ; à réintroduire avec Capybara + navigateur headless quand une vraie suite existe.

---

## Nitpicks (faible impact)

- Messages flash en anglais alors que le README est mixte FR/EN — traiter par convention unique.
- **`QuoteValidationService`** : soit centraliser **toute** la logique d’autorisation de `update` dedans et l’appeler depuis le controller, soit supprimer les méthodes inutilisées pour éviter la **dérive**.

---

## Ce que je mettrais en avant en entretien

1. Choix **decimal + Postgres** et pourquoi pas les cents entiers dans ce contexte.
2. **PaperTrail** avec événement `validate` lisible métier.
3. **Services + transactions** sur les écritures sensibles.
4. **CI honnête** (Linux, Postgres, pas de binaires JS macOS sur Ubuntu).
5. **Limites assumées** : pas d’auth multi-tenant, pas de tests système, et **durcissement encore à faire** sur les updates des devis validés — avec proposition de correctif (readonly / policy / endpoint dédié).

---

*Document pour appuyer une relecture candidat ; à ajuster selon le niveau de détail souhaité dans l’email à l’examinateur.*
