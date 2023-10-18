FactoryGirl.define do
  factory :benefit_markets_products_health_products_health_product, class: 'BenefitMarkets::Products::HealthProducts::HealthProduct' do

    benefit_market_kind  :aca_shop
    application_period   Date.new(Date.today.year, 1, 1)..Date.new(Date.today.year, 12, 31)
    sequence(:hbx_id)    { |n| n + 12345 }

    sequence(:title)     { |n| "#{issuer_name} #{metal_level_kind}#{n} 2,000" }
    description          { "Highest rated and highest value" }
    health_plan_kind     { :pos }
    ehb                  { 0.9943 }
    metal_level_kind     { BenefitMarkets::Products::HealthProducts::HealthProduct::METAL_LEVEL_KINDS.sample }
    deductible           { "$500 per person" }
    family_deductible    { "$500 per person | $1000 per group" }

    product_package_kinds { [:single_product, :single_issuer, :metal_level] }
    sequence(:hios_id, (10..99).cycle)  { |n| "41842DC04000#{n}-01" }
    hios_base_id          { hios_id.split('-')[0] }

    service_area { create(:benefit_markets_locations_service_area) }

    transient do
      issuer_name { 'BlueChoice' }
    end

    trait :with_issuer_profile do
      transient do
        assigned_site nil
      end

      issuer_profile { create(:benefit_sponsors_organizations_issuer_profile, assigned_site: assigned_site) }
    end

    trait :with_renewal_product do
      transient do
        renewal_service_area nil
      end

      before(:create) do |product, evaluator|
        renewal_product = create(:benefit_markets_products_health_products_health_product,
          application_period: (product.application_period.min.next_year..product.application_period.max.next_year),
          product_package_kinds: product.product_package_kinds,
          service_area: evaluator.renewal_service_area,
          issuer_profile_id: product.issuer_profile_id,
          metal_level_kind: product.metal_level_kind)

        product.renewal_product_id = renewal_product.id
      end
    end


    # association :service_area, factory: :benefit_markets_locations_service_area, strategy: :create

    after(:build) do |product, evaluator|
      product.premium_tables << build_list(:benefit_markets_products_premium_table, 1, effective_period: product.application_period, rating_area: create(:benefit_markets_locations_rating_area))
    end


  end
end
