FactoryGirl.define do
  factory :hbx_enrollment_member do
    is_subscriber true
    premium_amount 20.0
    coverage_start_on (Date.today - 30.days)
  end
end