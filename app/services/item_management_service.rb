class ItemManagementService
  class << self
    def create_item(quote, item_params)
      return error_result('Cannot modify items in a validated quote.') unless quote.draft?

      item = quote.items.build(item_params)

      ActiveRecord::Base.transaction do
        item.save!
      end

      success_result('Item was successfully added.')
    rescue ActiveRecord::RecordInvalid
      error_result('Unable to add item.')
    end

    def update_item(item, item_params)
      return error_result('Cannot modify items in a validated quote.') unless item.quote.draft?

      ActiveRecord::Base.transaction do
        item.update!(item_params)
      end

      success_result('Item was successfully updated.')
    rescue ActiveRecord::RecordInvalid
      error_result('Unable to update item.')
    end

    def destroy_item(item)
      return error_result('Cannot modify items in a validated quote.') unless item.quote.draft?

      ActiveRecord::Base.transaction do
        item.destroy!
      end

      success_result('Item was successfully deleted.')
    rescue ActiveRecord::RecordNotDestroyed
      error_result('Unable to delete item.')
    end

    private

    def success_result(message)
      { success: true, message: message }
    end

    def error_result(error)
      { success: false, error: error }
    end
  end
end
