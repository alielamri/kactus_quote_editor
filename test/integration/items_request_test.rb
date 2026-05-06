require "test_helper"

class ItemsRequestTest < ActionDispatch::IntegrationTest
  test "POST item invalide redirige avec le détail des erreurs de validation en flash" do
    quote = Quote.create!(name: "Devis test", status: :draft)

    post quote_items_path(quote), params: {
      item: { name: "", quantity: -1, unit_price: 50.0, vat_rate: 20.0 }
    }

    assert_redirected_to quote_path(quote)
    assert_predicate flash[:alert], :present?
    assert_match(
      /nom|quantité|vide|doit|grand|renseign/i,
      flash[:alert].to_s.downcase,
      "le flash doit reprendre les messages de validation ActiveRecord (locale fr)"
    )
  end
end
