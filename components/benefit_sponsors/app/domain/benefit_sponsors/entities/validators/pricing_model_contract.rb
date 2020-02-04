# frozen_string_literal: true

module BenefitSponsors
  module Entities
    module Validators
      class PricingModelContract < ApplicationContract

        params do
          required(:name).filled(:string)
          required(:price_calculator_kind).filled(:string)
          required(:product_multiplicities).array(:symbol)
          required(:pricing_units).array(:hash)
          required(:member_relationships).array(:hash)
        end

        rule(:pricing_units).each do
          if key? && value
            result = PricingUnitContract.call(value)
            key.failure(text: "invalid benefit application", error: result.errors.to_h) if result && result.failure?
          end
        end

        rule(:member_relationships).each do
          if key? && value 
            result = MemberRelationshipContract.call(value)
            key.failure(text: "invalid product package", error: result.errors.to_h) if result && result.failure?
          end
        end
      end
    end
  end
end