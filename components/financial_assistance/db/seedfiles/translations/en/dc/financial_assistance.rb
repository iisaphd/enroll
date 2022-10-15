# frozen_string_literal: true

# Assistance Translations

# rubocop:disable Layout/LineLength

FINANCIAL_ASSISTANCE_TRANSLATIONS = {
  "en.faa.curam_lookup" => "It looks like you've already completed an application for Medicaid and cost savings on DC Health Link.
     Please call DC Health Link at (855) 532-5465 to make updates to that application.
      If you keep going, we'll check to see if you qualify to enroll in a private health insurance plan on DC Health Link, but won't be able to tell you if you qualify for Medicaid or cost savings.",
  "en.faa.acdes_lookup" => "It looks like you're already covered by Medicaid. Please call DC Health Link at (855) 532-5465 to make updates to your case.
     If you keep going, we'll check to see if you qualify to enroll in a private health insurance plan on DC Health Link, but won't be able to tell you if you qualify for Medicaid or cost savings.",
  "en.faa.other_ques.title" => "Other Questions for",
  "en.faa.other_ques.answer_request" => "Answer these questions for this person. When you're finished, select CONTINUE.",
  "en.faa.other_ques.ssn_apply" => "Has this person applied for an SSN?*",
  "en.faa.other_ques.is_ssn_applied" => "Has this person applied for an SSN?",
  "en.faa.other_ques.why_no_ssn" => "Why doesn't this person have an SSN?",
  "en.faa.other_ques.is_pregnant" => "Is this person pregnant?*",
  "en.faa.other_ques.pregnancy_due_date" => "Pregnancy due date?",
  "en.faa.other_ques.children_expected" => "How many children is this person expecting?*",
  "en.faa.other_ques.pregnant_last_60d" => "Was this person pregnant in the last 60 days?*",
  "en.faa.other_ques.pregnancy_end" => "Pregnancy end date:*",
  "en.faa.other_ques.is_enrolled_on_medicaid" => 'Was this person enrolled in Medicaid during the pregnancy?',
  "en.faa.other_ques.foster_care_at18" => "Was this person in foster care at age 18 or older?*",
  "en.faa.other_ques.foster_care_state" => "Where was this person in foster care?",
  "en.faa.other_ques.foster_care_age_left" => "How old was this person when they left foster care?",
  "en.faa.other_ques.foster_care_medicaid" => "Was this person enrolled in Medicaid when they left foster care?",
  'en.faa.other_ques.is_student' => 'Is this person a full-time student?*',
  "en.faa.other_ques.student_type" => "What is the type of student?",
  "en.faa.other_ques.student_status_end" => "Student status end on date?",
  "en.faa.other_ques.student_school_type" => "What type of school do you go to?",
  "en.faa.other_ques.is_blind" => "Is this person blind?",
  "en.faa.other_ques.daily_living_help" => "Does this person need help with daily life activities, such as dressing or bathing? ",
  "en.faa.other_ques.help_paying_bills" => "Does this person need help paying for any medical bills from the last 3 months? ",
  "en.faa.other_ques.disability_question" => "Does this person have a disability?",
  "en.faa.other_ques.is_resident_post_092296" => "Did you move to the U.S. on or after August 22, 1996?",
  "en.faa.other_ques.is_veteran_or_active_military" => "Are you an honorably discharged veteran or active duty member of the military?",
  "en.faa.other_ques.is_vets_spouse_or_child" => "Are you the spouse or dependent child of such a veteran or individual in active duty status?",
  "en.faa.medicaid_question" => "Do you want us to submit this application to the DC Department of Human Services (DHS) to do a full review of your application for Medicaid eligibility?",
  'en.faa.edit.delete_applicant' => 'Are you sure you want to remove this applicant?',
  'en.faa.edit.remove_warning' => 'This cannot be undone.',
  'en.faa.incomes.job_income_note' => "Note: For job income this person currently receives, do not enter an end date into the ‘To’ field. Only enter an end date if the job income ended.",
  "en.faa.incomes.from_employer" => "Does this person have <strong> income from an employer</strong>(wages, tips, bonuses, etc.) in %{assistance_year}?*",
  "en.faa.incomes.from_self_employment" => "Does this person expect to receive <strong>self-employment income</strong> in %{assistance_year}?*",
  "en.faa.other_incomes.unemployment" => "Did this person receive <strong>Unemployment Income</strong> at any point in %{assistance_year}?*",
  "en.faa.other_incomes.other_sources" => "Does this person expect to have <strong> income from other sources </strong> in %{assistance_year}?*",
  "en.faa.deductions.income_adjustments" => "Does this person expect to have income adjustments in %{assistance_year}?*",
  "en.faa.deductions.divorce_agreement" => "(from a divorce agreement finalized before January 1, 2019)",
  "en.faa.we_have_your_results" => "We have your results",
  "en.faa.medicaid" => "Medicaid",
  "en.faa.eligible_for_medicaid" => "These people <span>likely qualify</span> for ",
  "en.faa.eligible_for_medicaid2" => "&#58", # use html character code for colon so l10n helper doesn't break
  "en.faa.dhs_decision" => "<span>NOTE: The Department of Human Services (DHS) will make a final decision on whether those listed qualify for <span class='run-glossary'>Medicaid</span>.</span>",
  "en.faa.dhs_contact" => "They will send you a letter, and may ask you to provide documents. If you haven’t heard from DHS within 45 days, you may want to ask for an update by calling District Direct at ",
  "en.faa.primary_caretaker_question_text" => "Is this person the main person taking care of any children age 18 or younger? *",
  "en.faa.premium_reductions_1" => "These people <strong>qualify for lower monthly premiums. The monthly premium reduction is %{reduction_amount} per month </strong>.",
  "en.faa.premium_reductions_2" => "per month.</span> This means they won't have to pay full price for health insurance.",
  "en.faa.qualify_for_lower_costs_1" => "They also qualify for lower out-of-pocket costs - a benefit that lowers other costs like the annual deductible and copayments. ",
  "en.faa.qualify_for_csr_100" => "They also won’t pay anything for services they receive from an Indian Health Service provider.",
  "en.faa.qualify_for_csr_limited" => "These people won’t pay anything for services they receive from an Indian Health Service provider.",
  "en.faa.silver_plan_checkmark" => "This benefit is only available if these people select a silver plan. Look for this check mark ",
  "en.faa.qualify_for_lower_costs_2" => " on plans that have this benefit.",
  "en.faa.does_not_qualify" => "Does Not Qualify",
  "en.faa.does_not_qualify_text" => "These people likely don't qualify for Medicaid , and don't qualify for private health insurance through CoverME.gov.",
  "en.faa.likely_does_not_qualify" => "These people <span> likely don't qualify for ",
  "en.faa.likely_does_not_qualify2" => "</span>, and don't qualify for private health insurance through DC Health Link:",
  "en.faa.private_health_insurance" => "Private Health Insurance",
  "en.faa.private_health_insurance_text" => "These people qualify to enroll in a private health insurance plan.",
  "en.faa.qualified_to_enroll" => "These people are not eligible for lower monthly premiums. They <span> qualify to enroll </span> in a private health insurance plan.",
  "en.faa.do_not_agree" => "If you do not agree with the determination, you have the right to appeal. <a href= %{appeal_link} target='_blank'>Find out more about the appeal process</a> or <a href= %{find_expert_link}  target='_blank'>get help</a> by contacting us directly.",
  "en.faa.your_application_reference" => "Your application reference number is ",
  "en.faa.next_step_without_aggregate" => "<b>NEXT STEP:</b> Pick a health insurance plan.",
  "en.faa.next_step_with_aggregate_1" => "<b>NEXT STEP:</b><ul><li><b>If you’re already enrolled in DC Health Link’s Individual & Family plan</b>, we’ve automatically changed your premium. You don’t have to do anything else.</li>",
  "en.faa.next_step_with_aggregate_2" => "<br><li><b>If you’re not enrolled or need to make changes to your plan</b>, select CONTINUE to pick a health insurance plan or change who is covered by your plan.</li></ul>",
  "en.faa.next_step_medicaid_eligible" => "<b>Medicaid coverage is free. If you would like to enroll and pay full price for private health insurance instead, select CONTINUE to:</b><ul><li>pick a plan, or</li><li>add or remove someone from your plan.</li>",
  "en.faa.next_step_medicaid_eligible_at_least_one_other_eligible" => "<b>Select CONTINUE to:</b><ul><li>add or remove someone from your plan, or</li><li> pick a plan because you do not have coverage.</li>",
  "en.faa.indian_health_service" => "Has this person ever gotten a health service from the Indian Health Service, a tribal health program, or urban Indian health program or through a referral from one of these programs?",
  "en.faa.indian_health_service_eligible" => "Is this person eligible to get health services from the Indian Health Service, a tribal health program, or an urban Indian health program or through referral from one of these programs?",
  "en.faa.medicaid_not_eligible" => "Was this person found not eligible for MaineCare (Medicaid) or Cub Care (Children's Health Insurance Program) within the last 90 days? *",
  "en.faa.medicaid_cubcare_end_date" => "When was this person denied MaineCare (Medicaid) or Cub Care (Children's Health Insurance Program)? *",
  "en.faa.change_eligibility_status" => "Did this person have MaineCare (Medicaid) or Cub Care (Children's Health Insurance Program) that will end soon or that recently ended because of a change in eligibility? *",
  "en.faa.household_income_changed" => "Has this person's household income or household size changed since they were told their coverage was ending? * ",
  "en.faa.person_medicaid_last_day" => "What's the last day of this person’s Medicaid or CHIP coverage? *",
  "en.faa.medicaid_chip_ineligible" => "Was this person found not eligible for MaineCare (Medicaid) or Cub Care (Children's Health Insurance Program) based on their immigration status since",
  "en.faa.immigration_status_changed" => "Has this person’s immigration status changed since they were not found eligible for MaineCare (Medicaid) or Cub Care (Children’s Health Insurance Program)",
  "en.faa.has_dependent_with_coverage" => "Did this person have coverage through a job (for example, a parent’s job) that ended in the last 3 months?*",
  "en.faa.dependent_job_end_on" => "What was the last day this person had coverage through the job?*",
  "en.faa.question.private_individual_and_family_coverage" => "%{short_name} Individual & Family coverage",
  "en.faa.question.acf_refugee_medical_assistance" => "ACF Refugee Medical Assistance",
  "en.faa.question.americorps_health_benefits" => "AmeriCorps health benefits",
  "en.faa.question.child_health_insurance_plan" => "Children's Health Insurance Program",
  "en.faa.question.medicaid" => "Medicaid",
  "en.faa.question.medicare" => "Medicare",
  "en.faa.question.medicare_advantage" => "Medicare Advantage",
  "en.faa.question.medicare_part_b" => "Medicare Part B, only",
  "en.faa.question.state_supplementary_payment" => "SSI",
  "en.faa.question.tricare" => "TRICARE",
  "en.faa.question.veterans_benefits" => "Veterans health benefits",
  "en.faa.question.naf_health_benefit_program" => "NAF Health Benefits Program",
  "en.faa.question.health_care_for_peace_corp_volunteers" => "Health care for Peace Corps volunteers",
  "en.faa.question.department_of_defense_non_appropriated_health_benefits" => "Department of Defense health benefits",
  "en.faa.question.cobra" => "COBRA",
  "en.faa.question.employer_sponsored_insurance" => "Coverage through a job (or another person's job, like a spouse or parent)",
  "en.faa.question.self_funded_student_health_coverage" => "Self-funded student health coverage",
  "en.faa.question.foreign_government_health_coverage" => "Foreign government health coverage",
  "en.faa.question.private_health_insurance_plan" => "Private health insurance plan",
  "en.faa.question.coverage_obtained_through_another_exchange" => "Coverage obtained through a non-%{short_name} marketplace",
  "en.faa.question.coverage_under_the_state_health_benefits_risk_pool" => "Coverage under the state health benefits risk pool",
  "en.faa.question.veterans_administration_health_benefits" => "Veterans Administration health benefits",
  "en.faa.question.peace_corps_health_benefits" => "Peace Corps health benefits",
  "en.faa.question.health_reimbursement_arrangement" => "Health Reimbursement Arrangement",
  "en.faa.question.retiree_health_benefits" => "Retiree Health Benefits",
  "en.faa.question.other_full_benefit_coverage" => "Other full benefit coverage",
  "en.faa.question.other_limited_benefit_coverage" => "Other limited benefit coverage",
  "en.faa.premium_reductions" => "Do you want to apply for monthly premium reductions and lower out-of-pocket costs?*",
  "en.faa.premium_reductions2" => "",
  "en.faa.question.type_of_hra" => "Type of HRA",
  "en.faa.question.max_employer_reimbursement" => "What's the maximum self-only amount of reimbursement offered by this employer?",
  "en.faa.question.required_indicator" => "* = required field",
  "en.faa.question.not_sure" => "Not sure?",
  "en.faa.question.eligible_immigration_status" => "Do you have eligible immigration status? *",
  "en.faa.question.immigration_continue_note_1" => "",
  "en.faa.question.immigration_continue_note_2" => "",
  # Submit Your Application Page
  "en.faa.submit_your_application" => "Submit Your Application",
  "en.faa.last_step_1" => "This is the last step. Carefully read the information below. Select 'I agree' after each statement to acknowledge your agreement.",
  "en.faa.last_step_2" => "Then, enter your name to electronically sign the application. When you're finished, select SUBMIT APPLICATION.",
  "en.faa.i_understand_eligibility" => "I understand that eligibility for private health insurance, with or without financial assistance, or Medicaid, will be reviewed every year.",
  "en.faa.renewal_process_1" => "This process is called renewal. %{short_name} will review eligibility by checking its records and other electronic data sources",
  "en.faa.renewal_process_2" => " including, with my consent, information about my federal tax returns from the IRS.",
  "en.faa.send_notice_1" => "%{short_name} will send me a notice that includes the information it has found by checking its records and other electronic data sources,",
  "en.faa.send_notice_2" => " and I will be able to correct information that is wrong. If found eligible for private health insurance, with or without financial assistance,",
  "en.faa.send_notice_3" => " or Medicaid, I may also be asked to provide additional information to extend coverage for another year for myself and/or other members of my application group.",
  "en.faa.i_agree" => "I agree",
  "en.faa.i_understand_eligibility_changes" => "I understand that I must report any changes that might affect my eligibility or the eligibility of a household member for health insurance.",
  "en.faa.report_changes_1" => "I can report changes by going online and logging into 'My Account', by calling %{short_name}'s Contact Center toll free at '#{Settings.contact_center.phone_number}' TTY: 711, ",
  "en.faa.report_changes_2" => "or by submitting information via mail or in-person at one of the Department of Human Services service centers.",
  "en.faa.signature_line_below_1" => "I'm the person whose name appears in the signature line below. ",
  "en.faa.signature_line_below_2" => "I understand that I'm submitting an application for health insurance and that information that I provided will be used to decide eligibility for each member of my application group.",
  "en.faa.i_understand_evaluation_1" => "",
  "en.faa.i_understand_evaluation_2" => "",
  "en.faa.i_understand_evaluation_3" => "",
  "en.faa.anyone_found_eligible_1" => "If anyone in my application group is found eligible for Medicaid, I am authorizing the Medicaid agency to pursue and get any money from other health insurance, ",
  "en.faa.anyone_found_eligible_2" => "legal settlements, or other third parties that may be legally responsible for paying for any health care received by me or members of my applicant group. ",
  "en.faa.anyone_found_eligible_3" => "",
  "en.faa.parent_living_outside_of_home_1" => "If yes, I know that, if anyone in my application group is found eligible for Medicaid, I will be asked to cooperate with the Child Support Agency ",
  "en.faa.parent_living_outside_of_home_2" => "to collect medical support from the parent who lives outside the home. If I think that cooperating to collect medical support will harm me or my children, ",
  "en.faa.parent_living_outside_of_home_3" => "I can tell my caseworker and I may not have to cooperate.",
  "en.faa.negative_income" => "Negative Income",
  "en.faa.full_long_name_determination" => "Based on the information you provided, no one on this application is likely to qualify for %{program_short_name}. Do you still want us to send your application to the %{program_long_name} so they can check on %{program_short_name} eligibility?",
  "en.faa.send_to_external_verification" => "Send to OFI", # TODO: This is for Maine, we don't know what it should be for DC yet, if anything,
  "en.faa.filing_as_head_of_household" => "Will this person be filing as head of household?",
  # Year Selection page
  "en.faa.year_selection_header" => "You’re About to Sign Up for Health Insurance that Starts January 1 or Later",
  "en.faa.year_selection_subheader" => "Select CONTINUE to start a new application for lower premiums or Medicaid.",
  "en.faa.assitance_year_option1" => "%{year} Open Enrollment",
  "en.faa.year_selection_oe_year" => " Open Enrollment",
  "en.faa.see_if_you_qualify_1" => "See if you qualify for lower monthly premiums for ",
  "en.faa.see_if_you_qualify_2" => " %{short_name} health insurance or free Medicaid coverage.",
  "en.faa.year_selection_oe_range_from" => "Open enrollment is from ",
  "en.faa.year_selection_oe_range_through" => " through ",
  "en.faa.year_selection_learn_more" => "If you need health insurance, lower premiums, or Medicaid now, you can <a target='_blank' href='https://www.dchealthlink.com/contact-us-for-2021-coverage?utm_source=2021EnrollmentCoverage&utm_medium=ea_link&utm_campaign=WantsCoverage2021'>submit a webform</a> or call %{short_name} at (855) 532-5465 / TTY: 711. <a target='_blank' href='https://www.dchealthlink.com/individuals/life-changes'>Learn more about Life Changes</a>.", # TODO: Update URL and phones
  'en.faa.publish_error.second_error_message' => 'There is an error while submitting the application for assistance determination.',
  "en.faa.eligibility_go_to_my_account_message" => "<b>If you’re already enrolled in DC Health Link’s Individual & Family plan</b>, you’re finished! To see your plan information, select <b>GO TO MY ACCOUNT</b>.",
  "en.faa.application_for_coverage" => "Application for Coverage",
  # Mec check
  "en.faa.mc_success" => "It looks like you may already be enrolled in Medicaid or CHIP. If you need to update information like your income, address, or who is in your household, contact DC Health Link at <a href='tel:1-855-532-5465'>1-855-532-5465</a> to make these changes before completing a DC Health Link application.",
  "en.faa.shop_check_success" => "It looks like you may already be enrolled in employer sponsored coverage. If you need to update information like your income, address, or who is in your household, visit the Manage Family page to make these changes before completing a DC Health Link application.",
  "en.faa.mc_continue" => "Select 'CONTINUE' if you would still like to complete a DC Health Link application.",
  # FAA display evidence type
  "en.faa.evidence_type_aces" => "Coverage from Medicaid and CHIP",
  "en.faa.evidence_type_esi" => "Coverage from a job",
  "en.faa.evidence_type_non_esi" => "Coverage from another program",
  "en.faa.evidence_type_income" => "Income",
  # FAA start new application page
  "en.faa.cost_savings_nav" => "Cost Savings",
  "en.faa.cost_savings_applications" => "Cost Savings Applications",
  "en.faa.cost_savings_applications_desc" => "If you started or completed an application for premium reductions, it will be listed below. If the status says it’s a draft, that means you haven’t completed the application. Select ‘Actions’ to view or update an application.",
  "en.faa.start_new_application" => "Start New Application",
  "en.faa.start_new_application_modal_body" => "You’re about to start a new application for cost savings. If you’ve got an application already, go to the most recent application and use ‘Actions’ to copy or update that application.",
  "en.faa.cancel" => "Cancel",
  "en.faa.income_temporary_message" => "<ul><li><strong>Start Date: </strong>If this is income you currently have, you must enter the date you began receiving this income in the 'From' field, or 1/1/%{current_year} (if the income started before this year). Do not enter a date in the future (for example, 1/1/%{next_year}) unless this is income that has not started but you expect to have in the future.</li><li><strong>End Date: </strong>Leave the 'To' field empty, unless you expect your income to end on a certain date (for example, if you have a seasonal job). Do not enter the last day of the year unless you know that you will not have this income the following year.</li></ul>",
  "en.faa.start_date_warning" => "<strong>Start Date: </strong>If this is income you currently have, you must enter the date you began receiving this income in the 'From' field, or 1/1/%{current_year} (if the income started before this year). Do not enter a date in the future (for example, 1/1/%{next_year}) unless this is income that has not started but you expect to have in the future.",
  "en.faa.end_date_warning" => "<strong>End Date: </strong>Leave the 'To' field empty, unless you expect your income to end on a certain date (for example, if you have a seasonal job). Do not enter the last day of the year unless you know that you will not have this income the following year.",
  "en.faa.not_applicable_abbreviation" => "N/A",
  # Transfer History
  "en.faa.transfer_history.column_header.transfer_id" => "Transfer Id",
  "en.faa.transfer_history.column_header.in_out_bound" => "In/Out Bound",
  "en.faa.transfer_history.column_header.timestamp" => "Timestamp",
  "en.faa.transfer_history.column_header.reason" => "Reason",
  "en.faa.transfer_history.column_header.source" => "Source",
  "en.faa.transfer_history" => "Transfer History",
  "en.faa.transfer_history_desc" => "Application transfers sent to or from %{site_short_name} related to this application are listed below.",
  "en.faa.no_history_available" => "No history available.",
  # Flash error display
  "en.faa.errors.should_be_answered" => "should be answered",
  "en.faa.errors.inconsistent_relationships_error" => "Some of the relationships you have listed are inconsistent. Review relationships and make sure each pair is correct.",
  "en.faa.errors.missing_relationships" => "You must have a complete set of relationships defined among every member.",
  "en.faa.errors.extra_relationship" => "Extra relationship exist without an applicant.",
  "en.faa.errors.invalid_application" => "Unable to create new application because of some validation errors.",
  "en.faa.errors.copy_application_error" => "Unable to copy given application.",
  "en.faa.errors.key_application_id_missing_error" => 'Missing application_id key.',
  "en.faa.errors.unable_to_find_application_error" => 'Unable to find application with given application_id.',
  "en.faa.errors.given_application_is_not_submitted_error" => 'Application is not in one of the %{valid_states} states',
  "en.faa.errors.invalid_household_relationships" => "Invalid set of relationships defined among household members.",

  "en.faa.results.eligibility_results" => "Eligibility Results",
  "en.faa.results.tax_household" => "Tax Household %{thh_number}",
  "en.faa.results.review_eligibility_header" => "Your Application for Lower Premiums",
  "en.faa.results.aptc_heading" => "Your Application for Lower Premiums",
  "en.faa.results.aptc_text" => "These people qualify for lower monthly premiums with financial assistance of $%{aptc} per month to be applied to the monthly premium amount selected during plan selection.",
  "en.faa.results.csr_73_87_or_94_text" => "These people qualify for for lower out-of-pocket costs including lower annual deductibles and lower copayments. This benefit is only available for a silver plan. To select a silver health plan, look for a checkbox next to the plan name.",
  "en.faa.results.csr_100_text" => "These people also qualify for lower out-of-pocket costs - a benefit that lowers other costs like the annual deductible and copayments. They also won’t pay anything for services they receive from an Indian Health Service provider.",
  "en.faa.results.csr_nal_text" => "These people won’t pay anything for services they receive from an Indian Health Service provider.",
  "en.faa.results.csr" => "Cost Sharing Reduction %{csr}",
  "en.faa.results.medicaid_or_chip_heading" => "Medicaid",
  "en.faa.results.medicaid_or_chip_text" => "These people appear to be eligible for Medicaid MaineCare (Medicaid) or Cub Care (the Children's Health Insurance Program):",
  "en.faa.results.medicaid_or_chip_special_box" => 'Next step: The Office for Family Independence will make a final decision on whether those listed qualify for MaineCare and Cub Care. They will send you a letter, and may ask you to provide documents. If you haven’t heard from OFI within 45 days, you may want to ask for an update by calling (855) 797-4357 / TTY: 711.',
  "en.faa.results.non_magi_referral_heading" => "Special MaineCare Referral",
  "en.faa.results.non_magi_referral_text" => "These people may qualify for MaineCare for reasons like age or disability:",
  "en.faa.results.non_magi_referral_special_box" => 'NEXT STEP: We are sending your application to the Department of Health and Human Services (DHHS). They will contact you to get more information to see if you qualify.',
  "en.faa.results.uqhp_heading" => "Private Health Insurance",
  "en.faa.results.uqhp_text" => "These people qualify to enroll in a private health insurance plan:",
  "en.faa.results.totally_ineligible_heading" => "Does Not Qualify",
  "en.faa.results.totally_ineligible_text" => "These people likely don't qualify for %{medicaid_or_chip_program_short_name}, and don't qualify to enroll in an insurance plan through %{short_name}.",
  "en.faa.results.next_steps" => 'Next Steps',
  "en.faa.results.all_medicaid_next_steps_continue_text" => "MaineCare coverage is free. If you would like to enroll and pay full price for an insurance plan through %{short_name}",
  "en.faa.results.next_steps_text" => "If you’re already enrolled in a %{short_name} plan, you’re finished! You’ll see any updates applied to your plan in a minute or two. Select “Return to Account Home“.",
  "en.faa.results.return_to_account_home" => 'Return to Account Home',
  "en.faa.results.continue_text" => "Select “CONTINUE” to see if you are eligible to select a new plan or make changes to your current plan.",
  "en.faa.results.your_application_reference_2" => "Application Reference ID: %{application_hbx_id}",
  "en.faa.results.view_my_applications" => "View my Applications",
  "en.faa.go_to_my_account" => "Go to my account",
  "en.faa.results.medicaid_eligible_next_steps" => "Medicaid coverage is free. If you would like to enroll and pay full price for private health insurance instead, select CONTINUE to:",
  "en.faa.results.medicaid_eligible_step1" => "pick a plan, or",
  "en.faa.results.medicaid_eligible_step2" => "add or remove someone from your plan.",
  "en.faa.verification.documents" => "Cost Savings Documents"
}.freeze
# rubocop:enable Layout/LineLength
