class QuoteValidationService
  def self.can_modify?(quote)
    quote.draft?
  end

  def self.validation_message_for(params)
    params[:status] == "validated" ? "Quote was successfully validated." : "Quote was successfully updated."
  end

  def self.can_validate_for_update?(quote, params)
    return true if quote.draft?
    return false if quote.validated? && params[:status].blank?
    true
  end
end
