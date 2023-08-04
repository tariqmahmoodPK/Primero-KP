import { touchedFormData } from "./touched-data";

describe("touchedFormData()", () => {
  it("returns touched data", () => {
    const data = {
      prop1: true,
      prop2: ["open"],
      prop3: "test",
      prop4: [{ prop4a: "prop-4a", prop4b: "prop-4b" }]
    };

    const expected = {
      prop1: true,
      prop2: ["open"],
      prop4: [{ prop4a: "prop-4a" }]
    };

    const touched = {
      prop1: true,
      prop2: [true],
      prop4: [{ prop4a: true }]
    };

    expect(touchedFormData(touched, data)).to.deep.equal(expected);
  });

  it("returns touched data for a field that was array and now is a single value", () => {
    const data = {
      prop1: "single"
    };

    const expected = {
      prop1: "single"
    };

    const touched = {
      prop1: ["value1", "value2"]
    };

    expect(touchedFormData(touched, data)).to.deep.equal(expected);
  });

  context("when keepArrayData = true", () => {
    it("returns all the array data", () => {
      const data = {
        prop4: [{ prop4a: "prop-4a", prop4b: "prop-4b" }, { prop4c: "prop-4c" }]
      };

      const expected = {
        prop4: [{ prop4a: "prop-4a", prop4b: "prop-4b" }, { prop4c: "prop-4c" }]
      };

      const touched = { prop4: [{ prop4a: true }] };

      expect(touchedFormData(touched, data, false, {}, true)).to.deep.equal(expected);
    });
  });
});
