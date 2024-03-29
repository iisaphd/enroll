class Products::QhpController < ApplicationController
  before_action :set_kind_for_market_and_coverage, only: [:comparison, :summary]

  def comparison
    params.permit("standard_component_ids", :hbx_enrollment_id)
    found_params = params["standard_component_ids"].map { |str| str[0..13] }
    if @market_kind == 'employer_sponsored' and @coverage_kind == 'health'
      @benefit_group = @hbx_enrollment.benefit_group
      @reference_plan = @benefit_group.reference_plan
      @qhps = Products::Qhp.where(:standard_component_id.in => found_params).to_a.each do |qhp|
        qhp[:total_employee_cost] = PlanCostDecorator.new(qhp.plan, @hbx_enrollment, @benefit_group, @reference_plan).total_employee_cost
      end
    else
      @qhps = Products::Qhp.where(:standard_component_id.in => found_params).to_a.each do |qhp|
        qhp[:total_employee_cost] = UnassistedPlanCostDecorator.new(qhp.plan, @hbx_enrollment).total_employee_cost
      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def summary
    sc_id = @new_params[:standard_component_id][0..13]
    @qhp = Products::Qhp.where(standard_component_id: sc_id).to_a.first
    if @market_kind == 'employer_sponsored' and @coverage_kind == 'health'
      @benefit_group = @hbx_enrollment.benefit_group
      @reference_plan = @benefit_group.reference_plan
      @plan = PlanCostDecorator.new(@qhp.plan, @hbx_enrollment, @benefit_group, @reference_plan)
    else
      @plan = UnassistedPlanCostDecorator.new(@qhp.plan, @hbx_enrollment)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
  def set_kind_for_market_and_coverage
    @new_params = params.permit(:standard_component_id, :hbx_enrollment_id)
    hbx_enrollment_id = @new_params[:hbx_enrollment_id]
    @hbx_enrollment = HbxEnrollment.find(hbx_enrollment_id)
    params[:market_kind] ||= @hbx_enrollment.kind
    @market_kind = params[:market_kind].present? ? params[:market_kind] : 'employer_sponsored'
    @coverage_kind = params[:coverage_kind].present? ? params[:coverage_kind] : 'health'
  end
end
