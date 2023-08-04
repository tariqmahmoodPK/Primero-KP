/* eslint-disable react/display-name */
/* eslint-disable react/no-multi-comp */
import { fromJS } from "immutable";
import { Tooltip } from "@material-ui/core";
import OfflinePin from "@material-ui/icons/OfflinePin";

import { ToggleIconCell } from "../../index-table";
import { RECORD_PATH, RECORD_TYPES } from "../../../config";
import { ALERTS_COLUMNS, ALERTS, ID_COLUMNS, COMPLETE } from "../constants";
import PhotoColumnBody from "../components/photo-column-body";
import DisableColumnOffline from "../components/disable-column-offline";

export default (allowedColumns, i18n, recordType, css, recordAvailable, online) => {
  const iconColumns = Object.values(ALERTS_COLUMNS);
  // eslint-disable-next-line react/display-name, jsx-a11y/control-has-associated-label
  const emptyHeader = name => <th key={name} className={css.overdueHeading} />;

  const rowAvailable = (rowIndex, data) => recordAvailable(data.getIn(["data", rowIndex], fromJS({}))) || online;

  const tableColumns = data => {
    let columns = allowedColumns
      .filter(column => ![ALERTS_COLUMNS.flag_count, ALERTS_COLUMNS.alert_count].includes(column.get("name")))
      .map(column => {
        const options = (name => {
          switch (name) {
            case ALERTS_COLUMNS.photo:
              return {
                disableOnClick: true,
                customHeadLabelRender: columnMeta => i18n.t(`${recordType}.${columnMeta.name}`),
                setCellHeaderProps: () => {
                  return { style: { width: "45px" } };
                },
                // eslint-disable-next-line react/no-multi-comp, react/display-name
                customBodyRender: (value, { rowIndex }) => (
                  <DisableColumnOffline
                    component={<PhotoColumnBody value={value} css={css} />}
                    rowAvailable={rowAvailable(rowIndex, data)}
                  />
                )
              };
            case "registration_date":
              return {
                customBodyRender: (value, { rowIndex }) => (
                  <DisableColumnOffline
                    value={value}
                    withTime={false}
                    rowAvailable={rowAvailable(rowIndex, data)}
                    type="date"
                  />
                )
              };
            case "case_opening_date":
              return {
                customBodyRender: (value, { rowIndex }) => (
                  <DisableColumnOffline
                    value={value}
                    withTime
                    type="date"
                    rowAvailable={rowAvailable(rowIndex, data)}
                  />
                )
              };
            case "id":
              return {
                // eslint-disable-next-line react/display-name
                customBodyRender: (value, { rowData, rowIndex }) => {
                  const idValue = column.get("field_name") === ID_COLUMNS.case_id_display ? value || rowData[1] : value;

                  return (
                    <div className={css.id}>
                      <DisableColumnOffline value={idValue} rowAvailable={rowAvailable(rowIndex, data)} />
                    </div>
                  );
                }
              };
            case "complete":
              return {
                customHeadLabelRender: () => <OfflinePin className={css.iconHeader} />,
                sort: !online,
                disableOnClick: true,
                customBodyRender: value => {
                  return value ? (
                    <Tooltip open title={i18n.t("action.marked_for_offline")}>
                      <ToggleIconCell value={value} icon={COMPLETE} />
                    </Tooltip>
                  ) : (
                    <span />
                  );
                }
              };
            default:
              return {
                sort: column.get("sort", true),
                customBodyRender: (value, { rowIndex }) => (
                  <DisableColumnOffline value={value} rowAvailable={rowAvailable(rowIndex, data)} />
                )
              };
          }
        })(column.get("name"));

        return {
          label: [...iconColumns].includes(column.get("name")) ? " " : i18n.t(`${recordType}.${column.get("name")}`),
          name: column.get("field_name") || " ",
          id: column.get("id_search"),
          options: {
            ...options,
            display: !(
              RECORD_TYPES[recordType] === RECORD_TYPES.cases && column.get("field_name") === ID_COLUMNS.short_id
            )
          }
        };
      })
      .sortBy(column => (iconColumns.includes(column.name) ? 1 : 0));

    const canShowAlertIcon = allowedColumns.some(allowedColumn => allowedColumn.name === ALERTS_COLUMNS.alert_count);
    const canShowFlagIcon = allowedColumns.some(allowedColumn => allowedColumn.name === ALERTS_COLUMNS.flag_count);

    if ([RECORD_PATH.cases, RECORD_PATH.incidents, RECORD_PATH.tracing_requests].includes(recordType)) {
      columns = columns.push({
        label: "",
        name: ALERTS,
        id: false,
        sort: false,
        options: {
          disableOnClick: true,
          customHeadRender: columnMeta => emptyHeader(columnMeta),
          // eslint-disable-next-line react/no-multi-comp, react/display-name
          customBodyRender: (value, { rowIndex }) => {
            const alertIcon =
              // eslint-disable-next-line camelcase
              canShowAlertIcon && value?.alert_count > 0 ? (
                <ToggleIconCell value={value.alert_count} icon={ALERTS_COLUMNS.alert_count} />
              ) : (
                <span />
              );

            const flagIcon =
              // eslint-disable-next-line camelcase
              canShowFlagIcon && value?.flag_count > 0 ? (
                <ToggleIconCell value={value.flag_count} icon={ALERTS_COLUMNS.flag_count} />
              ) : (
                <span />
              );

            return (
              <DisableColumnOffline
                value={
                  <div className={css.alerts}>
                    {alertIcon}
                    {flagIcon}
                  </div>
                }
                rowAvailable={rowAvailable(rowIndex, data)}
              />
            );
          }
        }
      });
    }

    return columns;
  };

  return data => tableColumns(data);
};
