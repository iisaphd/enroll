# frozen_string_literal: true

module FinancialAssistance
  module Locations
    class Phone
      include Mongoid::Document
      include Mongoid::Timestamps

      embedded_in :applicant, class_name: '::FinancialAssistance::Applicant'

      after_save :save_phone_components
      before_save :set_full_phone_number

      KINDS = %w[home work mobile fax].freeze

      field :kind, type: String, default: ''
      field :country_code, type: String, default: ''
      field :area_code, type: String, default: ''
      field :number, type: String, default: ''
      field :extension, type: String, default: ''
      field :primary, type: Boolean
      field :full_phone_number, type: String, default: ''

      validates :area_code,
                numericality: true,
                length: {minimum: 3, maximum: 3, message: '%{value} is not a valid area code'},
                allow_blank: true

      validates :number,
                numericality: true,
                length: {minimum: 7, maximum: 7, message: '%{value} is not a valid phone number'},
                allow_blank: true

      validates :kind,
                inclusion: {in: KINDS, message: '%{value} is not a valid phone type'},
                allow_blank: false

      validates_presence_of :area_code, :number

      def blank?
        [:full_phone_number, :area_code, :number, :extension].all? do |attr|
          self.send(attr).blank?
        end
      end

      def save_phone_components
        phone_number = filter_non_numeric(self.full_phone_number).to_s
        if phone_number.blank?
          self.area_code = ''
          self.extension = ''
          self.number = ''
          return
        end

        length = phone_number.length

        if length > 10
          self.area_code = phone_number[0, 3]
          self.number = phone_number[3, 7]
          self.extension = phone_number[10, length - 10]
        elsif length == 10
          self.area_code = phone_number[0, 3]
          self.number = phone_number[3, 7]
        end
      end

      def full_phone_number=(new_full_phone_number)
        super filter_non_numeric(new_full_phone_number)
        save_phone_components
      end

      def area_code=(new_area_code)
        super filter_non_numeric(new_area_code)
      end

      def number=(new_number)
        super filter_non_numeric(new_number)
      end

      def extension=(new_extension)
        super filter_non_numeric(new_extension)
      end

      def to_s
        full_number = area_code.present? && number.present? ? (self.area_code + self.number).to_i : ""
        return "" unless full_number.present?
        if self.extension.present?
          full_number.to_s(:phone, area_code: true, extension: self.extension)
        else
          full_number.to_s(:phone, area_code: true)
        end
      end

      def set_full_phone_number
        self.full_phone_number = to_s
      end

      def kinds
        KINDS
      end

      private

      def filter_non_numeric(str)
        str.present? ? str.to_s.gsub(/\D/, '') : ''
      end
    end
  end
end
