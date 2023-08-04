import { fromJS } from "immutable";
import { Chip } from "@material-ui/core";
import Autocomplete from "@material-ui/lab/Autocomplete";

import { setupMountedComponent } from "../../../../test";
import { OPTION_TYPES, whichFormMode } from "../../../form";
import SearchableSelect from "../../../searchable-select";
import { SERVICE_SECTION_FIELDS } from "../../../record-actions/transitions/components/referrals";
import actions from "../../../record-actions/transitions/actions";

import SelectField from "./select-field";

describe("<SelectField />", () => {
  context("when the lookup is custom", () => {
    const props = {
      name: "agency",
      field: {
        option_strings_source: OPTION_TYPES.AGENCY
      },
      label: "Agency",
      mode: whichFormMode("edit"),
      open: true,
      optionsSelector: () => ({
        source: OPTION_TYPES.AGENCY,
        useUniqueId: true
      })
    };

    const initialState = fromJS({
      application: {
        agencies: [
          {
            unique_id: "agency-test-1",
            name: {
              en: "Agency Test 1"
            },
            agency_code: "test1",
            disabled: false,
            services: ["service_test_1"]
          },
          {
            unique_id: "agency-test-2",
            name: {
              en: "Agency Test 2"
            },
            agency_code: "test2",
            disabled: false,
            services: ["service_test_1", "service_test_2"]
          }
        ],
        reportingLocationConfig: {
          field_key: "owned_by_location",
          admin_level: 2,
          admin_level_map: {
            1: ["province"],
            2: ["district"]
          },
          hierarchy_filter: [],
          label_keys: ["district"]
        }
      },
      forms: {
        options: {
          locations: [
            { id: 1, code: "MC", admin_level: 0, disabled: false, name: { en: "MyCountry" } },
            { id: 2, code: "MCMP1", admin_level: 1, disabled: false, name: { en: "MyCountry:MyProvince1" } },
            { id: 3, code: "MCMP2", admin_level: 1, disabled: false, name: { en: "MyCountry:MyProvince2" } },
            {
              id: 4,
              code: "MCMP1MD1",
              admin_level: 2,
              disabled: false,
              name: { en: "MyCountry:MyProvince1:MyDistrict1" }
            },
            {
              id: 5,
              code: "MCMP2MD2",
              admin_level: 2,
              disabled: false,
              name: { en: "MyCountry:MyProvince2:MyDistrict2" }
            }
          ]
        }
      }
    });

    const { component } = setupMountedComponent(SelectField, props, initialState, [], {
      initialValues: { agency: "agency-test-1" }
    });

    it("render the select field with options", () => {
      const expected = [
        { id: "agency-test-1", disabled: false, display_text: "Agency Test 1" },
        { id: "agency-test-2", disabled: false, display_text: "Agency Test 2" }
      ];
      const selectField = component.find(SelectField);
      const searchableSelect = selectField.find(SearchableSelect);

      expect(searchableSelect).to.have.lengthOf(1);
      expect(searchableSelect.props().options).to.deep.equal(expected);
    });

    it("render the select field with options for ReportingLocations", () => {
      const { component: componentSelectField } = setupMountedComponent(
        SelectField,
        {
          ...props,
          field: {
            option_strings_source: OPTION_TYPES.REPORTING_LOCATIONS
          },
          name: "service_delivery_location",
          optionsSelector: () => ({
            source: OPTION_TYPES.REPORTING_LOCATIONS,
            usePlacename: false
          })
        },
        initialState,
        [],
        {
          initialValues: { service_delivery_location: "MCMP2MD2" }
        }
      );
      const expected = [
        { id: "MCMP1MD1", admin_level: 2, disabled: false, display_text: "MyCountry:MyProvince1:MyDistrict1" },
        { id: "MCMP2MD2", admin_level: 2, disabled: false, display_text: "MyCountry:MyProvince2:MyDistrict2" }
      ];
      const selectField = componentSelectField.find(SelectField);
      const searchableSelect = selectField.find(SearchableSelect);

      expect(searchableSelect).to.have.lengthOf(1);
      expect(searchableSelect.props().options).to.deep.equal(expected);
    });
  });
  context("when is service_type", () => {
    const props = {
      name: SERVICE_SECTION_FIELDS.type,
      field: {
        option_strings_source: "lookup lookup-service-type"
      },
      label: "Type of Service",
      mode: whichFormMode("edit"),
      open: true,
      optionsSelector: () => ({
        source: "lookup lookup-service-type",
        useUniqueId: true
      })
    };

    const initialState = fromJS({
      forms: {
        options: {
          lookups: [
            {
              id: 20,
              unique_id: "lookup-service-type",
              name: {
                en: "Service Type"
              },
              values: [
                {
                  id: "health_medical_service",
                  disabled: false,
                  display_text: {
                    en: "Health/Medical Service"
                  }
                }
              ]
            }
          ]
        }
      }
    });

    const { component } = setupMountedComponent(SelectField, props, initialState, [], {
      initialValues: {
        service_type: "health_medical_service"
      }
    });

    it("render the select field with options", () => {
      const expected = [{ display_text: "Health/Medical Service", disabled: false, id: "health_medical_service" }];

      const selectField = component.find(SelectField);
      const searchableSelect = selectField.find(SearchableSelect);

      expect(searchableSelect).to.have.lengthOf(1);
      expect(searchableSelect.props().options).to.deep.equal(expected);
    });
  });

  context("when a disabled value is selected", () => {
    const props = {
      name: SERVICE_SECTION_FIELDS.type,
      field: {
        option_strings_text: [
          { id: "test1", display_text: "Test 1" },
          { id: "test2", disabled: true, display_text: "Test 2" },
          { id: "test3", display_text: "Test 3" },
          { id: "test4", disabled: true, display_text: "Test 4" }
        ]
      },
      label: "Type of Service",
      mode: whichFormMode("edit"),
      open: true,
      optionsSelector: () => ({
        options: [
          { id: "test1", display_text: "Test 1" },
          { id: "test2", disabled: true, display_text: "Test 2" },
          { id: "test3", display_text: "Test 3" },
          { id: "test4", disabled: true, display_text: "Test 4" }
        ]
      })
    };

    const { component } = setupMountedComponent(SelectField, props, {}, [], {
      initialValues: {
        service_type: "test2"
      }
    });

    it("render the select field with options included the disabled selected", () => {
      const selectField = component.find(SelectField);
      const searchableSelect = selectField.find(SearchableSelect);
      const autocomplete = selectField.find(Autocomplete);

      expect(searchableSelect).to.have.lengthOf(1);
      expect(searchableSelect.props().options).to.have.lengthOf(3);
      expect(autocomplete.props().options[1].disabled).to.be.true;
    });
  });

  context("when is service_implementing_agency_individual", () => {
    const paramsService = "health_medical_service";
    const propsSelectUser = {
      name: SERVICE_SECTION_FIELDS.implementingAgencyIndividual,
      field: {
        option_strings_source: "User"
      },
      label: "Type of Service",
      mode: whichFormMode("edit"),
      open: true,
      filters: { values: { service: paramsService } },
      formik: {
        values: {
          [SERVICE_SECTION_FIELDS.implementingAgencyIndividual]: "user1",
          [SERVICE_SECTION_FIELDS.type]: paramsService
        }
      },
      recordType: "cases",
      recordModuleID: "record-module-1",
      optionsSelector: () => ({ source: OPTION_TYPES.REFER_TO_USERS, useUniqueId: true })
    };
    const expectedAction = {
      type: actions.REFERRAL_USERS_FETCH,
      api: {
        path: actions.USERS_REFER_TO,
        params: { record_module_id: "record-module-1", record_type: "case", service: paramsService }
      }
    };

    it("should fetch referral users", () => {
      const { component: componentSelectUser } = setupMountedComponent(SelectField, propsSelectUser, {}, [], {
        initialValues: {
          [SERVICE_SECTION_FIELDS.implementingAgencyIndividual]: "user1",
          [SERVICE_SECTION_FIELDS.type]: paramsService
        }
      });

      const selectUser = componentSelectUser.find(SearchableSelect);

      selectUser.props().onOpen();
      const componentActions = componentSelectUser.props().store.getActions();

      expect(componentActions[componentActions.length - 1]).to.deep.equal(expectedAction);
    });
  });

  context("when is service_implementing_agency", () => {
    const paramsService = "health_medical_service";
    const initialStateAgency = fromJS({
      application: {
        agencies: [
          {
            unique_id: "agency-test-1",
            name: {
              en: "Agency Test 1"
            },
            agency_code: "test1",
            disabled: false,
            services: ["service_test_1"]
          },
          {
            unique_id: "agency-test-2",
            name: {
              en: "Agency Test 2"
            },
            agency_code: "test2",
            disabled: false,
            services: ["service_test_1", "service_test_2"]
          }
        ]
      }
    });
    const propsSelectAgency = {
      name: SERVICE_SECTION_FIELDS.implementingAgency,
      field: {
        option_strings_text: "Agency"
      },
      label: "Implementing Agency",
      mode: whichFormMode("edit"),
      open: true,
      filters: { values: { service: "another-service" }, filterState: { filtersChanged: true, userIsSelected: false } },
      formik: {
        values: {
          [SERVICE_SECTION_FIELDS.type]: paramsService,
          [SERVICE_SECTION_FIELDS.implementingAgency]: "agency-test-1"
        }
      },
      recordType: "cases",
      recordModuleID: "record-module-1",
      optionsSelector: () => ({ source: OPTION_TYPES.AGENCY, useUniqueId: true })
    };

    it("should clear out field if filters", () => {
      const { component: componentSelectUser } = setupMountedComponent(
        SelectField,
        propsSelectAgency,
        initialStateAgency,
        [],
        {
          initialValues: {
            [SERVICE_SECTION_FIELDS.implementingAgency]: "agency-test-1",
            [SERVICE_SECTION_FIELDS.type]: paramsService
          }
        }
      );
      const selectFieldAgency = componentSelectUser.find(SearchableSelect);

      expect(selectFieldAgency.props().value).to.be.equal(null);
    });
  });

  context("when the lookup is yes-no-lookup", () => {
    const props = {
      name: "test",
      field: {
        option_strings_source: "lookup lookup-yes-no"
      },
      label: "Test",
      mode: whichFormMode("edit"),
      open: true,
      optionsSelector: () => ({ source: "lookup lookup-yes-no" })
    };

    const initialState = fromJS({
      forms: {
        options: {
          lookups: [
            {
              id: 93,
              unique_id: "lookup-yes-no",
              name: {
                en: "Yes or No"
              },
              values: [
                {
                  id: "true",
                  display_text: {
                    en: "Yes"
                  }
                },
                {
                  id: "false",
                  display_text: {
                    en: "No"
                  }
                }
              ]
            }
          ]
        }
      }
    });

    const { component } = setupMountedComponent(SelectField, props, initialState, [], {
      initialValues: { test: false }
    });

    it("render the select field with the selected option even if the option is boolean", () => {
      const expected = [{ id: "false", disabled: false, display_text: "No" }];

      const selectField = component.find(SelectField);
      const searchableSelect = selectField.find(SearchableSelect);

      expect(searchableSelect).to.have.lengthOf(1);
      expect(searchableSelect.props().defaultValues).to.deep.equal(expected);
    });
  });

  context("when a multi select has different value selected", () => {
    const props = {
      name: "test",
      field: {
        multi_select: true,
        option_strings_text: [
          { id: "option_1", display_text: { en: "Option 1" } },
          { id: "option_2", display_text: { en: "Option 2" } },
          { id: "option_3", display_text: { en: "Option 3" } }
        ]
      },
      label: "Test",
      mode: whichFormMode("show"),
      open: true,
      optionsSelector: () => ({
        options: [
          { id: "option_1", display_text: { en: "Option 1" } },
          { id: "option_2", display_text: { en: "Option 2" } },
          { id: "option_3", display_text: { en: "Option 3" } }
        ]
      })
    };

    const { component } = setupMountedComponent(SelectField, props, fromJS([]), [], {
      initialValues: { test: ["option_1", "option_2", "option_3"] }
    });

    it("renders the correct values", () => {
      expect(component.find(Chip).map(chip => chip.text())).to.deep.equal(["Option 1", "Option 2", "Option 3"]);
    });
  });
});
