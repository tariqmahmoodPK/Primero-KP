import { fromJS } from "immutable";
import { Button } from "@material-ui/core";

import { setupMountedComponent, spy } from "../../../../test";
import { TransitionRecord } from "../../records";
import { ACCEPTED } from "../../../../config";

import TransferApproval from "./component";
import actions from "./actions";

describe("<TransferApproval /> - Component", () => {
  const props = {
    openTransferDialog: true,
    close: () => {},
    approvalType: "accepted",
    recordId: "2fe3312b-8de2-4bd0-ab39-cdfc020f86b3",
    transferId: "be62e823-4d9d-402e-aace-8e4865a4882e",
    recordType: "cases",
    setPending: spy()
  };
  const initialState = fromJS({
    records: {
      cases: {
        data: [
          {
            record_state: true,
            assigned_user_names: ["primero_cp"],
            sex: "male",
            transfer_status: "in_progress",
            owned_by_agency_id: 1,
            notes_section: [],
            date_of_birth: "1981-02-04",
            record_in_scope: true,
            case_id: "5f0c7bd6-7d84-4367-91f1-d29ad7b970f8",
            created_at: "2020-02-04T20:22:40.716Z",
            name_last: "asfd",
            name: "asdf asfd",
            alert_count: 0,
            previously_owned_by: "primero",
            case_id_display: "7b970f8",
            created_by: "primero",
            module_id: "primeromodule-cp",
            owned_by: "primero",
            reopened_logs: [],
            status: "open",
            registration_date: "2020-02-04",
            complete: true,
            type: "cases",
            id: "2fe3312b-8de2-4bd0-ab39-cdfc020f86b3",
            flag_count: 0,
            name_first: "asdf",
            short_id: "7b970f8",
            age: 39,
            workflow: "new"
          }
        ],
        errors: false
      },
      transitions: {
        data: [
          TransitionRecord({
            id: "be62e823-4d9d-402e-aace-8e4865a4882e",
            record_id: "2fe3312b-8de2-4bd0-ab39-cdfc020f86b3",
            record_type: "case",
            created_at: "2020-02-04T20:24:49.464Z",
            notes: "",
            rejected_reason: "",
            status: "in_progress",
            type: "Transfer",
            consent_overridden: true,
            consent_individual_transfer: true,
            transitioned_by: "primero",
            transitioned_to: "primero_cp",
            service: null
          })
        ]
      }
    }
  });

  it("renders Transitions component", () => {
    const { component } = setupMountedComponent(TransferApproval, props, initialState);

    expect(component.find(TransferApproval)).to.have.length(1);
  });

  context("when the current_user is not the recipient", () => {
    it("renders the managed user message", () => {
      const { component } = setupMountedComponent(
        TransferApproval,
        props,
        initialState.setIn(["user", "username"], "primero_mgr_cp")
      );

      expect(component.find(TransferApproval).find("p").text()).to.equal("cases.transfer_managed_user_accepted");
    });
  });

  context("when transfer is approved", () => {
    it("renders the managed user message", () => {
      const { component } = setupMountedComponent(TransferApproval, props, initialState);
      const buttons = component.find(Button);

      buttons.first().simulate("click");

      expect(props.setPending).to.have.been.called;
      expect(component.props().store.getActions()[0].type).to.deep.equals(actions.APPROVE_TRANSFER);
      expect(component.props().store.getActions()[0].api.body.data.status).to.deep.equals(ACCEPTED);
    });
  });
});
