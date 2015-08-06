require 'rails_helper'
require File.join(Rails.root, "spec", "support", "acapi_vocabulary_spec_helpers")

RSpec.describe "events/employer/updated.haml.erb" do
  let(:legal_name) { "A Legal Employer Name" }
  let(:fein) { "867530900" }
  let(:entity_kind) { "c_corporation" }

  let(:organization) { Organization.new(:legal_name => legal_name, :fein => fein, :is_active => false) }

  describe "given a single plan year" do
    include AcapiVocabularySpecHelpers

    before(:all) do
      download_vocabularies
    end

    let(:plan_year) { PlanYear.new(:aasm_state => "published", :created_at => DateTime.now, :start_on => DateTime.now, :open_enrollment_start_on => DateTime.now, :open_enrollment_end_on => DateTime.now) }
    let(:employer) { EmployerProfile.new(:organization => organization, :plan_years => [plan_year], :entity_kind => entity_kind) }

    before :each do
      render :template => "events/employers/updated", :locals => { :employer => employer }
    end

    it "should have one plan year" do
      expect(rendered).to have_xpath("//plan_years/plan_year")
    end

    it "should be schema valid" do
      expect(validate_with_schema(Nokogiri::XML(rendered))).to eq []
    end

  end

  (1..15).to_a.each do |rnd|

    describe "given a generated employer, round #{rnd}" do
      include AcapiVocabularySpecHelpers

      before(:all) do
        download_vocabularies
      end

      let(:employer) { FactoryGirl.build_stubbed :generative_employer_profile }

      before :each do
        render :template => "events/employers/updated", :locals => { :employer => employer }
      end

      it "should be schema valid" do
        expect(validate_with_schema(Nokogiri::XML(rendered))).to eq []
      end

    end

  end
end
