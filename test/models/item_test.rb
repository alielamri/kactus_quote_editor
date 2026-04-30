require "test_helper"

class ItemTest < ActiveSupport::TestCase
  def setup
    @quote = Quote.create(name: "Test Quote")
  end

  test "should create an item with valid attributes" do
    item = @quote.items.new(
      name: "Test Item",
      quantity: 2,
      unit_price: 50.00,
      vat_rate: 20
    )
    assert item.valid?
  end

  test "should not create an item without a name" do
    item = @quote.items.new(
      name: "",
      quantity: 2,
      unit_price: 50.00,
      vat_rate: 20
    )
    assert_not item.valid?
  end

  test "should not create an item with quantity 0" do
    item = @quote.items.new(
      name: "Test Item",
      quantity: 0,
      unit_price: 50.00,
      vat_rate: 20
    )
    assert_not item.valid?
  end

  test "should not create an item with negative unit price" do
    item = @quote.items.new(
      name: "Test Item",
      quantity: 2,
      unit_price: -10.00,
      vat_rate: 20
    )
    assert_not item.valid?
  end

  test "should not create an item with VAT rate > 100" do
    item = @quote.items.new(
      name: "Test Item",
      quantity: 2,
      unit_price: 50.00,
      vat_rate: 150
    )
    assert_not item.valid?
  end

  test "should calculate total_ht correctly" do
    item = @quote.items.create!(
      name: "Test Item",
      quantity: 3,
      unit_price: 25.50,
      vat_rate: 20
    )
    assert_equal 76.50, item.total_ht
  end

  test "should calculate total_vat correctly" do
    item = @quote.items.create!(
      name: "Test Item",
      quantity: 2,
      unit_price: 100.00,
      vat_rate: 20
    )
    assert_equal 40.0, item.total_vat
  end

  test "should calculate total_ttc correctly" do
    item = @quote.items.create!(
      name: "Test Item",
      quantity: 2,
      unit_price: 100.00,
      vat_rate: 20
    )
    assert_equal 240.0, item.total_ttc
  end

  test "should not create item if quote is validated" do
    @quote.update(status: :validated)
    item = @quote.items.new(
      name: "Test Item",
      quantity: 2,
      unit_price: 50.00,
      vat_rate: 20
    )
    assert_not item.valid?
  end
end
