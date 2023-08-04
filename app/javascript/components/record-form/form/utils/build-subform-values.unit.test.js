import buildSubformValues from "./build-subform-values";

describe("buildSubformValues", () => {
  context("when is a violation subform", () => {
    it("should return the values for subform", () => {
      const values = {
        killing_number_of_victims: {
          boys: 2,
          girls: 1
        },
        attack_type: "other",
        unique_id: "123abc",
        individual_victims: [
          {
            unique_id: "individual1",
            violations_ids: ["abc123"]
          },
          {
            unique_id: "individual2",
            violations_ids: ["123abc"]
          }
        ],
        perpetrators: [
          {
            unique_id: "perpetrator1",
            violations_ids: ["abc123"]
          }
        ]
      };
      const result = buildSubformValues("killing", values);

      expect(result).to.deep.equal({
        killing_number_of_victims: {
          boys: 2,
          girls: 1
        },
        attack_type: "other",
        unique_id: "123abc"
      });
    });
  });
  context("when is no a violation subform", () => {
    it("should return the values for subform", () => {
      const values = {
        field_one: "other",
        field_two: "123abc",
        field_three: ["a", "b"]
      };
      const result = buildSubformValues("test", values);

      expect(result).to.deep.equal(values);
    });
  });
});
