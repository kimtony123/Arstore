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
  const [updateApp, setUpdatingApp] = useState(true);

  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  const updateOptions = [
    { key: "1", text: "AppName", value: "AppName" },
    { key: "2", text: "description", value: "description" },
    { key: "3", text: " websiteUrl", value: " websiteUrl" },
    { key: "4", text: "discordUrl", value: "discordUrl" },
    { key: "5", text: "twitterUrl", value: "twitterUrl" },
    { key: "6", text: "coverUrl", value: "coverUrl" },
    { key: "7", text: "banner1Url", value: "banner1Url" },
    { key: "8", text: "banner2Url", value: "banner2Url" },
    { key: "9", text: "banner3Url", value: "banner3Url" },
    { key: "10", text: "banner4Url", value: "banner4Url" },
    { key: "11", text: "companyName", value: "companyName" },
    { key: "12", text: "appIconUrl", value: "appIconUrl" },
    { key: "13", text: "username", value: "username" },
    { key: "14", text: "profileUrl", value: "profileUrl" },
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
        process: ARS,
        tags: [
          { name: "Action", value: "UpdateAppDetails" },
          { name: "AppId", value: String(AppId) },
          { name: "NewValue", value: String(updateValue) },
          { name: "UpdateOption", value: String(projectTypeValue) },
        ],

        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: ARS,
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

  const src = "AO.svg";

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
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
            </MenuMenu>
          </Menu>
          <Header textAlign="center" as="h1">
            Update App.
          </Header>
          <Form>
            <FormField required>
              <label>What are you planning to update?</label>
              <FormSelect
                options={updateOptions}
                placeholder="Project Type"
                value={selectedProjectType}
                onChange={handleProjectTypeChange}
              />
            </FormField>
            <FormField required>
              <label>New Updated Value?</label>
              <Input
                type="text"
                name="updatevalue"
                value={updateValue}
                onChange={handleInputChange}
                placeholder="New Value"
              />
            </FormField>
            <Button color="purple" onClick={() => updateproject(AppId)}>
              {" "}
              Update App.
            </Button>
          </Form>
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
