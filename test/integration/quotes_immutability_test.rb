require "test_helper"

class QuotesImmutabilityTest < ActionDispatch::IntegrationTest
  setup do
    @draft = Quote.create!(name: "Draft Q", status: :draft)
    @validated = Quote.create!(name: "Locked Q", status: :validated)
  end

  test "PATCH validated quote cannot change name even when status validated is sent" do
    original_name = @validated.name
    patch quote_path(@validated), params: { quote: { name: "Hacked", status: "validated" } }

    assert_redirected_to quote_path(@validated)
    assert_equal I18n.t("flash.quotes.cannot_modify_validated"), flash[:alert]
    assert_equal original_name, @validated.reload.name
  end

  test "PATCH validated quote cannot change name with name-only params" do
    original_name = @validated.name
    patch quote_path(@validated), params: { quote: { name: "Hacked" } }

    assert_redirected_to quote_path(@validated)
    assert_equal I18n.t("flash.quotes.cannot_modify_validated"), flash[:alert]
    assert_equal original_name, @validated.reload.name
  end

  test "PATCH validated quote cannot revert to draft" do
    patch quote_path(@validated), params: { quote: { status: "draft" } }

    assert_redirected_to quote_path(@validated)
    assert_equal I18n.t("flash.quotes.cannot_modify_validated"), flash[:alert]
    assert_predicate @validated.reload, :validated?
  end

  test "PATCH draft quote can transition to validated" do
    patch quote_path(@draft), params: { quote: { status: "validated" } }

    assert_redirected_to quote_path(@draft)
    assert_predicate @draft.reload, :validated?
  end

  test "PATCH draft quote can update name" do
    patch quote_path(@draft), params: { quote: { name: "Renamed" } }

    assert_redirected_to quote_path(@draft)
    assert_equal "Renamed", @draft.reload.name
  end

  test "POST item to validated quote is rejected" do
    assert_no_difference -> { @validated.items.count } do
      post quote_items_path(@validated), params: {
        item: { name: "Line", quantity: 1, unit_price: "10.00", vat_rate: "20.0" }
      }
    end

    assert_redirected_to quote_path(@validated)
    assert_equal I18n.t("flash.items.cannot_modify_validated_quote"), flash[:alert]
  end
end
