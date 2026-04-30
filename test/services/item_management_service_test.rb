require 'test_helper'

class ItemManagementServiceTest < ActiveSupport::TestCase
  def setup
    @draft_quote = Quote.create!(name: 'Draft Quote', status: :draft)
    @validated_quote = Quote.create!(name: 'Validated Quote', status: :validated)
    @item = Item.create!(
      name: 'Test Item',
      quantity: 1,
      unit_price: 100.0,
      vat_rate: 20.0,
      quote: @draft_quote
    )
  end

  # Tests for create_item
  test 'create_item succeeds for draft quote' do
    params = { name: 'New Item', quantity: 2, unit_price: 50.0, vat_rate: 20.0 }
    result = ItemManagementService.create_item(@draft_quote, params)
    
    assert result[:success]
    assert_equal 'Item was successfully added.', result[:message]
  end

  test 'create_item fails for validated quote' do
    params = { name: 'New Item', quantity: 2, unit_price: 50.0, vat_rate: 20.0 }
    result = ItemManagementService.create_item(@validated_quote, params)
    
    assert_not result[:success]
    assert_equal 'Cannot modify items in a validated quote.', result[:error]
  end

  test 'create_item fails with invalid params' do
    params = { name: '', quantity: -1, unit_price: 50.0, vat_rate: 20.0 }
    result = ItemManagementService.create_item(@draft_quote, params)
    
    assert_not result[:success]
    assert_equal 'Unable to add item.', result[:error]
  end

  # Tests for update_item
  test 'update_item succeeds for draft quote' do
    params = { name: 'Updated Item', quantity: 3, unit_price: 75.0, vat_rate: 20.0 }
    result = ItemManagementService.update_item(@item, params)
    
    assert result[:success]
    assert_equal 'Item was successfully updated.', result[:message]
    assert_equal 'Updated Item', @item.reload.name
  end

  test 'update_item fails for validated quote' do
    # Create item while quote is still draft
    item = Item.create!(
      name: 'Item in Validated Quote',
      quantity: 1,
      unit_price: 100.0,
      vat_rate: 20.0,
      quote: @draft_quote
    )
    # Now validate the quote
    @draft_quote.update!(status: :validated)
    
    params = { name: 'Updated Item', quantity: 3, unit_price: 75.0, vat_rate: 20.0 }
    result = ItemManagementService.update_item(item, params)
    
    assert_not result[:success]
    assert_equal 'Cannot modify items in a validated quote.', result[:error]
  end

  test 'update_item fails with invalid params' do
    params = { name: '', quantity: -1, unit_price: 75.0, vat_rate: 20.0 }
    result = ItemManagementService.update_item(@item, params)
    
    assert_not result[:success]
    assert_equal 'Unable to update item.', result[:error]
  end

  # Tests for destroy_item
  test 'destroy_item succeeds for draft quote' do
    result = ItemManagementService.destroy_item(@item)
    
    assert result[:success]
    assert_equal 'Item was successfully deleted.', result[:message]
    assert_not Item.exists?(@item.id)
  end

  test 'destroy_item fails for validated quote' do
    # Create item while quote is still draft
    item = Item.create!(
      name: 'Item in Validated Quote',
      quantity: 1,
      unit_price: 100.0,
      vat_rate: 20.0,
      quote: @draft_quote
    )
    # Now validate the quote
    @draft_quote.update!(status: :validated)
    
    result = ItemManagementService.destroy_item(item)
    
    assert_not result[:success]
    assert_equal 'Cannot modify items in a validated quote.', result[:error]
  end
end
