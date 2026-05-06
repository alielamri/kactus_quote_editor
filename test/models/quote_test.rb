require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  def setup
    @quote = Quote.create(name: "Test Quote")
  end

  test "should create a quote with valid attributes" do
    quote = Quote.new(name: "Valid Quote")
    assert quote.valid?
  end

  test "should not create a quote without a name" do
    quote = Quote.new(name: "")
    assert_not quote.valid?
  end

  test "should have draft status by default" do
    assert @quote.draft?
  end

  test "should calculate total_ht correctly" do
    @quote.items.create!(name: "Item 1", quantity: 2, unit_price: 50.00, vat_rate: 20)
    @quote.items.create!(name: "Item 2", quantity: 1, unit_price: 100.00, vat_rate: 20)
    assert_equal 200.0, @quote.total_ht
  end

  test "should calculate total_vat correctly" do
    @quote.items.create!(name: "Item 1", quantity: 2, unit_price: 50.00, vat_rate: 20)
    assert_equal 20.0, @quote.total_vat
  end

  test "should calculate total_ttc correctly" do
    @quote.items.create!(name: "Item 1", quantity: 2, unit_price: 50.00, vat_rate: 20)
    assert_equal 120.0, @quote.total_ttc
  end

  test "should destroy associated items when quote is destroyed" do
    item = @quote.items.create!(name: "Item 1", quantity: 1, unit_price: 50.00, vat_rate: 20)
    item_id = item.id
    @quote.destroy
    assert_nil Item.find_by(id: item_id)
  end

  test "should validate quote" do
    @quote.update(status: :validated)
    assert @quote.validated?
  end

  test "cannot update name on an already validated quote" do
    q = Quote.create!(name: "Original", status: :validated)
    assert_not q.update(name: "Changed")
    assert_equal I18n.t("errors.quote.cannot_modify_validated"), q.errors[:base].first
    assert_equal "Original", q.reload.name
  end

  test "draft quote can still be renamed" do
    q = Quote.create!(name: "Draft name", status: :draft)
    assert q.update(name: "New name")
    assert_equal "New name", q.reload.name
  end

  test "totals are zero for quote with no line items" do
    empty = Quote.create!(name: "Empty", status: :draft)
    assert_equal 0, empty.total_ht
    assert_equal 0, empty.total_vat
    assert_equal 0, empty.total_ttc
  end
end
