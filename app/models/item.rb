class Item < ApplicationRecord
  belongs_to :quote

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vat_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validate :quote_must_not_be_validated

  def unit_price
    unit_price_cents / 100.0
  end

  def unit_price=(value)
    self.unit_price_cents = (value.to_f * 100).round.to_i
  end

  def total_ht_cents
    quantity * unit_price_cents
  end

  def total_vat_cents
    (total_ht_cents * vat_rate / 100).round
  end

  def total_ttc_cents
    total_ht_cents + total_vat_cents
  end

  def total_ht
    total_ht_cents / 100.0
  end

  def total_vat
    total_vat_cents / 100.0
  end

  def total_ttc
    total_ttc_cents / 100.0
  end

  private

  def quote_must_not_be_validated
    errors.add(:quote, 'cannot be modified because it is validated') if quote&.draft? == false
  end
end
