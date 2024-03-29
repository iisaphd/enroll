class Employers::BrokerAgencyController < ApplicationController

  before_action :find_employer
  before_action :find_borker_agency, :except => [:index, :active_broker]


  def index
    @filter_criteria = params.permit(:q, :working_hours, :languages => [])

    if @filter_criteria.empty?
      @orgs = Organization.active_broker_agencies
      @page_alphabets = page_alphabets(@orgs, "legal_name")

      if params[:page].present?
        page_no = cur_page_no(@page_alphabets.first)
        @organizations = @orgs.where("legal_name" => /^#{page_no}/i)
      else
        @organizations = @orgs.to_a.first(10)
      end
      @broker_agency_profiles = @organizations.map(&:broker_agency_profile).uniq
    else
      results = Organization.broker_agencies_with_matching_agency_or_broker(@filter_criteria)
      if results.first.is_a?(Person)
        @filtered_broker_roles  = results.map(&:broker_role)
        @broker_agency_profiles = results.map{|broker| broker.broker_role.broker_agency_profile}.uniq
      else
        @broker_agency_profiles = results.map(&:broker_agency_profile).uniq
      end
    end
  end

  def show
  end

  def active_broker
    @broker_agency_accounts = @employer_profile.broker_agency_accounts
  end

  def create
    broker_agency_id = params.permit(:broker_agency_id)[:broker_agency_id]
    broker_role_id = params.permit(:broker_role_id)[:broker_role_id]

    if broker_agency_profile = BrokerAgencyProfile.find(broker_agency_id)
      @employer_profile.broker_role_id = broker_role_id
      @employer_profile.broker_agency_profile = broker_agency_profile
      @employer_profile.save!
    end

    flash[:notice] = "Successfully associated broker with your account."
    redirect_to employers_employer_profile_path(@employer_profile)
  end

  def terminate
    termination_date = ""
    if params["termination_date"].present?
      termination_date = DateTime.strptime(params["termination_date"], '%m/%d/%Y').try(:to_date)
    end

    if termination_date.present?
      @employer_profile.terminate_active_broker_agency(termination_date)
      @fa = @employer_profile.save!
    end

    respond_to do |format|
      format.js {
        if termination_date.present? and @fa
          flash[:notice] = "Broker terminated successfully."
          render text: true
        else
          render text: false
        end
      }
      format.all {
        flash[:notice] = "Broker terminated successfully."
        redirect_to employers_employer_profile_path(@employer_profile)
      }
    end
  end

  private

  def find_employer
    @employer_profile = EmployerProfile.find(params["employer_profile_id"])
  end

  def find_borker_agency
    id = params[:id] || params[:broker_agency_id]
    @broker_agency_profile = BrokerAgencyProfile.find(id)
  end
end