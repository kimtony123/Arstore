import { useEffect, useState } from "react";
import {
  Container,
  Divider,
  Header,
  Grid,
  Menu,
  MenuItem,
  MenuMenu,
  CommentGroup,
  Loader,
  Icon,
  FormField,
  FormSelect,
  Input,
  Button,
  DropdownProps,
  Form,
  Table,
} from "semantic-ui-react";
import Footer from "../../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import { useParams } from "react-router-dom";

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
  const { AppId } = useParams();
  const [loadingAirdrops, setLoadingAirdrops] = useState(true);
  const [airdropData, setAppAirdropData] = useState<AppAirdropData[]>([]);
  const [updateApp, setUpdatingApp] = useState(false);
  const [updateValue, setUpdateValue] = useState("");
  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

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

  const handleAirdropInfo = (appId: string) => {
    navigate(`/appairdropinfo/${appId}`);
  };

  useEffect(() => {
    if (!AppId) return;
    console.log(AppId);

    const fetchAppAirdrops = async () => {
      setLoadingAirdrops(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "getAirdropsByAppId" },
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
          alert("Error fetching project Airdrops: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data);
          console.log(data);
          setAppAirdropData(Object.values(data));
        }
      } catch (error) {
        console.error("Error fetching App Airdrops:", error);
      } finally {
        setLoadingAirdrops(false);
      }
    };

    (async () => {
      await fetchAppAirdrops();
    })();
  }, [AppId]);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Container textAlign="center">
          {loadingAirdrops ? (
            <Loader active inline="centered" />
          ) : airdropData.length > 0 ? (
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
                <Divider />
                <Header as="h1" textAlign="center">
                  {" "}
                  Airdrops list.
                </Header>
                <Table celled>
                  <Table.Header>
                    <Table.Row>
                      <Table.HeaderCell>App Name</Table.HeaderCell>
                      <Table.HeaderCell>Timestamp</Table.HeaderCell>
                      <Table.HeaderCell> Amount</Table.HeaderCell>
                      <Table.HeaderCell>Status</Table.HeaderCell>
                      <Table.HeaderCell> Airdrop Info</Table.HeaderCell>
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
                            onClick={() => handleAirdropInfo(app.airdropId)}
                          >
                            Airdrop Info.
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))}
                  </Table.Body>
                </Table>
              </Container>
            </>
          ) : (
            <Header as="h4" color="grey">
              No Dev Forum Questions found for this app.
            </Header>
          )}

          <Divider />
        </Container>
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
