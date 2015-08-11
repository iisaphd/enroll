class ConsumerProfilesController < ApplicationController

  before_action :get_family, except: [:inbox, :check_qle_date]

  def home
    @family_members = @family.active_family_members if @family.present?
    @employee_roles = @person.employee_roles
    #FIXME should pick up  the active employee_role and dactive others
    @employer_profile = @employee_roles.last.employer_profile if @employee_roles.any?
    @current_plan_year = @employer_profile.latest_plan_year if @employer_profile.present?
    @benefit_groups = @current_plan_year.benefit_groups if @current_plan_year.present?
    @benefit_group = @current_plan_year.benefit_groups.first if @current_plan_year.present?
    @qualifying_life_events = QualifyingLifeEventKind.all
    @hbx_enrollments = @family.try(:latest_household).try(:hbx_enrollments).active || []

    @employee_role = @employee_roles.first

    respond_to do |format|
      format.html
      format.js
    end
  end

  def plans
    hbx_enrollments = @family.try(:latest_household).try(:hbx_enrollments).active || []
    @plan = hbx_enrollments.last.try(:plan)
    @qhp = Products::Qhp.find_by(standard_component_id: @plan.hios_id[0..13])
    @qhp_benefits = @qhp.qhp_benefits
    @benefit_group_assignment = hbx_enrollments.last.try(:benefit_group_assignment)
  end

  def personal
    @family_members = @family.active_family_members if @family.present?
    respond_to do |format|
      format.html
      format.js
    end
  end

  def family
    @family_members = @family.active_family_members if @family.present?
    @qualifying_life_events = QualifyingLifeEventKind.all
    @employee_role = @person.employee_roles.first

    respond_to do |format|
      format.html
      format.js
    end
  end

  def check_qle_date
    qle_date = Date.strptime(params[:date_val], "%m/%d/%Y")
    start_date = TimeKeeper.date_of_record - 30.days
    end_date = TimeKeeper.date_of_record + 30.days

    if ["I've had a baby", "Death"].include? params[:qle_type]
      end_date = TimeKeeper.date_of_record + 0.days
    end

    @qualified_date = (start_date <= qle_date && qle_date <= end_date) ? true : false
  end

  def inbox
    @folder = params[:folder] || 'Inbox'
    @sent_box = false
  end

  def purchase
    @enrollment = @family.try(:latest_household).try(:hbx_enrollments).active.last

    if @enrollment.present?
      plan = @enrollment.try(:plan)
      @benefit_group = @enrollment.benefit_group
      @reference_plan = @benefit_group.reference_plan
      @plan = PlanCostDecorator.new(plan, @enrollment, @benefit_group, @reference_plan)
      @enrollable = @family.is_eligible_to_enroll?

      @change_plan = params[:change_plan].present? ? params[:change_plan] : ''
      @terminate = params[:terminate].present? ? params[:terminate] : ''
    else
      redirect_to :back
    end
  end

  private
  def get_family
    set_current_person
    @family = @person.primary_family
  end
end
