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
  "REGISTERED_CASES_BY_PROTECTION_CONCERN_SUCCESS"
  // -------------------------------------------------------------------
]);
