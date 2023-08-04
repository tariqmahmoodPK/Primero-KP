import { Menu, MenuItem, Button } from "@material-ui/core";
import LanguageIcon from "@material-ui/icons/Language";
import { useState } from "react";

import { DropdownDoubleIcon } from "../../images/primero-icons";
import { useI18n } from "../i18n";
import { selectLocales } from "../application/selectors";
import { useMemoizedSelector } from "../../libs";

import css from "./styles.css";
import { NAME } from "./constants";

const TranslationsToggle = () => {
  const { changeLocale, locale, ...i18n } = useI18n();
  const [anchorEl, setAnchorEl] = useState(null);

  const handleClick = event => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = option => {
    setAnchorEl(null);

    if (option) {
      changeLocale(option);
    }
  };

  const handleClickMenu = () => handleClose(null);

  // TODO: Need better list of locales with direction from backend
  const locales = useMemoizedSelector(state => selectLocales(state));

  const renderLocales = () => {
    const handleClickMenuItem = value => () => handleClose(value);

    return (
      locales &&
      locales.map(currLocale => {
        return (
          <MenuItem key={currLocale} onClick={handleClickMenuItem(currLocale)}>
            {i18n.t(`home.${currLocale}`)}
          </MenuItem>
        );
      })
    );
  };

  return (
    <>
      <Button
        id={`home.${locale}`}
        className={css.button}
        fullWidth
        onClick={handleClick}
        aria-haspopup="true"
        aria-owns={anchorEl ? "simple-menu" : undefined}
      >
        <LanguageIcon className={css.icon} />
        <div>{i18n.t(`home.${locale}`)}</div>
        <DropdownDoubleIcon />
      </Button>
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleClickMenu}
        classes={{
          paper: css.paper
        }}
        anchorOrigin={{
          vertical: "top",
          horizontal: "center"
        }}
        transformOrigin={{
          vertical: "top",
          horizontal: "center"
        }}
      >
        {renderLocales()}
      </Menu>
    </>
  );
};

TranslationsToggle.displayName = NAME;

export default TranslationsToggle;
