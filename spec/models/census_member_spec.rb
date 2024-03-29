require 'rails_helper'

RSpec.describe CensusMember, :db_clean => :after_all do
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :dob }

  let(:census_employee) { FactoryGirl.create(:census_employee, employer_profile_id: "1111") }

  it "sets gender" do
    census_employee.gender = "MALE"
    expect(census_employee.gender).to eq "male"
  end

  it "sets date of birth" do
    census_employee.date_of_birth = "1980-12-12"
    expect(census_employee.dob).to eq "1980-12-12".to_date
  end

  context "dob" do
    before(:each) do
      census_employee.date_of_birth = "1980-12-01"
    end

    it "dob_string" do
      expect(census_employee.dob_string).to eq "19801201"
    end

    it "date_of_birth" do
      expect(census_employee.date_of_birth).to eq "12/01/1980"
    end
  end

  context "validate of date_of_birth_is_past" do
    it "should invalid" do
      dob = (Date.today + 10.days)
      census_employee.date_of_birth = dob.strftime("%Y-%m-%d")
      expect(census_employee.save).to be_falsey
      expect(census_employee.errors[:dob].any?).to be_truthy
      expect(census_employee.errors[:dob].to_s).to match /future date: #{dob.to_s} is invalid date of birth/
    end
  end

  context "without a gender" do
    it "should be invalid" do
      expect(census_employee.valid?).to eq true
      census_employee.gender = nil
      expect(census_employee.valid?).to eq false
      expect(census_employee).to have_errors_on(:gender)
    end
  end
end
