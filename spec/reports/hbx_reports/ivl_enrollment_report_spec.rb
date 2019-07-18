require "rails_helper"
require 'csv'
require File.join(Rails.root, "app", "reports", "hbx_reports", "ivl_enrollment_report")

describe IvlEnrollmentReport, dbclean: :after_each do
  subject { IvlEnrollmentReport.new("ivl_enrollment_report", double(:current_scope => nil)) }

  before(:each) do
    subject.migrate
    @file = "#{Rails.root}/hbx_report/ivl_enrollment_report.csv"
  end

  it "creates csv file" do
    ClimateControl.modify purchase_date_start:"#{06/01/2018}", purchase_date_end:"#{06/10/2018}" do 
      file_context = CSV.read(@file)
      expect(file_context.size).to be > 0
    end
  end

  it "returns correct fields" do
    ClimateControl.modify purchase_date_start:"#{06/01/2018}", purchase_date_end:"#{06/10/2018}" do 

      CSV.foreach(@file, :headers => true) do |csv|
        expect(csv).to eq ['Enrollment GroupID', 'Purchase Date', 'Coverage Start', 'Coverage End', 'Coverage Kind', 'Enrollment State', 
                           'Subscriber HBXID', 'Subscriber First Name','Subscriber Last Name', 'HIOS ID', 'Premium Subtotal', 
                           'ER Contribution', 'Applied APTC Amount', 'Total Responsible Amount', 'Family Size', 'Enrollment Reason', 
                           'In Glue']
      end
    end
  end

  after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}//hbx_report"])
  end
end