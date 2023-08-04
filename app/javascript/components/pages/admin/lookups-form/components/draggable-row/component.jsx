import PropTypes from "prop-types";
import { Draggable } from "react-beautiful-dnd";

import css from "../styles.css";
import { DragIndicator } from "../../../forms-list/components";
import FormSectionField from "../../../../../form/components/form-section-field";
import { FieldRecord, TEXT_FIELD } from "../../../../../form";
import SwitchInput from "../../../../../form/fields/switch-input";
import { LOCALE_KEYS } from "../../../../../../config";

import { NAME } from "./constants";

const Component = ({
  firstLocaleOption,
  index,
  isDragDisabled,
  isLockedLookup,
  localesKeys,
  selectedOption,
  uniqueId,
  formMode,
  formMethods
}) => {
  const renderTranslationValues = () => {
    return localesKeys.map(localeKey => {
      const name = `values.${localeKey}.${uniqueId}`;
      const show = firstLocaleOption === localeKey || selectedOption === localeKey;

      if (!show) return null;

      return (
        <div key={name}>
          <FormSectionField
            field={FieldRecord({ name, type: TEXT_FIELD, disabled: localeKey === LOCALE_KEYS.en && isLockedLookup })}
            formMode={formMode}
            formMethods={formMethods}
          />
        </div>
      );
    });
  };

  const renderDisabledCheckbox = (
    <div className={css.dragIndicatorContainer}>
      <SwitchInput
        commonInputProps={{ name: `disabled.${uniqueId}`, disabled: isDragDisabled || isLockedLookup }}
        metaInputProps={{ selectedValue: true }}
        formMethods={formMethods}
      />
    </div>
  );

  return (
    <Draggable key={uniqueId} draggableId={uniqueId} index={index} isDragDisabled={isDragDisabled}>
      {provider => {
        return (
          <div ref={provider.innerRef} {...provider.draggableProps} {...provider.dragHandleProps} className={css.row}>
            <div className={css.dragIndicatorContainer}>
              <DragIndicator {...provider.dragHandleProps} />
            </div>
            {renderTranslationValues()}
            {renderDisabledCheckbox}
          </div>
        );
      }}
    </Draggable>
  );
};

Component.displayName = NAME;

Component.propTypes = {
  firstLocaleOption: PropTypes.string,
  formMethods: PropTypes.object.isRequired,
  formMode: PropTypes.object.isRequired,
  index: PropTypes.number,
  isDragDisabled: PropTypes.bool,
  isLockedLookup: PropTypes.bool,
  localesKeys: PropTypes.array,
  selectedOption: PropTypes.string,
  uniqueId: PropTypes.string
};

export default Component;
