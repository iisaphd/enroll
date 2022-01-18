# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module FinancialAssistance
  module Operations
    module Applications
      module MedicaidGateway
        # This Operation adds the MEC Check to the Application(persistence object)
        # Operation receives the MEC Check results
        class AddMecCheckApplication
          include Dry::Monads[:result, :do]

          # @param [Hash] opts The options to add eligibility determination to Application(persistence object)
          # @return [Dry::Monads::Result]
          def call(params)
            application_entity = yield initialize_application_entity(params)
            application = yield find_application(application_entity)
            result = yield update_applicant(application_entity, application)
            Success(result)
          end

          private

          def initialize_application_entity(params)
            ::AcaEntities::MagiMedicaid::Operations::InitializeApplication.new.call(params)
          end

          def find_application(application_entity)
            application = ::FinancialAssistance::Application.by_hbx_id(application_entity.hbx_id).first
            application.present? ? Success(application) : Failure("Could not find application with given hbx_id: #{application_entity.hbx_id}")
          end

          def update_applicant(response_app_entity, application)
            response_app_entity.applicants.each do |response_applicant_entity|
              applicant = find_matching_applicant(application, response_applicant_entity)
              update_applicant_verifications(applicant, response_applicant_entity)
            end
            Success('Successfully updated Applicant with evidences and verifications')
          end

          def find_matching_applicant(application, res_applicant_entity)
            application.applicants.detect do |applicant|
              applicant.person_hbx_id == res_applicant_entity.person_hbx_id
            end
          end

          def update_applicant_verifications(applicant, response_applicant_entity)
            response_evidence = response_applicant_entity.local_mec_evidence
            applicant_local_mec_evidence = applicant.local_mec_evidence

            if applicant_local_mec_evidence.present?
              if response_evidence.aasm_state == 'outstanding'
                applicant.set_evidence_outstanding(applicant_local_mec_evidence)
              else
                applicant.set_evidence_verified(applicant_local_mec_evidence)
              end

              response_evidence.request_results&.each do |eligibility_result|
                applicant_local_mec_evidence.request_results << Eligibilities::RequestResult.new(eligibility_result.to_h)
              end
              applicant.save!
            end

            Success(applicant)
          end
        end
      end
    end
  end
end
