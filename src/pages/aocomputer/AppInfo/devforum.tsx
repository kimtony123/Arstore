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
} from "semantic-ui-react";
import Footer from "../../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import { useParams } from "react-router-dom";

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
  const { AppId } = useParams();
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

  const handleProjectStats = (appId: string) => {
    navigate(`/projectstatsuser/${appId}`);
  };

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  const handleDeveloperInfo = (appId: string) => {
    navigate(`/projectdevinfo/${appId}`);
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
            { name: "Action", value: "FetchDevForumData" },
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
  }, [AppId]);

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
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
            <MenuItem onClick={() => handleDeveloperInfo(AppId)}>
              <Icon name="github square" />
              Developer Forum.
            </MenuItem>
          </MenuMenu>
        </Menu>
        <Divider />
        <Container>
          {loadingAppReviews ? (
            <Loader active inline="centered" />
          ) : appReviews ? (
            <>
              <Container>
                <Divider />
                <Header as="h1" textAlign="center">
                  Project Dev Forum
                </Header>

                <Divider />
                <Grid>
                  <CommentGroup threaded>
                    {Object.entries(appReviews).map(([key, review]) => (
                      <SUIComment key={review.forumId}>
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
                                    src={typedReply.username}
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
            <Header as="h4" color="grey">
              No reviews found for this app.
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
