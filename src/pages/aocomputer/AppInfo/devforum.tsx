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
} from "semantic-ui-react";
import Footer from "../../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import { useParams } from "react-router-dom";

interface Review {
  devForumId: string;
  forumId: string;
  username: string;
  comment: string;
  rating: number;
  time: number;
  profileUrl: string;
  header: string;
  replies: Reply[];
}

interface Reply {
  replyId: string;
  comment: string;
  timestamp: number;
  user: string;
  username: string;
  profileUrl: string;
}

const Home = () => {
  const { AppId } = useParams();
  const [loadingAppReviews, setLoadingAppReviews] = useState(true);
  const [appReviews, setAppReviews] = useState<Review[]>(null);
  const [updateApp, setUpdatingApp] = useState(false);
  const [updateValue, setUpdateValue] = useState("");
  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const updateOptions = [
    {
      key: "1",
      text: "Technical Requirements",
      value: "Technical Requirements",
    },
    {
      key: "2",
      text: "Integration and Dependencies",
      value: "Integration and Dependencies",
    },
    {
      key: "3",
      text: "Future Scalability and Maintenance",
      value: "Future Scalability and Maintenance",
    },
    {
      key: "4",
      text: "Problem and Solution Understanding",
      value: "Problem and Solution Understanding",
    },
    {
      key: "5",
      text: "Design and Branding Preferences",
      value: "Design and Branding Preferences",
    },
    {
      key: "6",
      text: "Performance and Metrics",
      value: "Performance and Metrics",
    },
    {
      key: "7",
      text: "Performance and Metrics",
      value: "Performance and Metrics",
    },
    {
      key: "8",
      text: "Security and Compliance",
      value: "Security and Compliance",
    },
    {
      key: "9",
      text: "Collaboration and Feedback",
      value: "Collaboration and Feedback",
    },
  ];

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    switch (name) {
      case "updatevalue":
        setUpdateValue(value);
        break;
      default:
        break;
    }
  };

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

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

  useEffect(() => {
    if (!AppId) return;
    console.log(AppId);
    const fetchAppReviews = async () => {
      setLoadingAppReviews(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "FetchDevForumDataN" },
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
          alert("Error fetching Dev Forum: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data);
          console.log(data);
          setAppReviews(data);
        }
      } catch (error) {
        console.error("Error fetching feature requests:", error);
      } finally {
        setLoadingAppReviews(false);
      }
    };

    (async () => {
      await fetchAppReviews();
    })();
  }, [AppId]);

  // Check if user has connected to Arweave Wallet
  const username = localStorage.getItem("username");
  const profileUrl = localStorage.getItem("profilePic");

  const AskQuestion = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setUpdatingApp(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "AskDevForum" },
          { name: "AppId", value: String(AppId) },
          { name: "comment", value: String(updateValue) },
          { name: "header", value: String(projectTypeValue) },
          { name: "profileUrl", value: String(profileUrl) },
          { name: "username", value: String(username) },
        ],

        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Sending inquiry.:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
      setUpdateValue("");
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setUpdatingApp(false);
    }
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Container textAlign="center">
          {loadingAppReviews ? (
            <Loader active inline="centered" />
          ) : appReviews ? (
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

                <Container textAlign="center">
                  <Form>
                    <FormField required>
                      <label>Type of Question.</label>
                      <FormSelect
                        options={updateOptions}
                        placeholder="Question Type"
                        value={selectedProjectType}
                        onChange={handleProjectTypeChange}
                      />
                    </FormField>
                    <FormField required>
                      <label>Question.</label>
                      <Input
                        type="text"
                        name="updatevalue"
                        value={updateValue}
                        onChange={handleInputChange}
                        placeholder="Inquiry"
                      />
                    </FormField>
                    <Button
                      loading={updateApp}
                      color="green"
                      onClick={() => AskQuestion(AppId)}
                    >
                      {" "}
                      Ask Question.
                    </Button>
                  </Form>
                </Container>

                <Divider />
                <Header as="h1" textAlign="center">
                  Project Dev Forum
                </Header>

                <Divider />
                <Grid>
                  <CommentGroup threaded>
                    {Object.entries(appReviews).map(([, review]) => (
                      <SUIComment key={review.devForumId}>
                        <SUIComment.Metadata>
                          <Header textAlign="center">
                            {" "}
                            Topic :{review.header}
                          </Header>{" "}
                        </SUIComment.Metadata>
                        <Divider />
                        <SUIComment.Avatar src={review.profileUrl} />
                        <SUIComment.Content>
                          <SUIComment.Author as="a">
                            {review.username || "Anonymous"}
                          </SUIComment.Author>
                          <SUIComment.Metadata>
                            <span>{formatDate(review.time)}</span>
                          </SUIComment.Metadata>

                          <SUIComment.Text>
                            {review.comment || "No comment provided."}
                          </SUIComment.Text>
                        </SUIComment.Content>
                        <SUIComment.Group>
                          {Object.entries(review.replies || []).map(
                            ([, reply]) => {
                              const typedReply = reply as Reply; // 👈 Type assertion

                              return (
                                <SUIComment key={typedReply.replyId}>
                                  <SUIComment.Avatar
                                    src={typedReply.profileUrl}
                                  />
                                  <SUIComment.Content>
                                    <SUIComment.Author as="a">
                                      {typedReply.username || "Anonymous"}
                                    </SUIComment.Author>
                                    <SUIComment.Metadata>
                                      <span>
                                        {formatDate(typedReply.timestamp)}
                                      </span>
                                    </SUIComment.Metadata>
                                    <SUIComment.Text>
                                      {typedReply.comment ||
                                        "No comment provided."}
                                    </SUIComment.Text>
                                  </SUIComment.Content>
                                </SUIComment>
                              );
                            }
                          )}
                        </SUIComment.Group>
                      </SUIComment>
                    ))}
                  </CommentGroup>
                </Grid>
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
