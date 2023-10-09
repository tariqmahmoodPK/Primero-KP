/* TODO Update the referencing comments after properly updating the files */

import { namespaceActions } from "../../../libs";

import NAMESPACE from "./namespace";

export default namespaceActions(NAMESPACE, [
  "CASES_BY_CASE_WORKER",
  "CASES_BY_STATUS",
  "CASES_REGISTRATION",
  "CASES_OVERVIEW",
  "DASHBOARDS",
  "DASHBOARDS_STARTED",
  "DASHBOARDS_SUCCESS",
  "DASHBOARDS_FINISHED",
  "DASHBOARDS_FAILURE",
  "DASHBOARD_FLAGS",
  "DASHBOARD_FLAGS_STARTED",
  "DASHBOARD_FLAGS_SUCCESS",
  "DASHBOARD_FLAGS_FINISHED",
  "DASHBOARD_FLAGS_FAILURE",
  "OPEN_PAGE_ACTIONS",
  "SERVICES_STATUS",
  // 'Percentage of Children who received Child Protection Services'
  "PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES",
  "PERCENTAGE_OF_CHILDREN_WHO_RECEIVED_CHILD_PROTECTION_SERVICES_SUCCESS",
  // 'Closed Cases by Sex and Reason'
  "RESOLVED_CASES_BY_GENDER_AND_REASON",
  "RESOLVED_CASES_BY_GENDER_AND_REASON_SUCCESS",
  // 'Cases Referrals (To Agency)'
  "CASES_REFERRALS_TO_AGENCY",
  "CASES_REFERRALS_TO_AGENCY_SUCCESS",
  // -------------------------------------------------------------------
  // 'Cases requiring Alternative Care Placement Services'
  "CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES",
  "CASES_REQUIRING_ALTERNATIVE_CARE_PLACEMENT_SERVICES_SUCCESS",
  // -------------------------------------------------------------------
  // month_wise_registered_and_resolved_cases_stats
  // Registered and Closed Cases by Month
  "MONTHLY_REGISTERED_AND_RESOLVED_CASES",
  "MONTHLY_REGISTERED_AND_RESOLVED_CASES_SUCCESS",
  // -------------------------------------------------------------------
  // significant_harm_cases_registered_by_age_and_gender_stats
  // Significant Harm Cases by Protection Concern
  "HARM_CASES",
  "HARM_CASES_SUCCESS",
  // -------------------------------------------------------------------
  "REGISTERED_CASES_BY_PROTECTION_CONCERN_REAL",
  "REGISTERED_CASES_BY_PROTECTION_CONCERN_REAL_SUCCESS"
  // -------------------------------------------------------------------
]);
