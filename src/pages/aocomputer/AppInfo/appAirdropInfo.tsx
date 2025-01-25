import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Container,
  Divider,
  Header,
  Icon,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
  Table,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../../components/footer/Footer";
import { useNavigate } from "react-router-dom";

interface AppData {
  appId: string;
  airdropId: string;
  appname: string;
  amount: string;
  status: string;
  timestamp: number;
  tokenId: string;
  Owner: string;
}

const AoprojectsInfo: React.FC = () => {
  const { AirdropId: paramAirdropId } = useParams<{ AirdropId?: string }>();
  const AirdropId = paramAirdropId || "defaultAirdropId"; // Default for safety
  const [appInfo, setAppInfo] = useState<AppData | null>(null);
  const [loading, setLoading] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

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

  useEffect(() => {
    const fetchAppInfo = async () => {
      setLoading(true);
      console.log("Fetching data for Airdrop ID:", AirdropId);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "FetchAirdropDataN" },
            { name: "airdropId", value: String(AirdropId) },
          ],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching app reviews: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data) as AppData;
          console.log(data);
          setAppInfo(data);
        }
      } catch (error) {
        console.error("Error fetching app reviews:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchAppInfo();
  }, [AirdropId]);

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
        <Divider />
        {loading ? (
          <Loader active inline="centered" />
        ) : appInfo ? (
          <Container>
            <Menu pointing>
              <MenuItem onClick={() => handleProjectInfo(appInfo.appId)}>
                <Icon name="pin" />
                Project Info
              </MenuItem>
              <MenuMenu position="right">
                <MenuItem onClick={() => handleProjectStats(appInfo.appId)}>
                  <Icon name="line graph" />
                  View Detailed Statistics
                </MenuItem>
                <MenuItem onClick={() => handleAppsAirdrops(appInfo.appId)}>
                  <Icon name="bitcoin" />
                  Airdrops
                </MenuItem>
                <MenuItem onClick={() => handleDeveloperInfo(appInfo.appId)}>
                  <Icon name="github square" />
                  Developer Forum
                </MenuItem>
              </MenuMenu>
            </Menu>
            <Header as="h1" textAlign="center">
              {" "}
              Airdrop Details.
            </Header>
            <Divider />
            <Table celled>
              <Table.Header>
                <Table.Row>
                  <Table.HeaderCell>Field</Table.HeaderCell>
                  <Table.HeaderCell>Value</Table.HeaderCell>
                </Table.Row>
              </Table.Header>
              <Table.Body>
                <Table.Row>
                  <Table.Cell>Airdrop ID</Table.Cell>
                  <Table.Cell>{appInfo.airdropId}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>App ID</Table.Cell>
                  <Table.Cell>{appInfo.appId}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>App Name</Table.Cell>
                  <Table.Cell>{appInfo.appname}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Amount</Table.Cell>
                  <Table.Cell>{appInfo.amount}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>{appInfo.status}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Timestamp</Table.Cell>
                  <Table.Cell>{formatDate(appInfo.timestamp)}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Token ID</Table.Cell>
                  <Table.Cell>{appInfo.tokenId}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>User ID</Table.Cell>
                  <Table.Cell>{appInfo.Owner}</Table.Cell>
                </Table.Row>
              </Table.Body>
            </Table>
            <Divider />
          </Container>
        ) : (
          <Header as="h4" color="grey">
            No Information found for this airdrop.
          </Header>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default AoprojectsInfo;
