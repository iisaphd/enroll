 # frozen_string_literal: true

require 'rails_helper'

module Effective
  module Datatables
    RSpec.describe BrokerAgencyEmployerDatatable, type: :model do
      context ".er_state" do
        let(:broker_agency_profile){ instance_double("BrokerAgencyProfile")}
        # let(:broker_agency_profile) { create(:benefit_sponsors_organizations_broker_agency_profile) }

        before do
          @datatable = ::Effective::Datatables::BrokerAgencyEmployerDatatable.new(profile_id: @broker_agency_profile._id)
        end

        it "should return summarized employer aasm_state" do
          expect(broker_agency_profile)
        end
      end
    end
  end
end
