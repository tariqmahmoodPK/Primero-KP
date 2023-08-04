import sortWithSortedArray from "./sort-with-sorted-array";

describe("<InsightsSubReport/>/utils - sortWithSortedArray", () => {
  it("sorts an array using the order of another array", () => {
    const expected = [3, 2, 1];

    expect(sortWithSortedArray([1, 2, 3], [3, 2, 1])).to.deep.equal(expected);
  });

  it("puts incomplete_data as last element", () => {
    const expected = [3, 2, 1, "incomplete_data"];

    expect(sortWithSortedArray([1, "incomplete_data", 2, 3], [3, 2, 1], null, "incomplete_data")).to.deep.equal(
      expected
    );
  });

  it("puts null as last element", () => {
    expect(
      sortWithSortedArray(
        [{ age: 1 }, { age: 2 }, { age: "incomplete_data" }, { age: 3 }],
        [3, 2, 1],
        elem => elem.age,
        "incomplete_data"
      )
    ).to.deep.equal([{ age: 3 }, { age: 2 }, { age: 1 }, { age: "incomplete_data" }]);
  });
});
