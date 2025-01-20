import { useEffect, useState } from "react";
import {
  Container,
  Divider,
  Header,
  Grid,
  GridColumn,
  Menu,
  MenuItem,
  MenuMenu,
  Loader,
} from "semantic-ui-react";
import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  TimeScale,
} from "chart.js";
import "chart.js/auto";
import { FaDollarSign } from "react-icons/fa"; // Importing the money icon
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

interface Transaction {
  amount: number;
  time: number;
}

interface StatsData {
  totalEarnings: number;
  transactions: { [key: string]: Transaction }; // Correct type for a dictionary of transactions
}

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  TimeScale
);

const Home = () => {
  const [userStats, setUserStats] = useState<StatsData | null>(null);
  const [loadingUserStats, setLoadingUserStats] = useState(true);
  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  const handleMessages = () => {
    navigate("/messages");
  };

  const handleFeatureRequests = () => {
    navigate("/featurerequests");
  };

  const handleBugReports = () => {
    navigate("/bugreports");
  };

  const handleUserStats = () => {
    navigate("/userstats");
  };

  useEffect(() => {
    const fetchUserStats = async () => {
      setLoadingUserStats(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "GetUserStatistics" }],
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
          const rawData = Messages[0].Data;
          console.log("Raw data:", rawData);

          const data = JSON.parse(rawData);
          console.log("Parsed data:", data);

          const transformedData = {
            ...data,
            transactions: Object.values(data.transactions || {}), // Ensure data.transactions is treated as an object
          };

          console.log("Transformed data:", transformedData);
          setUserStats(transformedData);
        }
      } catch (error) {
        console.error("Error fetching user statistics:", error);
      } finally {
        setLoadingUserStats(false);
      }
    };

    (async () => {
      await fetchUserStats();
    })();
  }, []);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Divider />
        <Menu pointing>
          <MenuItem onClick={() => handleMessages()} name="Messages" />
          <MenuItem
            onClick={() => handleFeatureRequests()}
            name="Feature Requests."
          />
          <MenuMenu position="right">
            <MenuItem onClick={() => handleBugReports()} name="Bug Reports." />
            <MenuItem onClick={() => handleUserStats()} name="My statistics." />
          </MenuMenu>
        </Menu>

        <Header as="h1" textAlign="center">
          User Statistics.
        </Header>
        <Divider />

        {loadingUserStats ? (
          <Loader active inline="centered" />
        ) : userStats ? (
          <>
            {/* Total Earnings Header with Money Icon */}
            <Header as="h3" textAlign="center">
              <FaDollarSign style={{ marginRight: "8px" }} />
              Total Earnings: ${userStats.totalEarnings.toFixed(2)} AOS.
            </Header>
            <Divider />

            {/* Bar Chart */}
            <Grid>
              <GridColumn width={15}>
                <Bar
                  data={{
                    labels: userStats.transactions.map((entry) =>
                      formatDate(entry.time)
                    ),
                    datasets: [
                      {
                        label: "Earnings Over Time",
                        data: userStats.transactions.map(
                          (entry) => entry.amount
                        ),
                        backgroundColor: "rgba(75, 192, 192, 0.6)",
                        borderColor: "rgba(75, 192, 192, 1)",
                        borderWidth: 1,
                      },
                    ],
                  }}
                  options={{
                    responsive: true,
                    plugins: {
                      title: {
                        display: true,
                        text: "Earnings",
                      },
                    },
                    scales: {
                      x: {
                        title: {
                          display: true,
                          text: "Time",
                        },
                      },
                      y: {
                        title: {
                          display: true,
                          text: "Amount",
                        },
                      },
                    },
                  }}
                />
              </GridColumn>
            </Grid>
          </>
        ) : (
          <p>No user statistics available.</p>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
