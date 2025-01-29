import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Container,
  Divider,
  Grid,
  GridColumn,
  Header,
  Loader,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import { Line, Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  TimeScale,
} from "chart.js";
import "chart.js/auto";
import "chartjs-adapter-date-fns";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../components/footer/Footer";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  TimeScale
);

interface CountHistory {
  count: number;
  time: number;
}

interface StatsData {
  AppName: string;
  CreatedTime: number;
  Title: string;
  TotalCount: number;
  TotalHistory: Record<number, number>; // Key is timestamp, value is count
  countHistory: CountHistory[];
}

const aoprojectsinfo = () => {
  const { AppId } = useParams();
  const [appStats, setAppstats] = useState<StatsData[]>([]);
  const [loadingAppStats, setLoadingAppStats] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";

  useEffect(() => {
    const fetchAppStats = async () => {
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "GetAostoreStatistics" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching Statistics: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data);
          console.log(data);
          // Transform data to ensure `countHistory` and `TotalHistory` are properly handled
          const transformedData = Object.values(data).map((item: any) => ({
            ...item,
            countHistory: item.countHistory
              ? Object.values(item.countHistory) // Convert object to array
              : [], // Default to an empty array if countHistory is missing
          }));
          console.log(transformedData);

          setAppstats(transformedData);
        }
      } catch (error) {
        console.error("Error fetching statistics:", error);
      } finally {
        setLoadingAppStats(false);
      }
    };

    (async () => {
      await fetchAppStats();
    })();
  }, []);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          {loadingAppStats ? (
            <div
              style={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                height: "60vh",
              }}
            >
              <Loader active inline="centered" size="large">
                Loading aostore statistics...
              </Loader>
            </div>
          ) : appStats.length > 0 ? (
            <>
              <Header as="h1" textAlign="center">
                Aostore Statistics
              </Header>
              <Divider />

              {appStats.map((app, index) => {
                const transformedData =
                  app.TotalHistory &&
                  Object.entries(app.TotalHistory)
                    .sort(([timeA], [timeB]) => Number(timeA) - Number(timeB)) // Sort by timestamp
                    .map(([time, count]) => ({
                      x: Number(time), // Convert timestamp to a number
                      y: count,
                    }));

                return (
                  <div key={index} style={{ marginBottom: "50px" }}>
                    <Header as="h3" textAlign="center">
                      {app.Title}
                    </Header>
                    <Header as="h5" textAlign="center" color="grey">
                      Total Count: {app.TotalCount}
                    </Header>
                    {transformedData && transformedData.length > 0 ? (
                      <Grid>
                        <GridColumn width={14}>
                          <Bar
                            data={{
                              labels: transformedData.map((d) =>
                                new Date(d.x).toLocaleDateString()
                              ),
                              datasets: [
                                {
                                  label: "Count Over Time",
                                  data: transformedData.map((d) => d.y),
                                  backgroundColor: "rgba(75, 192, 192, 0.6)",
                                  borderColor: "rgba(75, 192, 192, 1)",
                                  borderWidth: 1,
                                  barThickness: 20, // Adjust bar thickness
                                },
                              ],
                            }}
                            options={{
                              responsive: true,
                              plugins: {
                                title: {
                                  display: true,
                                  text: app.Title,
                                },
                              },
                              scales: {
                                x: {
                                  title: {
                                    display: true,
                                    text: "Time",
                                  },
                                  ticks: {
                                    autoSkip: true,
                                    maxTicksLimit: 7,
                                  },
                                },
                                y: {
                                  title: {
                                    display: true,
                                    text: "Count",
                                  },
                                },
                              },
                            }}
                          />
                        </GridColumn>
                      </Grid>
                    ) : (
                      <Header as="h5" textAlign="center" color="red">
                        No data available for this chart.
                      </Header>
                    )}
                  </div>
                );
              })}
            </>
          ) : (
            <>
              <Container>
                <Header as="h4" color="grey" textAlign="center">
                  App Statistics failed to load.
                </Header>
              </Container>
            </>
          )}
        </Container>

        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
