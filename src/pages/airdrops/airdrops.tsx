import { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Table,
  Loader,
  Header,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

// Home Component
interface AppAirdropData {
  userId: string;
  appId: string;
  tokenId: string;
  amount: number;
  timestamp: number;
  appname: string;
  airdropId: string;
  status: string;
}

const Home = () => {
  const [loadingAirdrops, setLoadingAirdrops] = useState(true);
  const [airdropData, setAppAirdropData] = useState<AppAirdropData[]>([]);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAirdrops = async () => {
      setLoadingAirdrops(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "getAllAirdropsN" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching Airdrops: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No messages returned from AO. Please try later.");
          return;
        }
        const data = JSON.parse(Messages[0].Data);
        console.log(data);
        setAppAirdropData(Object.values(data));
      } catch (error) {
        console.error("Error fetching Airdrops:", error);
      } finally {
        setLoadingAirdrops(false);
      }
    };
    (async () => {
      await fetchAirdrops();
    })();
  }, []);

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        {loadingAirdrops ? (
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              height: "60vh",
            }}
          >
            <Loader active inline="centered" size="large">
              Loading airdrops...
            </Loader>
          </div>
        ) : airdropData.length > 0 ? (
          <>
            <Header as="h1"> Airdrops List</Header>
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
            <Header as="h1" textAlign="center">
              {" "}
              Airdrops list.
            </Header>
            <Table celled>
              <Table.Header>
                <Table.Row>
                  <Table.HeaderCell>App Name</Table.HeaderCell>
                  <Table.HeaderCell>Created Time</Table.HeaderCell>
                  <Table.HeaderCell> Amount</Table.HeaderCell>
                  <Table.HeaderCell>Status</Table.HeaderCell>
                  <Table.HeaderCell>App Info</Table.HeaderCell>
                </Table.Row>
              </Table.Header>
              <Table.Body>
                {airdropData.map((app, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>{app.appname}</Table.Cell>
                    <Table.Cell>{formatDate(app.timestamp)}</Table.Cell>
                    <Table.Cell>{app.amount}</Table.Cell>
                    <Table.Cell>{app.status}</Table.Cell>
                    <Table.Cell>
                      <Button
                        primary
                        onClick={() => handleProjectInfo(app.appId)}
                      >
                        App Info
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table.Body>
            </Table>
          </>
        ) : (
          <>
            <Container>
              <Header as="h1" color="red" textAlign="center">
                There is no airdrops Now , check back later.
              </Header>
            </Container>
          </>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
