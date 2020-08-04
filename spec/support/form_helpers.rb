module FormHelpers
  def fill_in_activity_form(
    identifier: "A-Unique-Identifier",
    title: "My Aid Activity",
    description: Faker::Lorem.paragraph,
    sector_category: "Basic Education",
    sector: "Primary education",
    programme_status: "07",
    # status: "2",
    planned_start_date_day: "1",
    planned_start_date_month: "1",
    planned_start_date_year: "2020",
    planned_end_date_day: "1",
    planned_end_date_month: "1",
    planned_end_date_year: "2021",
    actual_start_date_day: "1",
    actual_start_date_month: "1",
    actual_start_date_year: "2020",
    actual_end_date_day: "1",
    actual_end_date_month: "2",
    actual_end_date_year: "2020",
    geography: "recipient_region",
    recipient_region: "Developing countries, unspecified",
    flow: "ODA",
    aid_type: "A01",
    level:,
    parent: nil
  )

    expect(page).to have_content I18n.t("form.legend.activity.level")
    expect(page).to have_content I18n.t("form.hint.activity.level")
    expect(page).to have_content I18n.t("form.hint.activity.level_step.#{level}")
    choose I18n.t("page_content.activity.level.#{level}").capitalize
    click_button I18n.t("form.button.activity.submit")

    if parent.present?
      expect(page).to have_content I18n.t("form.legend.activity.parent", parent_level: parent.level, level: I18n.t("page_content.activity.level.#{level}"))
      expect(page).to have_content I18n.t("form.hint.activity.parent", parent_level: parent.level, level: I18n.t("page_content.activity.level.#{level}"))
      choose parent.title
      click_button I18n.t("form.button.activity.submit")
    end

    expect(page).to have_content I18n.t("form.label.activity.identifier")
    expect(page).to have_content I18n.t("form.hint.activity.identifier")
    fill_in "activity[identifier]", with: identifier
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.purpose", level: activity_level(level))
    expect(page).to have_content I18n.t("form.label.activity.title", level: activity_level(level).humanize)
    expect(page).to have_content I18n.t("form.label.activity.description")
    fill_in "activity[title]", with: title
    fill_in "activity[description]", with: description
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.sector_category", level: activity_level(level))
    expect(page).to have_content(
      ActionView::Base.full_sanitizer.sanitize(
        I18n.t("form.legend.activity.sector_category", level: I18n.t("page_content.activity.level.#{level}"))
      )
    )
    choose sector_category
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.sector", sector_category: sector_category, level: activity_level(level))

    choose sector
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.programme_status")
    expect(page).to have_content "Delivery"
    expect(page).to have_content "Planned"
    expect(page).to have_content "Agreement in place"
    expect(page).to have_content "Call/Activity open"
    expect(page).to have_content "Review"
    expect(page).to have_content "Decided"
    expect(page).to have_content "Spend in progress"
    expect(page).to have_content "Finalisation"
    expect(page).to have_content "Completed"
    expect(page).to have_content "Stopped"
    expect(page).to have_content "Cancelled"

    choose("activity[programme_status]", option: programme_status)
    click_button I18n.t("form.button.activity.submit")

    # expect(page).to have_content I18n.t("form.legend.activity.status", level: activity_level(level))
    # expect(page).to have_content "The activity is being scoped or planned"
    # expect(page).to have_content "The activity is currently being implemented"
    # expect(page).to have_content "Physical activity is complete or the final disbursement has been made"
    # expect(page).to have_content "Physical activity is complete or the final disbursement has been made, but the activity remains open pending financial sign off or M&E"
    # expect(page).to have_content "The activity has been cancelled"
    # expect(page).to have_content "The activity has been temporarily suspended"

    # choose("activity[status]", option: status)
    # click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("page_title.activity_form.show.dates", level: activity_level(level))

    expect(page).to have_content I18n.t("form.legend.activity.planned_start_date")
    fill_in "activity[planned_start_date(3i)]", with: planned_start_date_day
    fill_in "activity[planned_start_date(2i)]", with: planned_start_date_month
    fill_in "activity[planned_start_date(1i)]", with: planned_start_date_year

    expect(page).to have_content I18n.t("form.legend.activity.planned_end_date")
    fill_in "activity[planned_end_date(3i)]", with: planned_end_date_day
    fill_in "activity[planned_end_date(2i)]", with: planned_end_date_month
    fill_in "activity[planned_end_date(1i)]", with: planned_end_date_year

    expect(page).to have_content I18n.t("form.legend.activity.actual_start_date")
    fill_in "activity[actual_start_date(3i)]", with: actual_start_date_day
    fill_in "activity[actual_start_date(2i)]", with: actual_start_date_month
    fill_in "activity[actual_start_date(1i)]", with: actual_start_date_year

    expect(page).to have_content I18n.t("form.legend.activity.actual_end_date")
    fill_in "activity[actual_end_date(3i)]", with: actual_end_date_day
    fill_in "activity[actual_end_date(2i)]", with: actual_end_date_month
    fill_in "activity[actual_end_date(1i)]", with: actual_end_date_year

    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.geography")
    choose "Region"
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.label.activity.recipient_region")
    select recipient_region, from: "activity[recipient_region]"
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.label.activity.flow")
    expect(page.html).to include I18n.t("form.hint.activity.flow")
    select flow, from: "activity[flow]"
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content I18n.t("form.legend.activity.aid_type")
    expect(page).to have_content "A code for the vocabulary aid-type classifications. International Aid Transparency Initiative (IATI) descriptions can be found here (Opens in new window)"
    choose("activity[aid_type]", option: aid_type)
    click_button I18n.t("form.button.activity.submit")

    expect(page).to have_content identifier
    expect(page).to have_content title
    expect(page).to have_content description
    expect(page).to have_content sector
    expect(page).to have_content I18n.t("activity.programme_status.#{programme_status}")
    # expect(page).to have_content status
    expect(page).to have_content recipient_region
    expect(page).to have_content flow
    expect(page).to have_content I18n.t("activity.aid_type.#{aid_type.downcase}")
    expect(page).to have_content localise_date_from_input_fields(
      year: planned_start_date_year,
      month: planned_start_date_month,
      day: planned_start_date_day
    )
    expect(page).to have_content localise_date_from_input_fields(
      year: planned_end_date_year,
      month: planned_end_date_month,
      day: planned_end_date_day
    )

    my_activity = Activity.find_by(identifier: identifier)
    iati_status = ProgrammeToIatiStatus.new.programme_status_to_iati_status(programme_status)
    expect(my_activity.status).not_to be_nil
    expect(my_activity.status).to eq(iati_status)
  end

  def fill_in_transaction_form(expectations: true,
    description: "This money will be purchasing a new school roof",
    transaction_type: "Outgoing Pledge",
    date_year: "2020",
    date_month: "1",
    date_day: "2",
    value: "1000.01",
    disbursement_channel: "Money is disbursed through central Ministry of Finance or Treasury",
    currency: "Pound Sterling",
    providing_organisation: OpenStruct.new(name: "Example provider", reference: "GB-GOV-1", type: "Government"),
    receiving_organisation: OpenStruct.new(name: "Example receiver", reference: "GB-COH-123", type: "Private Sector"))
    fill_in "transaction[description]", with: description
    select transaction_type, from: "transaction[transaction_type]"
    fill_in "transaction[date(3i)]", with: date_day
    fill_in "transaction[date(2i)]", with: date_month
    fill_in "transaction[date(1i)]", with: date_year
    fill_in "transaction[value]", with: value
    select disbursement_channel, from: "transaction[disbursement_channel]"
    select currency, from: "transaction[currency]"

    fill_in "transaction[providing_organisation_name]", with: providing_organisation.name
    select providing_organisation.type, from: "transaction[providing_organisation_type]"
    fill_in "transaction[providing_organisation_reference]", with: providing_organisation.reference

    fill_in "transaction[receiving_organisation_name]", with: receiving_organisation.name
    select receiving_organisation.type, from: "transaction[receiving_organisation_type]"
    fill_in "transaction[receiving_organisation_reference]", with: receiving_organisation.reference

    click_on(I18n.t("default.button.submit"))

    if expectations
      within ".transactions" do
        expect(page).to have_content(transaction_type)
        expect(page).to have_content localise_date_from_input_fields(
          year: date_year,
          month: date_month,
          day: date_day
        )
        expect(page).to have_content(ActionController::Base.helpers.number_to_currency(value, unit: "£"))
        expect(page).to have_content(disbursement_channel)
        expect(page).to have_content(currency)
        expect(page).to have_content(providing_organisation.name)
        expect(page).to have_content(receiving_organisation.name)
      end
    end
  end

  def fill_in_planned_disbursement_form(planned_disbursement_type: "Original",
    period_start_date_day: "1",
    period_start_date_month: "1",
    period_start_date_year: "2020",
    period_end_date_day: "28",
    period_end_date_month: "4",
    period_end_date_year: "2020",
    currency: "Pound Sterling",
    value: "100000",
    receiving_organisation: OpenStruct.new(name: "Example receiver", reference: "GB-COH-987", type: "Private Sector"))

    choose planned_disbursement_type
    fill_in "planned_disbursement[period_start_date(3i)]", with: period_start_date_day
    fill_in "planned_disbursement[period_start_date(2i)]", with: period_start_date_month
    fill_in "planned_disbursement[period_start_date(1i)]", with: period_start_date_year

    fill_in "planned_disbursement[period_end_date(3i)]", with: period_end_date_day
    fill_in "planned_disbursement[period_end_date(2i)]", with: period_end_date_month
    fill_in "planned_disbursement[period_end_date(1i)]", with: period_end_date_year

    select currency, from: "planned_disbursement[currency]"
    fill_in "planned_disbursement[value]", with: value

    fill_in "planned_disbursement[receiving_organisation_name]", with: receiving_organisation.name
    select receiving_organisation.type, from: "planned_disbursement[receiving_organisation_type]"
    fill_in "planned_disbursement[receiving_organisation_reference]", with: receiving_organisation.reference

    click_on(I18n.t("default.button.submit"))
  end

  def localise_date_from_input_fields(year:, month:, day:)
    I18n.l(Date.parse("#{year}-#{month}-#{day}"))
  end

  private def activity_level(level)
    I18n.t("page_content.activity.level.#{level}")
  end
end
