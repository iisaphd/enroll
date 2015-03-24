class Plan
  include Mongoid::Document
  include Mongoid::Timestamps
#  include Mongoid::Versioning

  COVERAGE_KINDS = %w[health dental]
  METAL_LEVEL_KINDS = %w[bronze silver gold platinum catastrophic dental]
  MARKET_KINDS = %w(shop individual)


  field :hbx_id, type: Integer
  field :active_year, type: Integer
  field :hios_id, type: String
  field :name, type: String
  field :abbrev, type: String
  field :provider, type: String
  field :ehb, type: Float, default: 0.0

  field :coverage_kind, type: String
  field :metal_level, type: String
  field :market, type: String

  field :carrier_profile_id, type: BSON::ObjectId
  field :renewal_plan_id, type: BSON::ObjectId

  field :minimum_age, type: Integer, default: 0
  field :maximum_age, type: Integer, default: 120

  field :is_active, type: Boolean, default: true
  field :updated_by, type: String

  embeds_many :premium_tables do
    def get_costs_by_ages(insured_age, start_on, end_on) 
      where(:age.in => [insured_age].flatten, :start_on.lte => start_on, :end_on.gte => end_on).entries.map{|t| { age: t.age, cost: t.cost } }
    end
  end
  accepts_nested_attributes_for :premium_tables

  embeds_many :benefits
  accepts_nested_attributes_for :benefits

  embeds_many :plan_benefits
  accepts_nested_attributes_for :plan_benefits
  
  index({ hbx_id: 1 })
  index({ coverage_kind: 1 })
  index({ metal_level: 1 })
  index({ market: 1 })

  index({ carrier_profile_id: 1 })
  index({ active_year: 1, hios_id: 1}, {unique: true})
  index({ renewal_plan_id: 1 })

  index({ "premium_tables.age" => 1 })
  index({ "premium_tables.age" => 1, "premium_tables.start_on" => 1, "premium_tables.end_on" => 1 })

  validates_presence_of :name, :hios_id, :active_year, :metal_level, :market, :carrier_profile_id

  validates :coverage_kind,
   allow_blank: false,
   inclusion: { 
     in: COVERAGE_KINDS, 
     message: "%{value} is not a valid coverage kind" 
  }
             
  validates :metal_level,
   allow_blank: false,
   inclusion: { 
     in: METAL_LEVEL_KINDS, 
     message: "%{value} is not a valid metal level kind" 
  }

  validates :market,
   allow_blank: false,
   inclusion: { 
     in: MARKET_KINDS, 
     message: "%{value} is not a valid market" 
   }
             
  validates :active_year,
    length: { minimum: 4, maximum: 4, message: "active year must be four digits" },
    numericality: { greater_than: 2013, less_than: 2020, message: "active year must fall between 2014..2019" },
    allow_blank: false
  
  def metal_level=(new_metal_level)
    write_attribute(:metal_level, new_metal_level.to_s.downcase)
  end

  def coverage_kind=(new_coverage_kind)
    write_attribute(:coverage_kind, new_coverage_kind.to_s.downcase)
  end

  # belongs_to CarrierProfile
  def carrier_profile=(new_carrier_profile)
    if new_carrier_profile.nil?
      self.carrier_profile_id = nil
    else
      raise ArgumentError.new("expected CarrierProfile ") unless new_carrier_profile.is_a? CarrierProfile
      self.carrier_profile_id = new_carrier_profile._id
    end
    self.carrier_profile
  end

  def carrier_profile
    CarrierProfile.find(carrier_profile_id) unless carrier_profile_id.blank?
  end

  # has_one renewal_plan
  def renewal_plan=(new_renewal_plan)
    if renewal_plan.nil?
      self.renewal_plan_id = nil
    else
      raise ArgumentError.new("expected Plan ") unless renewal_plan.is_a? Plan
      self.renewal_plan_id = renewal_plan._id
    end
    self.renewal_plan
  end

  def renewal_plan
    find(renewal_plan_id) unless renewal_plan_id.blank?
  end


  def bound_age(given_age)
    return minimum_age if given_age < minimum_age
    return maximum_age if given_age > maximum_age
    given_age
  end

  class << self
    def monthly_premium(plan_year, hios_id, insured_age, coverage_begin_date)
      # plan_premium = Plan.and(
      #       { active_year: plan_year }, { hios_id: hios_id }, 
      #       { "premium_tables.age" => insured_age },
      #       { "premium_tables.start_on" => { "$lte" => coverage_begin_date }}, 
      #       { "premium_tables.end_on" => { "$gte" => coverage_begin_date }}
      #     ).only("premium_tables.cost", "premium_tables.age").entries
      # offset = insured_age - plan_documents.first.premium_tables.first.age

      #begin_date = Date.parse(coverage_begin_date)
      #plan_documents = Plan.and({ active_year: plan_year }, { hios_id: hios_id }).entries
      #premium_table = plan_documents.first.premium_tables.detect do |table|
      #  (table.age == insured_age) && (begin_date >= table.start_on) && (begin_date <= table.end_on)
      #end
      #plan_premium = premium_table.cost

      #Rails.cache.fetch("#{hios_id.to_s}_#{plan_year.to_i.to_s}_#{coverage_begin_date.to_s.to_i}_#{[insured_age].flatten.join('-')}", expires_in: 1.day) do
      #  plan_premiums = Plan.and(
      #    { active_year: plan_year }, { hios_id: hios_id }
      #  ).map do |plan|
      #    {plan_id: plan.id, tables: plan.premium_tables.get_costs_by_ages(insured_age, coverage_begin_date, coverage_begin_date) }
      #  end.flatten
      #end
      cache_key = [hios_id, plan_year, coverage_begin_date, [insured_age].flatten.join('-')]

      Rails.cache.fetch( cache_key, expires_in: 1.day) do
        plan_premiums = Plan.and(
          { active_year: plan_year }, { hios_id: hios_id }
        ).first
        .premium_tables.where(:age.in => [insured_age].flatten, :start_on.lte => coverage_begin_date, :end_on.gte => coverage_begin_date)
        .entries.map{|t| { age: t.age, cost: t.cost } }
      end
    end


    def find_by_carrier_profile(carrier_profile)
      raise ArgumentError("expected CarrierProfile") unless carrier_profile is_a? CarrierProfile
      where(carrier_profile_id: carrier_profile._id)
    end 
  end 
end
