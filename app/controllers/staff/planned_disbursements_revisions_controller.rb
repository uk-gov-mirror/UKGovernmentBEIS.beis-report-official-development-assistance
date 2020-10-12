# frozen_string_literal: true

class Staff::PlannedDisbursementsRevisionsController < Staff::BaseController
  before_action do
    @activity = Activity.find(params["activity_id"])
    authorize @activity

    @original_planned_disbursement = PlannedDisbursementPresenter.new(PlannedDisbursement.find(params["planned_disbursement_id"]))
    authorize @original_planned_disbursement
  end

  def new
    @revised_planned_disbursement = @original_planned_disbursement.dup
    authorize @revised_planned_disbursement
  end

  def create
    @revised_planned_disbursement = revise_planned_disbursement(@original_planned_disbursement)

    if @revised_planned_disbursement.valid?
      @revised_planned_disbursement.save
      flash[:notice] = t("action.planned_disbursement.revision.create.success")
      redirect_to organisation_activity_path(@activity.organisation, @activity)
    else
      render :new
    end
  end

  def revise_planned_disbursement(original_planned_disbursement)
    revised_planned_disbursement = original_planned_disbursement.dup

    revised_planned_disbursement.planned_disbursement_type = "2"
    revised_planned_disbursement.value = params["planned_disbursement"]["value"]
    revised_planned_disbursement.report = Report.editable_for_activity(@activity)
    revised_planned_disbursement
  end
end
