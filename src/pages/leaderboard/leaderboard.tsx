import { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Table,
  Image,
  Loader,
  Header,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

interface LeaderboardEntry {
  name: any;
  ratings: any;
  rank: any;
  AppIconUrl: any;
  category: string;
}

const Home = () => {
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [loadingLeaderboard, setLoadingLeaderboard] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  useEffect(() => {
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
            category: app.stats.category,
          }));
        setLeaderboard(mappedLeaderboard);
      } catch (error) {
        console.error("Error fetching leaderboard:", error);
      } finally {
        setLoadingLeaderboard(false);
      }
    };

    (async () => {
      await fetchLeaderboard();
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
      <Container>
        <Header as="h1"> Arweave and acomputer Top 15.</Header>
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
        <Divider />
        {loadingLeaderboard ? (
          <Loader active inline="centered" content="Loading Leaderboard..." />
        ) : (
          <Table celled>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>Icon.</Table.HeaderCell>
                <Table.HeaderCell>Name.</Table.HeaderCell>
                <Table.HeaderCell>Rank.</Table.HeaderCell>
                <Table.HeaderCell>Ratings.</Table.HeaderCell>
                <Table.HeaderCell>Category.</Table.HeaderCell>
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
                  <Table.Cell>{app.category}</Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
