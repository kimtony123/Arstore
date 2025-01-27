import classNames from "classnames";
import React, { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Form,
  FormField,
  Header,
  Input,
  Loader,
  Menu,
  MenuItem,
  MenuMenu,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";

import * as othent from "@othent/kms";

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

const aoprojectsinfo = () => {
  const { AppId: paramAppId } = useParams();
  const AppId = paramAppId || "defaultAppId"; // Ensure AppId is always a valid string
  const [apps, setAppInfo] = useState<AppData[]>([]);

  const [loadingAppInfo, setLoadingAppInfo] = useState(true);

  const [newOwner, setNewOwner] = useState("");

  const [, setUpdatingNewOwner] = useState(true);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    switch (name) {
      case "newowner":
        setNewOwner(value);
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

    (async () => {
      await fetchAppInfo();
    })();
  }, [AppId]);

  const changeowner = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setUpdatingNewOwner(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "UpdateAppDetails" },
          { name: "AppId", value: String(AppId) },
          { name: "NewValue", value: String(newOwner) },
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
      const data = Messages[Messages.length - 1]?.Data;
      alert(data);
      setNewOwner("");
      // ✅ Redirect to the homepage after successful change
      navigate("/");
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setUpdatingNewOwner(false);
    }
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          <Divider />
          {loadingAppInfo ? (
            <div
              style={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                height: "60vh",
              }}
            >
              <Loader active inline="centered" size="large">
                Loading Change Owner...
              </Loader>
            </div>
          ) : apps ? (
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
              <Header textAlign="center" as="h1">
                Change App ownership.
              </Header>
              <Form>
                <FormField required>
                  <label>New Owner Address.</label>
                  <Input
                    type="text"
                    name="newowner"
                    value={newOwner}
                    onChange={handleInputChange}
                    placeholder="New Owner Address."
                  />
                </FormField>
                <Button color="purple" onClick={() => changeowner(AppId)}>
                  {" "}
                  Change Owner.
                </Button>
              </Form>
            </>
          ) : (
            <Header as="h4" color="grey">
              No reviews found for this app.
            </Header>
          )}
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
