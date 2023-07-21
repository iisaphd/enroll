# frozen_string_literal: true

module Events
  module BenefitSponsors
    module CensusEmployee
      # This class will register event 'census_employee_publisher'
      class Created < EventSource::Event
        publisher_path 'publishers.benefit_sponsors.census_employee_publisher'

      end
    end
  end
end
