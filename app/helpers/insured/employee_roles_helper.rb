module Insured::EmployeeRolesHelper
  def employee_role_submission_options_for(model)
    if model.persisted?
      { :url => insured_employee_path(model), :method => :put }
    else
      { :url => insured_employee_index_path, :method => :post }
    end
  end

  def coverage_relationship_check(offered_relationship_benefits=[], family_member, new_effective_on )
    relationship = PlanCostDecorator.benefit_relationship(family_member.primary_relationship)
    if relationship == "child_under_26" && (calculate_age_by_dob(family_member.dob) > 26 || (new_effective_on.kind_of?(Date) && new_effective_on >= family_member.dob+26.years))
      relationship = "child_over_26"
    end

    offered_relationship_benefits.include? relationship
  end

end
