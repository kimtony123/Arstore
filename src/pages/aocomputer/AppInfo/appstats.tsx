import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Container,
  Divider,
  Grid,
  GridColumn,
  Header,
  Icon,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import { Line } from "react-chartjs-2";
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
import "chartjs-adapter-date-fns";
import * as othent from "@othent/kms";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon

import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../../components/footer/Footer";
import { useNavigate } from "react-router-dom";

interface CountHistory {
  count: number;
  time: number;
}

interface StatsData {
  AppName: string;
  CreatedTime: number;
  Title: string;
  count: number;
  countHistory: CountHistory[];
}

const aoprojectsinfo = () => {
  const { AppId } = useParams();
  const [appStats, setAppstats] = useState<StatsData[]>([]);
  const [loadingAppStats, setLoadingAppStats] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAppStats = async () => {
      if (!AppId) return;
      console.log(AppId);
      setLoadingAppStats(true);

      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "GetAppStatistics" },
            { name: "AppId", value: String(AppId) },
          ],
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
          // Transform the data to ensure `countHistory` is always an array
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
  }, [AppId]);

  const handleProjectStats = (appId: string) => {
    navigate(`/projectstatsuser/${appId}`);
  };

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  const handleDeveloperInfo = (appId: string) => {
    navigate(`/projectdevinfo/${appId}`);
  };

  const handleAppsAirdrops = (appId: string) => {
    navigate(`/projectairdrops/${appId}`);
  };

  const src = "AO.svg";

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
                Loading Project Statistics...
              </Loader>
            </div>
          ) : appStats.length > 0 ? (
            <>
              <Menu pointing>
                <MenuItem onClick={() => handleProjectInfo(AppId)}>
                  <Icon name="pin" />
                  Project Info.
                </MenuItem>
                <MenuMenu position="right">
                  <MenuItem onClick={() => handleProjectStats(AppId)}>
                    <Icon name="line graph" />
                    View Detailed Statistics
                  </MenuItem>
                  <MenuItem onClick={() => handleAppsAirdrops(AppId)}>
                    <Icon name="bitcoin" />
                    Airdrops
                  </MenuItem>
                  <MenuItem onClick={() => handleDeveloperInfo(AppId)}>
                    <Icon name="github square" />
                    Developer Forum.
                  </MenuItem>
                </MenuMenu>
              </Menu>
              <Divider />
              <Header as="h1" textAlign="center">
                Project Statistics.
              </Header>
              <Divider />

              {loadingAppStats ? (
                <Loader active inline="centered" />
              ) : (
                appStats.map((app, index) => (
                  <>
                    <Grid key={index}>
                      <GridColumn width={14}>
                        <Line
                          data={{
                            datasets: [
                              {
                                label: "Count Over Time",
                                data: app.countHistory.map((entry) => ({
                                  x: entry.time, // Use Unix timestamp
                                  y: entry.count,
                                })),
                                borderColor: "rgba(75, 192, 192, 1)",
                                backgroundColor: "rgba(75, 192, 192, 0.2)",
                                borderWidth: 2,
                                pointRadius: 5, // Set the size of the dots
                                pointBackgroundColor: "rgba(75, 192, 192, 1)", // Color of the dots
                                pointBorderColor: "rgba(0, 0, 0, 0.8)", // Border color of the dots
                                pointBorderWidth: 1, // Border width of the dots
                                tension: 0.7, // Smooth the line (0 = no smoothing, 1 = maximum smoothing)
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
                                type: "time",
                                time: {
                                  unit: "day",
                                  tooltipFormat: "Pp",
                                  displayFormats: {
                                    day: "MMM dd, yyyy",
                                  },
                                },
                                title: {
                                  display: true,
                                  text: "Time",
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
                  </>
                ))
              )}
            </>
          ) : (
            <>
              <Container>
                <Menu pointing>
                  <MenuItem onClick={() => handleProjectInfo(AppId)}>
                    <Icon name="pin" />
                    Project Info.
                  </MenuItem>
                  <MenuMenu position="right">
                    <MenuItem onClick={() => handleProjectStats(AppId)}>
                      <Icon name="line graph" />
                      View Detailed Statistics
                    </MenuItem>
                    <MenuItem onClick={() => handleAppsAirdrops(AppId)}>
                      <Icon name="bitcoin" />
                      Airdrops
                    </MenuItem>
                    <MenuItem onClick={() => handleDeveloperInfo(AppId)}>
                      <Icon name="github square" />
                      Developer Forum.
                    </MenuItem>
                  </MenuMenu>
                </Menu>
                <Header as="h4" color="grey" textAlign="center">
                  App Statistics failed to load .
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
