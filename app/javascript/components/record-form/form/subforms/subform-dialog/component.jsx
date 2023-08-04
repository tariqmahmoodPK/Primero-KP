/* eslint-disable react/no-multi-comp, react/display-name */
import { useEffect, useState, useRef } from "react";
import PropTypes from "prop-types";
import { Formik, Form, getIn } from "formik";
import { object } from "yup";
import isEmpty from "lodash/isEmpty";

import { fieldValidations } from "../../validations";
import { SUBFORM_DIALOG } from "../constants";
import ServicesSubform from "../services-subform";
import SubformMenu from "../subform-menu";
import { getSubformValues, serviceHasReferFields, updateSubformEntries, addSubformEntries } from "../../utils";
import ActionDialog from "../../../../action-dialog";
import SubformDrawer from "../subform-drawer";
import { compactValues, constructInitialValues } from "../../../utils";
import SubformErrors from "../subform-errors";
import SubformDialogFields from "../subform-dialog-fields";
import ViolationActions from "../subform-fields/components/violation-actions";
import ViolationTitle from "../subform-fields/components/violation-title";
import uuid from "../../../../../libs/uuid";
import { useApp } from "../../../../application";

const Component = ({
  arrayHelpers,
  dialogIsNew,
  field,
  formik,
  formSection,
  i18n,
  index,
  isFormShow,
  mode,
  oldValue,
  open,
  setOpen,
  title,
  isReadWriteForm,
  orderedValues,
  recordType,
  recordModuleID,
  parentTitle,
  isViolation,
  isViolationAssociation,
  violationOptions
}) => {
  const { online } = useApp();
  const [initialValues, setInitialValues] = useState({});
  const [openConfirmationModal, setOpenConfirmationModal] = useState(false);
  const childFormikRef = useRef();
  const isValidIndex = index === 0 || index > 0;
  const asDrawer = isViolation || isViolationAssociation;

  const subformValues = getSubformValues(field, index, formik.values, orderedValues, isViolation);

  const initialSubformValues = isEmpty(subformValues) ? initialValues : subformValues;

  const isNewViolation = isEmpty(subformValues);

  const initialSubformErrors = isValidIndex ? getIn(formik.errors, `${field.name}[${index}]`) : {};

  const buildSchema = () => {
    const subformSchema = field.subform_section_id.fields.map(sf => fieldValidations(sf, { i18n, online }));

    return object().shape(Object.assign({}, ...subformSchema));
  };

  const handleClose = () => {
    const compactedValues = compactValues(childFormikRef.current.values, initialSubformValues);

    if (Object.keys(childFormikRef.current.touched).length || Object.keys(compactedValues).length) {
      setOpenConfirmationModal(true);
    } else {
      setOpen({ open: false, index: null });
    }
  };

  let boundSubmitForm = null;

  const bindSubmitForm = submitForm => {
    boundSubmitForm = submitForm;
  };

  const onSubmit = values => {
    // eslint-disable-next-line camelcase
    const valuesWithUniqueId = { ...values, ...(!values?.unique_id ? { unique_id: uuid.v4() } : {}) };

    if (isValidIndex) {
      updateSubformEntries(formik, field.name, index, valuesWithUniqueId, isViolation);
    } else {
      addSubformEntries(formik, arrayHelpers, { ...initialSubformValues, ...valuesWithUniqueId }, isViolation);
      formik.setTouched({ [field.name]: true });
    }

    // Trigger validations only if the form was already submitted.
    if (formik.submitCount) {
      formik.validateForm();
    }

    setOpen({ open: false, index: null });
  };

  const buttonDialogText = dialogIsNew ? "buttons.add" : "buttons.update";

  const dialogActions =
    field.subform_section_id.unique_id === "services_section" &&
    mode.isShow &&
    // eslint-disable-next-line camelcase
    serviceHasReferFields(formik.values?.services_section?.[index]) ? (
      <SubformMenu index={index} values={formik.values.services_section} />
    ) : null;

  const renderSubform = (subformField, subformIndex, values, setFieldValue) => {
    if (subformField.subform_section_id.unique_id === "services_section") {
      return (
        <ServicesSubform
          field={subformField}
          index={subformIndex}
          mode={mode}
          formSection={formSection}
          isReadWriteForm={isReadWriteForm}
          recordType={recordType}
          recordModuleID={recordModuleID}
          values={values}
          parentValues={formik.values}
        />
      );
    }

    return (
      <SubformDialogFields
        field={subformField}
        mode={mode}
        index={subformIndex}
        formSection={formSection}
        isReadWriteForm={isReadWriteForm}
        values={values}
        parentValues={formik.values}
        parentTitle={title}
        parentViolationOptions={violationOptions}
        arrayHelpers={arrayHelpers}
        isViolation={isViolation}
        isViolationAssociation={isViolationAssociation}
        setFieldValue={setFieldValue}
      />
    );
  };

  const modalConfirmationProps = {
    open: openConfirmationModal,
    maxSize: "xs",
    confirmButtonLabel: i18n.t("buttons.ok"),
    dialogTitle: title,
    dialogText: i18n.t("messages.confirmation_message_subform"),
    disableBackdropClick: true,
    cancelHandler: () => setOpenConfirmationModal(false),
    successHandler: () => {
      arrayHelpers.replace(index, oldValue);
      setOpen({ open: false, index: null });
      setOpenConfirmationModal(true);
    }
  };

  const ComponentToRender = asDrawer ? SubformDrawer : ActionDialog;
  const propsForComponent = asDrawer
    ? {
        open,
        cancelHandler: handleClose,
        title: <ViolationTitle title={title} values={subformValues} fields={field.subform_section_id.fields} />
      }
    : {
        open,
        successHandler: e => boundSubmitForm(e),
        cancelHandler: handleClose,
        dialogTitle: title,
        title,
        omitCloseAfterSuccess: true,
        confirmButtonLabel: i18n.t(buttonDialogText),
        onClose: handleClose,
        dialogActions,
        disableActions: isFormShow
      };

  const handleBackLabel = i18n.t(`incident.violation.${isNewViolation ? "save" : "update"}_and_return`, {
    association: isViolationAssociation ? parentTitle || title : i18n.t("incident.violation.title")
  });

  useEffect(() => {
    if (open) {
      setInitialValues(constructInitialValues([field.subform_section_id]));
    }
  }, [open]);

  return (
    <>
      <ComponentToRender {...propsForComponent}>
        <Formik
          initialValues={initialSubformValues}
          validationSchema={buildSchema()}
          validateOnBlur={false}
          validateOnChange={false}
          enableReinitialize
          onSubmit={values => onSubmit(values)}
          innerRef={childFormikRef}
        >
          {({ handleSubmit, submitForm, setErrors, setTouched, errors, values, setFieldValue }) => {
            bindSubmitForm(submitForm);

            return (
              <Form autoComplete="off" onSubmit={handleSubmit}>
                <SubformErrors
                  initialErrors={initialSubformErrors}
                  errors={errors}
                  setErrors={setErrors}
                  setTouched={setTouched}
                />
                {asDrawer && (
                  <ViolationActions
                    handleBackLabel={handleBackLabel}
                    handleBack={event => submitForm(event)}
                    handleCancel={handleClose}
                    isShow={mode.isShow}
                  />
                )}
                {renderSubform(field, index, values, setFieldValue)}
              </Form>
            );
          }}
        </Formik>
      </ComponentToRender>
      <ActionDialog {...modalConfirmationProps} />
    </>
  );
};

Component.displayName = SUBFORM_DIALOG;

Component.propTypes = {
  arrayHelpers: PropTypes.object.isRequired,
  asDrawer: PropTypes.bool.isRequired,
  dialogIsNew: PropTypes.bool.isRequired,
  field: PropTypes.object.isRequired,
  formik: PropTypes.object.isRequired,
  formSection: PropTypes.object,
  i18n: PropTypes.object.isRequired,
  index: PropTypes.number,
  isFormShow: PropTypes.bool,
  isReadWriteForm: PropTypes.bool,
  isViolation: PropTypes.bool.isRequired,
  isViolationAssociation: PropTypes.bool.isRequired,
  mode: PropTypes.object.isRequired,
  oldValue: PropTypes.object,
  open: PropTypes.bool.isRequired,
  orderedValues: PropTypes.array.isRequired,
  parentTitle: PropTypes.string,
  recordModuleID: PropTypes.string,
  recordType: PropTypes.string,
  setOpen: PropTypes.func.isRequired,
  subformSectionConfiguration: PropTypes.object,
  title: PropTypes.string.isRequired,
  violationOptions: PropTypes.array
};

export default Component;
