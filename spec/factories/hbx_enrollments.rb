FactoryGirl.define do
  factory :hbx_enrollment do
    household
    kind "employer_sponsored"
    elected_premium_credit 0
    applied_premium_credit 0
    plan
    effective_on {1.month.ago.to_date}
    terminated_on nil
    #broker_agency_id nil
    # writing_agent_id nil
    submitted_at {2.months.ago}
    aasm_state :plan_effectuated
    aasm_state_date {effective_on}
    updated_by "factory"
    is_active true
    broker_agency_profile_id 1
    hbx_enrollment_members []
    employee_role
    # comments
  end
end
