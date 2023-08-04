import PropTypes from "prop-types";
import { FormControl, FormControlLabel, FormHelperText, FormLabel, Radio, RadioGroup } from "@material-ui/core";
import { Controller } from "react-hook-form";

import css from "./styles.css";

const RadioInput = ({ commonInputProps, options, formMethods }) => {
  const { helperText, error, name, label: radioGroupLabel, className, disabled } = commonInputProps;
  const { control } = formMethods;

  return (
    <FormControl id={name} error={error} className={className}>
      <FormLabel component="legend" className="MuiInputLabel-root">
        {radioGroupLabel}
      </FormLabel>
      <Controller
        control={control}
        as={
          <RadioGroup aria-label="format" name={name} className={css.rowDirection}>
            {options &&
              options.map(({ id, label, display_text: displayText }) => (
                <FormControlLabel
                  key={`form-control-label-${id}`}
                  value={id}
                  label={label || displayText}
                  disabled={disabled}
                  control={<Radio />}
                />
              ))}
          </RadioGroup>
        }
        name={name}
      />
      {helperText && <FormHelperText>{helperText}</FormHelperText>}
    </FormControl>
  );
};

RadioInput.displayName = "RadioInput";

RadioInput.propTypes = {
  commonInputProps: PropTypes.shape({
    className: PropTypes.string,
    disabled: PropTypes.bool,
    error: PropTypes.bool,
    helperText: PropTypes.string,
    label: PropTypes.string,
    name: PropTypes.string
  }),
  formMethods: PropTypes.object.isRequired,
  options: PropTypes.array
};

export default RadioInput;
