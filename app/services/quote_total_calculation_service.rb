class QuoteTotalCalculationService
  def self.calculate_ht(quote)
    quote.items.sum(&:total_ht)
  end

  def self.calculate_vat(quote)
    quote.items.sum(&:total_vat)
  end

  def self.calculate_ttc(quote)
    calculate_ht(quote) + calculate_vat(quote)
  end
end
