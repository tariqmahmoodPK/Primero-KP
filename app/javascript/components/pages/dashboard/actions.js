/* TODO Update the referencing comments after properly updating the files */
/* TODO Add Explanatory Comments */

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
  // protection_concerns_services_stats
  "REGISTERED_CASES_BY_PROTECTION_CONCERN",
  "REGISTERED_CASES_BY_PROTECTION_CONCERN_SUCCESS",
  // -------------------------------------------------------------------
  // resolved_cases_by_gender_and_types_of_violence_stats
  // Closed Cases by Sex and Protection Concern
  "RES_CASES_BY_GENDER",
  "RES_CASES_BY_GENDER_SUCCESS",
  // -------------------------------------------------------------------
  // cases_referral_to_agency_stats
  // Cases Referral (To Agency )
  "CASES_REFERRAL_TO_AGENCY",
  "CASES_REFERRAL_TO_AGENCY_SUCCESS",
  // -------------------------------------------------------------------
  // alternative_care_placement_by_gender
  // Cases requiring Alternative Care Placement Services
  "GRAPH_THREE_SUCCESS",
  "GRAPH_FOUR"
  // -------------------------------------------------------------------
]);
