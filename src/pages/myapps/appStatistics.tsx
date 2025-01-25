import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Container,
  Divider,
  Grid,
  GridColumn,
  Header,
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
import Footer from "../../components/footer/Footer";
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
  const ratingsData = {
    1: 20,
    2: 10,
    3: 15,
    4: 25,
    5: 30,
  };

  const { AppId } = useParams();
  const [appStats, setAppstats] = useState<StatsData[]>([]);
  const [loadingAppStats, setLoadingAppStats] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  // Ensure AppId is never undefined
  const handleProjectReviewsInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectreviews/${appId}`);
  };

  const handleOwnerStatisticsInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectstats/${appId}`);
  };

  const handleOwnerAirdropInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectairdropsadmin/${appId}`);
  };

  const handleOwnerUpdatesInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectupdates/${appId}`);
  };

  const handleOwnerChange = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/ownerchange/${appId}`);
  };

  const handleNotification = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/sendupdates/${appId}`);
  };

  const handleFeaturesandBugs = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectfeaturesbugs/${appId}`);
  };

  const handleBugReports = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectbugreports/${appId}`);
  };

  const handleAostoreAi = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectaostoreai/${appId}`);
  };

  const handleTasks = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projecttasks/${appId}`);
  };

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

  const src = "AO.svg";

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          <Divider />
          <Menu pointing>
            <MenuItem
              onClick={() => handleProjectReviewsInfo(AppId)}
              name="Reviews"
            />
            <MenuItem
              onClick={() => handleOwnerStatisticsInfo(AppId)}
              name="Statistics"
            />
            <MenuItem
              onClick={() => handleOwnerAirdropInfo(AppId)}
              name="Airdrops"
            />
            <MenuMenu position="right">
              <MenuItem
                onClick={() => handleOwnerUpdatesInfo(AppId)}
                name="Update"
              />
              <MenuItem
                onClick={() => handleOwnerChange(AppId)}
                name="change owner"
              />
              <MenuItem
                onClick={() => handleNotification(AppId)}
                name="Send Messages."
              />
              <MenuItem
                onClick={() => handleFeaturesandBugs(AppId)}
                name="F Requests."
              />
              <MenuItem
                onClick={() => handleBugReports(AppId)}
                name="Bug Reports."
              />

              <MenuItem
                onClick={() => handleAostoreAi(AppId)}
                name="aostore AI"
              />
              <MenuItem onClick={() => handleTasks(AppId)} name="tasks" />
            </MenuMenu>
          </Menu>
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
                Loading App statistics...
              </Loader>
            </div>
          ) : (
            appStats.map((app, index) => (
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
            ))
          )}
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
