import { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Grid,
  GridColumn,
  GridRow,
  Table,
  Image,
  Loader,
  Card,
  CardGroup,
  Header,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

// AlternatingCards Component
interface Card {
  title: string;
  content: string;
  buttonText: string;
  buttonAction: () => void;
}
const AlternatingCards = ({ apps }: { apps: AppData[] }) => {
  const [activeCard, setActiveCard] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      goToNextCard();
    }, 5000);
    return () => clearInterval(interval);
  }, [activeCard]);

  const goToNextCard = () => {
    setIsTransitioning(true);
    setTimeout(() => setIsTransitioning(false), 500);
    setActiveCard((prevCard) => (prevCard + 1) % apps.length);
  };

  return (
    <div className="relative mt-8">
      <div className="w-full overflow-hidden">
        <div
          className={`flex px-2 transition-transform duration-500 ease-in-out ${
            isTransitioning ? "transform" : ""
          }`}
          style={{ transform: `translateX(-${activeCard * 100}%)` }}
        >
          {apps.map((app, index) => (
            <div
              key={index}
              className="min-w-full p-6 bg-gradient-to-tl from-gray-800 to-transparent rounded-xl ml-2 mr-2 first:ml-0 shadow-lg text-md md:text-lg"
            >
              <h3 className="xl:text-2xl font-semibold mb-4">{app.AppName}</h3>
              <p className="text-gray-400 mb-6">{app.Description}</p>
              <button
                onClick={() => window.open(app.WebsiteUrl, "_blank")}
                className="bg-white text-black px-4 py-2 rounded-full font-medium"
              >
                Visit Site
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Home Component
interface AppData {
  AppName: string;
  CompanyName: string;
  WebsiteUrl: string;
  ProjectType: string;
  AppIconUrl: string;
  CoverUrl: string;
  Company: string;
  Description: string;
}

// Home Component
interface FavoriteAppData {
  AppName: string;
  CompanyName: string;
  WebsiteUrl: string;
  ProjectType: string;
  AppIconUrl: string;
  CoverUrl: string;
  Company: string;
  Description: string;
}

interface LeaderboardEntry {
  name: any;
  ratings: any;
  rank: any;
  AppIconUrl: any;
}

const Home = () => {
  const [apps, setApps] = useState<AppData[]>([]);
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [loadingApps, setLoadingApps] = useState(true);
  const [isloadingFavoriteApps, setLoadingFavoriteApps] = useState(true);
  const [loadingLeaderboard, setLoadingLeaderboard] = useState(true);
  const [FavoriteApps, setFavoriteApps] = useState<FavoriteAppData[]>([]);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchApps = async () => {
      setLoadingApps(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "getApps" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching apps: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No messages returned from AO. Please try later.");
          return;
        }

        const data = JSON.parse(Messages[0].Data);
        setApps(Object.values(data));
      } catch (error) {
        console.error("Error fetching apps:", error);
      } finally {
        setLoadingApps(false);
      }
    };

    const fetchLeaderboard = async () => {
      setLoadingLeaderboard(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "fetch_app_leaderboard" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching leaderboard: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No leaderboard data returned from AO.");
          return;
        }
        // Parse and map the leaderboard data
        const data: Record<string, any> = JSON.parse(Messages[0].Data);
        console.log(data);
        const mappedLeaderboard = Object.values(data)
          .slice(0, 15) // Get top 15 apps
          .map((app) => ({
            rank: app.rank,
            ratings: app.stats.ratings || 0,
            name: app.stats.name,
            AppIconUrl: app.stats.AppIconUrl || "", // Default to empty string if not available
          }));
        setLeaderboard(mappedLeaderboard);
      } catch (error) {
        console.error("Error fetching leaderboard:", error);
      } finally {
        setLoadingLeaderboard(false);
      }
    };

    const fetchFavoriteApps = async () => {
      setLoadingFavoriteApps(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "getFavoriteApps" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching favorite apps: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No messages returned from AO. Please try later.");
          return;
        }

        const data = JSON.parse(Messages[0].Data);
        console.log(data);
        setApps(Object.values(data));
      } catch (error) {
        console.error("Error fetching favorite apps:", error);
      } finally {
        setLoadingFavoriteApps(false);
      }
    };

    (async () => {
      await fetchFavoriteApps();
      await fetchLeaderboard();
      await fetchApps();
    })();
  }, []);

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Grid columns="equal">
        <GridColumn width={9}>
          <Container>
            {loadingApps ? (
              <Loader active inline="centered" content="Loading Apps..." />
            ) : (
              <AlternatingCards apps={apps} />
            )}
            <Divider />
          </Container>
          <Divider />
          <Button
            onClick={handleAddAoprojects}
            floated="right"
            icon="add circle"
            primary
            size="large"
          >
            Add Project.
          </Button>
          <Header> Favorite Apps.</Header>

          <Card>
            <CardGroup itemsPerRow={3}>
              {FavoriteApps.map((app, index) => (
                <Card
                  size="small"
                  key={index}
                  image={app.CoverUrl}
                  header={app.AppName}
                  meta={app.Company}
                  description={app.Description}
                  extra={
                    <a
                      href={app.WebsiteUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Visit Site
                    </a>
                  }
                />
              ))}
            </CardGroup>
          </Card>
        </GridColumn>
        <GridColumn>
          <span className="font-bold">AOComputer Top 15</span>
          <Divider />
          {loadingLeaderboard ? (
            <Loader active inline="centered" content="Loading Leaderboard..." />
          ) : (
            <Table celled>
              <Table.Header>
                <Table.Row>
                  <Table.HeaderCell>Icon</Table.HeaderCell>
                  <Table.HeaderCell>Name</Table.HeaderCell>
                  <Table.HeaderCell>Rank</Table.HeaderCell>
                  <Table.HeaderCell>Ratings</Table.HeaderCell>
                </Table.Row>
              </Table.Header>

              <Table.Body>
                {leaderboard.map((app, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>
                      <Image src={app.AppIconUrl} size="tiny" rounded />
                    </Table.Cell>
                    <Table.Cell>{app.name}</Table.Cell>
                    <Table.Cell>{app.rank}</Table.Cell>
                    <Table.Cell>{app.ratings}</Table.Cell>
                  </Table.Row>
                ))}
              </Table.Body>
            </Table>
          )}
        </GridColumn>
      </Grid>
      <Footer />
    </div>
  );
};

export default Home;
