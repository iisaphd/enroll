require "rails_helper"
require File.join(Rails.root, "app", "data_migrations", "make_benefit_group_assignment_active")

describe MakeBenefitGroupAssignmentActive, dbclean: :after_each do

  let(:given_task_name) { "make_benefit_group_assignment_active" }
  subject { MakeBenefitGroupAssignmentActive.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do
    it "has the given task name" do
      expect(subject.name).to eql given_task_name
    end
  end

  describe 'creates an inactive benefit group assignment' do
    let(:site_key)                  { Settings.site.key.to_sym }
    let(:site)                      { build(:benefit_sponsors_site, :with_benefit_market, :as_hbx_profile, site_key) }
    let(:benefit_sponsor)           { create(:benefit_sponsors_organizations_general_organization, "with_aca_shop_#{site_key}_employer_profile_initial_application".to_sym, site: site) }
    let(:benefit_sponsorship)       { benefit_sponsor.active_benefit_sponsorship }
    let(:employer_profile)          { benefit_sponsorship.profile }
    let!(:benefit_package)          { benefit_sponsorship.benefit_applications.first.benefit_packages.first}
    let(:benefit_group_assignment)  { build(:benefit_group_assignment, benefit_package: benefit_package, start_on: benefit_package.start_on) }
    let!(:census_employee)          { create(:census_employee, :with_active_assignment, benefit_sponsorship: benefit_sponsorship, employer_profile: employer_profile, benefit_group: benefit_package, benefit_group_assignments: [benefit_group_assignment] ) }

    before(:each) do
      census_employee.benefit_group_assignments.last.update(is_active:false)
    end

    context "updating benefit group assignment to active", dbclean: :after_each do

      it "should make the benefit group assignment active" do
        expect(census_employee.benefit_group_assignments.last.is_active).to eq(false)
        subject.migrate
        census_employee.reload
        expect(CensusEmployee.find(census_employee.id).benefit_group_assignments.last.is_active).to eq(true)
      end

    end
  end
end
