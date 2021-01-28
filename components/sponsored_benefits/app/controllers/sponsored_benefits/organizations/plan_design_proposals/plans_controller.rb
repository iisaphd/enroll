module SponsoredBenefits
  module Organizations
    class PlanDesignProposals::PlansController < ApplicationController

      def index
        offering_query = ::Queries::EmployerPlanOfferings.new(plan_design_organization)
        @plans = case selected_carrier_level
          when "single_carrier"
            offering_query.single_carrier_offered_health_plans(params[:carrier_id], params[:active_year])
          when "metal_level"
            offering_query.metal_level_offered_health_plans(params[:metal_level], params[:active_year])
          when "single_plan"
            offering_query.send "single_option_offered_#{kind}_plans", params[:carrier_id], params[:active_year]
          when "sole_source"
            offering_query.sole_source_offered_health_plans(params[:carrier_id], params[:active_year])
          end
        @plans = @plans.select{|a| a.premium_tables.present?}
        @search_options = ::Plan.search_options(@plans)
        @search_option_titles = {
                'plan_type': 'HMO / PPO',
                'plan_hsa': 'HSA - Compatible',
                'metal_level': 'Metal Level',
                'plan_deductible': 'Individual deductible (in network)'
              }

        @plan_deductibles = plan_deductible_values(@plans)
      end

      private
      helper_method :selected_carrier_level, :plan_design_organization, :carrier_profile, :carriers_cache, :kind, :plan_deductible_values

      def selected_carrier_level
        @selected_carrier_level ||= params[:selected_carrier_level]
      end

      def plan_design_organization
        @plan_design_organization ||= PlanDesignOrganization.find(params[:plan_design_organization_id])
      end

      def carrier_profile
        @carrier_profile ||= ::CarrierProfile.find(params[:carrier_id])
      end

      def carriers_cache
        @carriers_cache ||= ::CarrierProfile.all.inject({}) do |carrier_hash, carrier_profile|
          carrier_hash[carrier_profile.id] = carrier_profile.legal_name
          carrier_hash
        end
      end

      def kind
        params[:kind]
      end

      def plan_deductible_values(plans)
        plan_deductibles = {}
        plans.each do |plan|
          qhp = Products::Qhp.where(active_year: plan.active_year, standard_component_id: plan.hios_base_id).first
          hios_id = plan.coverage_kind == "dental" ? (plan.hios_id + "-01") : plan.hios_id
          csr = qhp.qhp_cost_share_variances.where(hios_plan_and_variant_id: hios_id).to_a.first
          if csr.qhp_deductibles.count > 1
            deductible_values = get_medical_and_dental(csr.qhp_deductibles)
            deductible = deductible_values[:deductible]
            family_deductible = deductible_values[:family_deductible]
            rx_deductible = deductible_values[:rx_deductible]
            rx_family_deductible = deductible_values[:rx_family_deductible]
          else
            combined = csr.qhp_deductibles.first
            deductible = combined.in_network_tier_1_individual
            family_deductible_value = combined.in_network_tier_1_family
            fam_value_match = family_deductible_value.match(/[|]\s([$]\d+)/)
            family_deductible = fam_value_match ? fam_value_match[1] : "N/A"
            rx_deductible = "N/A"
            rx_family_deductible = "N/A"
          end

          deductible = "N/A" if deductible == "Not Applicable"
          rx_deductible = "N/A" if rx_deductible == "Not Applicable"

          plan_deductibles[plan.id] = {deductible: deductible, family_deductible: family_deductible, rx_deductible: rx_deductible, rx_family_deductible: rx_family_deductible}
        end

        plan_deductibles
      end

      def get_medical_and_dental(deductibles)
        medical = deductibles.where(deductible_type: "Medical EHB Deductible").first
        if medical
          deductible = medical.in_network_tier_1_individual
          family_deductible_value = medical.in_network_tier_1_family
          fam_value_match = family_deductible_value.match(/[|]\s([$]\d+)/)
          family_deductible = fam_value_match ? fam_value_match[1] : "N/A"
        else
          deductible = "N/A"
          family_deductible = "N/A"
        end

        drug = deductibles.where(deductible_type: "Drug EHB Deductible").first
        if drug
          rx_deductible = drug.in_network_tier_1_individual
          rx_family_deductible = drug.in_network_tier_1_family
          fam_value = rx_family_deductible.match(/[|]\s([$]\d+)/)
          rx_family_deductible = fam_value ? fam_value[1] : "N/A"
        else
          rx_deductible = "N/A"
          rx_family_deductible = "N/A"
        end

        {deductible: deductible, family_deductible: family_deductible, rx_deductible: rx_deductible, rx_family_deductible: rx_family_deductible}
      end
    end
  end
end
