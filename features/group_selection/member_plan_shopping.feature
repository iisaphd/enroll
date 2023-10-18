Feature: EE plan purchase

  Background: Setup site, employer, and benefit application
	Given a CCA site exists with a benefit market
	Given benefit market catalog exists for enrollment_open initial employer that has both health and dental benefits
	And there is an employer Acme Inc.
	And Acme Inc. employer has a staff role
	Given Continuous plan shopping is enabled
	Given staff role person logged in
	And employer Acme Inc. has enrollment_open benefit application with dental
	And Acme Inc. employer visit the Employee Roster
	And there is a census employee record for Patrick Doe for employer Acme Inc.
	Then Employer logs out

  Scenario: New employee shops for both health and dental plan
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll & waive buttons
	When Employee clicks continue button on group selection page for dependents
	When Employee selects a health plan on the plan shopping page
	And Employee selects a dental plan on the plan shopping page
	When Employee clicks on Confirm button on the coverage summary page
	Then Employee should see both health & dental plans on receipt page
	Then Employee should see the receipt page

  Scenario: New employee shops for dental plan only
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll buttons are checked by default
	Then Employee should see enroll & waive buttons
	And Employee waives health plan
	And Employee selects Waive reason for health
	When Employee clicks continue button on group selection page for dependents
	When Employee selects a dental plan on the plan shopping page
	Then Employee clicks no on choose coverage for household
	When Employee clicks on Confirm button on the coverage summary page
	Then Employee should see dental enrollment text on receipt page

  Scenario: Waive coverage for some members
    And Employee has not signed up as an HBX user
  	And Patrick Doe visits the employee portal
  	When Patrick Doe creates an HBX account
  	And I select the all security question and give the answer
  	When I have submitted the security questions
  	When Employee goes to register as an employee
  	Then Employee should see the employee search page
  	When Employee enters the identifying info of Patrick Doe
  	Then Employee should see the matched employee record form
  	When Employee accepts the matched employer
  	When Employee completes the matched employee form for Patrick Doe
  	Then Employee should see the dependents page
    When Employee clicks Add Member
    Then Employee should see the new dependent form
    When Employee enters the dependent info of Patrick wife
    When Employee clicks confirm member
    Then Employee should see 1 dependents
  	When Employee clicks continue on the dependents page
  	Then Employee should see the group selection page
  	Then Employee should see enroll & waive buttons
    And Employee waives health plan for dependent
    And Employee waives dental plan for dependent
  	When Employee clicks continue button on group selection page for dependents
    When Employee selects a health plan on the plan shopping page
  	When Employee selects a dental plan on the plan shopping page
  	When Employee clicks on Confirm button on the coverage summary page
    Then Employee should see health product confirmation on receipt page
  	Then Employee should see dental product confirmation on receipt page

  Scenario: Dependent child age 26 or over
    And Employee has not signed up as an HBX user
  	And Patrick Doe visits the employee portal
  	When Patrick Doe creates an HBX account
  	And I select the all security question and give the answer
  	When I have submitted the security questions
  	When Employee goes to register as an employee
  	Then Employee should see the employee search page
  	When Employee enters the identifying info of Patrick Doe
  	Then Employee should see the matched employee record form
  	When Employee accepts the matched employer
  	When Employee completes the matched employee form for Patrick Doe
  	Then Employee should see the dependents page
    When Employee clicks Add Member
    Then Employee should see the new dependent form
    When Employee enters the dependent info of Patrick daughter
    When Employee clicks confirm member
    Then Employee should see 1 dependents
  	When Employee clicks continue on the dependents page
  	Then Employee should see the group selection page
    Then dependent child should be ineligible for health and dental coverage

  Scenario: Display health & dental confirmation text
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll & waive buttons
	When Employee clicks continue button on group selection page for dependents
	When Employee selects a health plan on the plan shopping page
	And Employee selects a dental plan on the plan shopping page
	When Employee clicks on Confirm button on the coverage summary page
	Then Employee should see health & dental confirmation text

  Scenario: Display health confirmation text
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll & waive buttons
	And Employee waives dental plan
	When Employee clicks continue button on group selection page for dependents
	When Employee selects a health plan on the plan shopping page
	Then Employee selects no for dental coverage
	Then Employee clicks on continue
	When Employee clicks on Confirm button on the coverage summary page
	Then Employee should see health confirmation text

  Scenario: Employee should not see error messages when all options are waived
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll & waive buttons
	And Employee waives dental plan
	And Employee waives health plan
	And Employee selects Waive reason for health
	When Employee clicks continue button on group selection page for dependents
	Then Employee should not see an error message

	Scenario: Employee should see error when waived health and did not select waiver reason
	And Employee has not signed up as an HBX user
	And Patrick Doe visits the employee portal
	When Patrick Doe creates an HBX account
	And I select the all security question and give the answer
	When I have submitted the security questions
	When Employee goes to register as an employee
	Then Employee should see the employee search page
	When Employee enters the identifying info of Patrick Doe
	Then Employee should see the matched employee record form
	When Employee accepts the matched employer
	When Employee completes the matched employee form for Patrick Doe
	Then Employee should see the dependents page
	When Employee clicks continue on the dependents page
	Then Employee should see the group selection page
	Then Employee should see enroll & waive buttons
	And Employee waives health plan
	When Employee clicks continue button on group selection page for dependents
	Then Employee should see an error message about waiver reason
	When Employee waives health plan
	And Employee selects waiver reason as outside service area
	Then Employee should see confirm your selection disabled
	And Employee enrolls health plan
	Then Employee should see confirm your selection enabled
