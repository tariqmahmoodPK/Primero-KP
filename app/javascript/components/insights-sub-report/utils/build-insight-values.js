import { fromJS } from "immutable";
import first from "lodash/first";
import sortBy from "lodash/sortBy";

import { YEAR } from "../../insights/constants";

import getGroupComparator from "./get-group-comparator";
import yearComparator from "./year-comparator";
import getDataGroups from "./get-data-groups";
import sortWithSortedArray from "./sort-with-sorted-array";

const buildRows = ({ tuples, rows, columnIndex, columnsNumber }) => {
  tuples.forEach(tuple => {
    const [lookupValue, ...values] = tuple;

    const existingIndex = rows.findIndex(elem => first(elem) === lookupValue);

    if (existingIndex !== -1) {
      // eslint-disable-next-line no-param-reassign
      rows[existingIndex] = [
        ...rows[existingIndex].slice(0, columnIndex),
        ...values,
        ...rows[existingIndex].slice(columnIndex + values.length)
      ];
    } else {
      const newRow = [lookupValue].concat(new Array(columnsNumber).fill(0, 0, columnsNumber));

      rows.push([...newRow.slice(0, columnIndex), ...values, ...newRow.slice(columnIndex + values.length)]);
    }
  });
};

const buildGroupedRows = ({ getLookupValue, data, key, groupedBy, subColumnItems }) => {
  const groups = getDataGroups(data, groupedBy);

  const groupedData = data.groupBy(value => value.get("group_id").toString());

  if (groupedBy === YEAR) {
    const columnsNumber = subColumnItems?.length ? subColumnItems.length * groups.length : groups.length;

    return (
      groups
        // .sort(yearComparator)
        .reduce((acc, year, index) => {
          const columnIndex = subColumnItems?.length ? index * subColumnItems?.length + 1 : index + 1;
          const tuples = groupedData
            .get(year, fromJS([]))
            .flatMap(value => {
              return value.get("data").map(dataElem => {
                const values = subColumnItems?.length
                  ? subColumnItems.map(lkOrder => dataElem.get(lkOrder) || 0)
                  : [dataElem.get("total")];

                return [getLookupValue(key, dataElem), ...values];
              });
            })
            .toArray();

          buildRows({ tuples, rows: acc, columnsNumber, columnIndex });

          return acc;
        }, [])
        .map(value => ({ colspan: 0, row: value }))
    );
  }

  const groupComparator = getGroupComparator(groupedBy);

  const columnsNumber = subColumnItems.length
    ? subColumnItems.length * Object.values(groups).flat().length
    : Object.values(groups).flat().length;

  const years = Object.keys(groups);

  return years
    .sort(yearComparator)
    .reduce((acc1, year, yearIndex) => {
      const previousYears = new Array(yearIndex).fill(0, 0, yearIndex);
      const columnsWritten = previousYears.reduce((acc, _value, index) => acc + groups[years[index]].length, 0);
      // index + 1 because the first value is the title of the row
      const columnInitialIndex = subColumnItems.length
        ? subColumnItems.length * (columnsWritten || 0) + 1
        : columnsWritten + 1;

      groups[year].sort(groupComparator).forEach((group, index) => {
        const tuples = groupedData
          .get(`${year}-${group}`, fromJS([]))
          .flatMap(value =>
            value.get("data").map(dataElem => {
              const values = subColumnItems.length
                ? subColumnItems.map(lkOrder => dataElem.get(lkOrder) || 0)
                : [dataElem.get("total")];

              return [getLookupValue(key, dataElem), ...values];
            })
          )
          .toArray();

        const columnsCurrentGroup = subColumnItems.length ? subColumnItems.length * index : index;

        buildRows({
          tuples,
          rows: acc1,
          columnIndex: columnInitialIndex + columnsCurrentGroup,
          columnsNumber
        });
      });

      return acc1;
    }, [])
    .map(value => ({ colspan: 0, row: value }));
};

const buildSingleRows = ({ getLookupValue, data, key }) =>
  data
    .map(value => {
      const lookupValue = getLookupValue(key, value);

      return { colspan: 0, row: [lookupValue, value.get("total")] };
    })
    .toArray();

export default {
  ghn_report: ({ data, getLookupValue, key }) => {
    const grouped = data.some(fs => fs.get("group_id"));

    if (data === 0) return [];

    if (grouped) {
      return buildGroupedRows({ data, key, getLookupValue, groupedBy: "year" });
    }

    return buildSingleRows({ data, getLookupValue, key });
  },
  default: ({
    getLookupValue,
    data,
    key,
    isGrouped,
    groupedBy,
    ageRanges,
    lookupValues,
    incompleteDataLabel,
    subColumnItems = fromJS([])
  }) => {
    if (data === 0) return [];

    const lookupDisplayTexts = [
      ...(lookupValues?.map(lookupValue => lookupValue.display_text) || []),
      incompleteDataLabel
    ];

    const sortByFn = elem => first(elem.row);

    const rows =
      isGrouped && groupedBy
        ? buildGroupedRows({ data, key, getLookupValue, groupedBy, subColumnItems: subColumnItems.toJS() })
        : buildSingleRows({ data, getLookupValue, key });

    if (key === "age" || key?.includes("_age")) {
      return sortWithSortedArray(rows, ageRanges, sortByFn, incompleteDataLabel);
    }

    if (lookupDisplayTexts.length > 1) {
      return sortWithSortedArray(rows, lookupDisplayTexts, sortByFn);
    }

    return sortBy(rows, row => first(row.row));
  }
};
