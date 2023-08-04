import PropTypes from "prop-types";
import { Select, MenuItem } from "@material-ui/core";

import css from "../styles.css";

const Component = ({ handleSelectedField, options, selectedField }) => {
  return (
    <div className={css.dateInput}>
      <Select fullWidth value={selectedField} onChange={handleSelectedField} variant="outlined">
        {options?.map(option => (
          <MenuItem value={option.id} key={option.id}>
            {option.display_name}
          </MenuItem>
        ))}
      </Select>
    </div>
  );
};

Component.displayName = "FieldSelect";

Component.propTypes = {
  handleSelectedField: PropTypes.func,
  options: PropTypes.array,
  selectedField: PropTypes.string
};

export default Component;
