import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  CommentGroup,
  Container,
  Divider,
  DropdownProps,
  Form,
  FormField,
  FormSelect,
  FormTextArea,
  Grid,
  GridColumn,
  Header,
  Icon,
  Loader,
  Rating,
  Statistic,
  StatisticLabel,
  StatisticValue,
  Table,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../../components/footer/Footer";
import { useNavigate } from "react-router-dom";
import Calendar from "react-calendar";

interface Review {
  reviewId: string;
  username: string;
  comment: string;
  rating: number;
  timestamp: number;
  upvotes: number;
  downvotes: number;
  helpfulVotes: number;
  unhelpfulVotes: number;
  profileUrl: string;
  voters: Record<string, any>;
  replies: Reply[];
}

interface Reply {
  replyId: string;
  comment: string;
  timestamp: number;
  upvotes: number;
  downvotes: number;
  user: string;
}

interface AppData {
  AppName: string;
  CompanyName: string;
  Reviews: Record<string, Review[]>;
  AppId: string;
}

type ValuePiece = Date | null;

type Value = ValuePiece | [ValuePiece, ValuePiece];

const aoprojectsinfo = () => {
  const { AirdropId: paramAppId } = useParams();
  const AppId = paramAppId || "defaultAppId"; // Provide a default AppId
  const [appInfo, setAppInfo] = useState<Record<string, any> | null>(null);
  const [loadingAirdropInfo, setLoadingAirdropInfo] = useState(true);
  const [value, onChange] = useState<Value>(new Date());
  const [finalizeAirdrop, setFinalizeAirdrop] = useState(true);

  // Separate state for start and end dates
  const [startDate, setStartDate] = useState<Date | null>(null);
  const [endDate, setEndDate] = useState<Date | null>(null);
  const [startUnixTime, setStartUnixTime] = useState<number | null>(null);
  const [endUnixTime, setEndUnixTime] = useState<number | null>(null);

  // Handle start date selection
  const handleStartDateChange = (date: Date) => {
    setStartDate(date);
    setStartUnixTime(Math.floor(date.getTime() / 1000));
  };

  // Handle end date selection
  const handleEndDateChange = (date: Date) => {
    setEndDate(date);
    setEndUnixTime(Math.floor(date.getTime() / 1000));
  };

  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const updateOptions = [
    { key: "1", text: "Favorites", value: "favoritesTable" },
    { key: "2", text: "Reviewers", value: "reviewsTable" },
    { key: "3", text: "Helpful", value: "helpfulTable" },
    { key: "4", text: "Upvoters", value: "upvotesTable" },
    { key: "5", text: "Feature Requesters", value: "featureRequestsTable" },
    { key: "6", text: "Bug Reporters", value: "bugReportTables" },
  ];
  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAppInfo = async () => {
      setLoadingAirdropInfo(true);
      console.log(AppId);
      try {
        const messageResponse = await message({
          process: "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk",
          tags: [
            { name: "Action", value: "FetchAirdropData" },
            { name: "airdropId", value: String(AppId) },
          ],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk",
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching app reviews: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data);
          console.log(data);
          setAppInfo(data);
        }
      } catch (error) {
        console.error("Error fetching app reviews:", error);
      } finally {
        setLoadingAirdropInfo(false);
      }
    };

    fetchAppInfo();
  }, [AppId]);

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

  const FinalizeAirdrop = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setFinalizeAirdrop(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "FinalizeAirdrop" },
          { name: "airdropId", value: String(AppId) },
          { name: "airdropsreceivers", value: String(projectTypeValue) },
          { name: "startTime", value: String(startUnixTime) },
          { name: "endTime", value: String(endUnixTime) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding Project:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the App Info: " + error);
      console.error(error);
    } finally {
      setFinalizeAirdrop(false);
      navigate("/");
    }
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Header as="h1">Finalize Airdrop.</Header>

        <Divider />
        {loadingAirdropInfo ? (
          <Loader active inline="centered" />
        ) : appInfo ? (
          <Container>
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
                  <Table.Cell>Amount</Table.Cell>
                  <Table.Cell>{appInfo.amount}</Table.Cell>
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
                  <Table.Cell>{appInfo.userId}</Table.Cell>
                </Table.Row>
              </Table.Body>
            </Table>
            <Divider />
          </Container>
        ) : (
          <Header as="h4" color="grey">
            No App Info found for this app.
          </Header>
        )}

        <Divider />
        {loadingAirdropInfo ? (
          <Loader active inline="centered" />
        ) : appInfo ? (
          <Container>
            <Grid>
              <Grid.Row>
                <GridColumn>
                  <Form>
                    <FormField required>
                      <label>Select Airdrop Type</label>
                      <FormSelect
                        options={updateOptions}
                        placeholder="Select airdrop type"
                        value={selectedProjectType}
                        onChange={handleProjectTypeChange}
                      />
                    </FormField>
                    <Divider />
                    <Grid columns={2}>
                      <GridColumn>
                        <Header as="h5">Start Date</Header>
                        <Calendar
                          onChange={(date: Date) => handleStartDateChange(date)}
                          value={startDate}
                        />
                        {startUnixTime && (
                          <p>Unix Start Time: {startUnixTime}</p>
                        )}
                      </GridColumn>
                      <GridColumn>
                        <Header as="h5">End Date</Header>
                        <Calendar
                          onChange={(date: Date) => handleEndDateChange(date)}
                          value={endDate}
                        />
                        {endUnixTime && <p>Unix End Time: {endUnixTime}</p>}
                      </GridColumn>
                    </Grid>
                    <Divider />
                    <Button
                      onClick={() => FinalizeAirdrop(appInfo.airdropId)}
                      color="green"
                    >
                      Finalize Airdrop
                    </Button>
                  </Form>
                </GridColumn>
              </Grid.Row>
            </Grid>
          </Container>
        ) : (
          <Header as="h4" color="grey">
            No Airdrop Info found for this Airdrop ID.
          </Header>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
