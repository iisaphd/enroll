require 'rails_helper'

describe Serializers::HbxEnrollmentSerializer do

  let(:carrier_profile) {FactoryGirl.build(:carrier_profile)}
  let(:broker_agency_profile){FactoryGirl.build(:broker_agency_profile)}
  let(:hbx_enrollment_member){FactoryGirl.build(:hbx_enrollment_member)}
  let(:plan){FactoryGirl.build(:plan, carrier_profile:carrier_profile)}
  let(:employee_role){ FactoryGirl.build(:employee_role, employer_profile:FactoryGirl.build(:employer_profile))}
  let(:hbx_enrollment) { FactoryGirl.build(:hbx_enrollment, household:nil, employee_role:employee_role, plan: plan,
                                           broker_agency_profile:broker_agency_profile, hbx_enrollment_members:[hbx_enrollment_member]) }

  subject { Serializers::HbxEnrollmentSerializer.new(hbx_enrollment) }

  it 'after initialization has a hbx_enrollment' do
    expect(subject.hbx_enrollment.present?).to be_truthy
  end

  it "returns a xml" do
    expect(subject.to_xml).to include("<?xml version=")
    puts subject.to_xml
  end
end