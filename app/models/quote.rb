class Quote < ApplicationRecord
  has_paper_trail ignore: [ :updated_at ]

  has_many :items, dependent: :destroy

  enum :status, { draft: 0, validated: 1 }

  validates :name, presence: true

  before_update :abort_if_already_validated

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

  def abort_if_already_validated
    prior = attribute_in_database(:status)
    return if prior.nil?

    validated_id = self.class.statuses[:validated]
    prior_id = prior.is_a?(Integer) ? prior : self.class.statuses[prior.to_s]
    return unless prior_id == validated_id

    errors.add(:base, I18n.t("errors.quote.cannot_modify_validated"))
    throw :abort
  end

  def tag_validate_event_for_paper_trail
    return unless status_changed? && validated?

    self.paper_trail_event = "validate"
  end
end
