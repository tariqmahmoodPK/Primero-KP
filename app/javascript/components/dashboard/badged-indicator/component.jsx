import PropTypes from "prop-types";
import { useDispatch } from "react-redux";
import { push } from "connected-react-router";
import isEmpty from "lodash/isEmpty";

import DashboardChip from "../dashboard-chip";
import { ROUTES } from "../../../config";
import { buildFilter } from "../utils";
import LoadingIndicator from "../../loading-indicator";
import NAMESPACE from "../../pages/dashboard/namespace";

import css from "./styles.css";

const BadgedIndicator = ({ data, lookup, sectionTitle, indicator, loading, errors }) => {
  const dispatch = useDispatch();

  const loadingIndicatorProps = {
    overlay: true,
    hasData: Boolean(data.size),
    type: NAMESPACE,
    loading,
    errors
  };

  const handleClick = queryValue => () => {
    if (!isEmpty(queryValue)) {
      dispatch(
        push({
          pathname: ROUTES.cases,
          search: buildFilter(queryValue)
        })
      );
    }
  };

  const dashboardChips = lookup.map(lk => {
    const value = data.getIn(["indicators", indicator, lk.id]);
    const countValue = value ? value.get("count") : 0;
    const queryValue = value ? value.get("query") : [];

    return (
      <div key={lk.id}>
        <DashboardChip label={`${countValue} ${lk.display_text}`} type={lk.id} handleClick={handleClick(queryValue)} />
      </div>
    );
  });

  return (
    <>
      <LoadingIndicator {...loadingIndicatorProps}>
        <div className={css.sectionTitle}>{sectionTitle}</div>
        <div className={css.content}>{dashboardChips}</div>
      </LoadingIndicator>
    </>
  );
};

BadgedIndicator.displayName = "BadgedIndicator";

BadgedIndicator.propTypes = {
  data: PropTypes.object.isRequired,
  errors: PropTypes.bool,
  indicator: PropTypes.string.isRequired,
  loading: PropTypes.bool,
  lookup: PropTypes.array.isRequired,
  sectionTitle: PropTypes.string
};

export default BadgedIndicator;
