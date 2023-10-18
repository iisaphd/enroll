# frozen_string_literal: true

module Organizers
  class PrepareForCheckout
    include Interactor::Organizer

    organize [FindEnrollmentAndAssociations,
              FindProduct,
              BuildMemberGroup,
              BuildJsonForCheckout]
  end
end