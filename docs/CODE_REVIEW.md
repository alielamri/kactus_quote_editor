# Revue de code — éditeur de devis (état du dépôt)

**Objectif :** document honnête pour relecture / recruteur — aligné sur le **code actuel**.

---

## Synthèse

L’app vise une **livrée proche prod** : Postgres, totaux en décimaux, `paper_trail`, services pour les écritures sur les lignes, CI (RuboCop, Brakeman, bundler-audit, tests sous Postgres).

**Invariants métier (brief)** : devis **validé** = plus modifiable ni supprimable ; items éditables seulement en **brouillon**. Appliqué en **HTTP** + **modèle** (`Quote#abort_if_already_validated`) + **tests d’intégration**.

**Internationalisation** : locale par défaut **`fr`** (`config/application.rb`) ; textes flash et messages applicatifs dans `config/locales/app.{fr,en}.yml` ; messages d’erreur ActiveRecord via **`rails-i18n`**.

**Schéma** : colonne **`user_id`** retirée des `quotes` (pas de modèle `User` dans ce périmètre — évite une dette schéma fantôme).

---

## Points forts

- **`ItemManagementService`** : garde `draft?`, transactions, `RecordInvalid` → **`full_messages`** (partenaire voit la cause).
- **Totaux devis** : uniquement **`Quote#total_*`** (pas de service dupliqué).
- **Tests** : intégration immutabilité + **requête POST item** avec assertion sur le **flash** de validation.
- **CI** : pipeline réaliste.

---

## Limites assumées (hors périmètre actuel)

| Sujet | Détail |
|--------|--------|
| **Auth / multi-tenant** | Pas de `User` ; tout devis est global dans l’app démo. |
| **Tests système** | Capybara présent ; pas de `test/system` tant que la suite n’est pas écrite. |
| **`allow_browser :modern`** | Choix produit / compat navigateurs. |

---

## Ce que je mettrais en avant en entretien

1. **Decimal + Postgres** pour montants / TVA.  
2. **PaperTrail** + événement `validate`.  
3. **I18n** (FR par défaut, EN dispo pour bascule éventuelle).  
4. **Intégrité devis validé** : contrôleur + modèle + specs.  
5. **Schéma propre** : pas de `user_id` orphelin.

---

*Document maintenu en phase avec les correctifs (immutabilité, messages explicites, i18n, migration user_id).*
