class ItemManagementService
  def self.create_item(quote, item_params)
    return error_result('Cannot modify items in a validated quote.') unless quote.draft?

    item = quote.items.build(item_params)
    if item.save
      success_result('Item was successfully added.')
    else
      error_result('Unable to add item.')
    end
  end

  def self.update_item(item, item_params)
    return error_result('Cannot modify items in a validated quote.') unless item.quote.draft?

    if item.update(item_params)
      success_result('Item was successfully updated.')
    else
      error_result('Unable to update item.')
    end
  end

  def self.destroy_item(item)
    return error_result('Cannot modify items in a validated quote.') unless item.quote.draft?

    if item.destroy
      success_result('Item was successfully deleted.')
    else
      error_result('Unable to delete item.')
    end
  end

  private

  def self.success_result(message)
    { success: true, message: message }
  end

  def self.error_result(error)
    { success: false, error: error }
  end
end
