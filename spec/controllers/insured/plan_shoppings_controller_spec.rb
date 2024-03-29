require 'rails_helper'

RSpec.describe Insured::PlanShoppingsController, :type => :controller do
  let(:plan) { double(id: "plan_id") }
  let(:hbx_enrollment) { double(id: "hbx_id") }
  let(:benefit_group) {double}
  let(:reference_plan) {double}
  let(:usermailer) {double}
  let(:person) { FactoryGirl.create(:person) }
  let(:user) { FactoryGirl.create(:user, person: person) }
  let(:employee_role) { EmployeeRole.new }
  let(:household) {double(hbx_enrollments: hbx_enrollments)}
  let(:hbx_enrollments) {double}

  context "POST checkout" do
    before do
      allow(Plan).to receive(:find).with("plan_id").and_return(plan)
      allow(HbxEnrollment).to receive(:find).with("hbx_id").and_return(hbx_enrollment)
      allow(hbx_enrollment).to receive(:plan=).with(plan).and_return(true)
      allow(hbx_enrollment).to receive(:benefit_group).and_return(benefit_group)
      allow(benefit_group).to receive(:reference_plan).and_return(:reference_plan)
      allow(PlanCostDecorator).to receive(:new).and_return(true)
      allow(hbx_enrollment).to receive(:may_select_coverage?).and_return(true)
      allow(hbx_enrollment).to receive(:select_coverage!).and_return(true)
      allow(hbx_enrollment).to receive(:save).and_return(true)
      allow(UserMailer).to receive(:plan_shopping_completed).and_return(usermailer)
      allow(usermailer).to receive(:deliver_now).and_return(true)
      allow(hbx_enrollment).to receive(:employee_role).and_return(employee_role)
      allow(employee_role).to receive(:hired_on).and_return(TimeKeeper.date_of_record + 10.days)
      allow(hbx_enrollment).to receive(:update_current).and_return(true)
      allow(hbx_enrollment).to receive(:inactive_related_hbxs).and_return(true)
    end

    it "returns http success" do
      sign_in
      post :checkout, id: "hbx_id", plan_id: "plan_id"
      expect(response).to have_http_status(:redirect)
    end

    context "employee hire_on date greater than enrollment date" do
      it "fails" do
        sign_in
        post :checkout, id: "hbx_id", plan_id: "plan_id"
        expect(flash[:error]).to include("You are attempting to purchase coverage prior to your date of hire on record. Please contact your Employer for assistance")
      end
    end
  end

  context "GET receipt" do

    let(:user) { double("User") }
    let(:enrollment) { double("HbxEnrollment") }
    let(:plan) { double("Plan") }
    let(:benefit_group) { double("BenefitGroup") }
    let(:reference_plan) { double("Plan") }
    let(:employee_role) { double("EmployeeRole") }

    before do
      allow(user).to receive(:person).and_return(person)
      allow(HbxEnrollment).to receive(:find).with("id").and_return(enrollment)
      allow(enrollment).to receive(:plan).and_return(plan)
      allow(enrollment).to receive(:benefit_group).and_return(benefit_group)
      allow(enrollment).to receive(:employee_role).and_return(employee_role)
      allow(benefit_group).to receive(:reference_plan).and_return(reference_plan)
      allow(enrollment).to receive(:employee_role).and_return(double)
      allow(PlanCostDecorator).to receive(:new).and_return(true)
    end

    it "returns http success" do
      sign_in(user)
      get :receipt, id: "id"
      expect(response).to have_http_status(:success)
    end
  end

  context "POST thankyou" do

    let(:enrollment) { double("HbxEnrollment") }
    let(:plan) { double("Plan") }
    let(:benefit_group) { double("BenefitGroup") }
    let(:reference_plan) { double("Plan") }
    let(:family) { double("Family") }
    let(:plan_year) { double("PlanYear") }

    before do
      allow(user).to receive(:person).and_return(person)
      allow(HbxEnrollment).to receive(:find).with("id").and_return(enrollment)
      allow(Plan).to receive(:find).with("plan_id").and_return(plan)
      allow(enrollment).to receive(:plan).and_return(plan)
      allow(enrollment).to receive(:benefit_group).and_return(benefit_group)
      allow(benefit_group).to receive(:reference_plan).and_return(reference_plan)
      allow(PlanCostDecorator).to receive(:new).and_return(true)
      allow(person).to receive(:primary_family).and_return(family)
      allow(enrollment).to receive(:can_complete_shopping?).and_return(true)
      allow(enrollment).to receive(:employee_role).and_return(double)
      allow(benefit_group).to receive(:plan_year).and_return(plan_year)
      allow(plan_year).to receive(:is_eligible_to_enroll?).and_return(true)
    end

    it "returns http success" do
      sign_in(user)
      post :thankyou, id: "id", plan_id: "plan_id"
      expect(response).to have_http_status(:success)
    end

    it "should be enrollable" do
      sign_in(user)
      post :thankyou, id: "id", plan_id: "plan_id"
      expect(assigns(:enrollable)).to be_truthy
    end

    it "should be waivable" do
      sign_in(user)
      post :thankyou, id: "id", plan_id: "plan_id"
      expect(assigns(:waivable)).to be_truthy
    end

    it "returns http success as BROKER" do
      person = create(:person)
      f=FactoryGirl.create(:family,:family_members=>[{:is_primary_applicant=>true, :is_active=>true, :person_id => person.id}])
      current_broker_user = FactoryGirl.create(:user, :roles => ['broker_agency_staff'],
        :person => person )
      current_broker_user.person.broker_role = BrokerRole.new({:broker_agency_profile_id => 99})
      allow(session).to receive(:[]).and_return(person.id.to_s)
      sign_in(current_broker_user)
      post :thankyou, id: "id", plan_id: "plan_id"
      expect(response).to have_http_status(:success)
    end

    context "when not eligible to complete shopping" do
      before do
        allow(enrollment).to receive(:can_complete_shopping?).and_return(false)
      end

      it "should not be enrollable" do
        sign_in(user)
        post :thankyou, id: "id", plan_id: "plan_id"
        expect(assigns(:enrollable)).to be_falsey
      end

      it "should not be waivable" do
        sign_in(user)
        post :thankyou, id: "id", plan_id: "plan_id"
        expect(assigns(:waivable)).to be_falsey
      end
    end
  end

  context "GET print_waiver" do
    let(:enrollment){ double(:HbxEnrollment) }

    it "should return hbx_enrollment to print waiver" do
      allow(user).to receive(:person).and_return(person)
      allow(HbxEnrollment).to receive(:find).with("id").and_return(enrollment)
      sign_in(user)
      get :print_waiver, id: "id"
      expect(response).to have_http_status(:success)
    end
  end


  context "POST terminate" do
    before do
      allow(HbxEnrollment).to receive(:find).with("hbx_id").and_return(hbx_enrollment)
      allow(hbx_enrollment).to receive(:may_terminate_coverage?).and_return(true)
      #allow(hbx_enrollment).to receive(:terminate_coverage!).and_return(true)
      allow(hbx_enrollment).to receive(:update_current).and_return(true)
      allow(hbx_enrollment).to receive(:propogate_terminate).and_return(true)
      sign_in
    end

    it "returns http success" do
      post :terminate, id: "hbx_id"
      expect(response).to be_redirect
    end

    it "goes back" do
      request.env["HTTP_REFERER"] = terminate_insured_plan_shopping_url(1)
      allow(hbx_enrollment).to receive(:may_terminate_coverage?).and_return(false)
      post :terminate, id: "hbx_id"
      expect(response).to redirect_to(:back)
    end
  end

  context "POST waive" do
    before :each do
      allow(HbxEnrollment).to receive(:find).with("hbx_id").and_return(hbx_enrollment)
      allow(hbx_enrollment).to receive(:may_waive_coverage?).and_return(true)
      allow(hbx_enrollment).to receive(:update_current).and_return(true)
      allow(hbx_enrollment).to receive(:propogate_waiver).and_return(true)
      sign_in user
    end

    it "should get success flash message" do
      allow(hbx_enrollment).to receive(:valid?).and_return(true)
      allow(hbx_enrollment).to receive(:save).and_return(true)
      allow(hbx_enrollment).to receive(:waive_coverage).and_return(true)
      allow(hbx_enrollment).to receive(:waiver_reason=).with("waiver").and_return(true)
      post :waive, id: "hbx_id", waiver_reason: "waiver"
      expect(flash[:notice]).to eq "Waive Successful"
      expect(response).to be_redirect
    end

    it "should get failure flash message" do
      allow(hbx_enrollment).to receive(:valid?).and_return(false)
      post :waive, id: "hbx_id", waiver_reason: "waiver"
      expect(flash[:alert]).to eq "Waive Failure"
      expect(response).to be_redirect
    end
  end

  context "GET show" do
    let(:plan1) {double(id: '10', deductible: '$10', total_employee_cost: 1000, carrier_profile_id: '12345')}
    let(:plan2) {double(id: '11', deductible: '$20', total_employee_cost: 2000, carrier_profile_id: '12346')}
    let(:plan3) {double(id: '12', deductible: '$30', total_employee_cost: 3000, carrier_profile_id: '12347')}
    
    before :each do
      allow(HbxEnrollment).to receive(:find).with("hbx_id").and_return(hbx_enrollment)
      allow(hbx_enrollment).to receive(:benefit_group).and_return(benefit_group)
      allow(benefit_group).to receive(:reference_plan).and_return(reference_plan)
      allow(benefit_group).to receive(:plan_option_kind).and_return("single_plan")
      allow(benefit_group).to receive(:decorated_elected_plans).with(hbx_enrollment).and_return([plan1, plan2, plan3])
      allow(hbx_enrollment).to receive(:can_complete_shopping?).and_return(true)
      sign_in user
    end

    context "normal" do
      before :each do
        allow(plan3).to receive(:total_employee_cost).and_return(3333)
        allow(plan3).to receive(:deductible).and_return("$998")
        get :show, id: "hbx_id"
      end

      it "should be success" do
        expect(response).to have_http_status(:success)
      end

      it "should be waivable" do
        expect(assigns(:waivable)).to be_truthy
      end

      it "should get max_total_employee_cost" do
        expect(assigns(:max_total_employee_cost)).to eq 4000
      end

      it "should get max_deductible" do
        expect(assigns(:max_deductible)).to eq 1000
      end

      it "should get plans which order by premium" do
        expect(assigns(:plans)).to eq [plan1, plan2, plan3]
      end
    end

    context "when not eligible to complete shopping" do
      before do
        allow(plan3).to receive(:total_employee_cost).and_return(3333)
        allow(plan3).to receive(:deductible).and_return("$998")
        allow(hbx_enrollment).to receive(:can_complete_shopping?).and_return(false)
        get :show, id: "hbx_id"
      end

      it "should not be waivable" do
        expect(assigns(:waivable)).to be_falsey
      end
    end

    context "when innormal total_employee_cost and deductible" do
      before :each do
        [plan1, plan2, plan3].each do |plan|
          allow(plan).to receive(:total_employee_cost).and_return(nil)
          allow(plan).to receive(:deductible).and_return(nil)
        end
        get :show, id: "hbx_id"
      end

      it "should get max_total_employee_cost and return 0" do
        expect(assigns(:max_total_employee_cost)).to eq 0
      end

      it "should get max_deductible and return 0" do
        expect(assigns(:max_deductible)).to eq 0
      end
    end
  end
end
