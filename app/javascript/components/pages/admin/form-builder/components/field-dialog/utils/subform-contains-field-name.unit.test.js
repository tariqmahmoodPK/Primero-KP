import { fromJS } from "immutable";

import { NEW_FIELD } from "../../../constants";

import subformContainsFieldName from "./subform-contains-field-name";

describe("subformContainsFieldName", () => {
  const subform = fromJS({
    id: 1,
    unique_id: "subform_1",
    fields: [{ id: 1, name: "field_1" }]
  });

  const subformField = fromJS({
    name: "subform_field_2"
  });

  it("return false if the subform does not have the field name", () => {
    expect(subformContainsFieldName(subform, "field_2")).to.be.false;
  });

  it("return true if the subform have the field name", () => {
    expect(subformContainsFieldName(subform, "field_1")).to.be.true;
  });

  it("return true if the subform field is new", () => {
    expect(subformContainsFieldName(subform, NEW_FIELD, subformField)).to.be.true;
  });
});
