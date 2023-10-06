// significant_harm_cases_registered_by_age_and_gender_stats
// Significant Harm Cases by Protection Concern

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { Chart } from "../../../../charts";
import { fetchHarmCases } from "../../action-creators";
import { getHarmCases } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getHarmCases(state));
  // const stats = data ? data.toJS() : null;
  // TODO Getting stats empty, So setting this dummpy data for the time being.
  const stats = {
    labels: ["Category 1", "Category 2", "Category 3", "Category 4", "Category 5", "Category 6", "Category 7"],
    data: [10, 20, 15, 10, 20, 15, 10] // Sample data values
  };

  useEffect(() => {
    dispatch(fetchHarmCases());
  }, []);

  let graphData;
  const chartOptions = {
    scales: {
      xAxes: [
        {
          ticks: {
            display: false
          },
          gridLines: {
            display: false
          },
          scaleLabel: {
            display: false,
            labelString: "Time in Seconds",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          ticks: {
            display: false
          },
          gridLines: {
            display: false
          },
          scaleLabel: {
            display: false,
            labelString: "Speed in Miles per Hour",
            fontColor: "green"
          }
        }
      ]
    }
  };

  if (stats && stats.data) {
    graphData = {
      labels: stats.labels,
      datasets: [
        {
          label: stats.labels,
          data: stats.data,
          backgroundColor: [
            "rgb(255, 99, 132)",
            "rgb(54, 162, 235)",
            "rgb(255, 205, 86)",
            "rgb(128, 0, 128)",
            "rgb(150,75,0)",
            "rgb(54, 170, 89)",
            "rgb(254, 170, 89)"
          ],
          hoverOffset: 6
        }
      ]
    };
  }

  return (
    <>
      {graphData && (
        <Grid item xl={6} md={6} xs={12}>
          <div className={css.container}>
            <h2>Significant Harm Cases by Protection Concern</h2>
            <div className={css.card} flat>
              <Chart type="doughnut" options={chartOptions} data={graphData} showDetails />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `RegResCases`;

export default Component;
