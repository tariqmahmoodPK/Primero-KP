import { Drawer } from "@material-ui/core";
import PropTypes from "prop-types";

import { useDrawer } from "../../../drawer";

import { FILTER_DRAWER, NAME } from "./constants";
import css from "./styles.css";

const FilterContainer = ({ children, mobileDisplay }) => {
  const { drawerOpen, toggleDrawer } = useDrawer(FILTER_DRAWER);

  if (mobileDisplay) {
    return (
      <Drawer anchor="right" open={drawerOpen} onClose={toggleDrawer}>
        {children}
      </Drawer>
    );
  }

  return (
    <div className={css.filterContainer} mx={2}>
      {children}
    </div>
  );
};

FilterContainer.displayName = NAME;

FilterContainer.propTypes = {
  children: PropTypes.node.isRequired,
  mobileDisplay: PropTypes.bool.isRequired
};

export default FilterContainer;
