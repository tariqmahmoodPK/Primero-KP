import { Map, fromJS } from "immutable";
import AddIcon from "@material-ui/icons/Add";
import { Menu, MenuItem } from "@material-ui/core";

import { setupMountedComponent } from "../../../../../test";
import { FieldRecord, FormSectionRecord } from "../../../records";
import { TRACING_REQUEST_STATUS_FIELD_NAME, TRACES_SUBFORM_UNIQUE_ID } from "../../../../../config";
import SubformDialog from "../subform-dialog";
import SubformFields from "../subform-fields";
import SubformHeader from "../subform-header";
import SubformDrawer from "../subform-drawer";
import SubformItem from "../subform-item";
import SubformAddEntry from "../subform-add-entry";
import { GuidingQuestions } from "../../components";

import SubformFieldArray from "./component";

describe("<SubformFieldArray />", () => {
  const props = {
    arrayHelpers: {},
    formSection: {
      id: 33,
      unique_id: "family_details",
      description: {
        en: "Family Details"
      },
      name: {
        en: "Family Details"
      },
      visible: true,
      is_first_tab: false,
      order: 10,
      order_form_group: 30,
      parent_form: "case",
      editable: true,
      module_ids: ["primeromodule-cp"],
      form_group_id: "identification_registration",
      form_group_name: {
        en: "Identification / Registration"
      }
    },
    field: FieldRecord({
      name: "family_details_section",
      display_name: { en: "Family Details" },
      subform_section_id: FormSectionRecord({
        unique_id: "family_section",
        fields: [
          FieldRecord({
            name: "relation_name",
            visible: true,
            type: "text_field"
          }),
          FieldRecord({
            name: "relation_child_is_in_contact",
            visible: true,
            type: "text_field"
          })
        ]
      }),
      subform_section_configuration: {
        subform_sort_by: "relation_name"
      },
      disabled: false,
      guiding_questions: { en: "This is a Guidance" }
    }),
    formik: {
      values: {
        family_details_section: [
          { relation_name: "father", relation_child_is_in_contac: "test A" },
          { relation_name: "aut", relation_child_is_in_contac: "test B" }
        ]
      },
      setValues: () => {},
      errors: { services_subform_section: [{ relation_name: "required" }] }
    },
    i18n: { t: value => value, locale: "en" },
    initialSubformValue: {
      relation_name: "",
      relation_child_is_in_contact: ""
    },
    mode: {
      isShow: false,
      isEdit: true
    },
    recordType: "cases",
    isReadWriteForm: true,
    form: {},
    forms: fromJS({}),
    recordModuleID: "primeromodule-cp"
  };

  const formProps = {
    initialValues: {
      relation_name: "",
      relation_child_is_in_contact: ""
    }
  };

  let component;

  beforeEach(() => {
    ({ component } = setupMountedComponent(SubformFieldArray, props, {}, [], formProps));
  });

  it("render the subform", () => {
    expect(component.find(SubformFieldArray)).lengthOf(1);
  });

  it("renders the SubformDialog", () => {
    expect(component.find(SubformDialog)).lengthOf(1);
  });

  it("renders the SubformFields", () => {
    expect(component.find(SubformFields)).lengthOf(1);
  });

  it("renders the SubformHeader", () => {
    expect(component.find(SubformHeader)).lengthOf(2);
  });

  it("renders the SubformAddEntry", () => {
    expect(component.find(SubformAddEntry)).lengthOf(1);
  });

  it("renders the AddIcon", () => {
    expect(component.find(AddIcon)).lengthOf(1);
  });

  it("renders the GuidingQuestions", () => {
    expect(component.find(GuidingQuestions)).lengthOf(1);
    expect(component.find(GuidingQuestions).text()).to.be.equal("buttons.guidance");
  });

  describe("when is a tracing request and the traces subform", () => {
    let tracingRequestComponent;

    beforeEach(() => {
      ({ component: tracingRequestComponent } = setupMountedComponent(
        SubformFieldArray,
        {
          ...props,
          recordType: "tracing_requests",
          formSection: {
            ...props.formSection,
            unique_id: TRACES_SUBFORM_UNIQUE_ID
          },
          mode: {
            isShow: true
          }
        },
        Map({
          forms: Map({
            fields: [{ name: TRACING_REQUEST_STATUS_FIELD_NAME, option_strings_source: "lookup lookup-test" }]
          })
        }),
        [],
        {}
      ));
    });

    it("renders the SubformDrawer", () => {
      expect(tracingRequestComponent.find(SubformDrawer)).lengthOf(1);
    });

    it("should not render the SubformDialog", () => {
      expect(tracingRequestComponent.find(SubformDialog)).lengthOf(0);
    });
  });

  describe("when is a violation", () => {
    let incidentComponent;

    beforeEach(() => {
      ({ component: incidentComponent } = setupMountedComponent(
        SubformFieldArray,
        {
          ...props,
          recordType: "incidents",
          formSection: {
            ...props.formSection,
            unique_id: "killing"
          },
          mode: {
            isShow: true
          },
          forms: fromJS({
            formSections: {
              1: {
                id: 1,
                name: {
                  en: "Form Section 1"
                },
                unique_id: "form_section_1",
                module_ids: ["some_module"],
                visible: true,
                is_nested: false,
                parent_form: "cases",
                fields: [1, 2, 3]
              }
            },
            fields: {
              1: {
                id: 1,
                name: "field_1",
                display_name: {
                  en: "Field 1"
                },
                type: "text_field",
                required: true,
                visible: true
              },
              2: {
                id: 2,
                name: "field_2",
                display_name: {
                  en: "Field 2"
                },
                type: "subform",
                visible: true
              }
            }
          })
        },
        fromJS({
          forms: {
            fields: [{ name: "killing" }]
          }
        }),
        [],
        {}
      ));
    });

    it("should render title", () => {
      const h3Tag = incidentComponent.find("h3");

      expect(h3Tag).lengthOf(1);
      expect(h3Tag.at(0).text()).to.be.equal(" Family Details ");
    });
  });

  describe("when is a violation association", () => {
    let incidentComponent;

    beforeEach(() => {
      ({ component: incidentComponent } = setupMountedComponent(
        SubformFieldArray,
        {
          ...props,
          recordType: "incidents",
          parentTitle: "Title",
          formSection: {
            ...props.formSection,
            unique_id: "individual_victims_subform_section"
          },
          mode: {
            isShow: false
          },
          forms: fromJS({
            formSections: {
              1: {
                id: 1,
                name: {
                  en: "Form Section 1"
                },
                unique_id: "form_section_1",
                module_ids: ["some_module"],
                visible: true,
                is_nested: false,
                parent_form: "cases",
                fields: [1, 2, 3]
              }
            },
            fields: {
              1: {
                id: 1,
                name: "field_1",
                display_name: {
                  en: "Field 1"
                },
                type: "text_field",
                required: true,
                visible: true
              },
              2: {
                id: 2,
                name: "field_2",
                display_name: {
                  en: "Field 2"
                },
                type: "subform",
                visible: true
              }
            }
          }),
          formik: {
            values: [
              {
                killing: {
                  unique_id: "abc123"
                }
              }
            ]
          },
          parentValues: {
            values: [
              {
                killing: {
                  unique_id: "def456"
                }
              }
            ]
          },
          field: FieldRecord({
            name: "killing",
            display_name: { en: "Killing" },
            subform_section_id: FormSectionRecord({
              unique_id: "killing_section",
              fields: [
                FieldRecord({
                  name: "relation_name",
                  visible: true,
                  type: "text_field"
                }),
                FieldRecord({
                  name: "relation_child_is_in_contact",
                  visible: true,
                  type: "text_field"
                })
              ]
            }),
            disabled: false
          })
        },
        fromJS({
          forms: {
            fields: [{ name: "killing" }]
          }
        }),
        [],
        {}
      ));
    });

    it("should render SubformAddEntry", () => {
      expect(incidentComponent.find(SubformAddEntry)).lengthOf(1);
    });

    it("should render Menu", () => {
      expect(incidentComponent.find(Menu)).lengthOf(1);
    });

    it("should render MenuItem", () => {
      expect(incidentComponent.find(MenuItem)).lengthOf(1);
    });

    it("should render add button", () => {
      expect(incidentComponent.find(AddIcon)).lengthOf(1);
    });

    it("renders SubformItem component with valid props", () => {
      const componentsProps = { ...component.find(SubformItem).props() };

      [
        "arrayHelpers",
        "dialogIsNew",
        "field",
        "formik",
        "forms",
        "formSection",
        "index",
        "isDisabled",
        "isTraces",
        "isReadWriteForm",
        "isViolation",
        "isViolationAssociation",
        "mode",
        "selectedValue",
        "open",
        "orderedValues",
        "recordModuleID",
        "recordType",
        "setOpen",
        "title",
        "parentTitle",
        "violationOptions"
      ].forEach(property => {
        expect(componentsProps).to.have.property(property);
        delete componentsProps[property];
      });

      expect(componentsProps).to.be.empty;
    });
  });
});
