import PropTypes from "prop-types";

import { fields } from "../../form";
import { useI18n } from "../../../i18n";
import { FieldRecord, FormSectionField } from "../../../record-form";

import { NAME } from "./constants";
import css from "./styles.css";

const Component = ({ recordID, recordType, mode }) => {
  const i18n = useI18n();

  return fields(i18n).map(field => {
    const formattedField = FieldRecord(field);
    const fieldProps = {
      name: formattedField.name,
      field: formattedField,
      mode,
      recordType,
      recordID
    };

    return (
      <div className={css.field}>
        <FormSectionField {...fieldProps} />
      </div>
    );
  });
};

Component.displayName = NAME;

Component.propTypes = {
  mode: PropTypes.object,
  record: PropTypes.object,
  recordType: PropTypes.string.isRequired
};

export default Component;
