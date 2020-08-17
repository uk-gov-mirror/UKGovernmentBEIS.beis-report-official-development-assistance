require "csv"

class ExportActivityToCsv
  attr_accessor :activity

  def initialize(activity: nil)
    @activity = activity
  end

  def call
    activity_presenter = ActivityPresenter.new(activity)
    [
      activity_presenter.identifier,
      activity_presenter.transparency_identifier,
      activity_presenter.sector,
      activity_presenter.title,
      activity_presenter.description,
      activity_presenter.status,
      activity_presenter.planned_start_date,
      activity_presenter.actual_start_date,
      activity_presenter.planned_end_date,
      activity_presenter.actual_end_date,
      activity_presenter.recipient_region,
      activity_presenter.recipient_country,
      activity_presenter.aid_type,
      activity_presenter.flow,
      activity_presenter.finance,
      activity_presenter.tied_status,
      activity_presenter.level_letter,
      activity_presenter.transactions_total,
      activity_presenter.link_to_roda,
    ].to_csv
  end

  def headers(report:)
    report_financial_quarter = ReportPresenter.new(report).financial_quarter_and_year
    [
      "Identifier",
      "Transparency identifier",
      "Sector",
      "Title",
      "Description",
      "Status",
      "Planned start date",
      "Actual start date",
      "Planned end date",
      "Actual end date",
      "Recipient region",
      "Recipient country",
      "Aid type",
      "Flow",
      "Finance",
      "Tied status",
      "Level",
      report_financial_quarter ? report_financial_quarter + " actuals" : "Actuals",
      "Link to activity in RODA",
    ].to_csv
  end
end
