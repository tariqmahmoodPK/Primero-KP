import * as moduleToTest from "./index";

describe("app/javascript/test/utils/index", () => {
  const clone = { ...moduleToTest };

  after(() => {
    expect(clone).to.be.empty;
  });

  [
    "abbrMonthNames",
    "setupMockFieldComponent",
    "setupMockFormComponent",
    "setupMountedComponent",
    "setupMountedThemeComponent",
    "tick",
    "createSimpleMount",
    "createMiddleware",
    "listHeaders",
    "lookups",
    "translateOptions",
    "setupHook",
    "FormikValueFromHook"
  ].forEach(property => {
    it(`exports property '${property}'`, () => {
      expect(clone).to.have.property(property);
      delete clone[property];
    });
  });
});
