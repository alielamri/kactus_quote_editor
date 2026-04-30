require 'test_helper'

class QuoteTotalCalculationServiceTest < ActiveSupport::TestCase
  def setup
    @quote = Quote.create!(name: 'Test Quote', status: :draft)
    @item1 = Item.create!(
      name: 'Item 1',
      quantity: 2,
      unit_price: 100.0,
      vat_rate: 20.0,
      quote: @quote
    )
    @item2 = Item.create!(
      name: 'Item 2',
      quantity: 1,
      unit_price: 50.0,
      vat_rate: 20.0,
      quote: @quote
    )
  end

  test 'calculate_ht sums all items total_ht' do
    expected = (@item1.quantity * @item1.unit_price) + (@item2.quantity * @item2.unit_price)
    assert_equal expected, QuoteTotalCalculationService.calculate_ht(@quote)
  end

  test 'calculate_vat sums all items total_vat' do
    expected = @item1.total_vat + @item2.total_vat
    assert_equal expected, QuoteTotalCalculationService.calculate_vat(@quote)
  end

  test 'calculate_ttc returns sum of HT and VAT' do
    expected = QuoteTotalCalculationService.calculate_ht(@quote) + QuoteTotalCalculationService.calculate_vat(@quote)
    assert_equal expected, QuoteTotalCalculationService.calculate_ttc(@quote)
  end

  test 'calculate_ht returns zero for quote with no items' do
    empty_quote = Quote.create!(name: 'Empty Quote', status: :draft)
    assert_equal 0, QuoteTotalCalculationService.calculate_ht(empty_quote)
  end

  test 'calculate_vat returns zero for quote with no items' do
    empty_quote = Quote.create!(name: 'Empty Quote', status: :draft)
    assert_equal 0, QuoteTotalCalculationService.calculate_vat(empty_quote)
  end

  test 'calculate_ttc returns zero for quote with no items' do
    empty_quote = Quote.create!(name: 'Empty Quote', status: :draft)
    assert_equal 0, QuoteTotalCalculationService.calculate_ttc(empty_quote)
  end
end
