# frozen_string_literal: true

module Eligibilities
  #Store the history of each transaction a user or admin has performed on an evidence
  class VerificationHistory
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :evidence, class_name: '::Eligibilities::Evidence'

    field :action, type: String
    field :modifier, type: String
    field :update_reason, type: String
    field :updated_by, type: String

  end
end