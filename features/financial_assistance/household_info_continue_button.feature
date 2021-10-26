Feature: A dedicated page that gives the user access to household member creation/edit as well as Financial application forms for each household member.

  Background: Household Info page
    Given EnrollRegistry show_download_tax_documents feature is enabled
    And EnrollRegistry medicaid_tax_credits_link feature is enabled
    Given the FAA feature configuration is enabled
    Given a plan year, with premium tables, exists
    Given that the user is on FAA Household Info: Family Members page

  Scenario: CONTINUE button navigation
    When at least one applicant is in the Info Needed state
    Then the CONTINUE button will be disabled

  Scenario: primary member with NO other household members
    And the primary member exists
    And NO other household members exist
    Then Family Relationships left section will NOT display

  Scenario: primary member with other household members
    And the primary member exists
    And at least one other household members exist
    And all applicants are in Info Completed state
    Then Family Relationships left section WILL display

  Scenario: dependent not applying will be shown the no ssn warning
    And the primary member exists
    And a new household member is not applying
    Then the no ssn warning will appear

  Scenario: CONTINUE button enabled when non-applying dependent does not enter ssn
    And the primary member exists
    And a new household member is not applying
    And all applicants are in Info Completed state
    Then the CONTINUE button will be ENABLED

  Scenario: CONTINUE button navigation
    When all applicants are in Info Completed state
    Then the CONTINUE button will be ENABLED

  Scenario: CONTINUE button navigation
    And the primary member exists
    And at least one other household members exist
    When all applicants are in Info Completed state
    And user clicks CONTINUE
    # TODO: This family relationships stuff not moved in yet
    # Then the user will navigate to Family Relationships page