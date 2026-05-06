class ItemManagementService
  class << self
    def create_item(quote, item_params)
      return error_result(I18n.t("flash.items.cannot_modify_validated_quote")) unless quote.draft?

      item = quote.items.build(item_params)

      ActiveRecord::Base.transaction do
        item.save!
      end

      success_result(I18n.t("flash.items.added"))
    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors.full_messages.to_sentence)
    end

    def update_item(item, item_params)
      return error_result(I18n.t("flash.items.cannot_modify_validated_quote")) unless item.quote.draft?

      ActiveRecord::Base.transaction do
        item.update!(item_params)
      end

      success_result(I18n.t("flash.items.updated"))
    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors.full_messages.to_sentence)
    end

    def destroy_item(item)
      return error_result(I18n.t("flash.items.cannot_modify_validated_quote")) unless item.quote.draft?

      ActiveRecord::Base.transaction do
        item.destroy!
      end

      success_result(I18n.t("flash.items.deleted"))
    rescue ActiveRecord::RecordNotDestroyed
      error_result(I18n.t("flash.items.delete_failed"))
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
