require 'test_helper'

class QuoteValidationServiceTest < ActiveSupport::TestCase
  def setup
    @quote_draft = Quote.create!(name: 'Draft Quote', status: :draft)
    @quote_validated = Quote.create!(name: 'Validated Quote', status: :validated)
  end

  test 'can_modify? returns true for draft quote' do
    assert QuoteValidationService.can_modify?(@quote_draft)
  end

  test 'can_modify? returns false for validated quote' do
    assert_not QuoteValidationService.can_modify?(@quote_validated)
  end

  test 'validation_message_for returns validation message when status is validated' do
    params = { status: 'validated' }
    message = QuoteValidationService.validation_message_for(params)
    assert_equal 'Quote was successfully validated.', message
  end

  test 'validation_message_for returns update message when status is not validated' do
    params = { status: 'draft' }
    message = QuoteValidationService.validation_message_for(params)
    assert_equal 'Quote was successfully updated.', message
  end

  test 'validation_message_for returns update message when status is blank' do
    params = { status: '' }
    message = QuoteValidationService.validation_message_for(params)
    assert_equal 'Quote was successfully updated.', message
  end

  test 'can_validate_for_update? returns true for draft quote' do
    params = { status: '' }
    assert QuoteValidationService.can_validate_for_update?(@quote_draft, params)
  end

  test 'can_validate_for_update? returns true for validated quote with status change' do
    params = { status: 'draft' }
    assert QuoteValidationService.can_validate_for_update?(@quote_validated, params)
  end

  test 'can_validate_for_update? returns false for validated quote with blank status' do
    params = { status: '' }
    assert_not QuoteValidationService.can_validate_for_update?(@quote_validated, params)
  end
end
