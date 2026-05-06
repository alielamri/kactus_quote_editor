class QuoteValidationService
  def self.can_modify?(quote)
    quote.draft?
  end

  def self.validation_message_for(params)
    params[:status].to_s == "validated" ? I18n.t("flash.quotes.validated") : I18n.t("flash.quotes.updated")
  end
end
