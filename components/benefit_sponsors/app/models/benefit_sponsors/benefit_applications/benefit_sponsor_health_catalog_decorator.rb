module BenefitSponsors
  module BenefitApplications
    class BenefitSponsorHealthCatalogDecorator < SimpleDelegator

      Product = Struct.new(:id, :title, :metal_level_kind, :carrier_name, :issuer_id, :sole_source, :coverage_kind, :product_type, :network_information, :deductible_value, :family_deductible_value, :rx_deductible_value, :rx_family_deductible_value)
      ContributionLevel = Struct.new(:id, :display_name, :contribution_factor, :is_offered, :contribution_unit_id)

      def sponsor_contributions(benefit_package_id = nil)
        return @contributions if defined? @contributions

        if benefit_package_id.present?
          benefit_package = self.benefit_application.benefit_packages.detect{|bp| bp.id.to_s == benefit_package_id}
        end


        @contributions = product_packages.by_product_kind(:health).inject({}) do |contributions, product_package|

          if benefit_package.present?
            if sponsored_benefit = benefit_package.sponsored_benefits.detect{|sb| sb.product_package == product_package}
              sponsor_contribution = sponsored_benefit.sponsor_contribution
            end
          end

          if sponsor_contribution.blank?
            contribution_service = BenefitSponsors::SponsoredBenefits::ProductPackageToSponsorContributionService.new
            sponsor_contribution = contribution_service.build_sponsor_contribution(product_package)
          end

          contributions[product_package.package_kind.to_s] = {
            id: nil,
            contribution_levels: sponsor_contribution.contribution_levels.collect do |cl|
              ContributionLevel.new(cl.id.to_s, cl.display_name, cl.contribution_factor, true, cl.contribution_unit_id)
            end
          }

          contributions
        end
      end

      def plan_option_kinds
        plan_options.keys
      end

      def single_issuer_options
        carrier_name_and_id_hash = {}
        Hash[plan_options[:single_issuer].sort_by { |k, v| k }].each do |k, v|
          carrier_name_and_id_hash[k] = v.first["issuer_id"].to_s
        end
        carrier_name_and_id_hash
      end

      def metal_levels
        plan_options[:metal_level].keys
      end

      def single_product_options
        single_product_options_hash = {}
        Hash[plan_options[:single_product].sort_by { |k, v| k }].each do |k, v|
          single_product_options_hash[k] = v.first["issuer_id"].to_s
        end
        single_product_options_hash
      end

      def probation_period_kinds
        [
          ["First of the month following or coinciding with date of hire", 'first_of_month'],
          ["First of the month following 30 days", 'first_of_month_after_30_days'],
          ["First of the month following 60 days", 'first_of_month_after_60_days']
        ]
      end

      def plan_options
        return @products if defined? @products
        @products = {}

        product_packages.by_product_kind(:health).each do |product_package|
          package_products = product_package.products.collect do |product|
            qhp = Products::Qhp.where(active_year: product.active_year, standard_component_id: product.hios_base_id).first
            csr = qhp.qhp_cost_share_variances.where(hios_plan_and_variant_id: product.hios_id).to_a.first
            if csr.qhp_deductibles.count > 1
              medical = csr.qhp_deductibles.where(deductible_type: "Medical EHB Deductible").first
              if medical
                deductible = medical.in_network_tier_1_individual
                family_deductible = medical.in_network_tier_1_family
                fam_value = family_deductible.match(/[|]\s([$]\d+)/)
                family_deductible = if fam_value
                                      fam_value[1]
                                    else
                                      "N/A"
                                    end
              else
                deductible = "N/A"
                family_deductible = "N/A"
              end

              drug = csr.qhp_deductibles.where(deductible_type: "Drug EHB Deductible").first
              if drug
                rx_deductible = drug.in_network_tier_1_individual
                rx_family_deductible = drug.in_network_tier_1_family
                fam_value = rx_family_deductible.match(/[|]\s([$]\d+)/)
                rx_family_deductible = if fam_value
                                         fam_value[1]
                                       else
                                         "N/A"
                                       end
              else
                rx_deductible = "N/A"
                rx_family_deductible = "N/A"
              end
            else
              combined = csr.qhp_deductibles.first
              deductible = combined.in_network_tier_1_individual
              family_deductible = combined.in_network_tier_1_family
              fam_value = family_deductible.match(/[|]\s([$]\d+)/)
              family_deductible = if fam_value
                                    fam_value[1]
                                  else
                                    family_deductible = "N/A"
                                  end
              rx_deductible = "N/A"
              rx_family_deductible = "N/A"
            end

            Product.new(product.id,
                        product.title,
                        product.metal_level_kind,
                        carriers[product.issuer_profile_id.to_s],
                        product.issuer_profile_id,
                        false,
                        product.is_a?(BenefitMarkets::Products::HealthProducts::HealthProduct) ? "health" : "dental",
                        product.product_type,
                        product.network_information,
                        deductible,
                        family_deductible,
                        rx_deductible,
                        rx_family_deductible
            )
          end
          @products[product_package.package_kind] = case product_package.package_kind
            when :single_issuer
              package_products.group_by(&:carrier_name)
            when :metal_level
              package_products.group_by(&:metal_level_kind)
            else
              package_products.group_by(&:carrier_name)
            end
        end
        @products
      end

      def carriers
        return @carriers if defined? @carriers
        issuer_orgs = BenefitSponsors::Organizations::Organization.where(:"profiles._type" => "BenefitSponsors::Organizations::IssuerProfile")
        @carriers = issuer_orgs.inject({}) do |issuer_hash, issuer_org|
          issuer_profile  = issuer_org.profiles.where(:"_type" => "BenefitSponsors::Organizations::IssuerProfile").first
          issuer_hash[issuer_profile.id.to_s] = issuer_org.legal_name
          issuer_hash
        end
      end

      def carrier_level_options
        plan_options.group_by(&:carrier_name)
      end

      def metal_level_options
        plan_options.group_by(&:metal_level_kind)
      end

      def single_plan_options
        plan_options
      end
    end
  end
end
