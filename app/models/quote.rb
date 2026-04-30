class Quote < ApplicationRecord
  has_many :items, dependent: :destroy

  enum :status, { draft: 0, validated: 1 }

  validates :name, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def total_ht_cents
    items.sum { |item| item.quantity * item.unit_price_cents }
  end

  def total_vat_cents
    items.sum { |item| (item.quantity * item.unit_price_cents * item.vat_rate / 100).round }
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
end
