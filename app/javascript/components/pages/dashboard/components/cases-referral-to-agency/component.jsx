// cases_referral_to_agency_stats
// Cases Referral (To Agency )
/* TODO Modify the Code to work with To Agency and By Agency Graph code */

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */

import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { BarChart } from "../../../../charts";
import { fetchCasesReferralToAgency } from "../../action-creators";
import { getCasesReferralToAgency } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getCasesReferralToAgency(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchCasesReferralToAgency());
  }, []);

  let graphData;
  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Departments",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Number Of Services",
            fontColor: "green"
          }
        }
      ]
    }
  };

  if (stats) {
    const labels = [];
    const reg = [];

    for (const key in stats) {
      labels.push(key);
    }
    for (const key in stats) {
      reg.push(stats[key]);
    }

    graphData = {
      labels,
      datasets: [
        {
          label: "Cases",
          data: reg,
          backgroundColor: [
            "blue",
            "red",
            "green",
            "orange",
            "purple",
            "cyan",
            "brown",
            "grey",
            "hotPink",
            "skyBlue",
            "yellow",
            "darkBlue",
            "pink"
          ]
        }
      ]
    };
  }

  return (
    <>
      {graphData && (
        <Grid item xl={6} md={6} xs={12}>
          <div className={css.container}>
            <h2>Case Referrals (by Agency)</h2>
            <div className={css.card} flat>
              <BarChart options={chartOptions} data={graphData} showDetails showLegend={false} />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `CasesReferralToAgency`;

export default Component;
