/* TODO Update the referencing comments after properly updating the files */
// registered_cases_by_protection_concern
// Registered Cases by Protection Concern

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { BarChart } from "../../../../charts";
import { fetchRegisteredCasesByProtectionConcernReal } from "../../action-creators";
import { getRegisteredCasesByProtectionConcernReal } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getRegisteredCasesByProtectionConcernReal(state));
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  useEffect(() => {
    dispatch(fetchRegisteredCasesByProtectionConcernReal());
  }, []);

  let graphData;
  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Protection Concerns",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Number of Cases",
            fontColor: "green"
          }
        }
      ]
    }
  };

  if (stats) {
    const labels = [];
    const cases = [];
    const male = [];
    const female = [];
    const transgender = [];

    for (const key in stats) {
      labels.push(key);
    }

    for (const key in stats) {
      cases.push(stats[key].cases);
      male.push(stats[key].male);
      female.push(stats[key].female);
      transgender.push(stats[key].transgender);
    }
    graphData = {
      labels,
      datasets: [
        {
          label: "Male",
          data: male,
          backgroundColor: "rgba(54, 162, 235)",
          stack: "Stack 0"
        },
        {
          label: "Female",
          data: female,
          backgroundColor: "rgb(255, 99, 132)",
          stack: "Stack 0"
        },
        {
          label: "Transgender",
          data: transgender,
          backgroundColor: "rgba(255, 159, 64)",
          stack: "Stack 0"
        }
      ]
    };
  }

  return (
    <>
      {graphData && (
        <Grid item xl={6} md={6} xs={12}>
          <div className={css.container}>
            <h2>Registered Cases by Protection Concern</h2>
            <div className={css.card} flat>
              <BarChart options={chartOptions} data={graphData} showDetails />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `RegisteredCasesByProtectionConcern`;

export default Component;
