import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  Card,
  CardGroup,
  CommentGroup,
  Container,
  Divider,
  DropdownProps,
  FormField,
  FormSelect,
  FormTextArea,
  Grid,
  GridColumn,
  GridRow,
  Header,
  Icon,
  List,
  ListContent,
  ListDescription,
  ListHeader,
  ListIcon,
  ListItem,
  Loader,
  Statistic,
  StatisticLabel,
  StatisticValue,
  Image,
  Rating,
  Form,
  Input,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";
import { Comment as SUIComment } from "semantic-ui-react";
import { useNavigate } from "react-router-dom";
import * as othent from "@othent/kms";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import RatingsBarChart from "./ratingsBarChart";
import Footer from "../../../components/footer/Footer";

// Home Component
interface AppData {
  AppName: string;
  CompanyName: string;
  WebsiteUrl: string;
  ProjectType: string;
  AppIconUrl: string;
  CoverUrl: string;
  Company: string;
  Description: string;
  Ratings: number;
  AppId: string;
  BannerUrls: Record<string, any>;
  CreatedTime: number;
  DiscordUrl: string;
  Downvotes: number;
  Protocol: string;
  Reviews: Record<string, any>;
  TwitterUrl: string;
  Upvotes: number;
  TotalRatings: number;
}

interface LeaderboardEntry {
  name: any;
  ratings: any;
  rank: any;
  AppIconUrl: any;
}

interface Reply {
  replyId: string;
  comment: string;
  timestamp: number;
  upvotes: number;
  downvotes: number;
  user: string;
  username: string;
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

const aoprojectsinfo = () => {
  const ratingsData = {
    1: 20,
    2: 10,
    3: 15,
    4: 25,
    5: 30,
  };

  const { AppId } = useParams();
  const [appInfo, setAppInfo] = useState<Record<string, any> | null>(null);
  const [loadingAppInfo, setLoadingAppInfo] = useState(true);
  const [rating, setRating] = useState(0); // ✅ State to hold the rating value
  const [selectedProtocol, setSelectedProtocol] = useState<string | undefined>(
    undefined
  );
  const [appReviews, setAppReviews] = useState<Record<string, any> | null>(
    null
  );
  const [loadingAppReviews, setLoadingAppReviews] = useState(true);
  const [addReview, setAddReview] = useState(false);
  const [comment, setComment] = useState("");

  const [addFavorite, setAddFavorite] = useState(false);
  const [addHelpful, setAddHelpful] = useState(false);
  const [addUnhelpful, setAddUnhelpful] = useState(false);
  const [addUpvote, setAddUpvote] = useState(false);
  const [addDownvote, setAddDownvote] = useState(false);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();
  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    switch (name) {
      case "comment":
        setComment(value);
        break;
      default:
        break;
    }
  };

  const updateOptions = [
    { key: "1", text: "FeatureRequests", value: "featureRequests" },
    { key: "2", text: "BugReports", value: "BugReports" },
  ];

  useEffect(() => {
    const fetchAppInfo = async () => {
      if (!AppId) return;
      console.log(AppId);
      setLoadingAppInfo(true);

      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "AppInfo" },
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
          alert("Error fetching app info: " + Error);
          return;
        }

        if (Messages && Messages.length > 0) {
          const data = JSON.parse(Messages[0].Data);
          console.log(data);
          setAppInfo(data);
        }
      } catch (error) {
        console.error("Error fetching app info:", error);
      } finally {
        setLoadingAppInfo(false);
      }
    };

    const fetchAppReviews = async () => {
      setLoadingAppReviews(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "FetchAppReviews" },
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

    (async () => {
      await fetchAppInfo();
      await fetchAppReviews();
    })();
  }, [AppId]);

  // ✅ Update rating on star click
  const handleStarClick = (star) => {
    setRating(star);
  };

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  const username = localStorage.getItem("username");
  const profileUrl = localStorage.getItem("profilePic");

  // Calculate full stars and half star for the second display
  const fullStars = Math.floor(rating);
  const halfStar = rating % 1 !== 0;

  const src = "AO.svg";

  const AddFavorite = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddFavorite(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "AddAppToFavorites" },
          { name: "AppId", value: String(AppId) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding project to Favorite:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setAddFavorite(false);
    }
  };

  const AddReview = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddReview(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "AddReviewApp" },
          { name: "AppId", value: String(AppId) },
          { name: "username", value: String(username) },
          { name: "profileUrl", value: String(profileUrl) },
          { name: "rating", value: String(rating) },
          { name: "comment", value: String(comment) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding review:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setAddReview(false);
    }
  };

  const AddHelpful = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddHelpful(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "HelpfulRatingApp" },
          { name: "AppId", value: String(AppId) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding project to Favorite:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setAddHelpful(false);
    }
  };

  const AddUnhelpful = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddUnhelpful(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "UnhelpfulRatingApp" },
          { name: "AppId", value: String(AppId) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding project to Favorite:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setAddUnhelpful(false);
    }
  };
  const AddUpvote = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddUpvote(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "UpvoteApp" },
          { name: "AppId", value: String(AppId) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding Upvoting App:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the Upvoting process: " + error);
      console.error(error);
    } finally {
      setAddUpvote(false);
    }
  };
  const AddDownvote = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setAddDownvote(true);
    try {
      const getTradeMessage = await message({
        process: ARS,

        tags: [
          { name: "Action", value: "Downvote" },
          { name: "AppId", value: String(AppId) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error Adding project to Favorite:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setAddDownvote(false);
    }
  };

  const handleProjectStats = (appId: string) => {
    navigate(`/projectstatsuser/${appId}`);
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          {loadingAppInfo ? (
            <Loader active inline="centered" />
          ) : appInfo ? (
            <>
              <Container>
                <Grid columns="equal">
                  <GridColumn width={11}>
                    <Header as="h1"> {appInfo.AppName}</Header>
                    <Header as="h3">{appInfo.CompanyName}</Header>
                    <Grid columns="equal">
                      <GridColumn>
                        <Image size="small" src={appInfo.AppIconUrl} />
                      </GridColumn>
                      <GridColumn>
                        <GridRow>
                          <Statistic size="small">
                            <Statistic.Value>
                              {appInfo.Ratings.Totalratings /
                                appInfo.Ratings.count}
                            </Statistic.Value>
                            <Rating
                              icon="star"
                              defaultRating={
                                appInfo.Ratings.Totalratings /
                                appInfo.Ratings.count
                              }
                              maxRating={5}
                              disabled
                            />
                          </Statistic>
                        </GridRow>

                        <GridRow>
                          {" "}
                          {/* Ratings Count */}
                          <Statistic size="small" horizontal>
                            <Statistic.Value>
                              {appInfo.Ratings.count}
                            </Statistic.Value>
                            <Statistic.Label>Reviews.</Statistic.Label>
                          </Statistic>
                        </GridRow>
                      </GridColumn>
                      <GridColumn>
                        <Statistic size="small">
                          <StatisticValue>{appInfo.Upvotes} +</StatisticValue>
                          <StatisticLabel>Upvotes.</StatisticLabel>
                        </Statistic>
                      </GridColumn>
                    </Grid>

                    <Grid columns="equal">
                      <GridRow>
                        <GridColumn width={5}>
                          <Button
                            color="blue"
                            onClick={() =>
                              window.open(appInfo.WebsiteUrl, "_blank")
                            }
                          >
                            Visit Website
                          </Button>
                        </GridColumn>
                        <GridColumn>
                          <Button color="purple" disabled icon>
                            <Icon name="share alternate" />
                            Share
                          </Button>
                        </GridColumn>
                        <GridColumn>
                          <Button
                            loading={addFavorite}
                            onClick={() => AddFavorite(appInfo.AppId)}
                            color="green"
                            icon
                          >
                            <Icon name="favorite" />
                            Add to favorites
                          </Button>
                        </GridColumn>
                      </GridRow>
                      <GridRow>
                        <Header as="h6">
                          {" "}
                          This Project is on {appInfo.Protocol}.
                        </Header>
                      </GridRow>
                    </Grid>
                  </GridColumn>
                  <GridColumn>
                    <Card>
                      <Image
                        src={appInfo.CoverUrl}
                        fluid
                        style={{
                          width: "650px",
                          height: "270px",
                          objectFit: "cover",
                        }}
                      />
                    </Card>
                  </GridColumn>
                </Grid>
                <Divider />
                <Grid columns="equal">
                  <GridColumn width={12}>
                    <CardGroup itemsPerRow={4}>
                      <Card>
                        <Image
                          src={appInfo.BannerUrl1} // Accessing the key without a period
                          fluid
                          style={{
                            width: "150px",
                            height: "150px",
                            objectFit: "cover",
                          }}
                        />
                      </Card>
                      <Card>
                        <Image
                          src={appInfo.BannerUrl2} // Accessing the key without a period
                          fluid
                          style={{
                            width: "150px",
                            height: "150px",
                            objectFit: "cover",
                          }}
                        />
                      </Card>
                      <Card>
                        <Image
                          src={appInfo.BannerUrl3} // Accessing the key without a period
                          fluid
                          style={{
                            width: "150px",
                            height: "150px",
                            objectFit: "cover",
                          }}
                        />
                      </Card>
                      <Card>
                        <Image
                          src={appInfo.BannerUrl4} // Accessing the key without a period
                          fluid
                          style={{
                            width: "150px",
                            height: "150px",
                            objectFit: "cover",
                          }}
                        />
                      </Card>
                    </CardGroup>
                    <Header as="h1">About the Project. </Header>
                    <Header as="h4">{appInfo.Description} </Header>
                    <Header as="h3"> Created on </Header>
                    <Header as="h5">{formatDate(appInfo.CreatedTime)}</Header>
                    <Header as="h3"> Project Type.</Header>
                    <Button> {appInfo.ProjectType}</Button>
                    <Header as="h3"> Social Media</Header>
                    <Button
                      color="twitter"
                      onClick={() => window.open(appInfo.TwitterUrl, "_blank")}
                    >
                      <Icon name="twitter" /> Twitter
                    </Button>
                    <Button
                      onClick={() => window.open(appInfo.DiscordUrl, "_blank")}
                    >
                      <Icon name="discord" /> Discord
                    </Button>
                    <Button
                      primary
                      onClick={() => handleProjectStats(appInfo.AppId)}
                    >
                      <Icon name="line graph" />
                      View Detailed Statistics
                    </Button>
                    <Header as="h1">Data Safety. </Header>
                    <List bordered>
                      <ListItem>
                        <ListIcon name="share alternate" />
                        <ListContent>
                          <ListHeader>Sharing.</ListHeader>
                          <ListDescription>
                            This Project does not Share your data with third
                            parties.
                          </ListDescription>
                        </ListContent>
                      </ListItem>
                      <ListItem>
                        <ListIcon name="cloud upload" />
                        <ListContent>
                          <ListHeader>Collection</ListHeader>
                          <ListDescription>
                            This Project does not collect any of your personal
                            Data.
                          </ListDescription>
                        </ListContent>
                      </ListItem>
                      <ListItem>
                        <ListIcon name="lock" />
                        <ListContent>
                          <ListHeader>Data Encryption</ListHeader>
                          <ListDescription>
                            Data is not encrypted in Transit.
                          </ListDescription>
                        </ListContent>
                      </ListItem>
                      <ListItem>
                        <ListIcon name="user delete" />
                        <ListContent>
                          <ListHeader>Delete</ListHeader>
                          <ListDescription>
                            Your Data cannot Be Deleted.
                          </ListDescription>
                        </ListContent>
                      </ListItem>
                    </List>
                    <Header as="h1">
                      Ratings and Reviews . (Ratings and reviews are verified.)
                    </Header>
                    <Header as="h3">
                      {appInfo.HelpfulRatings} Found This Project Helpful. Did
                      You find this Project Helpful ?
                    </Header>
                    <GridColumn>
                      <Button
                        loading={addHelpful}
                        onClick={() => AddHelpful(appInfo.AppId)}
                        color="blue"
                        size="mini"
                        icon
                      >
                        <Icon name="thumbs up" />
                        Helpful.
                      </Button>
                      <Button
                        loading={addUnhelpful}
                        onClick={() => AddUnhelpful(appInfo.AppId)}
                        color="red"
                        size="mini"
                        icon
                      >
                        <Icon name="thumbs down" />
                        Unhelpful.
                      </Button>
                    </GridColumn>
                    <Header as="h3">
                      {appInfo.Upvotes} Upvoted this Project, Do you want to
                      Upvote this project??
                    </Header>
                    <GridColumn>
                      <Button
                        loading={addUpvote}
                        onClick={() => AddUpvote(appInfo.AppId)}
                        color="blue"
                        size="mini"
                        icon
                      >
                        <Icon name="thumbs up" />
                        Upvote.
                      </Button>
                      <Button
                        loading={addDownvote}
                        onClick={() => AddDownvote(appInfo.AppId)}
                        color="red"
                        size="mini"
                        icon
                      >
                        <Icon name="thumbs down" />
                        Downvote.
                      </Button>
                    </GridColumn>
                    <Header as="h2">Review {appInfo.AppName} Project.</Header>
                    <Header as="h5">Rate {appInfo.AppName} </Header>
                    <Grid>
                      <GridRow>
                        {/* ✅ Star Rating Component */}
                        <div style={{ display: "flex", marginBottom: "10px" }}>
                          {[1, 2, 3, 4, 5].map((star) => (
                            <Icon
                              key={star}
                              name="star"
                              size="large"
                              color={star <= rating ? "yellow" : "grey"} // Highlight stars based on rating
                              onClick={() => handleStarClick(star)} // ✅ Update rating on click
                              style={{ cursor: "pointer" }}
                            />
                          ))}
                        </div>
                        {/* ✅ Display Selected Rating */}
                        <Header as="h6">Your Rating: {rating} stars </Header>
                      </GridRow>

                      <GridRow>
                        {/* ✅ Feedback Form */}
                        <Form reply>
                          <FormField>
                            <Input
                              size="big"
                              type="text"
                              name="comment"
                              value={comment}
                              onChange={handleInputChange}
                              placeholder="Tell us about your experience..."
                            />
                          </FormField>
                          <FormField>
                            <Button
                              primary
                              loading={addReview}
                              onClick={() => AddReview(appInfo.AppId)}
                              content="Add Review"
                              labelPosition="left"
                              icon="edit"
                            />
                          </FormField>
                        </Form>
                      </GridRow>
                    </Grid>
                    <Divider />
                    <Grid columns="equal">
                      <GridColumn>
                        <GridRow>
                          <Statistic>
                            <Statistic.Value>
                              {appInfo.Ratings.Totalratings /
                                appInfo.Ratings.count}
                            </Statistic.Value>
                            <Rating
                              icon="star"
                              defaultRating={
                                appInfo.Ratings.Totalratings /
                                appInfo.Ratings.count
                              }
                              maxRating={5}
                              disabled
                            />
                          </Statistic>
                        </GridRow>
                        <Divider />
                        <GridRow>
                          {" "}
                          {/* Ratings Count */}
                          <Statistic horizontal>
                            <Statistic.Value>
                              {appInfo.Ratings.count}
                            </Statistic.Value>
                            <Statistic.Label>Reviews.</Statistic.Label>
                          </Statistic>
                        </GridRow>
                      </GridColumn>
                      <GridColumn width={8}>
                        <RatingsBarChart ratingsData={ratingsData} />
                      </GridColumn>
                    </Grid>
                    <Divider />
                    <Header as="h1">Feature Requests and Bug Reports.</Header>
                    <Form>
                      <FormField required>
                        <label>Protocol</label>
                        <FormSelect
                          options={updateOptions}
                          placeholder="Requests"
                          value={selectedProtocol}
                          onChange={handleProjectTypeChange}
                        />
                        <FormTextArea placeholder="Make Feature Request or Report Bug" />
                        <Button
                          content="Request"
                          labelPosition="left"
                          icon="edit"
                          primary
                        />
                      </FormField>{" "}
                    </Form>
                    <Header as="h1">Whats new.</Header>
                    <Header as="h4">{appInfo.Description}</Header>
                    <Divider />
                    <Header as="h5">Flag Project..</Header>
                    <Icon name="flag" />
                    {appInfo.Flags} People have Flagged this project as
                    inappropriate.
                  </GridColumn>
                  <GridColumn>
                    <Header>Similar Apps.</Header>
                  </GridColumn>
                </Grid>
              </Container>
            </>
          ) : (
            <Header as="h4" color="grey">
              No reviews found for this app.
            </Header>
          )}
        </Container>
        <Container>
          <Container>
            <Divider />
            {loadingAppReviews ? (
              <Loader active inline="centered" />
            ) : appReviews ? (
              <>
                <Container>
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
                                  <Icon name="thumbs up" />{" "}
                                  {review.upvotes || 0} Upvotes
                                </Button>
                                <Button color="red" size="mini" icon>
                                  <Icon name="thumbs down" />{" "}
                                  {review.downvotes || 0} Downvotes
                                </Button>
                              </SUIComment.Action>
                            </SUIComment.Actions>
                            <SUIComment.Text>
                              {review.helpfulVotes} Found This Review Helpful.
                              Did You find this Review Helpful ?
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
                                      <SUIComment.Actions>
                                        <SUIComment.Action>
                                          <Button color="blue" size="mini" icon>
                                            <Icon name="thumbs up" />{" "}
                                            {typedReply.upvotes || 0} Upvotes
                                          </Button>
                                          <Button color="red" size="mini" icon>
                                            <Icon name="thumbs down" />{" "}
                                            {typedReply.downvotes || 0}{" "}
                                            Downvotes
                                          </Button>
                                        </SUIComment.Action>
                                      </SUIComment.Actions>
                                      <SUIComment.Text>
                                        {typedReply.downvotes} Found This Review
                                        Helpful. Did You find this Response
                                        Helpful?
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
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
