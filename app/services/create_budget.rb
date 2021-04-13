class CreateBudget
  attr_accessor :activity

  def initialize(activity:)
    self.activity = activity
  end

  def call(attributes: {})
    budget = Budget.new
    budget.parent_activity = activity
    budget.assign_attributes(attributes)

    budget.currency = activity.organisation.default_currency

    convert_and_assign_value(budget, attributes[:value])

    unless activity.organisation.service_owner?
      budget.report = editable_report_for_activity(activity: activity)
    end

    infer_and_assign_providing_org_attrs(budget)

    result = if budget.valid?
      Result.new(budget.save, budget)
    else
      Result.new(false, budget)
    end

    result
  end

  private

  def editable_report_for_activity(activity:)
    Report.editable_for_activity(activity)
  end

  def convert_and_assign_value(budget, value)
    budget.value = ConvertFinancialValue.new.convert(value.to_s)
  rescue ConvertFinancialValue::Error
    budget.errors.add(:value, I18n.t("activerecord.errors.models.budget.attributes.value.not_a_number"))
  end

  def infer_and_assign_providing_org_attrs(budget)
    if Budget::DIRECT_BUDGET_TYPES.include?(budget.budget_type)
      budget.providing_organisation_id = Organisation.find_by(service_owner: true).id
      budget.providing_organisation_name = nil
      budget.providing_organisation_type = nil
      budget.providing_organisation_reference = nil
    elsif Budget::TRANSFERRED_BUDGET_TYPES.include?(budget.budget_type)
      budget.providing_organisation_name = nil
      budget.providing_organisation_type = nil
      budget.providing_organisation_reference = nil
    else
      budget.providing_organisation_id = nil
    end
  end
end
