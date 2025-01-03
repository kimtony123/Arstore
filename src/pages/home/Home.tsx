import { useEffect, useState } from "react";
import {
  Button,
  Card,
  CardGroup,
  Container,
  Divider,
  Grid,
  GridColumn,
  GridRow,
  Segment,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

interface Card {
  title: string;
  content: string;
  buttonText: string;
  buttonAction: () => void;
}
const AlternatingCards = () => {
  const [activeCard, setActiveCard] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false); // For smooth transitions

  const cards: Card[] = [
    {
      title: "Aoclimaoptions",
      content:
        "AoClimOptions is a decentralized weather market that allows you to trade temperature-based binary options.",
      buttonText: "Trade Now",
      buttonAction: () => alert("Trade Now clicked!"),
    },

    {
      title: "Arstore",
      content: "Appstore For ao and Arweave ecosystem",
      buttonText: "Trade Now",
      buttonAction: () => alert("Trade Now clicked!"),
    },
    {
      title: "AoWeatherAgent",
      content:
        "AO Weather Agent, powered by AO, we provide climate insights while keeping your data private.",
      buttonText: "Make Prediction Now",
      buttonAction: () => alert("Make Prediction clicked!"),
    },

    // Add more cards here when needed
  ];

  // Auto-switch between cards every 5 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      goToNextCard();
    }, 5000); // Change card every 10 seconds

    return () => clearInterval(interval);
  }, [activeCard]);

  const goToNextCard = () => {
    setIsTransitioning(true); // Start transition
    setTimeout(() => setIsTransitioning(false), 500); // End transition after 0.5s

    setActiveCard((prevCard) => (prevCard + 1) % cards.length);
  };

  const goToCard = (index: number) => {
    setIsTransitioning(true); // Start transition
    setTimeout(() => setIsTransitioning(false), 500); // End transition after 0.5s

    setActiveCard(index);
  };

  return (
    <div className="relative mt-8">
      {/* Cards Container */}
      <div className="w-full overflow-hidden">
        <div
          className={`flex px-2 transition-transform duration-500 ease-in-out ${
            isTransitioning ? "transform" : ""
          }`}
          style={{ transform: `translateX(-${activeCard * 100}%)` }}
        >
          {cards.map((card, index) => (
            <div
              key={index}
              className="min-w-full p-6 bg-gradient-to-tl from-gray-800 to-transparent rounded-xl ml-2 mr-2 first:ml-0 shadow-lg text-md md:text:lg"
            >
              <h3 className="xl:text-2xl font-semibold mb-4">{card.title}</h3>
              <p className="text-gray-400 mb-6">{card.content}</p>
              <button
                onClick={card.buttonAction}
                className="bg-white text-black px-4 py-2 rounded-full font-medium"
              >
                {card.buttonText}
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Dots Indicator */}
      <div className="flex justify-center mt-4 space-x-2">
        {cards.map((_, index) => (
          <span
            key={index}
            onClick={() => goToCard(index)}
            className={`h-3 w-3 rounded-full cursor-pointer ${
              activeCard === index ? "bg-amber-400" : "bg-white"
            }`}
          ></span>
        ))}
      </div>
    </div>
  );
};

const Home = () => {
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

  interface Stats {
    totalTrades: number;
    wins: number;
    losses: number;
    winRate: number;
  }

  interface LeaderboardEntry {
    totalTrades: number;
    wins: number;
    losses: number;
    winRate: number;
    traderID: string;
  }
  interface TraderData {
    UserId: string;
    stats: Stats;
  }

  const [apps, setApps] = useState<AppData[]>([]); // Initialize as an empty array
  const [isLoading, setIsLoadingData] = useState(false); // Loading state for check
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [loading, setLoading] = useState(true); // Add loading state

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  const navigate = useNavigate();

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  useEffect(() => {
    const fetchLeaderboard = async () => {
      setLoading(true); // Start loading

      try {
        const signer = createDataItemSigner(othent); // Create Othent signer

        // Send message to fetch leaderboard
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "fetch_app_leaderboard" }],
          signer, // Using Othent signer here
        });

        const getLeaderboardMessage = messageResponse;
        try {
          const { Messages, Error } = await result({
            message: getLeaderboardMessage,
            process: ARS,
          });

          if (Error) {
            alert("Error fetching leaderboard: " + Error);
            setLoading(false);
            return;
          }

          if (!Messages || Messages.length === 0) {
            alert("No messages were returned from AO. Please try later.");
            setLoading(false);
            return;
          }

          // Explicitly cast the parsed data to Record<string, TraderData>
          const data: Record<string, TraderData> = JSON.parse(Messages[0].Data);

          // Properly map the leaderboard data
          const leaderboardData = Object.entries(data).map(
            ([rank, traderData]) => ({
              traderID: traderData.UserId,
              totalTrades: traderData.stats.totalTrades,
              wins: traderData.stats.wins,
              losses: traderData.stats.losses,
              winRate: traderData.stats.winRate,
              rank: parseInt(rank), // Parse rank as an integer
            })
          );

          // Sort the leaderboard data by win rate, then by total trades if win rates are the same
          const sortedLeaderboard = leaderboardData.sort((a, b) => {
            if (b.winRate === a.winRate) {
              return b.totalTrades - a.totalTrades; // Compare total trades if win rates are equal
            }
            return b.winRate - a.winRate; // Compare win rates
          });

          setLeaderboard(sortedLeaderboard); // Update the leaderboard state
          setLoading(false); // End loading
        } catch (error) {
          alert("There was an error when loading the leaderboard: " + error);
          setLoading(false); // End loading on error
        }
      } catch (error) {
        console.error("Error fetching leaderboard:", error);
        setLoading(false); // End loading on error
      }
    };

    fetchLeaderboard(); // Call fetchLeaderboard when component mounts
  }, []);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Grid columns="equal">
          <GridColumn width={10}>
            <Container>
              <AlternatingCards />
              <Divider />
              <span className="font-bold"> Favorite Apps.</span>
              <Divider />
              <Grid>
                <Button
                  onClick={handleAddAoprojects}
                  floated="right"
                  icon="add circle"
                  primary
                  size="large"
                >
                  Add Project.
                </Button>
                <GridRow>
                  <CardGroup itemsPerRow={3}>
                    {apps.map((app, index) => (
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
                </GridRow>
                <GridRow></GridRow>
              </Grid>
            </Container>
          </GridColumn>
          <GridColumn>
            <Container>
              <Divider />
              <span className="font-bold">aocomputer Top 15.</span>
              <Divider />
              <Grid>
                <CardGroup>
                  <Card fluid color="red" header="Option 1" />
                  <Card fluid color="orange" header="Option 2" />
                  <Card fluid color="yellow" header="Option 3" />
                  <Card fluid color="red" header="Option 1" />
                  <Card fluid color="orange" header="Option 2" />
                  <Card fluid color="yellow" header="Option 3" />
                  <Card fluid color="red" header="Option 1" />
                  <Card fluid color="orange" header="Option 2" />
                  <Card fluid color="yellow" header="Option 3" />
                  <Card fluid color="red" header="Option 1" />
                  <Card fluid color="orange" header="Option 2" />
                  <Card fluid color="yellow" header="Option 3" />
                  <Card fluid color="red" header="Option 1" />
                  <Card fluid color="orange" header="Option 2" />
                  <Card fluid color="yellow" header="Option 3" />
                </CardGroup>
              </Grid>
            </Container>
          </GridColumn>
        </Grid>
      </div>
      <Divider />
      <Footer />
    </div>
  );
};

export default Home;
