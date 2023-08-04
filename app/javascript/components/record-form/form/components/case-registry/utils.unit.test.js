/* eslint-disable react/sort-prop-types */

import { buildValidation } from "./utils";

describe("buildValidation", () => {
  const fields = [
    {
      option_strings_text: [
        { id: "option1", display_text: "Option 1" },
        { id: "option2", display_text: "Option 2" }
      ]
    }
  ];

  it("should return form validation object (validation passes)", async () => {
    const validations = await buildValidation(fields).isValid({ search_by: "option1", option1: "test" });

    expect(validations).to.be.true;
  });

  it("should return form validation object (validation fails)", async () => {
    const validations = await buildValidation(fields).isValid({});

    expect(validations).to.be.false;
  });
});
