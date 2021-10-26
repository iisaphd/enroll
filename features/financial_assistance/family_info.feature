# frozen_string_literal: true

Feature: Start a new Financial Assistance Application
  Background:
    Given a consumer, with a family, exists
    And the FAA feature configuration is enabled
    And is logged in
    And a benchmark plan exists

  Scenario: A consumer should see the applications assistance year when feature enabled
    Given IAP Assistance Year Display feature is enabled
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    Then They should see the application assistance year above Info Needed

  Scenario: A consumer should NOT see the applications assistance year when feature disabled
    Given IAP Assistance Year Display feature is disabled
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    Then They should not see the application assistance year above Info Needed

  Scenario: A consumer wants to start a new financial assistance application
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    And they should see each of their dependents listed
    And consumer clicks on pencil symbol next to primary person
    Then consumer should see today date and clicks continue

  Scenario: American Indian/ Alaskan Native Details feature is enabled
    Given AI AN Details feature is enabled
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    And they should see each of their dependents listed
    And the user clicks Add Member
    And the user fills the the applicant add member form with indian member yes
    And the user clicks submit applicant form
    Then the user should see the AI AN Details fields
    Then the user should see an error message for indian tribal state and name

  Scenario: American Indian/ Alaskan Native Details feature is enabled and user enters a name with a number
    Given AI AN Details feature is enabled
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    And they should see each of their dependents listed
    And the user clicks Add Member
    And the user fills the the applicant add member form with indian member yes
    And the user enters a tribal name with a number
    And the user clicks submit applicant form
    Then the user should see an error for tribal name containing a number

  Scenario: No Coverage Tribe Details feature is enabled
    Given No coverage tribe details feature is enabled
    When a consumer visits the Get Help Paying for coverage page
    And selects yes they would like help paying for coverage
    Then they should see a new finanical assistance application
    And they should see each of their dependents listed
    And the user clicks Add Member
    And the user selects not applying for coverage
    Then user should still see the member of a tribe question