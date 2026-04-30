class Quote < ApplicationRecord
  has_many :items, dependent: :destroy

  enum :status, { draft: 0, validated: 1 }

  validates :name, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def total_ht
    items.sum(&:total_ht)
  end

  def total_vat
    items.sum(&:total_vat)
  end

  def total_ttc
    items.sum(&:total_ttc)
  end
end
