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
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
// Home Component
interface MessagesData {
  AppName: string;
  AppIconUrl: string;
  Company: string;
  Header: string;
  Message: string;
  LinkInfo: string;
  currentTime: number;
}

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
  username: string;
  profileUrl: string;
}

const Home = () => {
  const [loadingAppReviews, setLoadingAppReviews] = useState(true);
  const [appReviews, setAppReviews] = useState<Record<string, any> | null>(
    null
  );
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
    const fetchAppReviews = async () => {
      setLoadingAppReviews(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "FetchFeatureRequestUserDataM" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching feature Requests.: " + Error);
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
  }, []);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Container>
          <Divider />
          {loadingAppReviews ? (
            <Loader active inline="centered" />
          ) : appReviews ? (
            <>
              <Container>
                <Divider />
                <Menu pointing>
                  <MenuItem onClick={() => handleMessages()} name="Messages" />
                  <MenuItem
                    onClick={() => handleFeatureRequests()}
                    name="Feature Requests."
                  />
                  <MenuMenu position="right">
                    <MenuItem
                      onClick={() => handleBugReports()}
                      name="Bug Reports."
                    />
                    <MenuItem
                      onClick={() => handleUserStats()}
                      name="My statistics."
                    />
                  </MenuMenu>
                </Menu>

                <Header as="h1" textAlign="center">
                  Feature Requests.
                </Header>
                <Divider />
                <Grid>
                  <CommentGroup threaded>
                    {Object.entries(appReviews).map(([key, review]) => (
                      <SUIComment key={review.reviewId}>
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
                          {Object.entries(review.replies || {}).map(
                            ([replyKey, reply]) => {
                              const typedReply = reply as Reply; // 👈 Type assertion

                              return (
                                <SUIComment key={typedReply.replyId}>
                                  <SUIComment.Avatar
                                    src={typedReply.profileUrl}
                                  />
                                  <SUIComment.Content>
                                    <SUIComment.Author as="a">
                                      {typedReply.user || "Anonymous"}
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
            <>
              <Container>
                <Menu pointing>
                  <MenuItem onClick={() => handleMessages()} name="Messages" />
                  <MenuItem
                    onClick={() => handleFeatureRequests()}
                    name="Feature Requests."
                  />
                  <MenuMenu position="right">
                    <MenuItem
                      onClick={() => handleBugReports()}
                      name="Bug Reports."
                    />
                    <MenuItem
                      onClick={() => handleUserStats()}
                      name="My statistics."
                    />
                  </MenuMenu>
                </Menu>
                <Header as="h4" color="grey">
                  You have not made any feature requests.
                </Header>
              </Container>
            </>
          )}

          <Divider />
        </Container>
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
