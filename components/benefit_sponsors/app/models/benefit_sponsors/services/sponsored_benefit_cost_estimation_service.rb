# frozen_string_literal: true

module BenefitSponsors
  module Services
    class SponsoredBenefitCostEstimationService

      def calculate_estimates_for_home_display(sponsored_benefit)
        query = ::BenefitSponsors::BenefitApplications::BenefitApplicationEnrollmentsQuery.new(sponsored_benefit.benefit_package.benefit_application, sponsored_benefit)
                                                                                          .call(::Family, TimeKeeper.date_of_record).lazy.map { |rec| rec["hbx_enrollment_id"] }
        reference_product = sponsored_benefit.reference_product
        benefit_application = sponsored_benefit.benefit_package.benefit_application
        package = sponsored_benefit.product_package
        calculator = HbxEnrollmentListSponsorCostCalculator.new(sponsored_benefit.benefit_sponsorship)
        sponsor_contribution, total, employer_costs = calculator.calculate(sponsored_benefit, query)
        if sponsor_contribution.sponsored_benefit.pricing_determinations.any?
          pd = sponsor_contribution.sponsored_benefit.latest_pricing_determination
          sorted_tiers = pd.pricing_determination_tiers.sort_by { |pdt| pdt.pricing_unit.order }
          tier_costs = pd.pricing_determination_tiers.map do |pdt|
            pdt_total = pdt.price
            pdt_employer = BigDecimal((pdt_total * pdt.sponsor_contribution_factor).to_s).round(2)
            BigDecimal((pdt_total - pdt_employer).to_s).round(2)
          end
          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: tier_costs.min,
            estimated_enrollee_maximum: tier_costs.max
          }
        else
          issuer_hios_ids = reference_product.carrier_profile_hios_ids if package.package_kind == :single_issuer

          lowest_cost_product = package.lowest_cost_product(benefit_application.start_on, issuer_hios_ids)
          highest_cost_product = package.highest_cost_product(benefit_application.start_on, issuer_hios_ids)
          group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
          sponsored_benefit_with_lowest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, lowest_cost_product, package)
          sponsored_benefit_with_highest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, highest_cost_product, package)

          minimum_cost = sponsored_benefit_with_lowest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.min

          maximum_cost = sponsored_benefit_with_highest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.max
          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: minimum_cost,
            estimated_enrollee_maximum: maximum_cost
          }
        end
      end

      def calculate_estimates_for_benefit_display(sponsored_benefit)
        reference_product = sponsored_benefit.reference_product
        benefit_application = sponsored_benefit.benefit_package.benefit_application
        package = sponsored_benefit.product_package
        cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeCoverageCostEstimator.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
        sponsor_contribution, total, employer_costs = cost_estimator.calculate(
          sponsored_benefit,
          reference_product,
          package
        )
        if sponsor_contribution.sponsored_benefit.pricing_determinations.any?
          pd = sponsor_contribution.sponsored_benefit.latest_pricing_determination
          sorted_tiers = pd.pricing_determination_tiers.sort_by { |pdt| pdt.pricing_unit.order }
          tier_costs = pd.pricing_determination_tiers.map do |pdt|
            pdt_total = pdt.price
            pdt_employer = BigDecimal((pdt_total * pdt.sponsor_contribution_factor).to_s).round(2)
            BigDecimal((pdt_total - pdt_employer).to_s).round(2)
          end
          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: tier_costs.min,
            estimated_enrollee_maximum: tier_costs.max
          }
        else
          issuer_hios_ids = reference_product.carrier_profile_hios_ids if package.package_kind == :single_issuer

          lowest_cost_product = package.lowest_cost_product(benefit_application.start_on, issuer_hios_ids)
          highest_cost_product = package.highest_cost_product(benefit_application.start_on, issuer_hios_ids)
          group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
          sponsored_benefit_with_lowest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, lowest_cost_product, package)
          sponsored_benefit_with_highest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, highest_cost_product, package)

          minimum_cost = sponsored_benefit_with_lowest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.min

          maximum_cost = sponsored_benefit_with_highest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.max

          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: minimum_cost,
            estimated_enrollee_maximum: maximum_cost
          }
        end
      end

      def calculate_employee_estimates_for_package_design(benefit_application, sponsored_benefit, reference_product, package)
        calculate_employee_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: true)
      end

      def calculate_employee_estimates_for_package_edit(benefit_application, sponsored_benefit, reference_product, package)
        calculate_employee_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
      end

      def calculate_estimates_for_package_design(benefit_application, sponsored_benefit, reference_product, package)
        calculate_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: true)
      end

      def calculate_estimates_for_package_edit(benefit_application, sponsored_benefit, reference_product, package)
        calculate_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
      end

      def calculate_employee_estimates_for_all_products_in_package(benefit_application, sponsored_benefit, reference_product, package)
        calculate_employee_estimates_for_all_products(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
      end

      protected

      def calculate_employee_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
        # TODO: Sometimes benefit_application/benefit_sponsorship are nil, gotta figure out if its from the form
        cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeCoverageCostEstimator.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
        sponsor_contribution, total, employer_costs = cost_estimator.calculate(
          sponsored_benefit,
          reference_product,
          package,
          rebuild_sponsor_contribution: false,
          build_new_pricing_determination: build_objects
        )
        if sponsor_contribution.sponsored_benefit.pricing_determinations.any?
          pd = sponsor_contribution.sponsored_benefit.latest_pricing_determination
          sorted_tiers = pd.pricing_determination_tiers.sort_by { |pdt| pdt.pricing_unit.order }
          tier_costs = pd.pricing_determination_tiers.lazy.map do |pdt|
            pdt_total = pdt.price
            pdt_employer = BigDecimal((pdt_total * pdt.sponsor_contribution_factor).to_s).round(2)
            BigDecimal((pdt_total - pdt_employer).to_s).round(2)
          end
          lowest_cost = tier_costs.min
          highest_cost = tier_costs.max
          group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
          sponsored_benefit_with_reference_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, reference_product, package)
          sponsored_benefit_with_reference_product.map do |estimate|
            main_name = estimate.primary_member.census_member.full_name
            dep_count = estimate.members.count - 1
            {
              name: main_name,
              dependent_count: dep_count,
              highest_cost_estimate: highest_cost,
              lowest_cost_estimate: lowest_cost,
              reference_estimate: employee_cost_from_group_enrollment(estimate.group_enrollment)
            }
          end
        else
          issuer_hios_ids = reference_product.carrier_profile_hios_ids if package.package_kind == :single_issuer

          lowest_cost_product = package.lowest_cost_product(benefit_application.start_on, issuer_hios_ids)
          highest_cost_product = package.highest_cost_product(benefit_application.start_on, issuer_hios_ids)

          group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)

          sponsored_benefit_with_lowest_cost_product  = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, lowest_cost_product, package)
          sponsored_benefit_with_highest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, highest_cost_product, package)
          sponsored_benefit_with_reference_product    = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, reference_product, package)
          all_estimates = sponsored_benefit_with_lowest_cost_product + sponsored_benefit_with_highest_cost_product + sponsored_benefit_with_reference_product
          grouped_estimates = all_estimates.group_by(&:group_id)
          grouped_estimates.values.map do |estimate_set|
            reference_record = estimate_set.first
            main_name = reference_record.primary_member.census_member.full_name
            dep_count = reference_record.members.count - 1
            ref_estimate = estimate_set.map(&:group_enrollment).detect do |ge|
              ge.product.id == reference_product.id
            end
            low_estimate = estimate_set.map(&:group_enrollment).detect do |ge|
              ge.product.id == lowest_cost_product.id
            end
            high_estimate = estimate_set.map(&:group_enrollment).detect do |ge|
              ge.product.id == highest_cost_product.id
            end
            {
              name: main_name,
              dependent_count: dep_count,
              highest_cost_estimate: employee_cost_from_group_enrollment(high_estimate),
              lowest_cost_estimate: employee_cost_from_group_enrollment(low_estimate),
              reference_estimate: employee_cost_from_group_enrollment(ref_estimate)
            }
          end
        end
      end

      def calculate_employee_estimates_for_all_products(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
        cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeCoverageCostEstimator.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
        sponsor_contribution, _total, _employer_costs = cost_estimator.calculate(
          sponsored_benefit,
          reference_product,
          package,
          rebuild_sponsor_contribution: false,
          build_new_pricing_determination: build_objects
        )

        # for dental we only need to display reference plan
        if sponsor_contribution.sponsored_benefit.pricing_determinations.any? || reference_product.dental?
          products = [reference_product]
        elsif package.package_kind == :single_issuer
          issuer_hios_ids = reference_product.carrier_profile_hios_ids
          products = package.load_base_products.select {|p| issuer_hios_ids.include?(p.hios_id.slice(0, 5))}
        else
          products = package.load_base_products.select {|p| p.metal_level_kind.eql?(reference_product.metal_level_kind)}
        end

        products = products.sort_by!(&:name) && ([reference_product] + products).uniq

        group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
        sb = sponsor_contribution.sponsored_benefit

        employee_product_costs = products.inject([]) do |result, product|
          sponsored_benefit_info = group_cost_estimator.calculate(sb, product, package)
          result << {
            product_id: product.id,
            employees: sponsored_benefit_info.inject([]) do |employees_result, ce_benefit_info|
              group_enrollment = ce_benefit_info.group_enrollment

              employees_result << {
                id: ce_benefit_info.group_id,
                sponsor_contribution_total: group_enrollment.sponsor_contribution_total,
                product_cost_total: group_enrollment.product_cost_total,
                carrier_name: product.issuer_profile.legal_name
              }
              employees_result
            end
          }
          result
        end

        employee_estimated_costs(group_cost_estimator, products, employee_product_costs)
      end

      def employee_estimated_costs(group_cost_estimator, products, employee_product_costs)
        group_cost_estimator.eligible_employee_criteria.inject([]) do |result, census_employee|
          result << {
            name: census_employee.full_name,
            expected_selection: census_employee.expected_selection,
            products: products.inject([]) do |output, product|
              info = employee_product_costs.detect {|i| i[:product_id] == product.id }
              employee_info = info[:employees].detect {|i| i[:id] == census_employee.id }
              output << {
                id: product.id,
                product_name: product.title,
                sponsor_contribution_total: employee_info[:sponsor_contribution_total],
                product_cost_total: employee_info[:product_cost_total],
                carrier_name: product.issuer_profile.legal_name
              }
              output
            end
          }
          result
        end
      end

      def calculate_estimates_for_package_action(benefit_application, sponsored_benefit, reference_product, package, build_objects: false)
        cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeCoverageCostEstimator.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
        sponsor_contribution, total, employer_costs = cost_estimator.calculate(
          sponsored_benefit,
          reference_product,
          package,
          rebuild_sponsor_contribution: false,
          build_new_pricing_determination: build_objects
        )
        if sponsor_contribution.sponsored_benefit.pricing_determinations.any?
          pd = sponsor_contribution.sponsored_benefit.latest_pricing_determination
          sorted_tiers = pd.pricing_determination_tiers.sort_by { |pdt| pdt.pricing_unit.order }
          tier_costs = pd.pricing_determination_tiers.lazy.map do |pdt|
            pdt_total = pdt.price
            pdt_employer = BigDecimal((pdt_total * pdt.sponsor_contribution_factor).to_s).round(2)
            BigDecimal((pdt_total - pdt_employer).to_s).round(2)
          end
          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: tier_costs.min,
            estimated_enrollee_maximum: tier_costs.max
          }
        else
          issuer_hios_ids = reference_product.carrier_profile_hios_ids if package.package_kind == :single_issuer

          lowest_cost_product = package.lowest_cost_product(benefit_application.start_on, issuer_hios_ids)
          highest_cost_product = package.highest_cost_product(benefit_application.start_on, issuer_hios_ids)
          group_cost_estimator = BenefitSponsors::SponsoredBenefits::CensusEmployeeEstimatedCostGroup.new(benefit_application.benefit_sponsorship, benefit_application.effective_period.min)
          sponsored_benefit_with_lowest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, lowest_cost_product, package)
          sponsored_benefit_with_highest_cost_product = group_cost_estimator.calculate(sponsor_contribution.sponsored_benefit, highest_cost_product, package)

          minimum_cost = sponsored_benefit_with_lowest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.min

          maximum_cost = sponsored_benefit_with_highest_cost_product.lazy.map do |mg|
            BigDecimal((mg.group_enrollment.product_cost_total - mg.group_enrollment.sponsor_contribution_total).to_s).round(2)
          end.max

          {
            estimated_total_cost: total,
            estimated_sponsor_exposure: employer_costs,
            estimated_enrollee_minimum: minimum_cost,
            estimated_enrollee_maximum: maximum_cost
          }
        end
      end

      def employee_cost_from_group_enrollment(group_enrollment)
        BigDecimal((group_enrollment.product_cost_total - group_enrollment.sponsor_contribution_total).to_s).round(2)
      end
    end
  end
end
