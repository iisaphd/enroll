# frozen_string_literal: true

class FindPreviousHbxEnrollment
  include Interactor

  def call
    return unless context.params.keys.include?(:hbx_enrollment_id) || context.params[:cart]

    context.fail!(message: "missing hbx_enrollment_id in params") unless hbx_enrollment_id.present?

    hbx_enrollment = HbxEnrollment.find(hbx_enrollment_id)
    if hbx_enrollment
      context.previous_hbx_enrollment = hbx_enrollment
    else
      context.fail!(message: "no hbx enrollment found for given id")
    end
  rescue StandardError => _e
    context.fail!(message: "invalid hbx enrollment ID")
  end

  def hbx_enrollment_id
    context.params[:hbx_enrollment_id] || context.params[:cart].collect{|_k,v| v["id"]}.first
  end
end