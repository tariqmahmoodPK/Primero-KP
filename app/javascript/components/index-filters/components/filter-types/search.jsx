import { useState, useEffect, useRef } from "react";
import { useFormContext } from "react-hook-form";
import { IconButton, InputBase, InputAdornment } from "@material-ui/core";
import SearchIcon from "@material-ui/icons/Search";
import ClearIcon from "@material-ui/icons/Clear";

import { useI18n } from "../../../i18n";

import css from "./styles.css";
import { registerInput } from "./utils";
import handleFilterChange from "./value-handlers";

const Search = () => {
  const i18n = useI18n();

  const { register, unregister, setValue } = useFormContext();
  const [inputValue, setInputValue] = useState();
  const valueRef = useRef();
  const fieldName = "query";
  const fieldNameIdSearch = "id_search";

  useEffect(() => {
    registerInput({
      register,
      name: fieldName,
      defaultValue: "",
      ref: valueRef,
      setInputValue
    });

    register({ name: fieldNameIdSearch });

    return () => {
      unregister(fieldName);
    };
  }, [register, unregister]);

  const handleChange = event => {
    const { value } = event.target;

    handleFilterChange({
      type: "basic",
      event,
      value: event.target.value,
      setInputValue,
      inputValue,
      setValue,
      fieldName
    });

    setValue(fieldNameIdSearch, !!value);
  };

  const handleClear = () => {
    setValue(fieldName, undefined);
  };

  return (
    <div className={css.searchContainer}>
      <div className={css.searchInputContainer}>
        <IconButton className={css.iconSearchButton} aria-label="menu" type="submit" color="primary">
          <SearchIcon />
        </IconButton>
        <InputBase
          id="search-input"
          className={css.searchInput}
          placeholder={i18n.t("navigation.search")}
          onKeyUp={handleChange}
          onChange={handleChange}
          value={inputValue}
          inputProps={{ "aria-label": i18n.t("navigation.search") }}
          endAdornment={
            <InputAdornment position="end">
              <IconButton className={css.iconSearchButton} onClick={handleClear}>
                <ClearIcon />
              </IconButton>
            </InputAdornment>
          }
        />
      </div>
    </div>
  );
};

Search.displayName = "Search";

export default Search;
