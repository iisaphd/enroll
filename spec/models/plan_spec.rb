require 'rails_helper'

RSpec.describe Plan, type: :model do
  def carrier_profile; FactoryGirl.create(:carrier_profile); end

  def name; "BlueChoice Silver $2,000"; end
  def active_year; 2015; end
  def hios_id; "86052DC0400001-01"; end
  def carrier_profile_id; carrier_profile._id; end
  def metal_level; "platinum"; end
  def coverage_kind; "health"; end
  def market; "shop"; end

  def bad_metal_level; "copper"; end
  def ehb; 0.9943; end

  def metal_level_error_message; "#{bad_metal_level} is not a valid metal level kind"; end

  it { should validate_presence_of :name }
  it { should validate_presence_of :carrier_profile_id }
  it { should validate_presence_of :hios_id }
  it { should validate_presence_of :active_year }

  describe ".new" do
    let(:valid_params) do
      {
        name: name,
        active_year: active_year,
        hios_id: hios_id,
        carrier_profile_id: carrier_profile_id,
        metal_level: metal_level,
        coverage_kind: coverage_kind,
        market: market
      }
    end

    context "with no arguments" do
      def params; {}; end
      it "should not save" do
        expect(Plan.new(**params).save).to be_false
      end
    end

    context "with all valid arguments" do
      def params; valid_params; end
      def plan; Plan.new(**params); end

      it "should save" do
        # expect(plan.inspect).to be_nil
        expect(plan.save).to be_true
      end

      context "and it is saved" do
        let!(:saved_plan) do
          alt_plan = plan
          alt_plan.hios_id = "86052DC0400001-02"
          alt_plan.save
          alt_plan
        end

        it "should be findable" do
          expect(Plan.find(saved_plan.id).id.to_s).to eq saved_plan.id.to_s
        end
      end
    end

    context "with no metal_level" do
      def params; valid_params.except(:metal_level); end

      it "should fail validation " do
        expect(Plan.create(**params).errors[:metal_level].any?).to be_true
      end
    end

    context "with improper metal_level" do
      def params; valid_params.deep_merge({metal_level: bad_metal_level}); end
      it "should fail validation with improper metal_level" do
        expect(Plan.create(**params).errors[:metal_level].any?).to be_true
        expect(Plan.create(**params).errors[:metal_level]).to eq [metal_level_error_message]

      end
    end

  end
end

RSpec.describe Plan, type: :model do
  describe "class methods" do
    describe ".monthly_premium" do

      let(:plan) {FactoryGirl.create(:plan_with_premium_tables)}
      let(:plan1) {FactoryGirl.create(:plan_with_premium_tables)}
      let(:premium_table) { plan.premium_tables.last }
      let(:year) { plan.active_year }
      let(:hios_id) { plan.hios_id }
      let(:insured_age) { plan.premium_tables.last.age }
      let(:coverage_begin_date) { "03/01/2015" }
      let(:premium) { plan.premium_tables.last.cost }

      context "with invalid parameters" do
        pending "TODO"
      end

      context "with correct parameters" do
        before(:each){ Rails.cache.clear }

        it "should return the correct monthly premium" do
          expect(Plan.monthly_premium(year, hios_id, insured_age, coverage_begin_date)).to eq [{age: insured_age, cost: premium}]
        end

        it "should return the correct monthly premium" do
          plan1.hios_id = hios_id
          plan1.premium_tables.create(age: insured_age, cost: premium, start_on: "02/20/2015", end_on: "03/09/2015")
          plan1.premium_tables.create(age: insured_age+20, cost: premium, start_on: "02/20/2015", end_on: "03/09/2015")
          plan1.save

          expect(Plan.monthly_premium(plan1.active_year, hios_id, [insured_age, insured_age+20], coverage_begin_date)).to eq [{age: insured_age, cost: premium}, {age: insured_age+20, cost: premium}]
        end
      end
    end
  end
end
