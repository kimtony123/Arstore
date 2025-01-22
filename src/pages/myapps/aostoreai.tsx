import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  Card,
  CardGroup,
  CommentGroup,
  CommentMetadata,
  CommentText,
  Container,
  Divider,
  DropdownProps,
  Form,
  FormField,
  FormSelect,
  FormTextArea,
  Grid,
  GridColumn,
  GridRow,
  Header,
  Icon,
  Input,
  Label,
  List,
  ListContent,
  ListDescription,
  ListHeader,
  ListIcon,
  ListItem,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
  Statistic,
  StatisticLabel,
  StatisticValue,
  TextArea,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";

import { Comment as SUIComment } from "semantic-ui-react";

import * as othent from "@othent/kms";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon

import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../components/footer/Footer";
import { useNavigate } from "react-router-dom";

interface AppData {
  AppName: string;
  CompanyName: string;
  WebsiteUrl: string;
  ProjectType: string;
  AppIconUrl: string;
  CoverUrl: string;
  Company: string;
  Description: string;
  Ratings: Array<number>; // Assuming ratings are numbers
  AppId: string;
  BannerUrls: Array<string>; // Assuming banner URLs are strings
  CreatedTime: number;
  DiscordUrl: string;
  Downvotes: Array<string>; // Assuming downvotes are strings (user IDs)
  Protocol: string;
  Reviews: Array<string>; // Assuming reviews are strings
  TwitterUrl: string;
  Upvotes: Array<string>; // Assuming upvotes are strings (user IDs)
}

interface LeaderboardEntry {
  name: any;
  ratings: any;
  rank: any;
  AppIconUrl: any;
}

const aoprojectsinfo = () => {
  const ratingsData = {
    1: 20,
    2: 10,
    3: 15,
    4: 25,
    5: 30,
  };

  const { AppId: paramAppId } = useParams();
  const AppId = paramAppId || "defaultAppId"; // Ensure AppId is always a valid string

  const [apps, setAppInfo] = useState<AppData[]>([]);
  const [updateValue, setUpdateValue] = useState("");
  const [getProjectInfo, setGetProjectInfo] = useState("");
  const [loadingApps, setLoadingApps] = useState(true);
  const [loadingAppInfo, setLoadingAppInfo] = useState(true);
  const [rating, setRating] = useState(0); // ✅ State to hold the rating value
  const [updateApp, setUpdatingApp] = useState(false);
  const [useAi, setUsingAi] = useState(false);

  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const AOS = "7wea_1MSDmZMm1Om9N8vdrkay9V9O8vscmSVO-2XdEY";

  const navigate = useNavigate();

  const updateOptions = [
    { key: "1", text: "reviewsTable", value: "reviewsTable" },
    { key: "2", text: "featureRequestsTable", value: "featureRequestsTable" },
    { key: "3", text: "bugsReportsTable", value: "bugsReportsTable" },
    { key: "4", text: "devForumTable", value: "devForumTable" },
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

  const handleNotification = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/sendupdates/${appId}`);
  };

  const handleFeaturesandBugs = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectfeaturesbugs/${appId}`);
  };

  const handleBugReports = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectbugreports/${appId}`);
  };

  const handleAostoreAi = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projectaostoreai/${appId}`);
  };

  const handleTasks = (appId: string | undefined) => {
    if (!appId) return;
    navigate(`/projecttasks/${appId}`);
  };

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

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
          setAppInfo(Object.values(data));
        }
      } catch (error) {
        console.error("Error fetching app info:", error);
      } finally {
        setLoadingAppInfo(false);
      }
    };

    (async () => {
      await fetchAppInfo();
    })();
  }, [AppId]);

  const updateproject = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setUpdatingApp(true);
    try {
      const getTradeMessage = await message({
        process: AOS,
        tags: [
          { name: "Action", value: "FetchAppComments" },
          { name: "AppId", value: String(AppId) },
          { name: "TableType", value: String(projectTypeValue) },
        ],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: AOS,
      });

      if (Error) {
        alert("Error Updating Project:" + Error);
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

  const UseAi = async () => {
    setUsingAi(true);
    try {
      const getTradeMessage = await message({
        process: AOS,
        tags: [{ name: "Action", value: "UseAI" }],
        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: AOS,
      });

      if (Error) {
        alert("Error Updating Project:" + Error);
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
      setUsingAi(false);
    }
  };

  const src = "AO.svg";

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container textAlign="center">
          <Divider />
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
                name="changeowner"
              />
              <MenuItem
                onClick={() => handleNotification(AppId)}
                name="Send Messages."
              />
              <MenuItem
                onClick={() => handleFeaturesandBugs(AppId)}
                name="F Requests."
              />
              <MenuItem
                onClick={() => handleBugReports(AppId)}
                name="Bug Reports."
              />

              <MenuItem
                onClick={() => handleAostoreAi(AppId)}
                name="aostore AI"
              />
              <MenuItem onClick={() => handleTasks(AppId)} name="tasks" />
            </MenuMenu>
          </Menu>
          <Header textAlign="center" as="h1">
            Project Sentiment Analysis.
          </Header>
          <Form>
            <FormField required>
              <label>What are you planning To analyse? </label>
              <FormSelect
                options={updateOptions}
                placeholder="Data Type"
                value={selectedProjectType}
                onChange={handleProjectTypeChange}
              />
            </FormField>
            <Button
              loading={updateApp}
              color="purple"
              onClick={() => updateproject(AppId)}
            >
              {" "}
              Deploy Data
            </Button>
          </Form>
        </Container>
        <Divider />
        <Container textAlign="center">
          <Button loading={useAi} color="purple" onClick={() => UseAi()}>
            {" "}
            Analyse.
          </Button>
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
