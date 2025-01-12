import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  CommentAction,
  CommentGroup,
  Container,
  Divider,
  Form,
  FormTextArea,
  Grid,
  GridColumn,
  Header,
  Icon,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
  Rating,
  Segment,
  Statistic,
  StatisticLabel,
  StatisticValue,
  Image,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../components/footer/Footer";
import { useNavigate } from "react-router-dom";

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

const aoprojectsinfo = () => {
  const { AppId: paramAppId } = useParams();
  const AppId = paramAppId || "defaultAppId"; // Provide a default AppId

  const [appReviews, setAppReviews] = useState<Record<string, any> | null>(
    null
  );
  const [loadingAppReviews, setLoadingAppReviews] = useState(true);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  // Ensure AppId is never undefined
  const handleProjectReviewsInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectreviews/${appId}`);
  };

  const handleOwnerStatisticsInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectstats/${appId}`);
  };

  const handleOwnerAirdropInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectairdrops/${appId}`);
  };

  const handleOwnerUpdatesInfo = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectupdates/${appId}`);
  };

  const handleOwnerChange = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/ownerchange/${appId}`);
  };
  useEffect(() => {
    const fetchAppReviews = async () => {
      setLoadingAppReviews(true);
      try {
        const messageResponse = await message({
          process: "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk",
          tags: [
            { name: "Action", value: "FetchAppReviews" },
            { name: "AppId", value: AppId },
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
          setAppReviews(data);
        }
      } catch (error) {
        console.error("Error fetching app reviews:", error);
      } finally {
        setLoadingAppReviews(false);
      }
    };

    fetchAppReviews();
  }, [AppId]);

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
        <Menu pointing>
          <MenuItem
            onClick={() => handleProjectReviewsInfo(AppId)}
            name="Reviews"
          />
          <MenuItem
            onClick={() => handleOwnerStatisticsInfo(AppId)}
            name="Statistics"
          />
          <MenuItem
            onClick={() => handleOwnerAirdropInfo(AppId)}
            name="Airdrops"
          />
          <MenuMenu position="right">
            <MenuItem
              onClick={() => handleOwnerUpdatesInfo(AppId)}
              name="Update"
            />
            <MenuItem
              onClick={() => handleOwnerChange(AppId)}
              name="change owner"
            />
          </MenuMenu>
        </Menu>

        <Header as="h1">Reviews</Header>
        <Divider />

        {loadingAppReviews ? (
          <Loader active inline="centered" />
        ) : appReviews ? (
          <>
            <Container>
              <Grid columns="equal">
                <GridColumn>
                  <Statistic>
                    <StatisticLabel>Views</StatisticLabel>
                    <StatisticValue>40,509</StatisticValue>
                  </Statistic>
                </GridColumn>
                <GridColumn>
                  <Statistic>
                    <StatisticLabel>Views</StatisticLabel>
                    <StatisticValue>40,509</StatisticValue>
                  </Statistic>
                </GridColumn>
                <GridColumn>
                  <Statistic>
                    <StatisticLabel>Views</StatisticLabel>
                    <StatisticValue>40,509</StatisticValue>
                  </Statistic>
                </GridColumn>
              </Grid>
              <Divider />
              <Grid>
                <CommentGroup threaded>
                  {Object.entries(appReviews).map(([key, review]) => (
                    <SUIComment key={review.reviewId}>
                      <SUIComment.Avatar
                        src={
                          review.profileUrl ||
                          "https://react.semantic-ui.com/images/avatar/small/matt.jpg"
                        }
                      />
                      <SUIComment.Content>
                        <SUIComment.Author as="a">
                          {review.username || "Anonymous"}
                        </SUIComment.Author>
                        <SUIComment.Metadata>
                          <span>{formatDate(review.timestamp)}</span>
                          <Rating
                            icon="star"
                            defaultRating={review.rating}
                            maxRating={5}
                            disabled
                          />
                        </SUIComment.Metadata>
                        <SUIComment.Text>
                          {review.comment || "No comment provided."}
                        </SUIComment.Text>
                        <SUIComment.Actions>
                          <SUIComment.Action>
                            <Button color="blue" size="mini" icon>
                              <Icon name="thumbs up" /> {review.upvotes || 0}{" "}
                              Upvotes
                            </Button>
                            <Button color="red" size="mini" icon>
                              <Icon name="thumbs down" />{" "}
                              {review.downvotes || 0} Downvotes
                            </Button>
                          </SUIComment.Action>
                        </SUIComment.Actions>
                        <SUIComment.Text>
                          {review.helpfulVotes} Found This Review Helpful. Did
                          You find this Review Helpful ?
                        </SUIComment.Text>
                        <SUIComment.Actions>
                          <SUIComment.Action>
                            <Button color="blue" size="mini" icon>
                              <Icon name="thumbs up" />
                              Yes.
                            </Button>
                            <Button color="red" size="mini" icon>
                              <Icon name="thumbs down" />
                              No.
                            </Button>
                          </SUIComment.Action>
                        </SUIComment.Actions>
                      </SUIComment.Content>
                      <SUIComment.Group>
                        {Object.entries(review.replies || {}).map(
                          ([replyKey, reply]) => {
                            const typedReply = reply as Reply; // 👈 Type assertion

                            return (
                              <SUIComment key={typedReply.replyId}>
                                <SUIComment.Avatar src="https://react.semantic-ui.com/images/avatar/small/matt.jpg" />
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
                                  <SUIComment.Actions>
                                    <SUIComment.Action>
                                      <Button color="blue" size="mini" icon>
                                        <Icon name="thumbs up" />{" "}
                                        {typedReply.upvotes || 0} Upvotes
                                      </Button>
                                      <Button color="red" size="mini" icon>
                                        <Icon name="thumbs down" />{" "}
                                        {typedReply.downvotes || 0} Downvotes
                                      </Button>
                                    </SUIComment.Action>
                                  </SUIComment.Actions>
                                  <SUIComment.Text>
                                    {typedReply.downvotes} Found This Review
                                    Helpful. Did You find this Response Helpful?
                                  </SUIComment.Text>
                                  <SUIComment.Actions>
                                    <SUIComment.Action>
                                      <Button color="blue" size="mini" icon>
                                        <Icon name="thumbs up" />
                                        Yes.
                                      </Button>
                                      <Button color="red" size="mini" icon>
                                        <Icon name="thumbs down" />
                                        No.
                                      </Button>
                                    </SUIComment.Action>
                                  </SUIComment.Actions>
                                </SUIComment.Content>
                              </SUIComment>
                            );
                          }
                        )}
                      </SUIComment.Group>

                      <Form reply>
                        <FormTextArea />
                        <Button
                          content="Reply"
                          labelPosition="left"
                          icon="edit"
                          primary
                        />
                      </Form>
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
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
