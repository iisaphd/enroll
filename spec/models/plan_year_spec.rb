require 'rails_helper'

describe PlanYear, :type => :model, :dbclean => :after_each do
  it { should validate_presence_of :start_on }
  it { should validate_presence_of :end_on }
  it { should validate_presence_of :open_enrollment_start_on }
  it { should validate_presence_of :open_enrollment_end_on }

  let!(:employer_profile)               { FactoryGirl.create(:employer_profile) }
  let(:valid_plan_year_start_on)        { Date.new(2015, 9, 1) }
  let(:valid_plan_year_end_on)          { valid_plan_year_start_on + 1.year - 1.day }
  let(:valid_open_enrollment_start_on)  { Date.new(2015, 8, 1) }
  let(:valid_open_enrollment_end_on)    { valid_open_enrollment_start_on + 9.days }
  let(:valid_fte_count)                 { 5 }
  let(:max_fte_count)                   { HbxProfile::ShopSmallMarketFteCountMaximum }
  let(:invalid_fte_count)               { HbxProfile::ShopSmallMarketFteCountMaximum + 1 }

  let(:valid_params) do
    {
      employer_profile: employer_profile,
      start_on: valid_plan_year_start_on,
      end_on: valid_plan_year_end_on,
      open_enrollment_start_on: valid_open_enrollment_start_on,
      open_enrollment_end_on: valid_open_enrollment_end_on,
      fte_count: valid_fte_count
    }
  end

  context ".new" do
    context "with no arguments" do
      let(:params) {{}}

      it "should not save" do
        expect(PlanYear.new(**params).save).to be_falsey
      end
    end

    context "with no employer profile" do
      let(:params) {valid_params.except(:employer_profile)}

      it "should raise" do
        expect{PlanYear.create(**params)}.to raise_error(Mongoid::Errors::NoParent)
      end
    end

    context "with no start on" do
      let(:params) {valid_params.except(:start_on)}

      it "should fail validation" do
        expect(PlanYear.create(**params).errors[:start_on].any?).to be_truthy
      end
    end

    context "with no end on" do
      let(:params) {valid_params.except(:end_on)}

      it "should fail validation" do
        expect(PlanYear.create(**params).errors[:end_on].any?).to be_truthy
      end
    end

    context "with no open enrollment start on" do
      let(:params) {valid_params.except(:open_enrollment_start_on)}

      it "should fail validation" do
        expect(PlanYear.create(**params).errors[:open_enrollment_start_on].any?).to be_truthy
      end
    end

    context "with no open enrollment end on" do
      let(:params) {valid_params.except(:open_enrollment_end_on)}

      it "should fail validation" do
        expect(PlanYear.create(**params).errors[:open_enrollment_end_on].any?).to be_truthy
      end
    end

    context "with all valid arguments" do
      let(:params) { valid_params }
      let(:plan_year) { PlanYear.new(**params) }

      it "should save" do
        expect(plan_year.save).to be_truthy
      end

      context "and it is saved" do
        let!(:saved_plan_year) do
          py = plan_year
          py.save
          py
        end

        it "should be findable" do
          expect(PlanYear.find(saved_plan_year.id).id.to_s).to eq saved_plan_year.id.to_s
        end
      end
    end
  end

  context "a new plan year is initialized" do
    let(:plan_year) { PlanYear.new(**valid_params) }

    it "census employees should not be matchable" do
      expect(plan_year.is_eligible_to_match_census_employees?).to be_falsey
    end

    context "and effective date is specified and effective date doesn't provide enough time for enrollment" do
      let(:prior_month_open_enrollment_start)  { TimeKeeper.date_of_record.beginning_of_month + HbxProfile::ShopOpenEnrollmentEndDueDayOfMonth.days - HbxProfile::ShopOpenEnrollmentPeriodMinimum.days - 1.day}
      let(:invalid_effective_date)   { (prior_month_open_enrollment_start + 1.month).beginning_of_month }
      before do
        plan_year.effective_date = invalid_effective_date
        plan_year.end_on = invalid_effective_date + HbxProfile::ShopPlanYearPeriodMinimum
      end

      context "and an employer is submitting the effective date" do
        it "should be invalid" do
          expect(plan_year.valid?).to be_falsey
        end
      end

      context "and an HbxAdmin or system service is submitting the effective date" do
        # TODO: how do we know an HbxAdmin is making the change at the model level?
        it "should be valid"
      end
    end

    context "and effective date is specified and effective date does provide enough time for enrollment" do
      let(:prior_month_open_enrollment_start)  { TimeKeeper.date_of_record.beginning_of_month + HbxProfile::ShopOpenEnrollmentEndDueDayOfMonth.days - HbxProfile::ShopOpenEnrollmentPeriodMinimum.days - 1.day}
      let(:valid_effective_date)   { (prior_month_open_enrollment_start + 3.months).beginning_of_month }
      before do
        plan_year.effective_date = valid_effective_date
        plan_year.end_on = valid_effective_date + HbxProfile::ShopPlanYearPeriodMinimum
      end

      it "should be valid" do
        expect(plan_year.valid?).to be_truthy
      end

    end

    context "and an open enrollment period is specified" do
      context "and open enrollment start date is after the end date" do
        let(:open_enrollment_end_on)    { TimeKeeper.date_of_record }
        let(:open_enrollment_start_on)  { open_enrollment_end_on + 1 }

        before do
          plan_year.open_enrollment_start_on = open_enrollment_start_on
          plan_year.open_enrollment_end_on = open_enrollment_end_on
        end

        it "should fail validation" do
          expect(plan_year.valid?).to be_falsey
          expect(plan_year.errors[:open_enrollment_end_on].any?).to be_truthy
        end
      end

      context "and the open enrollment period is too short" do
        let(:invalid_length)  { HbxProfile::ShopOpenEnrollmentPeriodMinimum - 1 }
        let(:open_enrollment_start_on)  { TimeKeeper.date_of_record }
        let(:open_enrollment_end_on)    { open_enrollment_start_on + invalid_length }

        before do
          plan_year.open_enrollment_start_on = open_enrollment_start_on
          plan_year.open_enrollment_end_on = open_enrollment_end_on
        end

        it "should fail validation" do
          expect(plan_year.valid?).to be_falsey
          expect(plan_year.errors[:open_enrollment_end_on].any?).to be_truthy
        end
      end

      context "and the open enrollment period is too long" do
        let(:invalid_length)  { HbxProfile::ShopOpenEnrollmentPeriodMaximum + 1 }
        let(:open_enrollment_start_on)  { TimeKeeper.date_of_record }
        let(:open_enrollment_end_on)    { open_enrollment_start_on + invalid_length }

        before do
          plan_year.open_enrollment_start_on = open_enrollment_start_on
          plan_year.open_enrollment_end_on = open_enrollment_end_on
        end

        it "should fail validation" do
          expect(plan_year.valid?).to be_falsey
          expect(plan_year.errors[:open_enrollment_end_on].any?).to be_truthy
        end
      end

      context "and a plan year start and end is specified" do
        context "and the plan year start date isn't first day of month" do
          let(:start_on)  { TimeKeeper.date_of_record.beginning_of_month + 1 }
          let(:end_on)    { start_on + HbxProfile::ShopPlanYearPeriodMinimum }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:start_on].any?).to be_truthy
          end
        end

        context "and the plan year start date is after the end date" do
          let(:end_on)    { TimeKeeper.date_of_record.beginning_of_month }
          let(:start_on)  { end_on + 1 }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:end_on].any?).to be_truthy
          end
        end

        context "and the plan year period is too short" do
          let(:invalid_length)  { HbxProfile::ShopPlanYearPeriodMinimum - 1.day }
          let(:start_on)  { TimeKeeper.date_of_record.end_of_month + 1 }
          let(:end_on)    { start_on + invalid_length }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:end_on].any?).to be_truthy
          end
        end

        context "and the plan year period is too long" do
          let(:invalid_length)  { HbxProfile::ShopPlanYearPeriodMaximum + 1.day }
          let(:start_on)  { TimeKeeper.date_of_record.end_of_month + 1 }
          let(:end_on)    { start_on + invalid_length }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:end_on].any?).to be_truthy
          end
        end

        context "and the plan year begins before open enrollment ends" do
          let(:valid_open_enrollment_length)  { HbxProfile::ShopOpenEnrollmentPeriodMaximum }
          let(:valid_plan_year_length)  { HbxProfile::ShopPlanYearPeriodMaximum }
          let(:open_enrollment_start_on)  { TimeKeeper.date_of_record }
          let(:open_enrollment_end_on)    { open_enrollment_start_on + valid_open_enrollment_length }
          let(:start_on)  { open_enrollment_start_on - 1 }
          let(:end_on)    { start_on + valid_plan_year_length }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:start_on].any?).to be_truthy
          end
        end

        context "and the effective date is too far in the future" do
          let(:invalid_initial_application_date)  { TimeKeeper.date_of_record + HbxProfile::ShopPlanYearPublishBeforeEffectiveDateMaximum.months + 1.month }
          let(:schedule)  { PlanYear.shop_enrollment_timetable(invalid_initial_application_date) }
          let(:start_on)  { schedule[:plan_year_start_on] }
          let(:end_on)    { schedule[:plan_year_end_on] }
          let(:open_enrollment_start_on) { schedule[:open_enrollment_earliest_start_on] }
          let(:open_enrollment_end_on)   { schedule[:open_enrollment_latest_end_on] }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
            plan_year.open_enrollment_start_on = open_enrollment_start_on
            plan_year.open_enrollment_end_on = open_enrollment_end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:start_on].any?).to be_truthy
            expect(plan_year.errors[:start_on].first).to match(/may not start application before/)
          end
        end

        context "and the end of open enrollment is past deadline for effective date" do
          let(:schedule)  { PlanYear.shop_enrollment_timetable(TimeKeeper.date_of_record) }
          let(:start_on)  { schedule[:plan_year_start_on] }
          let(:end_on)    { schedule[:plan_year_end_on] }
          let(:open_enrollment_start_on) { schedule[:open_enrollment_latest_start_on] }
          let(:open_enrollment_end_on)   { schedule[:open_enrollment_latest_end_on] + 1 }

          before do
            plan_year.start_on = start_on
            plan_year.end_on = end_on
            plan_year.open_enrollment_start_on = open_enrollment_start_on
            plan_year.open_enrollment_end_on = open_enrollment_end_on
          end

          it "should fail validation" do
            expect(plan_year.valid?).to be_falsey
            expect(plan_year.errors[:open_enrollment_end_on].any?).to be_truthy
            expect(plan_year.errors[:open_enrollment_end_on].first).to match(/open enrollment must end on or before/)
          end
        end
      end
    end
  end

  ## Initial application workflow process

  context "an employer prepares an initial plan year application" do
    let(:workflow_plan_year) { PlanYear.new(**valid_params) }

    it "plan year should be in draft state" do
      expect(workflow_plan_year.aasm_state).to eq "draft"
    end

    ## Application Errors
    context "and application is submitted with NO benefit groups defined" do
      before { workflow_plan_year.publish! }

      it "application should NOT be publishable" do
        expect(workflow_plan_year.is_application_unpublishable?).to be_truthy
      end

      it "and should provide relevent warning message" do
        expect(workflow_plan_year.application_errors[:benefit_groups].present?).to be_truthy
        expect(workflow_plan_year.application_errors[:benefit_groups]).to match(/You must create at least one benefit group/)
      end

      it "should be in draft status" do
        expect(workflow_plan_year.aasm_state).to eq "draft"
      end
    end

    context "and application is submitted with a benefit group defined" do
      let(:benefit_group) { FactoryGirl.build(:benefit_group) }
      let(:workflow_plan_year_with_benefit_group) do
        py = PlanYear.new(**valid_params)
        py.employer_profile = employer_profile
        py.benefit_groups = [benefit_group]
        py.save
        py
      end

      context "and at least one employee is present on the roster sans assigned benefit group" do
        let!(:census_employee_no_benefit_group)   { FactoryGirl.create(:census_employee, employer_profile: employer_profile) }

        it "census employee has no benefit group assignment and employer profile is the same as plan year's" do
          expect(census_employee_no_benefit_group.benefit_group_assignments).to eq []
          expect(census_employee_no_benefit_group.employer_profile).to eq workflow_plan_year_with_benefit_group.employer_profile
        end

        it "application should NOT be publishable" do
          expect(workflow_plan_year_with_benefit_group.is_application_unpublishable?).to be_truthy
        end

        it "and should provide relevent warning message" do
          expect(workflow_plan_year_with_benefit_group.application_errors[:benefit_groups].present?).to be_truthy
          expect(workflow_plan_year_with_benefit_group.application_errors[:benefit_groups]).to match(/Every employee must be assigned to a benefit group/)
        end
      end

      context "and no employees on the roster" do
        before do
          workflow_plan_year_with_benefit_group.publish!
        end

        it "application should be publishable" do
          expect(workflow_plan_year_with_benefit_group.is_application_unpublishable?).to be_falsey
        end

        it "plan year should be in published state" do
          expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "published"
        end
      end

      context "and another published application for this employer exists for same plan year" do
        let(:published_plan_year)       { FactoryGirl.build(:plan_year, aasm_state: :published)}
        let(:published_benefit_group)   { FactoryGirl.build(:benefit_group) }

        before do
          published_plan_year.benefit_groups << published_benefit_group
          employer_profile.plan_years << published_plan_year
          published_plan_year.save
          employer_profile.save
        end

        it "second plan year application should NOT be publishable" do
          expect(workflow_plan_year_with_benefit_group.is_application_unpublishable?).to be_truthy
        end

        it "and should provide relevent error message" do
          expect(workflow_plan_year_with_benefit_group.application_errors[:publish].present?).to be_truthy
          expect(workflow_plan_year_with_benefit_group.application_errors[:publish]).to match(/You may only have one published plan year at a time/)
        end
      end

      context "and employer profile is in enrollment ineligible state" do
        before do
          employer_profile.plan_years = [workflow_plan_year_with_benefit_group]
          employer_profile.aasm_state = :enrollment_ineligible
        end

        it "application should NOT be publishable" do
          expect(workflow_plan_year_with_benefit_group.is_application_unpublishable?).to be_truthy
        end

        it "and should provide relevent warning message" do
          expect(workflow_plan_year_with_benefit_group.application_errors[:employer_profile].present?).to be_truthy
          expect(workflow_plan_year_with_benefit_group.application_errors[:employer_profile]).to match(/This employer is ineligible to enroll for coverage at this time/)
        end
      end

      ## Application Eligibility Warnings
      context "and employer's primary office isn't located in-state" do
        before do
          workflow_plan_year_with_benefit_group.employer_profile.organization.primary_office_location.address.state = "AK"
        end

        it "application should not be valid" do
          expect(workflow_plan_year_with_benefit_group.is_application_valid?).to be_falsey
        end

        it "and should provide relevent warning message" do
          expect(workflow_plan_year_with_benefit_group.application_eligibility_warnings[:primary_office_location].present?).to be_truthy
          expect(workflow_plan_year_with_benefit_group.application_eligibility_warnings[:primary_office_location]).to match(/Primary office must be located/)
        end
      end

      context "and the number of FTEs exceeds the maximum size on initial application" do
        before do
          workflow_plan_year_with_benefit_group.fte_count = invalid_fte_count
          workflow_plan_year_with_benefit_group.publish
        end

        it "application should not be valid" do
          expect(workflow_plan_year_with_benefit_group.is_application_valid?).to be_falsey
        end

        it "and should provide relevent warning message" do
          expect(workflow_plan_year_with_benefit_group.application_eligibility_warnings[:fte_count].present?).to be_truthy
          expect(workflow_plan_year_with_benefit_group.application_eligibility_warnings[:fte_count]).to match(/Number of full time equivalents/)
        end

        it "and plan year should be in publish pending state" do
          expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "publish_pending"
        end
      end

      context "and the employer contribution amount is below minimum" do
        let(:invalid_relationship_benefit)  { RelationshipBenefit.new(
                                                relationship: :employee,
                                                offered: true,
                                                premium_pct: HbxProfile::ShopEmployerContributionPercentMinimum - 1
                                              ) }

        let(:invalid_benefit_group)         { FactoryGirl.build(:benefit_group,
                                                relationship_benefits: [invalid_relationship_benefit]
                                              ) }
        let(:invalid_plan_year)             { PlanYear.new(**valid_params) }

        context "and the effective date isn't January 1" do
          before do
            invalid_plan_year.benefit_groups << invalid_benefit_group
            invalid_plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year + 1.month
            invalid_plan_year.publish
          end

          it "application should not be valid" do
            expect(invalid_plan_year.is_application_valid?).to be_falsey
          end

          it "and should provide relevent warning message" do
            expect(invalid_plan_year.application_eligibility_warnings[:minimum_employer_contribution].present?).to be_truthy
            expect(invalid_plan_year.application_eligibility_warnings[:minimum_employer_contribution]).to match(/Employer contribution percent/)
          end

          it "and plan year should be in publish pending state" do
            expect(invalid_plan_year.publish_pending?).to be_truthy
          end
        end

        context "and the effective date is January 1" do
          before do
            invalid_plan_year.benefit_groups << invalid_benefit_group
            invalid_plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year
            invalid_plan_year.publish
          end

          it "application should be valid" do
            expect(invalid_plan_year.is_application_valid?).to be_truthy
          end

          it "and plan year should be in published state" do
            expect(invalid_plan_year.published?).to be_truthy
          end
        end
      end

      context "and applicant submits plan year application with eligibility errors" do
        before do
          workflow_plan_year_with_benefit_group.employer_profile.organization.primary_office_location.address.state = "AK"
          workflow_plan_year_with_benefit_group.publish!
        end

        it "application should not be valid" do
          expect(workflow_plan_year_with_benefit_group.is_application_valid?).to be_falsey
        end

        it "should transition into publish pending status" do
          expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "publish_pending"
        end

        it "should record state transition and timestamp" do
          expect(workflow_plan_year_with_benefit_group.latest_workflow_state_transition.from_state).to eq "draft"
          expect(workflow_plan_year_with_benefit_group.latest_workflow_state_transition.to_state).to eq "publish_pending"
          expect(workflow_plan_year_with_benefit_group.latest_workflow_state_transition.transition_at.utc).to be_within(1.second).of(DateTime.now)
        end

        context "and the applicant chooses to cancel application submission" do
          before { workflow_plan_year_with_benefit_group.withdraw_pending! }

          it "should transition plan year application back to draft status" do
            expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "draft"
          end
        end

        context "and the applicant chooses to submit with application eligibility warnings" do
          let(:submit_date) { TimeKeeper.date_of_record }

          before { workflow_plan_year_with_benefit_group.force_publish! }

          it "should transition plan year application into publish_invalid status" do
            expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "publish_invalid"
          end

          it "should transition applicant employer profile into enrollment enrollment_ineligible status" do
            expect(employer_profile.aasm_state).to eq "enrollment_ineligible"
          end

          context "and the employer doesn't request eligibility review" do
            context "and 90 days have elapsed since the ineligible application was submitted" do
              before do
                TimeKeeper.set_date_of_record_unprotected!(submit_date + 90.days)
                TimeKeeper.instance.push_date_of_record
              end

              it "should transition employer profile to applicant status" do
                expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq "applicant"
              end
            end
          end

          context "and the applicant requests eligibility review" do
            context "and 30 days or less have elapsed since application was submitted" do
              before do
                TimeKeeper.set_date_of_record_unprotected!(submit_date + 10.days)
                workflow_plan_year_with_benefit_group.request_eligibility_review!
              end

              it "should transition into review status" do
                expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "eligibility_review"
              end

              context "and review overturns ineligible application determination" do
                before { workflow_plan_year_with_benefit_group.grant_eligibility! }

                it "should transition application into published status" do
                  expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "published"
                end

                it "should transition employer profile into registered status" do
                  expect(employer_profile.aasm_state).to eq "registered"
                end
              end

              context "and review affirms ineligible application determination" do
                before { workflow_plan_year_with_benefit_group.deny_eligibility! }

                it "should transition application back into publish_invalid status" do
                  expect(workflow_plan_year_with_benefit_group.aasm_state).to eq "publish_invalid"
                end
              end
            end

            context "and more than 30 days have elapsed since application was submitted" do
              before do
                TimeKeeper.set_date_of_record_unprotected!(submit_date + 31.days)
              end

              it "should not be able to request eligibility review" do
                expect {workflow_plan_year_with_benefit_group.request_eligibility_review!}.to raise_error(AASM::InvalidTransition)
              end

              context "and 90 days have elapsed since the ineligible application was submitted" do
                before do
                  TimeKeeper.set_date_of_record_unprotected!(submit_date + HbxProfile::ShopApplicationIneligiblePeriodMaximum)
                  TimeKeeper.instance.push_date_of_record
                end

                it "should transition employer to applicant status" do
                  expect(EmployerProfile.find(employer_profile.id).aasm_state).to eq "applicant"
                end
              end
            end
          end
        end
      end


      # Proceed with enrollment
      context "and employer submits a valid plan year application with today as start open enrollment" do
        before do
          TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record.beginning_of_month.next_month + 8.days)
          workflow_plan_year_with_benefit_group.open_enrollment_start_on = TimeKeeper.date_of_record + 1.day
          workflow_plan_year_with_benefit_group.open_enrollment_end_on = TimeKeeper.date_of_record + 5.days
          workflow_plan_year_with_benefit_group.start_on = TimeKeeper.date_of_record.beginning_of_month.next_month
          workflow_plan_year_with_benefit_group.end_on = workflow_plan_year_with_benefit_group.start_on + 1.year - 1.day
          TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record + 1.day)
          workflow_plan_year_with_benefit_group.publish!
        end

        it "should transition directly to enrolling state" do
          expect(workflow_plan_year_with_benefit_group.aasm_state).to eq("enrolling")
        end

        context "and today is the day following close of open enrollment" do
          before do
            TimeKeeper.set_date_of_record_unprotected!(workflow_plan_year_with_benefit_group.open_enrollment_end_on + 1.day)
          end

          context "and enrollment non-owner participation minimum not met" do
            let(:invalid_non_owner_count) { HbxProfile::ShopEnrollmentNonOwnerParticipationMinimum - 1 }
            let!(:owner_census_employee) { FactoryGirl.create(:census_employee, :owner, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
            let!(:non_owner_census_families) { FactoryGirl.create_list(:census_employee, invalid_non_owner_count, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }

            before do
              owner_census_employee.add_benefit_group_assignment(benefit_group, workflow_plan_year_with_benefit_group.start_on)
              owner_census_employee.save!
              # non_owner_census_families.each do |census_employee|
              #   owner_census_employee.add_benefit_group_assignment(benefit_group, plan_year.start_on)
              #   owner_census_employee.save!
              # end
              TimeKeeper.set_date_of_record_unprotected!(workflow_plan_year_with_benefit_group.open_enrollment_end_on + 1.day)
              TimeKeeper.instance.push_date_of_record
              # workflow_plan_year_with_benefit_group.advance_enrollment_date
            end

            it "enrollment should be invalid" do
              expect(workflow_plan_year_with_benefit_group.is_enrollment_valid?).to be_falsey
              expect(workflow_plan_year_with_benefit_group.enrollment_errors[:non_business_owner_enrollment_count].present?).to be_truthy
              expect(workflow_plan_year_with_benefit_group.enrollment_errors[:non_business_owner_enrollment_count]).to match(/non-owner employee must enroll/)
            end

            it "should advance state to canceled" do
              expect(PlanYear.find(workflow_plan_year_with_benefit_group.id).canceled?).to be_truthy
            end
          end

          # context "and enrollment the minimum enrollment ratio isn't met" do
          #   let!(:non_owner_census_families) { FactoryGirl.create_list(:census_employee, 1, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
          #
          #   before do
          #     non_owner_census_families.each do |census_employee|
          #       census_employee.add_benefit_group_assignment(benefit_group, workflow_plan_year_with_benefit_groupstart_on)
          #       census_employee.save!
          #     end
          #   end
          #
          #   context "and the effective date is January 1" do
          #     before do
          #       workflow_plan_year_with_benefit_groupstart_on = TimeKeeper.date_of_record.beginning_of_year
          #       non_owner_census_families.each do |census_employee|
          #         benefit_group_assignment = census_employee.benefit_group_assignments.first
          #         benefit_group_assignment.start_on = workflow_plan_year_with_benefit_groupstart_on
          #         hbx_enrollment = instance_double("HbxEnrollment", :_id => 12345, :benefit_group_id => benefit_group.id, :employee_role_id => census_employee.employee_role_id)
          #         allow(hbx_enrollment).to receive(:is_a?).with(HbxEnrollment).and_return(true)
          #         benefit_group_assignment.hbx_enrollment = hbx_enrollment
          #         benefit_group_assignment.select_coverage
          #         census_employee.save!
          #       end
          #       employer_profile.advance_enrollment_date
          #     end
          #
          #     it "enrollment should be valid" do
          #       expect(workflow_plan_year_with_benefit_groupis_enrollment_valid?).to be_truthy
          #     end
          #
          #     it "should advance state to binder pending" do
          #       expect(employer_profile.binder_pending?).to be_truthy
          #     end
          #   end
          #
          #   context "and the effective date isn't January 1" do
          #     before do
          #       workflow_plan_year_with_benefit_groupstart_on = TimeKeeper.date_of_record.beginning_of_year.next_month
          #       non_owner_census_families.each do |census_employee|
          #         census_employee.benefit_group_assignments.first.start_on = workflow_plan_year_with_benefit_groupstart_on
          #         census_employee.save!
          #       end
          #
          #       employer_profile.advance_enrollment_date
          #     end
          #
          #     it "enrollment should be invalid" do
          #       expect(workflow_plan_year_with_benefit_groupis_enrollment_valid?).to be_falsey
          #       expect(workflow_plan_year_with_benefit_groupenrollment_errors[:enrollment_ratio].present?).to be_truthy
          #       expect(workflow_plan_year_with_benefit_groupenrollment_errors[:enrollment_ratio]).to match(/less than minimum required/)
          #     end
          #
          #     it "should advance state to canceled" do
          #       expect(workflow_plan_year_with_benefit_group.canceled?).to be_truthy
          #     end
          #   end
          # end
          #
          # context "and the number of enrollments for first month is 0" do
          #   it "should be compliant"
          #   it "should advance to enrolled state without requirement for binder premium"
          # end
        end
      end

    end
  end

  # context "has registered and enters initial application process" do
  #   let(:benefit_group)         { FactoryGirl.build(:benefit_group)}
  #   let(:plan_year)             { FactoryGirl.build(:plan_year, benefit_groups: [benefit_group]) }
  #   let!(:employer_profile)     { EmployerProfile.new(**valid_params, plan_years: [plan_year]) }
  #   let(:min_non_owner_count )  { HbxProfile::ShopEnrollmentNonOwnerParticipationMinimum }
  #
  #   it "should initialize in applicant status" do
  #     expect(employer_profile.applicant?).to be_truthy
  #   end
  #
  #   context "a plan year application is submitted with tomorrow as start open enrollment" do
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record.beginning_of_month.next_month + 8.days)
  #       plan_year.open_enrollment_start_on = TimeKeeper.date_of_record + 1.day
  #       plan_year.open_enrollment_end_on = TimeKeeper.date_of_record + 5.days
  #       plan_year.start_on = TimeKeeper.date_of_record.beginning_of_month.next_month
  #       plan_year.end_on = plan_year.start_on + 1.year - 1.day
  #       plan_year.publish!
  #     end
  #
  #     it "should transition to registered state" do
  #       expect(employer_profile.registered?).to be_truthy
  #     end
  #   end
  #
  #   context "and employer submits a valid plan year application with today as start open enrollment" do
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record.beginning_of_month.next_month + 8.days)
  #       plan_year.open_enrollment_start_on = TimeKeeper.date_of_record + 1.day
  #       plan_year.open_enrollment_end_on = TimeKeeper.date_of_record + 5.days
  #       plan_year.start_on = TimeKeeper.date_of_record.beginning_of_month.next_month
  #       plan_year.end_on = plan_year.start_on + 1.year - 1.day
  #       TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record + 1.day)
  #       plan_year.publish!
  #     end
  #
  #     it "should transition directly to enrolling state" do
  #       expect(employer_profile.aasm_state).to eq("enrolling")
  #     end
  #
  #     context "and employer has enrolled" do
  #
  #       context "and today is the day following close of open enrollment" do
  #         before do
  #           TimeKeeper.set_date_of_record_unprotected!(plan_year.open_enrollment_end_on + 1.day)
  #         end
  #
  #         context "and employer's enrollment is non-compliant" do
  #
  #           context "because enrollment non-owner participation minimum not met" do
  #             let(:invalid_non_owner_count) { min_non_owner_count - 1 }
  #             let!(:owner_census_employee) { FactoryGirl.create(:census_employee, :owner, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
  #             let!(:non_owner_census_families) { FactoryGirl.create_list(:census_employee, invalid_non_owner_count, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
  #
  #             before do
  #               owner_census_employee.add_benefit_group_assignment(benefit_group, plan_year.start_on)
  #               owner_census_employee.save!
  #               # non_owner_census_families.each do |census_employee|
  #               #   owner_census_employee.add_benefit_group_assignment(benefit_group, plan_year.start_on)
  #               #   owner_census_employee.save!
  #               # end
  #
  #               employer_profile.advance_enrollment_date
  #             end
  #
  #             it "enrollment should be invalid" do
  #               expect(plan_year.is_enrollment_valid?).to be_falsey
  #               expect(plan_year.enrollment_errors[:non_business_owner_enrollment_count].present?).to be_truthy
  #               expect(plan_year.enrollment_errors[:non_business_owner_enrollment_count]).to match(/non-owner employee must enroll/)
  #             end
  #
  #             it "should advance state to canceled" do
  #               expect(employer_profile.canceled?).to be_truthy
  #             end
  #           end
  #
  #           context "or the minimum enrollment ratio isn't met" do
  #             let!(:non_owner_census_families) { FactoryGirl.create_list(:census_employee, 1, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
  #
  #             before do
  #               non_owner_census_families.each do |census_employee|
  #                 census_employee.add_benefit_group_assignment(benefit_group, plan_year.start_on)
  #                 census_employee.save!
  #               end
  #             end
  #
  #             context "and the effective date isn't January 1" do
  #               before do
  #                 plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year.next_month
  #                 non_owner_census_families.each do |census_employee|
  #                   census_employee.benefit_group_assignments.first.start_on = plan_year.start_on
  #                   census_employee.save!
  #                 end
  #
  #                 employer_profile.advance_enrollment_date
  #               end
  #
  #               it "enrollment should be invalid" do
  #                 expect(plan_year.is_enrollment_valid?).to be_falsey
  #                 expect(plan_year.enrollment_errors[:enrollment_ratio].present?).to be_truthy
  #                 expect(plan_year.enrollment_errors[:enrollment_ratio]).to match(/less than minimum required/)
  #               end
  #
  #               it "should advance state to canceled" do
  #                 expect(employer_profile.canceled?).to be_truthy
  #               end
  #             end
  #
  #             context "and the effective date is January 1" do
  #               before do
  #                 plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year
  #                 non_owner_census_families.each do |census_employee|
  #                   benefit_group_assignment = census_employee.benefit_group_assignments.first
  #                   benefit_group_assignment.start_on = plan_year.start_on
  #                   hbx_enrollment = instance_double("HbxEnrollment", :_id => 12345, :benefit_group_id => benefit_group.id, :employee_role_id => census_employee.employee_role_id)
  #                   allow(hbx_enrollment).to receive(:is_a?).with(HbxEnrollment).and_return(true)
  #                   benefit_group_assignment.hbx_enrollment = hbx_enrollment
  #                   benefit_group_assignment.select_coverage
  #                   census_employee.save!
  #                 end
  #                 employer_profile.advance_enrollment_date
  #               end
  #
  #               it "enrollment should be valid" do
  #                 expect(plan_year.is_enrollment_valid?).to be_truthy
  #               end
  #
  #               it "should advance state to binder pending" do
  #                 expect(employer_profile.binder_pending?).to be_truthy
  #               end
  #             end
  #           end
  #         end
  #
  #         context "the number of enrollments for first month is 0" do
  #           it "should advance to enrolled state without requirement for binder premium"
  #         end
  #
  #         context "and employer enrollment is compliant when the effective date isn't January 1" do
  #           let!(:non_owner_census_families) { FactoryGirl.create_list(:census_employee, 1, hired_on: (TimeKeeper.date_of_record - 2.years), employer_profile_id: employer_profile.id) }
  #
  #           before do
  #             plan_year.start_on = plan_year.start_on.next_month if plan_year.start_on.month == 1
  #             non_owner_census_families.each do |census_employee|
  #               census_employee.add_benefit_group_assignment(benefit_group, plan_year.start_on)
  #               benefit_group_assignment = census_employee.benefit_group_assignments.first
  #               hbx_enrollment = instance_double("HbxEnrollment", :_id => 12345, :benefit_group_id => benefit_group.id, :employee_role_id => census_employee.employee_role_id)
  #               allow(hbx_enrollment).to receive(:is_a?).with(HbxEnrollment).and_return(true)
  #               benefit_group_assignment.hbx_enrollment = hbx_enrollment
  #               benefit_group_assignment.select_coverage
  #               census_employee.save!
  #             end
  #             employer_profile.advance_enrollment_date!
  #           end
  #
  #           it "enrollment should be valid" do
  #             expect(plan_year.is_enrollment_valid?).to be_truthy
  #           end
  #
  #           it "should advance state to binder pending" do
  #             expect(employer_profile.binder_pending?).to be_truthy
  #           end
  #
  #           it "should initialize a employer profile account" do
  #             expect(employer_profile.employer_profile_account).to be
  #           end
  #
  #           it "should be waiting for binder payment" do
  #             expect(employer_profile.employer_profile_account.binder_pending?).to be_truthy
  #           end
  #
  #           context "and employer doesn't post timely binder payment" do
  #             before do
  #               employer_profile.employer_profile_account.advance_billing_period
  #             end
  #
  #             it "should advance state to canceled" do
  #               expect(employer_profile.employer_profile_account.canceled?).to be_truthy
  #             end
  #           end
  #
  #           context "and employer pays binder premium on timely basis" do
  #             before do
  #               employer_profile.employer_profile_account.allocate_binder_payment
  #             end
  #
  #             it "should transition employer to enrolled" do
  #               expect(employer_profile.enrolled?).to be_truthy
  #             end
  #
  #             context "and enrolled employer enters Dunning process" do
  #               before do
  #                 employer_profile.employer_profile_account.advance_billing_period
  #               end
  #
  #               it "should be in overdue status" do
  #                 expect(employer_profile.employer_profile_account.overdue?)
  #               end
  #
  #               context "and employer pays in full" do
  #                 before do
  #                   employer_profile.employer_profile_account.advance_coverage_period
  #                 end
  #
  #                 it "should transition employer to enrolled" do
  #                   expect(employer_profile.enrolled?).to be_truthy
  #                 end
  #
  #                 it "should be in current status" do
  #                   expect(employer_profile.employer_profile_account.current?).to be_truthy
  #                 end
  #               end
  #
  #               context "and employer transitions into late status" do
  #                 before do
  #                   employer_profile.employer_profile_account.advance_billing_period
  #                 end
  #
  #                 it "should be in late status" do
  #                   expect(employer_profile.employer_profile_account.late?).to be_truthy
  #                 end
  #
  #                 it "should transmit notice to employer"
  #
  #                 it "should transmit notice to broker"
  #
  #                 it "should transmit notices to all employees"
  #
  #                 context "and employer pays in full" do
  #                   before do
  #                     employer_profile.employer_profile_account.advance_coverage_period
  #                   end
  #
  #                   it "should be enrolled" do
  #                     expect(employer_profile.enrolled?).to be_truthy
  #                   end
  #
  #                   it "should be in current status" do
  #                     expect(employer_profile.employer_profile_account.current?).to be_truthy
  #                   end
  #                 end
  #
  #                 context "and employer transitions into suspended status" do
  #                   before do
  #                     employer_profile.employer_profile_account.advance_billing_period
  #                   end
  #
  #                   it "should be in suspended status" do
  #                     expect(employer_profile.employer_profile_account.suspended?).to be_truthy
  #                   end
  #
  #                   it "should put the employer in suspended status" do
  #                     expect(employer_profile.suspended?).to be_truthy
  #                   end
  #
  #                   it "should transmit notice to employer"
  #
  #                   it "should transmit notice to broker"
  #
  #                   it "should transmit retroactive terminations to issuers"
  #
  #                   context "and employees are placed under a Special Enrollment Period" do
  #                     it "should transmit notices to all employees"
  #
  #                     it "should create a IVL market QLE for all employees"
  #
  #                     it "SEP should be retroactive"
  #                   end
  #
  #                   context "and employer pays in full" do
  #                     before do
  #                       employer_profile.employer_profile_account.advance_coverage_period
  #                     end
  #
  #                     it "should be enrolled" do
  #                       expect(employer_profile.enrolled?).to be_truthy
  #                     end
  #
  #                     it "should be in current status" do
  #                       expect(employer_profile.employer_profile_account.current?).to be_truthy
  #                     end
  #
  #                     it "now what happens to SEP, etc?"
  #                   end
  #
  #                   context "and employer transitions to terminated status" do
  #                     before do
  #                       employer_profile.employer_profile_account.advance_billing_period
  #                     end
  #
  #                     it "should be in terminated status" do
  #                       expect(employer_profile.employer_profile_account.terminated?).to be_truthy
  #                     end
  #
  #                     it "should put the employer in terminated status" do
  #                       expect(employer_profile.terminated?).to be_truthy
  #                     end
  #
  #                     it "should transmit notice to employer"
  #
  #                     it "should transmit notice to broker"
  #
  #                     it "should transmit notices to all employees"
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  #   context "and today is the day following this month's deadline for start of open enrollment" do
  #     before do
  #       # employer_profile.advance_enrollment_period
  #     end
  #
  #     context "and employer profile is in applicant state" do
  #       context "and effective date is next month" do
  #         it "should change status to canceled"
  #       end
  #
  #       context "and effective date is later than next month" do
  #         it "should not change state"
  #       end
  #     end
  #
  #     context "and employer is in ineligible or ineligible_appealing state" do
  #       it "what should be done?"
  #     end
  #   end
  # end
  #
  # context "application is submitted to be published" do
  #   let(:plan_year)                   { PlanYear.new(aasm_state: "draft", **valid_params) }
  #   let(:valid_fte_count)             { HbxProfile::ShopSmallMarketFteCountMaximum }
  #   let(:invalid_fte_count)           { HbxProfile::ShopSmallMarketFteCountMaximum + 1 }
  #
  #   it "plan year should be in draft state" do
  #     expect(plan_year.draft?).to be_truthy
  #   end
  #
  #   context "and the employer contribution amount is below minimum" do
  #     let(:benefit_group) { FactoryGirl.build(:benefit_group, :invalid_employee_relationship_benefit, plan_year: plan_year) }
  #
  #     context "and the effective date isn't January 1" do
  #       before do
  #         plan_year.benefit_groups << benefit_group
  #         plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year + 1.month
  #         plan_year.publish
  #       end
  #
  #       it "application should not be valid" do
  #         expect(plan_year.is_application_valid?).to be_falsey
  #       end
  #
  #       it "and should provide relevent warning message" do
  #         expect(plan_year.application_eligibility_warnings[:minimum_employer_contribution].present?).to be_truthy
  #         expect(plan_year.application_eligibility_warnings[:minimum_employer_contribution]).to match(/employer contribution percent/)
  #       end
  #
  #       it "and plan year should be in publish pending state" do
  #         expect(plan_year.publish_pending?).to be_truthy
  #       end
  #     end
  #
  #     context "and the effective date is January 1" do
  #       before do
  #         plan_year.benefit_groups << benefit_group
  #         plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year
  #         plan_year.publish
  #       end
  #
  #       it "application should be valid" do
  #         expect(plan_year.is_application_valid?).to be_truthy
  #       end
  #
  #       it "and plan year should be in published state" do
  #         expect(plan_year.published?).to be_truthy
  #       end
  #     end
  #   end
  #
  #   context "and one or more application elements are invalid" do
  #     let(:benefit_group) { FactoryGirl.build(:benefit_group, :invalid_employee_relationship_benefit, plan_year: plan_year) }
  #
  #     before do
  #       plan_year.benefit_groups << benefit_group
  #       plan_year.fte_count = invalid_fte_count
  #       plan_year.start_on = TimeKeeper.date_of_record.beginning_of_year + 1.month
  #       plan_year.publish
  #     end
  #
  #     it "and application should not be valid" do
  #       expect(plan_year.is_application_valid?).to be_falsey
  #     end
  #
  #     it "and plan year should be in publish pending state" do
  #       expect(plan_year.publish_pending?).to be_truthy
  #     end
  #
  #     context "and application is withdrawn for correction" do
  #       before do
  #         plan_year.withdraw_pending
  #       end
  #
  #       it "plan year should be in draft state" do
  #         expect(plan_year.draft?).to be_truthy
  #       end
  #     end
  #
  #     context "and application is submitted with warnings" do
  #       before do
  #         plan_year.force_publish
  #       end
  #
  #       it "plan year should be in publish invalid state" do
  #         expect(plan_year.publish_invalid?).to be_truthy
  #       end
  #
  #       it "employer_profile should be in ineligible state" do
  #         expect(plan_year.employer_profile.ineligible?).to be_truthy
  #       end
  #
  #       # TODO: We need to determine the form this notification will take
  #       it "employer should be notified that applcation is ineligible"
  #
  #       context "and 30 days or less has elapsed since applicaton was submitted" do
  #         context "and the employer appeals" do
  #           it "should transition to ineligible-appealing state"
  #
  #           # TODO: We need to determine the form this notification will take
  #           it "should notify HBX representatives of appeal request"
  #
  #             context "and HBX determines appeal has merit" do
  #               it "should transition employer status to registered"
  #             end
  #
  #             context "and HBX determines appeal has no merit" do
  #               it "should transition employer status to ineligible"
  #             end
  #
  #             context "and HBX determines application was submitted with errors" do
  #               it "should transition plan year application to draft"
  #               it "and should transition employer status to applicant"
  #             end
  #           end
  #         end
  #
  #       context "and more than 30 days has elapsed since application was submitted" do
  #         it "should employer actually move the employer into an additional 60-day waiting period?"
  #       end
  #     end
  #   end
  #
  #   context "and it has a terminated employee assigned to the benefit group" do
  #     let(:benefit_group) { FactoryGirl.build(:benefit_group) }
  #
  #     before do
  #       plan_year.benefit_groups = [benefit_group]
  #       terminated_census_employee = FactoryGirl.create(
  #         :census_employee, employer_profile: plan_year.employer_profile,
  #         benefit_group_assignments: [FactoryGirl.build(:benefit_group_assignment, benefit_group: benefit_group)]
  #       )
  #       terminated_census_employee.terminate_employment!(TimeKeeper.date_of_record.yesterday)
  #     end
  #
  #     context "and all application elements are valid and it is published" do
  #       before do
  #         @starting_date_of_record = TimeKeeper.date_of_record
  #         TimeKeeper.set_date_of_record_unprotected!(plan_year.open_enrollment_start_on - 5.days)
  #         plan_year.publish
  #       end
  #
  #       after do
  #         TimeKeeper.set_date_of_record_unprotected!(@starting_date_of_record)
  #       end
  #
  #       it "plan year should publish" do
  #         expect(plan_year.published?).to be_truthy
  #       end
  #
  #       it "and employer_profile should be in either registered or enrolling state" do
  #         expect(plan_year.employer_profile.registered? || plan_year.employer_profile.enrolling?).to be_truthy
  #       end
  #
  #       context "and the plan year is changed" do
  #         before do
  #           plan_year.start_on = plan_year.start_on.next_month
  #           plan_year.end_on = plan_year.end_on.next_month
  #           plan_year.open_enrollment_start_on = plan_year.open_enrollment_start_on.next_month
  #           plan_year.open_enrollment_end_on = plan_year.open_enrollment_end_on.next_month
  #         end
  #
  #         it "should not be valid"
  #       end
  #     end
  #   end
  # end
  #
  # context "check_start_on" do
  #   it "should fail when start on is not the first day of the month" do
  #     start_on = (TimeKeeper.date_of_record + 2.month).beginning_of_month + 10.days
  #     rsp = PlanYear.check_start_on(start_on)
  #     expect(rsp[:result]).to eq "failure"
  #     expect(rsp[:msg]).to eq "start on must be first day of the month"
  #   end
  #
  #   it "should valid" do
  #     start_on = (TimeKeeper.date_of_record + 2.month).beginning_of_month
  #     rsp = PlanYear.check_start_on(start_on)
  #     expect(rsp[:result]).to eq "ok"
  #     expect(rsp[:msg]).to eq ""
  #   end
  #
  #   it "should failure when current date more than open_enrollment_latest_start_on" do
  #     TimeKeeper.set_date_of_record_unprotected!(TimeKeeper.date_of_record.beginning_of_month + 14.days)
  #     start_on = (TimeKeeper.date_of_record + 1.month).beginning_of_month
  #     rsp = PlanYear.check_start_on(start_on)
  #     expect(rsp[:result]).to eq "failure"
  #     expect(rsp[:msg]).to start_with "must choose a start on date"
  #   end
  # end
  #
  # context "calculate_open_enrollment_date when the earliest effective date is chosen" do
  #   let(:new_effective_date) { PlanYear.calculate_start_on_dates.first }
  #   let(:calculate_open_enrollment_date) { PlanYear.calculate_open_enrollment_date(new_effective_date) }
  #
  #   context "on the first of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 1) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 1) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 8, 1) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the second of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 2) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 2) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 8, 1) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the third of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 3) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 3) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 8, 1) }
  #     let(:date_of_record_to_use) { TimeKeeper.date_of_record.beginning_of_month + 2.days }
  #     let(:expected_open_enrollment_start_on) { date_of_record_to_use }
  #     let(:expected_open_enrollment_end_on) { Date.new(date_of_record_to_use.year, date_of_record_to_use.month, 10) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the fourth of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 4) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 4) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 8, 1) }
  #     let(:date_of_record_to_use) { TimeKeeper.date_of_record.beginning_of_month + 3.days }
  #     let(:expected_open_enrollment_start_on) { date_of_record_to_use }
  #     let(:expected_open_enrollment_end_on) { Date.new(date_of_record_to_use.year, date_of_record_to_use.month, 10) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the fifth of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 5) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 5) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 8, 1) }
  #     let(:date_of_record_to_use) { TimeKeeper.date_of_record.beginning_of_month + 4.days }
  #     let(:expected_open_enrollment_start_on) { date_of_record_to_use }
  #     let(:expected_open_enrollment_end_on) { Date.new(date_of_record_to_use.year, date_of_record_to_use.month, 10) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the sixth of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 6) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 6) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 7, 10) }
  #     let(:expected_start_on) { Date.new(2015, 9, 1) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the 7th of the month" do
  #     let(:date_of_record_to_use) { Date.new(2015, 7, 7) }
  #     let(:expected_open_enrollment_start_on) { Date.new(2015, 7, 7) }
  #     let(:expected_open_enrollment_end_on) { Date.new(2015, 8, 10) }
  #     let(:expected_start_on) { Date.new(2015, 9, 1) }
  #     before do
  #       TimeKeeper.set_date_of_record_unprotected!(date_of_record_to_use)
  #     end
  #
  #     it "should suggest correct open enrollment start" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_start_on]).to eq expected_open_enrollment_start_on
  #     end
  #
  #     it "should suggest correct open enrollment end" do
  #       expect(calculate_open_enrollment_date[:open_enrollment_end_on]).to eq expected_open_enrollment_end_on
  #     end
  #
  #     it "should have the right start on" do
  #       expect(new_effective_date).to eq expected_start_on
  #     end
  #   end
  #
  #   context "on the tenth of the month" do
  #   end
  #
  #   context "on the twelfth of the month" do
  #   end
  #
  #   context "on the last day of the month" do
  #   end
  # end
  #
  # context "map binder_payment_due_date" do
  #   it "in interval of map" do
  #     binder_payment_due_date = PlanYear.map_binder_payment_due_date_by_start_on(TimeKeeper.set_date_of_record_unprotected!(Date.new(2015,9,1)))
  #     expect(binder_payment_due_date).to eq TimeKeeper.set_date_of_record_unprotected!(Date.new(2015,8,12))
  #   end
  #
  #   it "out of map" do
  #     binder_payment_due_date = PlanYear.map_binder_payment_due_date_by_start_on(TimeKeeper.set_date_of_record_unprotected!(Date.new(2017,9,1)))
  #
  #     expect(binder_payment_due_date).to eq PlanYear.shop_enrollment_timetable(TimeKeeper.set_date_of_record_unprotected!(Date.new(2017,9,1)))[:binder_payment_due_date]
  #   end
  # end
  #
  # context "calculate_start_on_options" do
  #   it "should return two options" do
  #     date1 = TimeKeeper.date_of_record.beginning_of_month.next_month.next_month
  #     date2 = date1.next_month
  #     dates = [date1, date2].map{|d| [d.strftime("%B %Y"), d.strftime("%Y-%m-%d")]}
  #
  #     TimeKeeper.set_date_of_record_unprotected!(Date.new(TimeKeeper.date_of_record.year, TimeKeeper.date_of_record.month, 15))
  #     expect(PlanYear.calculate_start_on_options).to eq dates
  #   end
  #
  #   it "should return three options" do
  #     date1 = TimeKeeper.date_of_record.beginning_of_month.next_month
  #     date2 = date1.next_month
  #     date3 = date2.next_month
  #     dates = [date1, date2, date3].map{|d| [d.strftime("%B %Y"), d.strftime("%Y-%m-%d")]}
  #
  #     TimeKeeper.set_date_of_record_unprotected!(Date.new(TimeKeeper.date_of_record.year, TimeKeeper.date_of_record.month, 2))
  #     expect(PlanYear.calculate_start_on_options).to eq dates
  #   end
  # end
  #
  # context "employee_participation_percent" do
  #   let(:employer_profile) {FactoryGirl.create(:employer_profile)}
  #   let(:plan_year) {FactoryGirl.create(:plan_year, employer_profile: employer_profile)}
  #   it "when fte_count equal 0" do
  #     allow(plan_year).to receive(:fte_count).and_return(0)
  #     expect(plan_year.employee_participation_percent).to eq "-"
  #   end
  #
  #   it "when fte_count > 0" do
  #     allow(plan_year).to receive(:fte_count).and_return(10)
  #     employee_role_linked_count = employer_profile.census_employees.where(aasm_state: "employee_role_linked").count
  #
  #     expect(plan_year.employee_participation_percent).to eq "#{(employee_role_linked_count/10.0*100).round(2)}%"
  #   end
  # end
end
