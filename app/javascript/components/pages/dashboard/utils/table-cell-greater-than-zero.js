import getCellValue from "./get-cell-value";

export default condition => ({
  setCellProps: currValue => {
    const value = getCellValue(currValue);
    const style = typeof value === "number" && value > 0 && condition ? { cursor: "pointer" } : { cursor: "auto" };

    return {
      style
    };
  }
});
