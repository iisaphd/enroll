# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Operations
  module CensusMembers
    # Updates CensusMember Records
    class Update
      send(:include, Dry::Monads[:result, :do])

      EMPLOYEE_RELATIONSHIP_KINDS = ['spouse', 'domestic_partner', 'child', 'child_under_26', 'child_26_and_over', 'disabled_child_26_and_over'].freeze

      # @param [ Person ] person Person
      # @param [ String ] action Type of action to perform
      # @return [ BenefitSponsors::Entities::EnrollmentEligibility ] enrollment_eligibility
      def call(params)
        validate                         = yield validate(params)
        _census_member_enrolled          = yield census_member_enrolled?(params)
        _update_census_employee_records  = yield update_census_employee_records(params)
        _update_dependent_records        = yield update_census_dependent_records(params)
        _update_dependent_relationship   = yield update_census_dependent_relationship(params)

        Success(true)
      end

      private

      def validate(params)
        return Failure("Employee roster update feature is turned off") unless EnrollRegistry.feature_enabled?(:employee_roster_updates)

        Success(params)
      end

      def census_member_enrolled?(params)
        family, family_member =
          case params[:action]
          when 'update_census_employee'
            family = params[:person]&.primary_family
            [family, family&.find_family_member_by_person(params[:person])]
          when 'update_census_dependent'
            [params[:family_member]&.family, params[:family_member]]
          when 'update_relationship'
            family = params[:relationship]&.person&.primary_family
            [family, family&.find_family_member_by_person(params[:relationship].person)]
          end

        return Failure("Unable to find family for the given payload: #{params}") unless family.present?

        result = family.enrollments.shop_market.enrolled_and_renewal.map(&:applicant_ids).flatten.map(&:to_s).include?(family_member.id.to_s)

        if result
          Success(result)
        else
          Failure("Family Member: #{family_member&.id} doesn't have an active coverage, params: #{params}")
        end
      end

      def fetch_family_member_ids(enrollments)
        enrollments.each do |enrollment|
          enrollment.applicant_ids
        end
      end

      def update_census_employee_records(params)
        return Success(true) unless params[:action] == 'update_census_employee'

        result = params[:person].active_employee_roles.collect do |role|
          update_record(params[:person], role.census_employee)
        end

        if result.any?(&:failure)
          Failure(result.select(&:failure).map(&:failure).join(','))
        else
          Success(true)
        end
      end

      def update_census_dependent_records(params)
        return Success(true) unless params[:action] == 'update_census_dependent'

        person = params[:person]
        return Failure("No families found, params: #{params}, action: update_census_dependent")  if person.families.blank?

        employee_roles = params[:family_member].family.primary_person.active_employee_roles
        result = employee_roles.collect do |role|
          census_dependent = role.census_employee.census_dependents.where(matching_criteria(person)).first
          update_record(person, census_dependent) if census_dependent.present?
        end

        if result.any?(&:failure)
          Failure(result.select(&:failure).map(&:failure).join(','))
        else
          Success(true)
        end
      end

      def allowed_relationship_kind?(kind)
        Operations::CensusMembers::Create::EMPLOYEE_RELATIONSHIP_KINDS.include?(kind)
      end

      def update_census_dependent_relationship(params)
        relationship = params[:relationship]
        return Success(true) unless params[:action] == 'update_relationship' || allowed_relationship_kind?(relationship&.kind)

        primary_person = relationship.person
        dependent_person = relationship.relative

        primary_person.active_employee_roles.each do |role|
          census_dependent = role.census_employee.census_dependents.where(matching_criteria(dependent_person)).first
          census_dependent&.update_attributes(employee_relationship: relationship.kind)
        end
        Success(true)
      rescue StandardError => e
        Failure("Unable to update Employee Info Changes for person: #{primary_person.hbx_id}, action: update_relationship due to #{e.inspect}")
      end

      def update_record(person, census_member)
        census_member.update_attributes(build_updated_value_hash(person.changes, required_person_attributes)) if person.changed_attributes

        census_member.address.update_attributes(build_updated_value_hash(person.mailing_address.changes)) if person.mailing_address&.changes && census_member.address

        email_changes = person.work_or_home_email.changes if person.work_or_home_email
        census_member.email.update_attributes(build_updated_value_hash(email_changes)) if email_changes.present?

        Success(census_member)
      rescue StandardError => e
        Failure("Unable to update Employee Info Changes for person: #{person.hbx_id}, census_member_id: #{census_member.id} due to #{e.inspect}")
      end

      def required_person_attributes
        ['first_name', 'middle_name', 'last_name', 'name_sfx', 'dob', 'encrypted_ssn', 'gender']
      end

      def matching_criteria(person)
        criteria =
          {
            'first_name' => person.first_name,
            'last_name' => person.last_name,
            'dob' => person.dob
          }
        criteria.keys.each do |changed_attr|
          person.changes.each do |k, v|
            criteria[changed_attr] = v[0] if k == changed_attr
          end
        end
        criteria
      end

      def build_updated_value_hash(attr_changes, req_attrs = nil)
        updated_values = { }
        attr_changes.each do |k, v|
          updated_values[k] = v[1] if req_attrs.nil? || req_attrs&.include?(k)
        end
        updated_values
      end
    end
  end
end
