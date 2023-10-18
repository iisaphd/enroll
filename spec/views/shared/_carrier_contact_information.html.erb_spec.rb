require 'rails_helper'

describe "shared/_#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information.html.erb", dbclean: :after_each do
  let(:plan) {
    double('Product',
      id: "122455",
      issuer_profile: issuer_profile
      )
  }

  let(:issuer_profile){
    double("IssuerProfile")
  }

  context 'for BMC HealthNet Plan' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('WellSense Health Plan')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("855-833-8120")
      expect(rendered).to match("memberquestions@bmchp.org")
      expect(rendered).to match("Monday through Friday from 8:00 a.m. to 6:00 p.m.")
    end
  end

  context 'for Fallon Health' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('Fallon Health')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("800-868-5200")
      expect(rendered).to match("FCHPcustomerservice@fallonhealth.org")
      expect(rendered).to match("Monday, Tuesday, Thursday, and Friday from 8:00 a.m. to 6:00 p.m., and Wednesday from 10:00 a.m. to 6:00 p.m.")
    end
  end

  context 'for Health New England' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('Health New England')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("413-787-4004")
      expect(rendered).to match("Please log into the  my.healthnewengland.org, our secure member portal , to send an email to our Members Services team. We’ll respond back to you within one business day and during normal business hours.")
      expect(rendered).to match("Monday through Friday, 8:00 a.m. to 6:00 p.m.")
    end
  end

  context 'for UnitedHealthcare' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('UnitedHealthcare')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("1-877-856-2429")
      expect(rendered).to match("8 AM to 5 PM")
    end
  end

  context 'for Harvard Pilgrim Health Care' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('Harvard Pilgrim Health Care')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("1-888-333-4742")
      expect(rendered).to match("send secure email after login to member account")
      expect(rendered).to match("Monday, Tuesday, & Thursday from 8:00 a.m. to 6:00 p.m.; Wednesday from 10:00 a.m. to 6:00 p.m.; and Friday from 8:00 a.m. to 5:30 p.m")
    end
  end

  context 'for AllWays Health Partners' do
    before :each do
      allow(plan).to receive(:kind).and_return('health')
      allow(issuer_profile).to receive(:legal_name).and_return('Mass General Brigham Health Plan')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("866-414-5533")
      expect(rendered).to match("HealthPlanCustomerService-Members@mgb.org")
      expect(rendered).to match("Monday, Tuesday, Wednesday, Friday from 8:00 a.m. to 6:00 p.m.; Thursday from 8:00 a.m. to 8:00 p.m.")
    end
  end

  context 'for Altus Dental' do
    before :each do
      allow(plan).to receive(:kind).and_return('Dental')
      allow(issuer_profile).to receive(:legal_name).and_return('Altus Dental')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("1.877.223.0588")
      expect(rendered).to match("customerservice@altusdental.com")
      expect(rendered).to match("Monday - Thursday, 8 am to 7 pm and Friday 8 am to 5 pm")
    end
  end

  context 'for Delta Dental' do
    before :each do
      allow(plan).to receive(:kind).and_return('Dental')
      allow(issuer_profile).to receive(:legal_name).and_return('Delta Dental')
      render partial: "shared/#{Settings.aca.state_abbreviation.downcase}_carrier_contact_information", locals: { plan: plan }
    end

    it "should display the carrier name and number" do
      expect(rendered).to match issuer_profile.legal_name
      expect(rendered).to match("800.872.0500")
      expect(rendered).to match("customer.care@deltadentalma.com")
      expect(rendered).to match("Monday - Thursday, 8:30 a.m. to 8:00 p.m.; Friday, 8:30 a.m. to 4:30 p.m.")
    end
  end
end
