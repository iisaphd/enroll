require 'rails_helper'

include ApplicationHelper

module SponsoredBenefits
  RSpec.describe Organizations::PlanDesignProposals::PlansController, type: :controller, dbclean: :around_each do

    describe ".index" do
      let!(:current_effective_date) { (TimeKeeper.date_of_record + 2.months).beginning_of_month }
      let!(:issuer_profile) { FactoryGirl.create(:benefit_sponsors_organizations_issuer_profile) }
      let!(:county_zip) { FactoryGirl.create(:benefit_markets_locations_county_zip,
        county_name: 'Middlesex',
        zip: '01754',
        state: 'MA'
      ) }
      let!(:service_area) { FactoryGirl.create(:benefit_markets_locations_service_area, county_zip_ids: [county_zip.id], active_year: current_effective_date.year) }

      let!(:hps) {FactoryGirl.create_list(:benefit_markets_products_health_products_health_product,
          5,
          application_period: (current_effective_date.beginning_of_year..current_effective_date.end_of_year),
          product_package_kinds: [:single_issuer, :metal_level, :single_product],
          service_area: service_area,
          issuer_profile_id: issuer_profile.id,
          metal_level_kind: :gold)}

      before do
        hps.each do |hp|
          qhp = create(:products_qhp, active_year: hp.active_year, standard_component_id: hp.hios_id)
          csr = FactoryGirl.build(:products_qhp_cost_share_variance, hios_plan_and_variant_id: hp.hios_id)
          qhp.qhp_cost_share_variances << csr
          qhp_d = FactoryGirl.build(:products_qhp_deductable, in_network_tier_1_individual: "$100", in_network_tier_1_family: "$100 | $200")
          csr.qhp_deductibles << qhp_d
          qhp.save!
          csr.save!
          qhp_d.save!
          doc = FactoryGirl.build(:document, identifier: '1:1#1')
          hp.sbc_document = doc
          hp.save!
          doc.save!
        end
      end

      it "returns formatted deductible values" do
        plans = []
        hps.each do |hp|
          plans << double(id: hp.id, active_year: current_effective_date.year, hios_base_id: hp.hios_base_id, hios_id: hp.hios_id, coverage_kind: 'health')
        end

        deductibles = subject.instance_eval { plan_deductible_values(plans) }

        expect(deductibles[hps[0].id][:deductible]).to eq('$100')
        expect(deductibles[hps[1].id][:family_deductible]).to eq('$200')
        expect(deductibles[hps[2].id][:rx_deductible]).to eq('N/A')
        expect(deductibles[hps[3].id][:rx_family_deductible]).to eq('N/A')
      end
    end
    
  end
end
