import PropTypes from "prop-types";

import { displayNameHelper } from "../../../../../libs";

const Component = ({ value, displayName, locale }) => {
  if (!value) {
    return null;
  }

  return (
    <>
      <span>
        {displayNameHelper(displayName, locale)} ({value.total})
      </span>
    </>
  );
};

Component.displayName = "SubformHeaderTally";

Component.propTypes = {
  displayName: PropTypes.object,
  locale: PropTypes.string,
  value: PropTypes.object
};

export default Component;
