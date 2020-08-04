class ActivityPolicy < ApplicationPolicy
  def show?
    if record.level.blank?
      return record.organisation == user.organisation
    end

    record.fund? && beis_user? ||
      record.programme? ||
      record.project? ||
      record.third_party_project?
  end

  def add_transaction?
    record.organisation == user.organisation && record.programme_status == "01"
  end

  def add_planned_disbursement?
    record.organisation == user.organisation && record.programme_status != "01"
  end

  def add_budget?
    record.organisation == user.organisation && record.programme_status != "01"
  end

  def create?
    record.organisation == user.organisation
  end

  def update?
    record.organisation == user.organisation
  end

  def redact_from_iati?
    beis_user? && record.project? || record.third_party_project?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
