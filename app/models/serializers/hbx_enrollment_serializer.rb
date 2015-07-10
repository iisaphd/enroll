module Serializers
  class HbxEnrollmentSerializer

    CV_XMLNS = {
        "xmlns" => 'http://openhbx.org/api/terms/1.0',
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
    }

    attr_reader :hbx_enrollment

    def initialize(hbx_enrollment)
      @hbx_enrollment = hbx_enrollment
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.enrollment(CV_XMLNS) do |xml|
          xml.type @hbx_enrollment.kind
          xml.market @hbx_enrollment.plan.market
          xml.policy do |xml|
            xml.id do |xml|
              xml.id @hbx_enrollment.try(:hbx_id) #since hbx_id not implemented yet
            end
            serialize_broker(@hbx_enrollment.broker_agency_profile, xml)
            serialize_enrollees(@hbx_enrollment.hbx_enrollment_members, xml)
            serialize_enrollment(@hbx_enrollment, xml)
          end
        end
      end
      # write_to_file builder.to_xml(:indent => 2)
      #validate_xml(builder.to_xml)
      builder.to_xml(:indent => 2)

    end

    def validate_xml(xml)
      xsd_path = Rails.root.join("cv/policy.xsd")
      xsd = Nokogiri::XML::Schema(File.read(xsd_path))
      doc = Nokogiri::XML(xml)

      xsd.validate(doc).each do |error|
        puts error.message
      end
    end

    def serialize_broker(broker_agency_profile, xml)
      return if broker_agency_profile.nil?

      xml.broker do |xml|
          xml.id do |xml|
            xml.id broker_agency_profile.corporate_npn
          end
          xml.name broker_agency_profile.legal_name
      end
    end

    def serialize_enrollees(enrollees, xml)
      xml.enrollees do |xml|
        enrollees.each do |enrollee|
          serialize_enrollee(enrollee, xml)
        end
      end
    end

    def serialize_enrollee(enrollee, xml)
      xml.enrollee do |xml|
        #serialize_member(enrollee, xml)
        #xml.is_subscriber (enrollee.primary_relationship.downcase == 'self')
        xml.benefit do |xml|
          xml.begin_date format_date(enrollee.coverage_start_on)
          xml.premium_amount enrollee.premium_amount
        end
      end
    end

    def format_date(date)
      #date = Date.strptime(date,'%m/%d/%Y')
      date.strftime('%Y%m%d')
    end

    def serialize_enrollment(enrollment, xml)
      xml.enrollment do |xml|
        serialize_plan(enrollment, xml)
      end
    end

    def serialize_plan(enrollment, xml)
      xml.plan do |xml|
        xml.id do |xml|
          xml.id enrollment.plan.hios_id
        end
        xml.coverage_type 'urn:openhbx:terms:v1:qhp_benefit_coverage#' + enrollment.plan.coverage_kind
        xml.plan_year '2015'
        xml.name enrollment.plan.name
        xml.metal_level enrollment.plan.metal_level
        xml.is_dental_only false
      end

      enrollment.plan.market.eql?("individual") ? serialize_individual_market(enrollment, xml) : serialize_shop_market(enrollment, xml)
      #xml.premium_total_amount format_amt(plan.premium_total)
      #xml.total_responsible_amount format_amt(plan.responsible_amount)
    end

    def serialize_individual_market(enrollment, xml)
      xml.individual_market do |xml|
        xml.is_carrier_to_bill true
        xml.applied_aptc_amount format_amt(enrollment.plan.employer_contribution)
      end
    end

    def serialize_shop_market(enrollment, xml)
      xml.shop_market do |xml|
        xml.employer_link do |xml|
          xml.id do |xml|
            xml.id enrollment.employer_profile.fein.gsub("-",'')
          end
          xml.name enrollment.employer_profile.legal_name
        end
        #xml.total_employer_responsible_amount format_amt(enrollment.plan.employer_contribution)
      end
    end

  end
end