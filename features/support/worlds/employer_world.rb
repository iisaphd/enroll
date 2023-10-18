module EmployerWorld
  include ActionView::Helpers::NumberHelper
  def employer(legal_name, *traits)
    attributes = traits.extract_options!
    traits.push(:with_aca_shop_cca_employer_profile) unless traits.include? :with_aca_shop_cca_employer_profile_no_attestation
    @organization ||= {}

    if @organization[legal_name].blank?
      organization = FactoryGirl.create(
        :benefit_sponsors_organizations_general_organization, *traits,
        attributes.merge(site: site)
        )

      @employer_profile = organization.employer_profile
      @organization[legal_name] = organization
    end

    @organization[legal_name]
  end

  def employer_profile(legal_name = nil)
    @employer_profile ||= employer(legal_name).employer_profile
  end

  def registering_employer
    @registering_organization ||= FactoryGirl.build(
      :benefit_sponsors_organizations_general_organization,
      :with_aca_shop_cca_employer_profile,
      site: site
    )
  end
end

World(EmployerWorld)

And(/^there is an employer (.*?)$/) do |legal_name|
  employer legal_name, legal_name: legal_name, dba: legal_name
  benefit_sponsorship(employer(legal_name))
end

And(/^it has an employer (.*?) with no attestation submitted$/) do |legal_name|
  employer legal_name, :with_aca_shop_cca_employer_profile_no_attestation, legal_name: legal_name, dba: legal_name
  benefit_sponsorship(employer(legal_name))
end

Given(/^at least one attestation document status is (.*?)$/) do |status|
  @employer_attestation_status = status
end

And(/^(.*?) employer has a staff role$/) do |legal_name|
  employer_profile = employer_profile(legal_name)
  employer_staff_role = FactoryGirl.build(:benefit_sponsor_employer_staff_role, aasm_state: 'is_active', benefit_sponsor_employer_profile_id: employer_profile.id)
  person = FactoryGirl.create(:person, employer_staff_roles: [employer_staff_role])
  @staff_role ||= FactoryGirl.create(:user, :person => person)
end

And(/^(.*?) employer terminates employees$/) do |legal_name|
  termination_date = TimeKeeper.date_of_record - 1.day
  @census_employees.each do |employee|
    employee.terminate_employment(termination_date)
  end
end

And(/^staff role person logged in$/) do
  login_as @staff_role, scope: :user
end

And(/^staff role person clicked on (.*?) tab$/) do |key|
  find(".interaction-click-control-#{key}").click
end

And(/^(.*?) is logged in and on the home page$/) do |legal_name|
  organization = @organization[legal_name]
  employer_profile = organization.employer_profile
  visit benefit_sponsors.profiles_employers_employer_profile_path(employer_profile.id, :tab => 'home')
end

Given(/^an employer (.*?) exists with statements and premium payments$/) do |legal_name|
  employer legal_name, legal_name: legal_name, dba: legal_name
  benefit_sponsorship = benefit_sponsorship(employer(legal_name))
  @benefit_sponsorship_account = FactoryGirl.create(:benefit_sponsors_benefit_sponsorships_benefit_sponsorship_account, :with_financial_transactions, :with_current_statement_activities, benefit_sponsorship: benefit_sponsorship)
end
