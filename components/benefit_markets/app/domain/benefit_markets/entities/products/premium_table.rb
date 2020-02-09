# frozen_string_literal: true

module BenefitMarkets
  module Entities
    module Products
      class PremiumTable < Dry::Struct
        transform_keys(&:to_sym)

        attribute :effective_period,    Types::DateRange
        # attribute :rating_area,         Types::RatingArea
        attribute :premium_tuples,      Types::Array.of(Products::PremiumTuple)

      end
    end
  end
end