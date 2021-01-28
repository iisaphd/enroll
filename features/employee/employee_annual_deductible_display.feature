Feature: Annual Deductible Display

  Scenario: Annual Deductible display on enrollment tile on employee home page
    Given Add Deductible Display is Enabled
    Given a CCA site exists with a benefit market
    Given benefit market catalog exists for enrollment_open renewal employer with health benefits
    Given Qualifying life events are present
    And there is an employer ABC Widgets
    Given there exists Patrick Doe employee for employer ABC Widgets
    And initial employer ABC Widgets has active benefit application
    And employee Patrick Doe has past hired on date
    And employee Patrick Doe already matched with employer ABC Widgets and logged into employee portal
    And Patrick Doe has active coverage in coverage enrolled state
    And Patrick Doe visits the employee portal
    And Patrick Doe should see annual deductible display
