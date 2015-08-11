class Consumer::EmployeeDependentsController < ApplicationController
  before_action :set_current_person, :set_family
  def index
    emp_role_id = params.require(:employee_role_id)
    @employee_role = @person.employee_roles.detect { |emp_role| emp_role.id.to_s == emp_role_id.to_s }

    @change_plan = params[:change_plan].present? ? params[:change_plan] : ''
    @change_plan_date = params[:qle_date].present? ? params[:qle_date] : ''

    if @change_plan.present? and @change_plan_date.present?
      qle_on = Date.strptime(@change_plan_date, '%m/%d/%Y')
      qualifying_life_event_kind = QualifyingLifeEventKind.where(title: @change_plan.gsub('"', "")).last
      if @family.special_enrollment_periods.where(qle_on: qle_on, qualifying_life_event_kind_id: qualifying_life_event_kind.id).blank?
        sep = @family.special_enrollment_periods.build
        sep.qle_on = qle_on
        sep.qualifying_life_event_kind = qualifying_life_event_kind
        sep.save
      end
    end
  end

  def new
    @dependent = Forms::EmployeeDependent.new(:family_id => params.require(:family_id))
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @dependent = Forms::EmployeeDependent.new(params.require(:dependent))

    if @dependent.save
      @created = true
      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'show' }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.js { render 'new' }
      end
    end
  end

  def destroy
    @dependent = Forms::EmployeeDependent.find(params.require(:id))
    @dependent.destroy!

    respond_to do |format|
      format.html { render 'index' }
      format.js { render 'destroyed' }
    end
  end

  def show
    @dependent = Forms::EmployeeDependent.find(params.require(:id))

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @dependent = Forms::EmployeeDependent.find(params.require(:id))

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @family = @person.primary_family
    @dependent = Forms::EmployeeDependent.find(params.require(:id))

    if @dependent.update_attributes(params.require(:dependent))
      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'show' }
      end
    else
      respond_to do |format|
        format.html { render 'edit' }
        format.js { render 'edit' }
      end
    end
  end
private
  def set_family
    @family = @person.try(:primary_family)
  end
end
