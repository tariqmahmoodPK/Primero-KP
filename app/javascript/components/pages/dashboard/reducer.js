/* TODO Update the referencing comments after properly updating the files */
/* TODO Add Explanatory Comments */

import { fromJS, Map } from "immutable";
import orderBy from "lodash/orderBy";

import actions from "./actions";
import NAMESPACE from "./namespace";
import { DASHBOARD_FLAGS_SORT_ORDER, DASHBOARD_FLAGS_SORT_FIELD } from "./constants";

const DEFAULT_STATE = Map({});

const reducer = (state = DEFAULT_STATE, { type, payload }) => {
  switch (type) {
    // protection_concerns_services_stats
    // Percentage of Children who received Child Protection Services
    case actions.REGISTERED_CASES_BY_PROTECTION_CONCERN_SUCCESS:
      return state.set("registeredCasesByProtectionConcern", fromJS(payload));
    // ------------------------------------------------------------------------
    // resolved_cases_by_gender_and_types_of_violence_stats
    // Closed Cases by Sex and Protection Concern
    case actions.RES_CASES_BY_GENDER_SUCCESS:
      return state.set("resCasesByGender", fromJS(payload));
    // ------------------------------------------------------------------------
    // cases_referral_to_agency_stats
    // Cases Referral (To Agency )
    case actions.CASES_REFERRAL_TO_AGENCY_SUCCESS:
      return state.set("casesReferralToAgency", fromJS(payload));
    // ------------------------------------------------------------------------
    case actions.DASHBOARD_FLAGS:
      return state.set("flags", fromJS(payload));
    case actions.CASES_BY_STATUS:
      return state.set("casesByStatus", fromJS(payload.casesByStatus));
    case actions.CASES_BY_CASE_WORKER:
      return state.set("casesByCaseWorker", fromJS(payload.casesByCaseWorker));
    case actions.CASES_REGISTRATION:
      return state.set("casesRegistration", fromJS(payload.casesRegistration));
    case actions.CASES_OVERVIEW:
      return state.set("casesOverview", fromJS(payload.casesOverview));
    case actions.DASHBOARDS_STARTED:
      return state.set("loading", fromJS(payload)).set("errors", false);
    case actions.DASHBOARDS_SUCCESS:
      return state.set("data", fromJS(payload.data));
    case actions.DASHBOARDS_FINISHED:
      return state.set("loading", fromJS(payload));
    case actions.DASHBOARDS_FAILURE:
      return state.set("errors", true);
    case actions.DASHBOARD_FLAGS_STARTED:
      return state.setIn(["flags", "loading"], fromJS(payload)).setIn(["flags", "errors"], false);
    case actions.DASHBOARD_FLAGS_SUCCESS: {
      const orderedArray = orderBy(payload.data, dateObj => new Date(dateObj[DASHBOARD_FLAGS_SORT_FIELD]), [
        DASHBOARD_FLAGS_SORT_ORDER
      ]);

      return state.setIn(["flags", "data"], fromJS(orderedArray));
    }
    case actions.DASHBOARD_FLAGS_FINISHED:
      return state.setIn(["flags", "loading"], fromJS(payload));
    case actions.DASHBOARD_FLAGS_FAILURE:
      return state.setIn(["flags", "errors"], true);
    case actions.SERVICES_STATUS:
      return state.set("servicesStatus", fromJS(payload.services));
    case actions.OPEN_PAGE_ACTIONS:
      return state.set("isOpenPageActions", fromJS(payload));
    case "user/LOGOUT_SUCCESS":
      return DEFAULT_STATE;
    default:
      return state;
  }
};

export default { [NAMESPACE]: reducer };
