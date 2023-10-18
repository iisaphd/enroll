# frozen_string_literal: true

class FetchMarketAndCoverageKindFromEnrollment
  include Interactor

  def call
    return unless context.previous_hbx_enrollment.present? #should not return failure so that it does not block the organizer.

    return unless context.previous_hbx_enrollment.present? && context.change_plan == "change_plan"

    context.mc_market_kind = context.previous_hbx_enrollment.kind == "employer_sponsored" ? "shop" : "individual"
    context.mc_coverage_kind = context.previous_hbx_enrollment.coverage_kind
  end

  private

  def hbx_enrollment_id
    context.params[:hbx_enrollment_id]
  end
end