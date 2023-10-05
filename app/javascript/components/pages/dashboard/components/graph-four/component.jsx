// alternative_care_placement_by_gender
// Cases requiring Alternative Care Placement Services

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { Chart } from "../../../../charts";
import { fetchGraphFour } from "../../action-creators";
import { getGraphFour } from "../../selectors";
import { useMemoizedSelector } from "../../../../../libs";

import styles from "./styles.css";

const useStyles = makeStyles(styles);

const Component = () => {
  const css = useStyles();
  const dispatch = useDispatch();
  const data = useMemoizedSelector(state => getGraphFour(state));
  // const stats = data ? data.toJS() : null;
  // TODO Getting stats empty, So setting this dummpy data for the time being.
  const stats = {
    labels: ["Category 1", "Category 2", "Category 3"],
    data: [10, 20, 15] // Sample data values
  };

  useEffect(() => {
    dispatch(fetchGraphFour());
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
          backgroundColor: ["rgb(54, 162, 235)", "rgb(255, 99, 132)", "rgba(255, 159, 64)"],
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
            <h2>Cases Requiring Alternative Care Placement</h2>
            <div className={css.card} flat>
              {graphData.datasets[0].data.reduce((acc, val) => {
                return acc + val;
              }, 0) !== 0 ? (
                <Chart type="doughnut" options={chartOptions} data={graphData} showDetails />
              ) : (
                <div className={css.messageDiv}>
                  {" "}
                  <p>Not enough data exists!</p>
                </div>
              )}
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

Component.displayName = `GraphFour`;

export default Component;
