/* eslint-disable react/display-name */
import Transitions from "../../../transitions";
import {
  APPROVALS,
  RECORD_OWNER,
  TRANSITION_TYPE,
  INCIDENT_FROM_CASE,
  CHANGE_LOGS,
  SUMMARY,
  RECORD_TYPES_PLURAL,
  REGISTRY_FROM_CASE,
  SUMMARY_INCIDENT_MRM
} from "../../../../config";
import RecordOwner from "../../../record-owner";
import Approvals from "../../../approvals";
import IncidentFromCase from "../../../incidents-from-case";
import ChangeLogs from "../../../change-logs";
import Summary from "../../../summary";
import CaseRegistry from "../../form/components/case-registry";
import SummaryIncidentMRM from "../../../summary-incident-mrm";

const externalForms =
  ({
    approvalSubforms,
    canSeeChangeLog,
    containerMode,
    handleCreateIncident,
    handleToggleNav,
    id,
    incidentsSubforms,
    mobileDisplay,
    primeroModule,
    record,
    recordType,
    selectedForm,
    summaryForm,
    transitionProps,
    userPermittedFormsIds
  }) =>
  (form, setFieldValue, handleSubmit, values, dirty, formSections) => {
    const isTransitions = TRANSITION_TYPE.includes(form);

    const externalFormSelected = isTransitions ? TRANSITION_TYPE : form;

    return {
      [RECORD_OWNER]: (
        <RecordOwner
          record={record}
          recordType={recordType}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
        />
      ),
      [APPROVALS]: (
        <Approvals approvals={approvalSubforms} mobileDisplapary={mobileDisplay} handleToggleNav={handleToggleNav} />
      ),
      [INCIDENT_FROM_CASE]: (
        <IncidentFromCase
          record={record}
          incidents={incidentsSubforms}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          mode={containerMode}
          setFieldValue={setFieldValue}
          handleSubmit={handleSubmit}
          recordType={recordType}
          primeroModule={primeroModule}
          handleCreateIncident={handleCreateIncident}
          dirty={dirty}
        />
      ),
      [TRANSITION_TYPE]: <Transitions {...transitionProps} />,
      [CHANGE_LOGS]: (
        <ChangeLogs
          recordID={id}
          fetchable={canSeeChangeLog}
          recordType={RECORD_TYPES_PLURAL[recordType]}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          primeroModule={primeroModule}
          selectedForm={selectedForm}
        />
      ),
      [SUMMARY]: (
        <Summary
          record={record}
          recordType={recordType}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          form={summaryForm}
          mode={containerMode}
          values={values}
          userPermittedFormsIds={userPermittedFormsIds}
        />
      ),
      [REGISTRY_FROM_CASE]: (
        <CaseRegistry
          values={values}
          record={record}
          mode={containerMode}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          primeroModule={primeroModule}
          recordType={recordType}
          setFieldValue={setFieldValue}
        />
      ),
      [SUMMARY_INCIDENT_MRM]: (
        <SummaryIncidentMRM
          recordType={recordType}
          recordID={id}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          mode={containerMode}
          formSections={formSections}
          values={values}
        />
      )
    }[externalFormSelected];
  };

export default externalForms;
