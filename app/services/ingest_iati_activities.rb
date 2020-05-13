require "nokogiri"

class IngestIatiActivities
  include CodelistHelper

  attr_accessor :file_io, :delivery_partner

  def initialize(delivery_partner:, file_io:)
    self.delivery_partner = delivery_partner
    self.file_io = file_io
  end

  def call
    doc = Nokogiri::XML(file_io, nil, "UTF-8")

    legacy_activities = doc.xpath("//iati-activity")

    legacy_activities.each do |legacy_activity|
      ActiveRecord::Base.transaction do
        new_activity = Activity.new(level: :project, organisation: delivery_partner)
        add_identifiers(legacy_activity: legacy_activity, new_activity: new_activity)

        parent_activity = find_or_create_parent_activities(delivery_partner: delivery_partner, new_activity: new_activity)
        new_activity.activity = parent_activity

        add_participating_organisation(delivery_partner: delivery_partner, new_activity: new_activity, legacy_activity: legacy_activity)

        title = legacy_activity.elements[2].children.detect { |child| child.name.eql?("narrative") }.children.text if legacy_activity.elements[2].name.eql?("title")
        new_activity.title = normalize_string(title)
        description = legacy_activity.elements[3].children.detect { |child| child.name.eql?("narrative") }.children.text if legacy_activity.elements[3].name.eql?("description")
        new_activity.description = normalize_string(description)
        new_activity.status = legacy_activity.elements.detect { |element| element.name.eql?("activity-status") }.attributes["code"].value

        sector = legacy_activity.elements.detect { |element| element.name.eql?("sector") }.attributes["code"].value
        new_activity.sector_category = sector_category_code(sector_code: sector)
        new_activity.sector = sector
        new_activity.flow = legacy_activity.elements.detect { |element| element.name.eql?("default-flow-type") }.attributes["code"].value
        new_activity.aid_type = legacy_activity.elements.detect { |element| element.name.eql?("default-aid-type") }.attributes["code"].value

        add_dates(legacy_activity: legacy_activity, new_activity: new_activity)
        add_geography(legacy_activity: legacy_activity, new_activity: new_activity)
        add_transactions(legacy_activity: legacy_activity, new_activity: new_activity)
        add_budgets(legacy_activity: legacy_activity, new_activity: new_activity)

        new_activity.ingested = true
        # Set the status to invoke validations
        new_activity.form_state = :complete
        new_activity.save
      end
    end
  end

  private def find_or_create_parent_activities(delivery_partner:, new_activity:)
    identifiers = new_activity.previous_identifier.split("-")
    fund_identifier = identifiers.fourth
    programme_identifier = identifiers.fifth

    fund = Activity.funds.find_by(identifier: fund_identifier)
    if fund.nil?
      puts "Could not find associated fund for: #{new_activity.previous_identifier} with `identifier`: #{programme_identifier}. Creating one." unless Rails.env.test?
      fund = CreateFundActivity.new(organisation_id: service_owner_organisation.id).call
      fund.update!(identifier: fund_identifier, form_state: :identifier)
    end

    programme = Activity.programmes.find_by(identifier: programme_identifier)
    if programme.nil?
      puts "Could not find associated programme for: #{new_activity.previous_identifier} with `identifier`: #{programme_identifier}. Creating one." unless Rails.env.test?
      programme = CreateProgrammeActivity.new(organisation_id: service_owner_organisation.id, fund_id: fund.id).call
      programme.update!(identifier: programme_identifier, form_state: :identifier)
    end

    programme
  end

  private def add_participating_organisation(delivery_partner:, new_activity:, legacy_activity:)
    reporting_org_reference = legacy_activity.elements[1].attributes["ref"].value if legacy_activity.elements[1].name.eql?("reporting-org")
    new_activity.reporting_organisation = Organisation.find_by(iati_reference: reporting_org_reference)

    funding_org_element = legacy_activity.elements.detect { |element| element.name.eql?("participating-org") && element.attributes["role"].value.eql?("1") }
    if funding_org_element
      funding_org_reference = funding_org_element.attributes["ref"].value
      funding_organisation = Organisation.find_by(iati_reference: funding_org_reference)
      new_activity.funding_organisation_name = funding_organisation.name
      new_activity.funding_organisation_type = funding_organisation.organisation_type
      new_activity.funding_organisation_reference = funding_organisation.iati_reference
    end

    accountable_org_element = legacy_activity.elements.detect { |element| element.name.eql?("participating-org") && element.attributes["role"].value.eql?("2") }
    if accountable_org_element
      accountable_org_reference = accountable_org_element.attributes["ref"].value
      accountable_organisation = Organisation.find_by(iati_reference: accountable_org_reference)
      new_activity.accountable_organisation_name = accountable_organisation.name
      new_activity.accountable_organisation_type = accountable_organisation.organisation_type
      new_activity.accountable_organisation_reference = accountable_organisation.iati_reference
    end

    # There is no DP reference in the extending element. We must ask the user for it.
    new_activity.extending_organisation = delivery_partner

    implementing_org_elements = legacy_activity.elements.select { |element| element.name.eql?("participating-org") && element.attributes["role"].value.eql?("4") }
    implementing_org_elements.each do |org_element|
      new_activity.implementing_organisations << ImplementingOrganisation.create!(
        name: org_element.children.detect { |child| child.name.eql?("narrative") }.text,
        organisation_type: org_element.attributes["type"].value,
        activity: new_activity
      )
    end
  end

  private def add_transactions(legacy_activity:, new_activity:)
    transaction_elements = legacy_activity.elements.select { |element| element.name.eql?("transaction") }
    transaction_elements.each do |transaction_element|
      currency = transaction_element.children.detect { |child| child.name.eql?("value") }.attributes["currency"].value
      date = transaction_element.children.detect { |child| child.name.eql?("value") }.attributes["value-date"].value
      value = transaction_element.children.detect { |child| child.name.eql?("value") }.children.text
      transaction_type = transaction_element.children.detect { |child| child.name.eql?("transaction-type") }.attributes["code"].value

      description = if transaction_element.children.detect { |child| child.name.eql?("description") }.present?
        transaction_element.children.detect { |child| child.name.eql?("description") }.children.detect { |child| child.name.eql?("narrative") }.text
      else
        "Unknown description"
      end

      providing_organisation_name = transaction_element.children.detect { |child| child.name.eql?("provider-org") }.children.detect { |child| child.name.eql?("narrative") }.text
      providing_organisation_reference = transaction_element.children.detect { |child| child.name.eql?("provider-org") }.attributes["ref"].value
      receiving_organisation_name = transaction_element.children.detect { |child| child.name.eql?("receiver-org") }.children.detect { |child| child.name.eql?("narrative") }.text
      receiving_organisation_reference = transaction_element.children.detect { |child| child.name.eql?("receiver-org") }.attributes["ref"].try(value, nil)

      transaction = Transaction.new(
        description: normalize_string(description),
        transaction_type: transaction_type,
        currency: currency,
        date: date,
        value: value,
        parent_activity: new_activity,
        disbursement_channel: "1", # guess as it's not returned,
        providing_organisation_name: providing_organisation_name,
        providing_organisation_type: "10",
        providing_organisation_reference: providing_organisation_reference,
        receiving_organisation_name: receiving_organisation_name,
        receiving_organisation_type: "0",
        receiving_organisation_reference: receiving_organisation_reference
      )

      transaction.save!
    end
  end

  private def add_budgets(legacy_activity:, new_activity:)
    budget_elements = legacy_activity.elements.select { |element| element.name.eql?("budget") }
    budget_elements.each do |budget_element|
      status = budget_element.attributes["status"].value
      budget_type = budget_element.attributes["type"].value
      period_start_date = budget_element.children.detect { |child| child.name.eql?("period-start") }.attributes["iso-date"].value
      period_end_date = budget_element.children.detect { |child| child.name.eql?("period-end") }.attributes["iso-date"].value
      value = budget_element.children.detect { |child| child.name.eql?("value") }.children.text
      currency = budget_element.children.detect { |child| child.name.eql?("value") }.attributes["currency"].value

      budget = Budget.new(
        status: status,
        budget_type: budget_type,
        period_start_date: period_start_date,
        period_end_date: period_end_date,
        value: value,
        currency: currency,
        parent_activity: new_activity,
        ingested: true
      )

      budget.save!
    end
  end

  private def sector_category_code(sector_code:)
    sectors = all_sectors
    sector = sectors.find { |s| s.code == sector_code }
    return if sector.nil?
    sector.category
  end

  private def add_geography(legacy_activity:, new_activity:)
    recipient_region_element = legacy_activity.elements.detect { |element| element.name.eql?("recipient-region") }
    if recipient_region_element
      new_activity.geography = :recipient_region
      new_activity.recipient_region = recipient_region_element.attributes["code"].value
    end

    recipient_country_element = legacy_activity.elements.detect { |element| element.name.eql?("recipient-country") }
    if recipient_country_element
      new_activity.geography = :recipient_country
      new_activity.recipient_country = recipient_country_element.attributes["code"].value
    end
  end

  private def add_dates(legacy_activity:, new_activity:)
    planned_start_date_element = legacy_activity.elements.detect { |element| element.name.eql?("activity-date") && element.attributes["type"].value.eql?("1") }
    new_activity.planned_start_date = planned_start_date_element.attributes["iso-date"].value || nil
    actual_start_date_element = legacy_activity.elements.detect { |element| element.name.eql?("activity-date") && element.attributes["type"].value.eql?("2") }
    new_activity.actual_start_date = actual_start_date_element.attributes["iso-date"].value || nil
    planned_end_date_element = legacy_activity.elements.detect { |element| element.name.eql?("activity-date") && element.attributes["type"].value.eql?("3") }
    new_activity.planned_end_date = planned_end_date_element.attributes["iso-date"].value || nil if planned_end_date_element
    actual_end_date_element = legacy_activity.elements.detect { |element| element.name.eql?("activity-date") && element.attributes["type"].value.eql?("4") }
    new_activity.actual_end_date = actual_end_date_element.attributes["iso-date"].value || nil if actual_end_date_element
  end

  private def add_identifiers(legacy_activity:, new_activity:)
    new_activity.identifier = SecureRandom.uuid
    new_activity.previous_identifier = legacy_activity.elements.detect { |element| element.name.eql?("iati-identifier") }.children.text
  end

  private def service_owner_organisation
    @service_owner_organisation ||= Organisation.find_by(service_owner: true)
  end

  private def normalize_string(string)
    CGI.unescape(string).strip
  end
end