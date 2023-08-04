import PropTypes from "prop-types";
import { useParams } from "react-router-dom";
import { useEffect } from "react";
import { useDispatch } from "react-redux";

import { useMemoizedSelector } from "../../libs";
import { getIncidentFromCase, selectRecord, getCaseIdForIncident, fetchRecord } from "../records";
import { RECORD_PATH, RECORD_TYPES, SUMMARY, RECORD_TYPES_PLURAL } from "../../config";
import {
  usePermissions,
  SHOW_FIND_MATCH,
  READ_RECORDS,
  REFER_FROM_SERVICE,
  SHOW_CHANGE_LOG,
  RESOURCES
} from "../permissions";
import { getRecordAttachments, getLoadingRecordState } from "../records/selectors";
import { getPermittedFormsIds } from "../user/selectors";
import { useApp } from "../application";

import {
  getAttachmentForms,
  getFirstTab,
  getFormNav,
  getRecordForms,
  getRecordFormsByUniqueId,
  getShouldFetchRecord
} from "./selectors";
import { NAME } from "./constants";
import { RecordForm } from "./components/record-form";

let caseRegistryLoaded = false;

const Container = ({ mode }) => {
  const params = useParams();
  const { demo } = useApp();
  const dispatch = useDispatch();
  const recordType = RECORD_TYPES[params.recordType];

  const containerMode = {
    isNew: mode === "new",
    isEdit: mode === "edit",
    isShow: mode === "show"
  };

  const isEditOrShow = containerMode.isEdit || containerMode.isShow;

  const canViewCases = usePermissions(params.recordType, READ_RECORDS);
  const canViewSummaryForm = usePermissions(RESOURCES.potential_matches, SHOW_FIND_MATCH);
  const canRefer = usePermissions(params.recordType, REFER_FROM_SERVICE);
  const canSeeChangeLog = usePermissions(params.recordType, SHOW_CHANGE_LOG);

  const incidentFromCase = useMemoizedSelector(state => getIncidentFromCase(state, recordType));
  const fetchFromCaseId = useMemoizedSelector(state => getCaseIdForIncident(state, recordType));
  const record = useMemoizedSelector(state =>
    selectRecord(state, { isEditOrShow, recordType: params.recordType, id: params.id })
  );
  const loading = useMemoizedSelector(state => getLoadingRecordState(state, params.recordType));
  const userPermittedFormsIds = useMemoizedSelector(state => getPermittedFormsIds(state));

  const selectedModule = {
    recordType,
    primeroModule: record ? record.get("module_id") : params.module,
    checkPermittedForms: true,
    renderCustomForms: canViewSummaryForm,
    checkWritable: true
  };

  const formNav = useMemoizedSelector(state => getFormNav(state, selectedModule));
  const forms = useMemoizedSelector(state => getRecordForms(state, selectedModule));
  const attachmentForms = useMemoizedSelector(state => getAttachmentForms(state));
  const firstTab = useMemoizedSelector(state => getFirstTab(state, selectedModule));
  const recordAttachments = useMemoizedSelector(state => getRecordAttachments(state, params.recordType));
  const summaryForm = useMemoizedSelector(state =>
    getRecordFormsByUniqueId(state, { ...selectedModule, formName: SUMMARY, getFirst: true })
  );
  const shouldFetchRecord = useMemoizedSelector(state => getShouldFetchRecord(state, params));

  const isNotANewCase = !containerMode.isNew && params.recordType === RECORD_PATH.cases;
  const isCaseIdEqualParam = params?.id === record?.get("id");
  const approvalSubforms = record?.get("approval_subforms");
  const incidentsSubforms = record?.get("incident_details");
  const registryRecordID = record?.get("registry_record_id", false);

  useEffect(() => {
    if (registryRecordID && !loading && !caseRegistryLoaded && params.recordType === RECORD_PATH.cases) {
      dispatch(fetchRecord(RECORD_TYPES_PLURAL.registry_record, registryRecordID));
      caseRegistryLoaded = true;
    }
  }, [loading, registryRecordID]);

  useEffect(() => {
    return () => {
      caseRegistryLoaded = false;
    };
  }, []);

  return (
    <RecordForm
      params={params}
      forms={forms}
      incidentFromCase={incidentFromCase}
      shouldFetchRecord={shouldFetchRecord}
      summaryForm={summaryForm}
      recordAttachments={recordAttachments}
      firstTab={firstTab}
      attachmentForms={attachmentForms}
      canViewCases={canViewCases}
      canViewSummaryForm={canViewSummaryForm}
      formNav={formNav}
      fetchFromCaseId={fetchFromCaseId}
      userPermittedFormsIds={userPermittedFormsIds}
      demo={demo}
      canRefer={canRefer}
      canSeeChangeLog={canSeeChangeLog}
      containerMode={containerMode}
      mode={mode}
      record={record}
      recordType={recordType}
      isNotANewCase={isNotANewCase}
      isCaseIdEqualParam={isCaseIdEqualParam}
      approvalSubforms={approvalSubforms}
      incidentsSubforms={incidentsSubforms}
    />
  );
};

Container.displayName = NAME;

Container.propTypes = {
  mode: PropTypes.string.isRequired
};

export default Container;
