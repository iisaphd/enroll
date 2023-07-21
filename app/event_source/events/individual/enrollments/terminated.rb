# frozen_string_literal: true

module Events
  module Individual
    module Enrollments
      # This class will register event
      class Terminated < EventSource::Event
        publisher_path 'publishers.enrollment_publisher'
      end
    end
  end
end