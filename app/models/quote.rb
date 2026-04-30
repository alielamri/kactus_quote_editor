class Quote < ApplicationRecord
  has_paper_trail ignore: [ :updated_at ]

  has_many :items, dependent: :destroy

  enum :status, { draft: 0, validated: 1 }

  validates :name, presence: true

  before_save :tag_validate_event_for_paper_trail

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

  private

  def tag_validate_event_for_paper_trail
    return unless status_changed? && validated?

    self.paper_trail_event = "validate"
  end
end
