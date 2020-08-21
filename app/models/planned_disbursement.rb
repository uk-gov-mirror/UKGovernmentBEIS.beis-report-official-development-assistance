class PlannedDisbursement < ApplicationRecord
  include PublicActivity::Common
  PLANNED_DISBURSEMENT_BUDGET_TYPES = {"1": "original", "2": "revised"}

  strip_attributes only: [:providing_organisation_reference, :receiving_organisation_reference]

  belongs_to :parent_activity, class_name: "Activity"
  belongs_to :report

  validates_presence_of :planned_disbursement_type,
    :period_start_date,
    :currency,
    :value,
    :providing_organisation_name,
    :providing_organisation_type,
    :receiving_organisation_name,
    :receiving_organisation_type
  validates :value, inclusion: {in: 0.01..99_999_999_999.00}
  validates_with EndDateNotBeforeStartDateValidator, if: -> { period_start_date.present? && period_end_date.present? }
  validates :period_start_date, :period_end_date, date_within_boundaries: true

  def unknown_receiving_organisation_type?
    receiving_organisation_type == "0"
  end
end
