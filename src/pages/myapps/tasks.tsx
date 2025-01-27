import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  Container,
  Divider,
  DropdownProps,
  Form,
  FormField,
  Image,
  Grid,
  GridColumn,
  GridRow,
  Header,
  Input,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
  Message,
  Segment,
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

// Home Component
interface MessagesData {
  AppName: string;
  AppIconUrl: string;
  Company: string;
  Header: string;
  Message: string;
  LinkInfo: string;
  currentTime: number;
  comment: string;
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
  const [isloadingmessages, setisLoadingMessages] = useState(true);
  const [MessageList, setMessageList] = useState<MessagesData[]>([]);

  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const updateOptions = [
    { key: "1", text: "OwnerUserName", value: "OwnerUserName" },
    { key: "2", text: "AppName", value: "AppName" },
    { key: "3", text: "Description", value: "Description" },
    { key: "4", text: "Protocol", value: "Protocol" },
    { key: "5", text: "WebsiteUrl", value: "WebsiteUrl" },
    { key: "6", text: "TwitterUrl", value: "TwitterUrl" },
    { key: "7", text: "DiscordUrl", value: "DiscordUrl" },
    { key: "8", text: "CoverUrl", value: "CoverUrl" },
    { key: "9", text: "profileUrl", value: "profileUrl" },
    { key: "10", text: "CompanyName", value: "CompanyName" },
    { key: "11", text: "AppIconUrl", value: "AppIconUrl" },
    { key: "12", text: "BannerUrl1", value: "BannerUrl1" },
    { key: "13", text: "BannerUrl2", value: "BannerUrl2" },
    { key: "14", text: "BannerUrl3", value: "BannerUrl3" },
    { key: "15", text: "BannerUrl4", value: "BannerUrl4" },
    { key: "16", text: "WhatsNew", value: "WhatsNew" },
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
    navigate(`/projectairdropsadmin/${appId}`);
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

    const fetchUpdates = async () => {
      setisLoadingMessages(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [
            { name: "Action", value: "FetchNewTableByAppId" },
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
          alert("Error fetching messages: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No messages returned from AO. Please try later.");
          return;
        }

        const data = JSON.parse(Messages[0].Data);
        console.log(data);
        setMessageList(Object.values(data));
      } catch (error) {
        console.error("Error fetching messages:", error);
      } finally {
        setisLoadingMessages(false);
      }
    };

    (async () => {
      await fetchAppInfo();
      await fetchUpdates();
    })();
  }, [AppId]);

  const AddWhatsNew = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setUpdatingApp(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "AddRequestToNewTable" },
          { name: "AppId", value: String(AppId) },
          { name: "comment", value: String(updateValue) },
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
          {isloadingmessages ? (
            <div
              style={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                height: "50vh",
              }}
            >
              <Loader active inline="centered" size="large">
                Loading Whats New...
              </Loader>
            </div>
          ) : (
            <>
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
                    name="Messages."
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
                  <MenuItem
                    onClick={() => handleTasks(AppId)}
                    name="Whats New"
                  />
                </MenuMenu>
              </Menu>
              <Header as="h1" textAlign="center">
                WhatsNew Updates.
              </Header>

              <Form>
                <FormField required></FormField>
                <FormField required>
                  <label>New Update ? </label>
                  <Input
                    type="text"
                    name="updatevalue"
                    value={updateValue}
                    onChange={handleInputChange}
                    placeholder="New Update."
                  />
                </FormField>
                <Button
                  loading={updateApp}
                  color="green"
                  onClick={() => AddWhatsNew(AppId)}
                >
                  {" "}
                  Update Projects.
                </Button>
              </Form>

              <Divider />
              {MessageList.length > 0 ? (
                MessageList.map((app, index) => (
                  <Segment textAlign="center" key={index} inverted tertiary>
                    <GridRow>
                      <Message compact>{app.comment}</Message>
                    </GridRow>
                  </Segment>
                ))
              ) : (
                <>
                  <Container>
                    <Header as="h4" color="grey" textAlign="center">
                      You have no whats New Updates.
                    </Header>
                  </Container>
                </>
              )}
            </>
          )}
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
