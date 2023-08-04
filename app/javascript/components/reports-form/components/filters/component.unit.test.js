import { fromJS } from "immutable";
import { Typography } from "@material-ui/core";

import { setupMountedComponent, fake } from "../../../../test";
import { ACTIONS } from "../../../permissions";
import FiltersDialog from "../filters-dialog";
import { MODULES_FIELD, RECORD_TYPE_FIELD, DEFAULT_FILTERS } from "../../constants";
import {
  DATE_FIELD,
  FieldRecord,
  FormSectionRecord,
  NUMERIC_FIELD,
  SELECT_FIELD,
  SUBFORM_SECTION,
  TEXT_FIELD
} from "../../../form";

import ReportFilters from "./component";

describe("<ReportFilters /> - Component", () => {
  let component;

  const initialState = fromJS({
    user: {
      permissions: {
        reports: [ACTIONS.MANAGE]
      }
    },
    forms: {
      formSections: {
        1: FormSectionRecord({
          id: 1,
          unique_id: "form_1",
          parent_form: "case",
          fields: [1, 2, 3],
          module_ids: ["primeromodule-cp"],
          visible: true
        })
      },
      fields: {
        1: FieldRecord({
          name: "status",
          display_name: {
            en: "Status"
          },
          type: SELECT_FIELD,
          visible: true
        }),
        2: FieldRecord({
          name: "record_state",
          display_name: {
            en: "Record State"
          },
          type: SELECT_FIELD,
          visible: true
        }),
        3: FieldRecord({
          name: "consent_reporting",
          display_name: {
            en: "Consent Reporting"
          },
          type: SELECT_FIELD,
          visible: true
        })
      }
    }
  });

  const formattedMinimumReportableFields = {
    case: [
      {
        id: "status",
        display_text: "Case Status",
        visible: true
      },
      {
        id: "record_state",
        display_text: "Record Valid",
        visible: true
      },
      {
        id: "consent_reporting",
        display_text: "Consent Reporting",
        visible: true
      }
    ]
  };

  const props = {
    indexes: [...DEFAULT_FILTERS.case, ...[{ attribute: "test_numeric_field", constraint: ">", value: "10" }]].map(
      (data, index) => ({ index, data })
    ),
    setIndexes: () => {},
    allRecordForms: fromJS([
      {
        id: 1,
        unique_id: "test_form_section",
        name: { en: "Test form section" },
        visible: true,
        module_ids: ["primeromodule-cp"],
        parent_form: "case",
        fields: [
          {
            name: "test_numeric_field",
            display_name: {
              en: "Test numeric field"
            },
            type: NUMERIC_FIELD,
            visible: true,
            option_strings_source: null,
            option_strings_text: null,
            tick_box_label: null
          }
        ],
        subform_section_id: null
      }
    ]),
    parentFormMethods: {
      control: { subjectsRef: {} },
      getValues: fake.returns({
        [MODULES_FIELD]: ["primeromodule-cp"],
        [RECORD_TYPE_FIELD]: "case"
      })
    },
    selectedModule: "primeromodule-cp",
    selectedRecordType: "case",
    formattedMinimumReportableFields,
    formMode: { isNew: false }
  };

  beforeEach(() => {
    ({ component } = setupMountedComponent(ReportFilters, props, initialState));
  });

  it("should render <Typography>", () => {
    expect(component.find(Typography)).to.have.lengthOf(1);
  });

  it("should render <FiltersDialog>", () => {
    expect(component.find(FiltersDialog)).to.have.lengthOf(1);
  });

  describe("when there are not filter", () => {
    let componentWithtoutFilter = null;
    const state = {
      records: {
        reports: {
          loading: false,
          errors: false,
          selectedReport: {
            editable: true,
            record_type: "case",
            name: {
              en: "Test 12"
            },
            graph_type: "bar",
            graph: false,
            module_id: ["primeromodule-cp"],
            group_dates_by: null,
            group_ages: false,
            report_data: {
              1: {
                _total: 0
              },
              2: {
                _total: 15
              }
            },
            fields: [
              {
                name: "age",
                display_name: {
                  en: "Age"
                },
                position: {
                  type: "horizontal",
                  order: 0
                }
              }
            ],
            id: 1,
            filters: [],
            disabled: false,
            description: {}
          }
        }
      },
      forms: {
        formSections: [
          FormSectionRecord({
            unique_id: "form_1",
            parent_form: "case",
            fields: [1]
          })
        ],
        fields: {
          1: {
            name: "age",
            display_name: {
              en: "Age"
            },
            position: {
              type: "horizontal",
              order: 0
            }
          }
        }
      }
    };

    beforeEach(() => {
      ({ component: componentWithtoutFilter } = setupMountedComponent(ReportFilters, { ...props, indexes: [] }, state, [
        "/reports/1/edit"
      ]));
    });

    it("should render new button", () => {
      expect(componentWithtoutFilter.find("button").text()).to.equal("buttons.new");
    });

    it("should render 'No filters added' message", () => {
      expect(componentWithtoutFilter.find("p").at(1).text()).to.equal("report.no_filters_added");
    });
  });

  describe("when the report is new", () => {
    describe("and the selectedRecordType is reportable_service", () => {
      it("should render the default service filters", () => {
        let appliedFilters = [];

        setupMountedComponent(
          ReportFilters,
          {
            ...props,
            allRecordForms: fromJS([
              {
                id: 1,
                unique_id: "services",
                name: { en: "Services Section" },
                visible: true,
                module_ids: ["primeromodule-cp"],
                parent_form: "case",
                fields: [
                  FieldRecord({
                    name: "nested_services",
                    type: SUBFORM_SECTION,
                    subform_section_id: FormSectionRecord({
                      fields: [
                        FieldRecord({
                          name: "service_type",
                          display_name: {
                            en: "Service type"
                          },
                          type: SELECT_FIELD,
                          visible: true
                        }),
                        FieldRecord({
                          name: "service_appointment_date",
                          display_name: {
                            en: "Service Appointment Date"
                          },
                          type: SELECT_FIELD,
                          visible: true
                        })
                      ]
                    })
                  })
                ]
              }
            ]),
            indexes: [],
            setIndexes: filters => {
              appliedFilters = filters;
            },
            formMode: { isNew: true },
            selectedModule: "primeromodule-cp",
            selectedRecordType: "reportable_service",
            formattedMinimumReportableFields
          },
          initialState
        );

        expect(appliedFilters.map(filter => filter.data.attribute)).to.deep.equals([
          "status",
          "record_state",
          "consent_reporting",
          "service_type",
          "service_appointment_date"
        ]);
      });
    });
    describe("and the selectedRecordType is reportable_follow_up", () => {
      it("should render the default follow_up filters", () => {
        let appliedFilters = [];

        setupMountedComponent(
          ReportFilters,
          {
            ...props,
            allRecordForms: fromJS([
              {
                id: 1,
                unique_id: "followup",
                name: { en: "Follow up" },
                visible: true,
                module_ids: ["primeromodule-cp"],
                parent_form: "case",
                fields: [
                  FieldRecord({
                    name: "followup_subform_section",
                    type: SUBFORM_SECTION,
                    subform_section_id: FormSectionRecord({
                      fields: [
                        FieldRecord({
                          name: "followup_date",
                          display_name: {
                            en: "Follow Up"
                          },
                          type: DATE_FIELD,
                          visible: true
                        })
                      ]
                    })
                  })
                ]
              }
            ]),
            indexes: [],
            setIndexes: filters => {
              appliedFilters = filters;
            },
            formMode: { isNew: true },
            selectedModule: "primeromodule-cp",
            selectedRecordType: "reportable_follow_up",
            formattedMinimumReportableFields
          },
          initialState
        );

        expect(appliedFilters.map(filter => filter.data.attribute)).to.deep.equals([
          "status",
          "record_state",
          "consent_reporting",
          "followup_date"
        ]);
      });
    });
    describe("and the selectedRecordType is reportable_protection_concern", () => {
      it("should render the default protection_concern filters", () => {
        let appliedFilters = [];

        setupMountedComponent(
          ReportFilters,
          {
            ...props,
            allRecordForms: fromJS([
              {
                id: 1,
                unique_id: "protection_concern_details",
                name: { en: "Protection Concern" },
                visible: true,
                module_ids: ["primeromodule-cp"],
                parent_form: "case",
                fields: [
                  FieldRecord({
                    name: "protection_concern_section",
                    type: SUBFORM_SECTION,
                    subform_section_id: FormSectionRecord({
                      fields: [
                        FieldRecord({
                          name: "protection_concern_type",
                          display_name: {
                            en: "Protection Concern Type"
                          },
                          type: TEXT_FIELD,
                          visible: true
                        })
                      ]
                    })
                  })
                ]
              }
            ]),
            indexes: [],
            setIndexes: filters => {
              appliedFilters = filters;
            },
            formMode: { isNew: true },
            selectedModule: "primeromodule-cp",
            selectedRecordType: "reportable_protection_concern",
            formattedMinimumReportableFields
          },
          initialState
        );

        expect(appliedFilters.map(filter => filter.data.attribute)).to.deep.equals([
          "status",
          "record_state",
          "consent_reporting",
          "protection_concern_type"
        ]);
      });
    });
  });
});
