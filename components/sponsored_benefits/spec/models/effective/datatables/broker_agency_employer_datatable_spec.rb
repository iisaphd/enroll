 # frozen_string_literal: true

require 'rails_helper'

module Effective
  module Datatables
    RSpec.describe BrokerAgencyEmployerDatatable, type: :model do
      context ".er_state" do
        let(:broker_agency_profile) { double(:sponsored_benefits_broker_agency_profile, id: double) }
        let(:plan_design_organization) { double("PlanDesignOrganization", is_prospect?: false, employer_profile: employer) }
        let(:organization) { double("Organization", active_benefit_sponsorship: benefit_sponsorship) }
        let(:employer) { double("Employer", organization: organization) }
        let(:benefit_sponsorship) { double("BenefitSponsorship") }
        let(:benefit_application) { double("BenefitApplication") }

        before do
          allow(plan_design_organization).to receive(:broker_relationship_inactive?).and_return(false)
          allow(benefit_sponsorship).to receive(:dt_display_benefit_application).and_return(nil)

          @datatable = ::Effective::Datatables::BrokerAgencyEmployerDatatable.new(profile_id: broker_agency_profile.id)
        end

        context 'when benefit application is not present' do
          it "should return nil" do
            expect(@datatable.er_state(plan_design_organization)).to eq nil
          end
        end

        context 'when there is no predecessor_id present' do
          before do
            allow(benefit_sponsorship).to receive(:dt_display_benefit_application).and_return(benefit_application)
            allow(benefit_application).to receive(:predecessor_id).and_return(false)
          end

          context 'when benefit application is in draft' do
            it "should return summarized aasm_state as draft" do
              allow(benefit_application).to receive(:aasm_state).and_return(:draft)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Draft'
            end
          end

          context 'when benefit application is in enrollment_open' do
            it "should return summarized aasm_state as Enrolling" do
              allow(benefit_application).to receive(:aasm_state).and_return(:enrollment_open)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Enrolling'
            end
          end

          context 'when benefit application is in enrollment_eligible' do
            it "should return summarized aasm_state as enrolled" do
              allow(benefit_application).to receive(:aasm_state).and_return(:enrollment_eligible)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Enrolled'
            end
          end

          context 'when benefit application is in binder_paid' do
            it "should return summarized aasm_state as enrolled" do
              allow(benefit_application).to receive(:aasm_state).and_return(:binder_paid)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Enrolled'
            end
          end

          context 'when benefit application is in approved' do
            it "should return summarized aasm_state as published" do
              allow(benefit_application).to receive(:aasm_state).and_return(:approved)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Published'
            end
          end

          context 'when benefit application is in pending' do
            it "should return summarized aasm_state as publish pending" do
              allow(benefit_application).to receive(:aasm_state).and_return(:pending)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Publish Pending'
            end
          end
        end

        context 'when there is predecessor_id present' do
          before do
            allow(benefit_sponsorship).to receive(:dt_display_benefit_application).and_return(benefit_application)
            allow(benefit_application).to receive(:predecessor_id).and_return(true)
          end

          context 'when benefit application is in draft' do
            it "should return summarized aasm_state as draft" do
              allow(benefit_application).to receive(:aasm_state).and_return(:draft)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Draft'
            end
          end

          context 'when benefit application is in enrollment_open' do
            it "should return summarized aasm_state as Enrolling" do
              allow(benefit_application).to receive(:aasm_state).and_return(:enrollment_open)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Enrolling'
            end
          end

          context 'when benefit application is in enrollment_eligible' do
            it "should return summarized aasm_state as enrolled" do
              allow(benefit_application).to receive(:aasm_state).and_return(:enrollment_eligible)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Enrolled'
            end
          end

          context 'when benefit application is in binder_paid' do
            it "should return summarized aasm_state as enrolled" do
              allow(benefit_application).to receive(:aasm_state).and_return(:binder_paid)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Enrolled'
            end
          end

          context 'when benefit application is in approved' do
            it "should return summarized aasm_state as published" do
              allow(benefit_application).to receive(:aasm_state).and_return(:approved)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Published'
            end
          end

          context 'when benefit application is in pending' do
            it "should return summarized aasm_state as publish pending" do
              allow(benefit_application).to receive(:aasm_state).and_return(:pending)
              expect(@datatable.er_state(plan_design_organization)).to eq 'Renewing Publish Pending'
            end
          end
        end
      end
    end
  end
end
