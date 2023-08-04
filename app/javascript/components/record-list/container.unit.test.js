import { Route } from "react-router-dom";
import { fromJS, OrderedMap } from "immutable";
import { TableCell, TableRow } from "@material-ui/core";

import { ConditionalWrapper } from "../../libs";
import Filters from "../index-filters";
import IndexTable from "../index-table";
import { ACTIONS } from "../permissions";
import { setupMountedComponent } from "../../test";
import { FieldRecord, FormSectionRecord } from "../record-form/records";
import { PrimeroModuleRecord } from "../application/records";

import ViewModal from "./view-modal";
import RecordList from "./container";
import RecordListToolbar from "./record-list-toolbar";

describe("<RecordList />", () => {
  let component;

  const initialState = fromJS({
    records: {
      FiltersTabs: {
        current: 0
      },
      cases: {
        data: [
          {
            id: "e15acbe5-9501-4615-9f43-cb6873997fc1",
            case_id_display: "e15acbe",
            short_id: "e15acbe",
            name: "Jose",
            record_state: true,
            module_id: "primeromodule-cp",
            age: 0
          },
          {
            id: "7d55b677-c9c4-7c6c-7a41-bfa1c3f74d1c",
            case_id_display: "7d55b67",
            short_id: "7d55b67",
            name: "Carlos",
            record_state: true,
            module_id: "primeromodule-cp",
            age: 5
          }
        ],
        metadata: { total: 2, per: 20, page: 1 },
        filters: {
          id_search: false,
          query: "",
          record_state: ["true"]
        },
        loading: false,
        errors: false
      }
    },
    user: {
      modules: ["primeromodule-cp"],
      listHeaders: {
        cases: [
          { id: "name", name: "Name", field_name: "name" },
          { id: "age", name: "Age", field_name: "age" }
        ]
      },
      filters: {
        cases: [
          {
            name: "cases.filter_by.enabled_disabled",
            field_name: "record_state",
            option_strings_source: null,
            options: {
              en: [
                { id: "true", display_name: "Enabled" },
                { id: "false", display_name: "Disabled" }
              ]
            },
            type: "multi_toggle"
          }
        ]
      },
      permissions: {
        cases: [ACTIONS.MANAGE, ACTIONS.DISPLAY_VIEW_PAGE]
      }
    },
    forms: {
      formSections: OrderedMap({
        1: FormSectionRecord({
          id: 1,
          unique_id: "incident_details_subform_section",
          name: { en: "Nested Incident Details Subform" },
          visible: false,
          is_first_tab: false,
          order: 20,
          order_form_group: 110,
          parent_form: "case",
          editable: true,
          module_ids: [],
          form_group_id: "",
          form_group_name: { en: "Nested Incident Details Subform" },
          fields: [2],
          is_nested: true,
          subform_prevent_item_removal: false,
          collapsed_field_names: ["cp_incident_date", "cp_incident_violence_type"]
        }),
        2: FormSectionRecord({
          id: 2,
          unique_id: "incident_details_container",
          name: { en: "Incident Details" },
          visible: true,
          is_first_tab: false,
          order: 0,
          order_form_group: 30,
          parent_form: "case",
          editable: true,
          module_ids: ["primeromodule-cp"],
          form_group_id: "identification_registration",
          form_group_name: { en: "Identification / Registration" },
          fields: [1],
          is_nested: false,
          subform_prevent_item_removal: false,
          collapsed_field_names: []
        }),
        3: FormSectionRecord({
          id: 3,
          unique_id: "basic_form",
          name: { en: "Basic Form" },
          visible: true,
          is_first_tab: false,
          order: 0,
          order_form_group: 30,
          parent_form: "case",
          editable: true,
          module_ids: ["primeromodule-cp"],
          form_group_id: "identification_registration",
          form_group_name: { en: "Identification / Registration" },
          fields: [2, 3, 4, 5, 6, 7],
          is_nested: false,
          subform_prevent_item_removal: false,
          collapsed_field_names: []
        })
      }),
      fields: OrderedMap({
        1: FieldRecord({
          name: "incident_details",
          type: "subform",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: 1,
          help_text: { en: "" },
          display_name: { en: "" },
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "summary_date",
          show_on_minify_form: false
        }),
        2: FieldRecord({
          name: "cp_incident_location_type_other",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: false
        }),
        3: FieldRecord({
          name: "name",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: true
        }),
        4: FieldRecord({
          name: "sex",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: false
        }),
        5: FieldRecord({
          name: "age",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: false
        }),
        6: FieldRecord({
          name: "estimated",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: false
        }),
        7: FieldRecord({
          name: "date_of_birth",
          type: "text_field",
          editable: true,
          disabled: false,
          visible: true,
          subform_section_id: null,
          help_text: {},
          multi_select: false,
          option_strings_source: null,
          option_strings_text: {},
          guiding_questions: "",
          required: false,
          date_validation: "default_date_validation",
          hide_on_view_page: false,
          date_include_time: false,
          selected_value: "",
          subform_sort_by: "",
          show_on_minify_form: false
        })
      }),
      options: {
        lookups: [
          {
            id: 1,
            unique_id: "lookup-sex",
            name: { en: "Sex" },
            values: [
              { id: "male", display_text: { en: "Male" } },
              { id: "female", display_text: { en: "Female" } }
            ]
          }
        ]
      },
      loading: false,
      errors: false
    },
    application: {
      online: true,
      modules: [
        PrimeroModuleRecord({
          unique_id: "primeromodule-cp",
          name: "CP",
          associated_record_types: ["case"]
        })
      ]
    }
  });

  const routedComponent = initialProps => {
    return (
      <Route
        path="/:recordType(cases|incidents|tracing_requests)"
        component={props => <RecordList {...{ ...props, ...initialProps }} />}
      />
    );
  };

  beforeEach(() => {
    ({ component } = setupMountedComponent(routedComponent, {}, initialState, ["/cases"]));
  });

  it("renders record list table", done => {
    expect(component.find(IndexTable)).to.have.length(1);
    done();
  });

  it("renders record view modal", done => {
    expect(component.find(ViewModal)).to.have.lengthOf(1);
    done();
  });

  it("opens the view modal when a record is clicked", () => {
    component.find(TableCell).at(4).simulate("click");

    expect(component.find(ViewModal).props().openViewModal).to.be.true;
  });

  it("renders filters", () => {
    expect(component.find(Filters)).to.have.lengthOf(1);
  });

  it("renders valid props for RecordListToolbar components", () => {
    const recordListToolbarProps = {
      ...component.find(RecordListToolbar).props()
    };

    expect(component.find(RecordListToolbar)).to.have.lengthOf(1);
    ["clearSelectedRecords", "currentPage", "recordType", "selectedRecords", "title"].forEach(property => {
      expect(recordListToolbarProps).to.have.property(property);
      delete recordListToolbarProps[property];
    });
    expect(recordListToolbarProps).to.be.empty;
  });

  it("renders valid props for Filters components", () => {
    const filtersProps = {
      ...component.find(Filters).props()
    };

    expect(component.find(Filters)).to.have.lengthOf(1);
    ["recordType", "setSelectedRecords", "metadata"].forEach(property => {
      expect(filtersProps).to.have.property(property);
      delete filtersProps[property];
    });
    expect(filtersProps).to.be.empty;
  });

  describe("when offline", () => {
    const { component: offlineComponent } = setupMountedComponent(
      routedComponent,
      {},
      initialState.setIn(["application", "online"], false),
      ["/cases"]
    );

    it("when a record is clicked it does not open the view modal", () => {
      offlineComponent.find(TableCell).at(3).simulate("click");

      expect(component.find(ViewModal).props().openViewModal).to.be.false;
    });
  });

  describe("when age is 0", () => {
    it("renders a 0 in the cell ", () => {
      expect(component.find(TableRow).at(1).find(TableCell).at(2).find(ConditionalWrapper).text()).to.equal("0");
    });
  });
});
