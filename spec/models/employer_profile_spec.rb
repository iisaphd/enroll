require 'rails_helper'

describe EmployerProfile, dbclean: :after_each do

  let(:entity_kind)     { "partnership" }
  let(:bad_entity_kind) { "fraternity" }
  let(:entity_kind_error_message) { "#{bad_entity_kind} is not a valid business entity kind" }

  let(:address)  { Address.new(kind: "work", address_1: "609 H St", city: "Washington", state: "DC", zip: "20002") }
  let(:phone  )  { Phone.new(kind: "main", area_code: "202", number: "555-9999") }
  let(:email  )  { Email.new(kind: "work", address: "info@sailaway.org") }

  let(:office_location) { OfficeLocation.new(
        is_primary: true,
        address: address,
        phone: phone
      )
    }

  let(:organization) { Organization.create(
      legal_name: "Sail Adventures, Inc",
      dba: "Sail Away",
      fein: "001223333",
      office_locations: [office_location]
      )
    }

  let(:valid_params) do
    {
      organization: organization,
      entity_kind: entity_kind
    }
  end

  after do
    TimeKeeper.set_date_of_record(TimeKeeper.date_of_record)
  end

  it { should validate_presence_of :entity_kind }

  context ".new" do
    context "with no arguments" do
      let(:params)  { {} }
      let(:employer_profile) {EmployerProfile.new(**params)}

      it "should initialize nested models" do
        expect(employer_profile.inbox).not_to be_nil
      end

      it "should not save" do
        expect(employer_profile.save).to be_falsey
      end
    end

    context "with no entity_kind" do
      def params; valid_params.except(:entity_kind); end

      it "should fail validation " do
        expect(EmployerProfile.create(**params).errors[:entity_kind].any?).to be_truthy
      end
    end

    context "with improper entity_kind" do
      def params; valid_params.deep_merge({entity_kind: bad_entity_kind}); end
      it "should fail validation with improper entity_kind" do
        expect(EmployerProfile.create(**params).errors[:entity_kind].any?).to be_truthy
        expect(EmployerProfile.create(**params).errors[:entity_kind]).to eq [entity_kind_error_message]
      end
    end

    context "with more than one owner" do
      def params; valid_params; end
      let(:employer_profile) {EmployerProfile.new(**params)}

      it "should have errors on owner" do
        allow(employer_profile).to receive(:owner).and_return(["owner1","owner2"])
        employer_profile.valid?
        expect(employer_profile).to have_errors_on(:owner)
      end
    end

    context "with all valid arguments" do
      def params; valid_params; end
      def employer_profile; EmployerProfile.new(**params); end

      it "should initialize employer profile workflow state to applicant" do
        expect(employer_profile.applicant?).to be_truthy
      end

      it "should save" do
        expect(employer_profile.save).to be_truthy
      end

      context "and it is saved" do
        let!(:saved_employer_profile) do
          er = employer_profile
          er.save
          er
        end

        it "should save all nested models" do
          expect(saved_employer_profile.inbox?).to be_truthy
        end

        it "and should be findable" do
          expect(EmployerProfile.find(saved_employer_profile.id).id.to_s).to eq saved_employer_profile.id.to_s
        end
      end
    end
  end

  context "has registered and enters initial application process" do
    let(:benefit_group)     { FactoryGirl.build(:benefit_group)}
    let(:plan_year)         { FactoryGirl.build(:plan_year, benefit_groups: [benefit_group]) }
    let!(:employer_profile)  { EmployerProfile.new(**valid_params, plan_years: [plan_year]) }
    let(:min_non_owner_count )  { HbxProfile::ShopEnrollmentNonOwnerParticipationMinimum }

    it "should initialize in applicant status" do
      expect(employer_profile.applicant?).to be_truthy
    end

    context "and employer submits a valid plan year application with tomorrow as start open enrollment" do
      before do
        TimeKeeper.set_date_of_record(TimeKeeper.date_of_record.beginning_of_month.next_month + 8.days)
        plan_year.open_enrollment_start_on = TimeKeeper.date_of_record + 1.day
        plan_year.open_enrollment_end_on = TimeKeeper.date_of_record + 5.days
        plan_year.start_on = TimeKeeper.date_of_record.beginning_of_month.next_month
        plan_year.end_on = plan_year.start_on + 1.year - 1.day
        plan_year.publish!
      end

      it "should transition to registered state" do
        expect(employer_profile.registered?).to be_truthy
      end
    end

    context "and today is the day following this month's deadline for start of open enrollment" do
      before do
        # employer_profile.advance_enrollment_period
      end

      context "and employer profile is in applicant state" do
        context "and effective date is next month" do
          it "should change status to canceled"
        end

        context "and effective date is later than next month" do
          it "should not change state"
        end
      end

      context "and employer is in ineligible or ineligible_appealing state" do
        it "what should be done?"
      end
    end
  end

  context "has hired a broker" do
  end

  context "has employees that have enrolled in coverage" do
    let(:benefit_group)       { FactoryGirl.build(:benefit_group)}
    let(:plan_year)           { FactoryGirl.build(:plan_year, benefit_groups: [benefit_group]) }
    let!(:employer_profile)   { EmployerProfile.new(**valid_params, plan_years: [plan_year]) }
    let(:census_employees)    { FactoryGirl.create_list(:census_employee, 7,
                                  employer_profile: employer_profile,
                                  benefit_group_assignments: [benefit_group]
                                )
                              }
    let(:person0)  { FactoryGirl.create(:person, ssn: census_employees[0].ssn, last_name: census_employees[0].last_name) }
    let(:person0)  { FactoryGirl.create(:person, ssn: census_employees[1].ssn, last_name: census_employees[1].last_name) }
    let!(:ee0)    { FactoryGirl.create(:employee_role, person: people[0], employer_profile: employer_profile) }
    let!(:ee1)    { FactoryGirl.create(:employee_role, person: people[1], employer_profile: employer_profile) }
    # let(:employees)         { FactoryGirl.create_list(:employee_role, employee_count, employer_profile: employer_profile) }
    let!(:ee_roles)          { employer_profile.employee_roles }


    before do
      census_employees.each
    end

  end
end

describe EmployerProfile, "given multiple existing employer profiles", :dbclean => :after_all do
  before(:all) do
    home_office = FactoryGirl.build(:office_location)
    @er0 = EmployerProfile.new(entity_kind: "partnership")
    @er1 =  EmployerProfile.new(entity_kind: "partnership")
    @er2 = EmployerProfile.new(entity_kind: "partnership")
    @er0.create_organization(legal_name: "huey",  fein: "687654321", office_locations: [home_office])
    @er1.create_organization(legal_name: "dewey", fein: "587654321", office_locations: [home_office])
    @er2.create_organization(legal_name: "louie", fein: "487654321", office_locations: [home_office])
    @no_employer_org = Organization.create!(fein: "123456789", office_locations: [home_office], legal_name: "I AM NOT AN EMPLOYER")
  end


  it "should be able to find those profiles with the .all class method" do
    expect(EmployerProfile.all).to include(@er0)
    expect(EmployerProfile.all).to include(@er1)
    expect(EmployerProfile.all).to include(@er2)
  end

  it "should not return any organizations which do not have employers" do
    expect(EmployerProfile.all).not_to include(@no_employer_org)
  end
end

describe EmployerProfile, "given an unlinked, linkable census employee with a family" do
  let(:census_dob) { Date.new(1983,2,15) }
  let(:census_ssn) { "123456789" }

  let(:benefit_group) { FactoryGirl.create(:benefit_group) }
  let(:plan_year) { benefit_group.plan_year }
  let(:employer_profile) { plan_year.employer_profile }
  let(:benefit_group_assignment) { FactoryGirl.build(:benefit_group_assignment, benefit_group: benefit_group)}
  let(:census_employee) { CensusEmployee.new(
    :ssn => census_ssn,
    :dob => census_dob,
    :employer_profile_id => "1111",
    :first_name => "Roger",
    :last_name => "Martin",
    :hired_on => 20.days.ago,
    :is_business_owner => false,
    :benefit_group_assignments => [benefit_group_assignment]
  ) }

  before do
    plan_year.publish!
  end

  it "should not find the linkable family when given a different ssn" do
    person = OpenStruct.new({
      :dob => census_dob,
      :ssn => "987654321"
    })
    expect(EmployerProfile.find_census_employee_by_person(person)).to eq []
  end

  it "should not find the linkable family when given a different dob" do
    person = OpenStruct.new({
      :dob => Date.new(2012,1,1),
      :ssn => census_ssn
    })
    expect(EmployerProfile.find_census_employee_by_person(person)).to eq []
  end

  it "should return the linkable employee when given the same dob and ssn" do
    person = OpenStruct.new({
      :dob => census_dob,
      :ssn => census_ssn
    })
    census_employee.save
    expect(EmployerProfile.find_census_employee_by_person(person)).to eq [census_employee]
  end
end

describe EmployerProfile, "Class methods", dbclean: :after_each do
  def er0; EmployerProfile.new(entity_kind: "partnership"); end
  def er1; EmployerProfile.new(entity_kind: "partnership"); end
  def er2; EmployerProfile.new(entity_kind: "partnership"); end

  def ee0; FactoryGirl.build(:census_employee, ssn: "369851245", dob: 32.years.ago.to_date, employer_profile_id: er0.id); end
  def ee1; FactoryGirl.build(:census_employee, ssn: "258741239", dob: 42.years.ago.to_date, employer_profile_id: er1.id); end


  def home_office; FactoryGirl.build(:office_location); end

  def organization0; er0.create_organization(legal_name: "huey",  fein: "687654321", office_locations: [home_office]); end
  def organization1; er1.create_organization(legal_name: "dewey", fein: "587654321", office_locations: [home_office]); end
  def organization2; er2.create_organization(legal_name: "louie", fein: "487654321", office_locations: [home_office]); end
  before { organization0; organization1; organization2 }

  describe '.find_by_broker_agency_profile' do
    let(:organization6)  {FactoryGirl.create(:organization, fein: "024897585")}
    let(:broker_agency_profile)  {organization6.create_broker_agency_profile(market_kind: "both", primary_broker_role_id: "8754985")}

    let(:organization3)  {FactoryGirl.create(:organization, fein: "034267123")}
    let(:organization4)  {FactoryGirl.create(:organization, fein: "027636010")}
    let(:organization5)  {FactoryGirl.create(:organization, fein: "076747654")}

    def er3; organization3.create_employer_profile(entity_kind: "partnership", broker_agency_profile: broker_agency_profile); end
    def er4; organization4.create_employer_profile(entity_kind: "partnership", broker_agency_profile: broker_agency_profile); end
    def er5; organization5.create_employer_profile(entity_kind: "partnership"); end
    before { broker_agency_profile; er3; er4; er5 }

    it 'returns employers represented by the specified broker agency' do
      expect(er3.broker_agency_profile.id).to eq broker_agency_profile.id
      expect(er4.broker_agency_profile.id).to eq broker_agency_profile.id
      expect(er5.broker_agency_profile).to be_nil

      employers_with_broker = EmployerProfile.find_by_broker_agency_profile(broker_agency_profile)
      expect(employers_with_broker.first).to be_a EmployerProfile
      expect(employers_with_broker.size).to eq 2
    end
  end

  describe ".find_by_fein" do
    let(:employer_profile) { FactoryGirl.build(:employer_profile) }
    it "should return record for matching fein" do
      employer_profile.save
      expect(EmployerProfile.find_by_fein(employer_profile.organization.fein)).to be_an_instance_of EmployerProfile
    end
  end

  describe ".staff_roles" do
    let(:employer_profile) { FactoryGirl.build(:employer_profile) }

    context "has no staff" do
      it "should return any staff" do
        expect(employer_profile.staff_roles).to eq []
      end
    end

    context "has staff" do
      let(:owner_person) { instance_double("Person")}

      it "should return an array of persons" do
        allow(Person).to receive(:find_all_staff_roles_by_employer_profile).with(employer_profile).and_return([owner_person])
        expect(employer_profile.staff_roles).to include(owner_person)
      end
    end
  end

  describe ".find_census_employee_by_person" do
    context "with person not matching ssn" do
      let(:params) do
        {  ssn:        "019283746",
           first_name: ee0.first_name,
           last_name:  ee0.last_name,
           dob:        ee0.dob
        }
      end
      def p0; Person.new(**params); end

      it "should return an empty array" do
        expect(EmployerProfile.find_census_employee_by_person(p0)).to eq []
      end
    end

    context "with person not matching dob" do
      let(:params) do
        {  ssn:        ee0.ssn,
           first_name: ee0.first_name,
           last_name:  ee0.last_name,
           dob:        (ee0.dob - 1.year).to_date
        }
      end
      def p0; Person.new(**params); end

      it "should return an empty array" do
        expect(EmployerProfile.find_census_employee_by_person(p0)).to eq []
      end
    end

    context "with person matching ssn and dob" do
      let(:benefit_group) { FactoryGirl.create(:benefit_group) }
      let(:plan_year) { benefit_group.plan_year }
      let(:benefit_group_assignment) { FactoryGirl.build(:benefit_group_assignment, benefit_group: benefit_group) }
      let(:census_employee) { FactoryGirl.create(:census_employee, ssn: ee0.ssn, dob: ee0.dob, employer_profile_id: "11112", benefit_group_assignments: [benefit_group_assignment]) }
      let(:params) do
        {  ssn:        ee0.ssn,
           first_name: ee0.first_name,
           last_name:  ee0.last_name,
           dob:        ee0.dob
        }
      end
      def p0; Person.new(**params); end
      before do
        plan_year.publish!
      end

      it "should return an instance of CensusEmployee" do
        # expect(organization0.save).errors.messages).to eq ""
        census_employee.valid?
        expect(EmployerProfile.find_census_employee_by_person(p0).first).to be_a CensusEmployee
      end

      it "should return employee_families where employee matches person" do
        census_employee.valid?
        expect(EmployerProfile.find_census_employee_by_person(p0).size).to eq 1
      end

      it "returns employee_families where employee matches person" do
        census_employee.valid?
        expect(EmployerProfile.find_census_employee_by_person(p0).first.dob).to eq census_employee.dob
      end
    end
  end

  describe ".find_all_by_person" do
    let(:black_and_decker) do
      org = FactoryGirl.create(:organization, legal_name: "Black and Decker, Inc.", dba: "Black Decker")
      er = org.create_employer_profile(entity_kind: "c_corporation")
    end
    let(:atari) do
      org = FactoryGirl.create(:organization, legal_name: "Atari Corporation", dba: "Atari Games")
      er = org.create_employer_profile(entity_kind: "s_corporation")
    end
    let(:google) do
      org = FactoryGirl.create(:organization, legal_name: "Google Inc.", dba: "Google")
      er = org.create_employer_profile(entity_kind: "partnership")
    end
    def bob_params; {first_name: "Uncle", last_name: "Bob", ssn: "999441111", dob: 35.years.ago.to_date}; end
    let!(:black_and_decker_bob) do
      ee = FactoryGirl.create(:census_employee, employer_profile_id: black_and_decker.id,  **bob_params)
    end
    let!(:atari_bob) do
      ee = FactoryGirl.create(:census_employee, employer_profile_id: atari.id, **bob_params)
    end
    let!(:google_bob) do
      # different dob
      ee = FactoryGirl.create(:census_employee, employer_profile_id: google.id, **bob_params.merge(dob: 40.years.ago.to_date))
    end

    def valid_ssn; ee0.ssn; end
    def invalid_ssn; "000000000"; end
    let(:params) do
      {
        first_name: ee0.first_name,
        last_name:  ee0.last_name,
        dob:        ee0.dob
      }
    end

    before do
      [black_and_decker, atari, google].each() do |employer_profile|
        plan_year = FactoryGirl.build(:plan_year, employer_profile: employer_profile)
        benefit_group = FactoryGirl.build(:benefit_group, plan_year: plan_year)
        plan_year.save
        benefit_group.save

        employer_profile.census_employees.each() do |census_employee|
          benefit_group_assignment = FactoryGirl.build(:benefit_group_assignment, benefit_group: benefit_group)
          census_employee.benefit_group_assignments = [benefit_group_assignment]
          census_employee.save
        end
        plan_year.publish!
      end
    end

    context "finds an EmployerProfile employee" do
      def valid_person; FactoryGirl.build(:person, **bob_params); end

      it "should find the active employee in multiple employer_profiles" do
        # it shouldn't find google bob because dob are different
        expect(EmployerProfile.find_census_employee_by_person(valid_person).size).to eq 2
      end

      it "should return EmployerProfile" do
        expect(EmployerProfile.find_census_employee_by_person(valid_person).first.employer_profile).to be_a EmployerProfile
      end

      it "should include the matching employee" do
        found = EmployerProfile.find_census_employee_by_person(valid_person).last
        [:first_name, :last_name, :ssn, :dob].each do |attr|
          expect(found.send(attr)).to eq valid_person.send(attr)
        end
      end
    end

    context "fails to match an employee" do
      def invalid_person; Person.new(**params.merge(ssn: invalid_ssn)); end

      it "should not return any matches" do
        # expect(invalid_person.ssn).to eq invalid_ssn
        expect(EmployerProfile.find_census_employee_by_person(invalid_person).size).to eq 0
      end
    end
  end
end

describe EmployerProfile, "instance methods" do
  let(:employer_profile)  { FactoryGirl.create(:employer_profile) }
  let(:census_employee)  { FactoryGirl.build(:census_employee, ssn: "069851240", dob: 34.years.ago.to_date, employer_profile_id: employer_profile.id)}
  let(:person)           { Person.new(first_name: census_employee.first_name, last_name: census_employee.last_name, ssn: census_employee.ssn, dob: 34.years.ago.to_date)}

  describe "#employee_roles" do
    let(:people)  { FactoryGirl.create_list(:person, 2) }
    let!(:ee0)  { FactoryGirl.create(:employee_role, person: people[0], employer_profile: employer_profile) }
    let!(:ee1)  { FactoryGirl.create(:employee_role, person: people[1], employer_profile: employer_profile) }
    # let(:employees)         { FactoryGirl.create_list(:employee_role, employee_count, employer_profile: employer_profile) }
    let!(:ee_roles)          { employer_profile.employee_roles }

    context "an employer profile with multiple associated employee roles" do
      it "should find all employees" do
        expect(ee_roles.size).to eq 2
      end

      it "should return array of employee_role instances" do
        expect(ee_roles.first).to be_a EmployeeRole
      end

      it "should be associated with correct employer profile" do
        expect(ee_roles.first.employer_profile).to eq employer_profile
      end
    end
  end
end

describe EmployerProfile, "roster size" do
  let(:employer_profile) {FactoryGirl.create(:employer_profile)}
  let(:census_employee1) {FactoryGirl.create(:census_employee, employer_profile_id: employer_profile.id, aasm_state: 'eligible')}
  let(:census_employee2) {FactoryGirl.create(:census_employee, employer_profile_id: employer_profile.id).update(aasm_state: 'employee_role_linked')}
  let(:census_employee3) {FactoryGirl.create(:census_employee, employer_profile_id: employer_profile.id).update(aasm_state: 'employment_terminated')}
  let(:census_employee4) {FactoryGirl.create(:census_employee, employer_profile_id: employer_profile.id).update(aasm_state: 'rehired')}

  it "should got 2" do
    census_employee1
    census_employee2
    census_employee3
    census_employee4
    expect(employer_profile.roster_size).to eq 2
  end
end

# describe "#advance_day" do
#   let(:start_on) { (TimeKeeper.date_of_record + 60).beginning_of_month }
#   let(:end_on) {start_on + 1.year - 1 }
#   let(:open_enrollment_start_on) { (start_on - 32).beginning_of_month }
#   let(:open_enrollment_end_on) { open_enrollment_start_on + 2.weeks }
#   let(:plan_year) { FactoryGirl.create(:plan_year, start_on: start_on, end_on: end_on, open_enrollment_start_on: open_enrollment_start_on, open_enrollment_end_on: open_enrollment_end_on) }
#   let(:employer_profile) { plan_year.employer_profile }
#   let(:organization) { employer_profile.organization }
#   let(:benefit_group) { FactoryGirl.create(:benefit_group, plan_year: plan_year) }

#   context "without any published plan years" do
#     it "should stay in the applicant state" do
#       EmployerProfile.advance_day(start_on - 100)
#       expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("applicant")
#     end
#   end

#   context "with a single successfully published a plan year" do
#     before do
#       plan_year.benefit_groups << benefit_group
#       plan_year.publish!
#       expect(plan_year.aasm_state).to eq("published")
#     end

#     it "should be in a registered state" do
#       expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("registered")
#     end

#     it "should be in an enrolling state if day is on or greater than open enrollment start" do
#       EmployerProfile.advance_day(open_enrollment_start_on)
#       expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("enrolling")
#     end

#     context "with an in in valid plan year" do
#       it "should be in an ineligible state" do
#         allow(plan_year).to receive(:is_application_valid?).and_return(false)
#         EmployerProfile.advance_day(open_enrollment_start_on)
#         expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("enrolling")
#       end
#     end
#   end

#   context "with a three plan years that one of which successfully published" do
#     let(:plan_year1) { FactoryGirl.create(:plan_year, start_on: start_on, end_on: end_on, open_enrollment_start_on: open_enrollment_start_on, open_enrollment_end_on: open_enrollment_end_on) }
#     let(:benefit_group2) { FactoryGirl.create(:benefit_group, plan_year: plan_year2) }
#     let(:plan_year2) { FactoryGirl.create(:plan_year, employer_profile: plan_year1.employer_profile, start_on: start_on, end_on: end_on, open_enrollment_start_on: open_enrollment_start_on, open_enrollment_end_on: open_enrollment_end_on) }
#     let(:benefit_group3) { FactoryGirl.create(:benefit_group, plan_year: plan_year3) }
#     let(:plan_year3) { FactoryGirl.create(:plan_year, employer_profile: plan_year1.employer_profile, start_on: start_on, end_on: end_on, open_enrollment_start_on: open_enrollment_start_on, open_enrollment_end_on: open_enrollment_end_on) }
#     let(:employer_profile) { plan_year1.employer_profile }

#     before do
#       plan_year1.benefit_groups << benefit_group
#       plan_year2.benefit_groups << benefit_group2
#       plan_year3.benefit_groups << benefit_group3
#       plan_year2.publish!
#       expect(plan_year2.aasm_state).to eq("published")
#     end

#     it "should be in a registered state" do
#       expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("registered")
#     end

#     it "should be in an enrolling state if day is on or greater than open enrollment start" do
#       EmployerProfile.advance_day(open_enrollment_start_on)
#       expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("enrolling")
#     end

#     context "with an in in valid plan year" do
#       it "should be in an ineligible state" do
#         allow(plan_year).to receive(:is_application_valid?).and_return(false)
#         EmployerProfile.advance_day(open_enrollment_start_on)
#         expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq("enrolling")
#       end
#     end
#   end
# end
