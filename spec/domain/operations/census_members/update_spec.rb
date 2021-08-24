# frozen_string_literal: true

require 'rails_helper'
require "#{BenefitSponsors::Engine.root}/spec/shared_contexts/benefit_market.rb"
require "#{BenefitSponsors::Engine.root}/spec/shared_contexts/benefit_application"

RSpec.describe Operations::CensusMembers::Update, :dbclean => :after_each do
  include_context "setup benefit market with market catalogs and product packages"
  include_context "setup renewal application"

  let(:family) { create(:family, :with_primary_family_member_and_dependent) }
  let(:person) { family.primary_person }
  let(:dependents) { family.family_members.where(is_primary_applicant: false) }
  let(:dependent) { dependents.first }
  let(:dependent_person) { dependent.person }
  let!(:census_dependent){ build(:census_dependent, first_name: dependent_person.first_name, last_name: dependent_person.last_name, dob: dependent_person.dob)}
  let!(:census_employee) do
    create(
      :benefit_sponsors_census_employee,
      :benefit_sponsorship => benefit_sponsorship,
      :employer_profile => abc_profile,
      :census_dependents => [census_dependent]
    )
  end
  let(:aasm_state) { 'coverage_enrolled' }

  let(:hbx_enrollment) do
    create(
      :hbx_enrollment,
      :with_enrollment_members,
      :with_product,
      household: family.active_household,
      aasm_state: aasm_state,
      effective_on: predecessor_application.start_on,
      rating_area_id: predecessor_application.recorded_rating_area_id,
      sponsored_benefit_id: predecessor_application.benefit_packages.first.health_sponsored_benefit.id,
      sponsored_benefit_package_id: predecessor_application.benefit_packages.first.id,
      benefit_sponsorship_id: predecessor_application.benefit_sponsorship.id,
      hbx_enrollment_members: [hbx_enrollment_member1, hbx_enrollment_member2],
      employee_role_id: employee_role.id
    )
  end

  let(:hbx_enrollment_member1) do
    build(
      :hbx_enrollment_member,
      applicant_id: family.find_family_member_by_person(person).id,
      is_subscriber: true,
      eligibility_date: Date.today
    )
  end

  let(:hbx_enrollment_member2) do
    build(
      :hbx_enrollment_member,
      applicant_id: dependent.id,
      is_subscriber: false,
      eligibility_date: Date.today
    )
  end

  let(:employee_role) { create(:benefit_sponsors_employee_role, person: person, census_employee_id: census_employee.id, benefit_sponsors_employer_profile_id: abc_profile.id)}

  describe "when updating person" do

    before do
      hbx_enrollment
      allow(person).to receive(:active_employee_roles).and_return([employee_role])
      person.assign_attributes(first_name: "Johnny", middle_name: 'S', last_name: 'Smith')
      Operations::CensusMembers::Update.new.call(person: person, action: 'update_census_employee')
      census_employee.reload
    end

    it 'should update census employee record' do
      expect(census_employee.first_name).to eq "Johnny"
      expect(census_employee.middle_name).to eq "S"
      expect(census_employee.last_name).to eq "Smith"
    end
  end

  describe "updating census dependent" do
    context "when enrolled" do
      before do
        hbx_enrollment
        dependent_person.assign_attributes(first_name: "Snow11", last_name: 'John11')
        Operations::CensusMembers::Update.new.call(person: dependent_person, family_member: dependent, action: 'update_census_dependent')
        census_employee.census_dependents.first.reload
      end

      it 'should update census dependent record' do
        expect(census_employee.census_dependents.first.first_name).to eq "Snow11"
        expect(census_employee.census_dependents.first.last_name).to eq "John11"
      end
    end

    context "when unenrolled" do
      before do
        allow(person).to receive(:active_employee_roles).and_return([employee_role])
        dependent_person.assign_attributes(first_name: "Test11", last_name: 'Snow11')
        Operations::CensusMembers::Update.new.call(person: dependent_person, family_member: dependent, action: 'update_census_dependent')
        census_employee.census_dependents.first.reload
      end

      it 'should not update existing census dependent record' do
        expect(census_employee.census_dependents.first.first_name).not_to eq "Test11"
        expect(census_employee.census_dependents.first.last_name).not_to eq "Snow11"
      end
    end

    context "when on expired/waived enrollment" do
      let(:aasm_state) { 'inactive' }

      before do
        hbx_enrollment
        dependent_person.assign_attributes(first_name: "Test11", last_name: 'Doe11')
        Operations::CensusMembers::Update.new.call(person: dependent_person, family_member: dependent, action: 'update_census_dependent')
      end

      it 'should not update census dependent record' do
        census_employee.census_dependents.first.reload
        expect(census_employee.census_dependents.first.first_name).not_to eq "Test11"
        expect(census_employee.census_dependents.first.last_name).not_to eq "Doe11"
      end
    end
  end

  describe 'updating census dependent relationship' do
    before do
      hbx_enrollment
      allow(person).to receive(:active_employee_roles).and_return([employee_role])
    end

    context "should update census dependent relationship if it is valid employee relationship kind" do
      it 'should update relationship' do
        expect(census_employee.census_dependents.first.employee_relationship).to eq 'spouse'
        dependent.update_relationship('domestic_partner') #calls operation
        expect(census_employee.census_dependents.first.reload.employee_relationship).to eq 'domestic_partner'
      end
    end

    context "should update census dependent relationship if it is invalid employee relationship kind" do
      let(:relationship) { 'sibling' }

      it 'should not update relationship' do
        expect(census_employee.census_dependents.first.employee_relationship).to eq 'spouse'
        dependent.update_relationship('sibling') #calls operation
        expect(census_employee.census_dependents.first.reload.employee_relationship).to eq 'spouse'
      end
    end
  end

  describe 'when employee roster updates feature is turned off' do
    before do
      EnrollRegistry[:employee_roster_updates].feature.stub(:is_enabled).and_return(false)
      allow(person).to receive(:active_employee_roles).and_return([employee_role])
      person.assign_attributes(first_name: "Johnny12", middle_name: 'S12', last_name: 'Smith12')
      Operations::CensusMembers::Update.new.call(person: person, action: 'update_census_employee')
      census_employee.reload
    end

    it 'should not update census employee record' do
      expect(census_employee.first_name).not_to eq "Johnny12"
      expect(census_employee.middle_name).not_to eq "S12"
      expect(census_employee.last_name).not_to eq "Smith12"
    end
  end
end