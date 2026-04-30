class Item < ApplicationRecord
  has_paper_trail ignore: [:updated_at]

  belongs_to :quote

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vat_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validate :quote_must_not_be_validated

  def total_ht
    quantity * unit_price
  end

  def total_vat
    (total_ht * vat_rate / 100).round(2)
  end

  def total_ttc
    total_ht + total_vat
  end

  private

  def quote_must_not_be_validated
    return if quote&.draft?

    errors.add(:quote, 'cannot be modified because it is validated')
  end
end
