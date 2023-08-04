import PropTypes from "prop-types";
import clsx from "clsx";

import css from "../styles.css";

const PageContent = ({ children, flex = false, hasNav = false }) => {
  const contentClasses = clsx(css.content, { [css.contentFlex]: flex, [css.hasNav]: hasNav });

  return <div className={contentClasses}>{children}</div>;
};

PageContent.propTypes = {
  children: PropTypes.node,
  flex: PropTypes.bool,
  hasNav: PropTypes.bool
};

PageContent.displayName = "PageContent";

export default PageContent;
