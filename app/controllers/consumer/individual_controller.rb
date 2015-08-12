class Consumer::IndividualController < ApplicationController
  before_action :set_current_person

  def welcome
    @person = Forms::EmployeeRole.new(@person)
  end

  def update
    save_and_exit = params['exit_after_method'] == 'true'
    object_params = params.require(:person).permit(*person_parameters_list)
    @person = Forms::EmployeeRole.new(@person)

    if @person.update_attributes(object_params)
      if save_and_exit
        redirect_to destroy_user_session_path
      else
        redirect_to household_consumer_individual_index_path
      end
    else
      if save_and_exit
        redirect_to destroy_user_session_path
      else
        respond_to do |format|
          format.html { render "welcome" }
        end
      end
    end
  end

  def household
    @family = @person.try(:primary_family)
  end

  def group_selection
    # for individual
    @employer_profile = Organization.where(legal_name: "Global Systems For Individual").last.employer_profile

    if @person.employee_roles.where(employer_profile_id: @employer_profile.id).blank?
      @employee_role = @person.employee_roles.create(
        employer_profile_id: @employer_profile.id,
        benefit_group_id: @employer_profile.plan_years.last.benefit_groups.last.id,
        hired_on: Date.today.at_beginning_of_month
      )
    else
      @employee_role = @person.employee_roles.where(employer_profile_id: @employer_profile.id).last
    end
    family = @person.primary_family
    coverage_household = family.active_household.immediate_family_coverage_household
    benefit_group = BenefitGroup.find(@employee_role.benefit_group_id)
    hbx_enrollment = HbxEnrollment.new_from(
      employee_role: @employee_role,
      coverage_household: coverage_household,
      benefit_group: benefit_group)

    if hbx_enrollment.save
      redirect_to individual_show_insured_plan_shopping_path(:id => hbx_enrollment.id)
    else
      redirect_to household_consumer_individual_index_path, error: "Something wrong."
    end
  end

  private
  def person_parameters_list
    [
      { :addresses_attributes => [:kind, :address_1, :address_2, :city, :state, :zip] },
      { :phones_attributes => [:kind, :full_phone_number, :id] },
      { :email_attributes => [:kind, :address, :id] },
      :first_name,
      :last_name,
      :middle_name,
      :name_pfx,
      :name_sfx,
      :date_of_birth,
      :ssn,
      :gender
    ]
  end
end
