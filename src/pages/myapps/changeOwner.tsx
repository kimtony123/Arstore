import classNames from "classnames";
import React, { useState } from "react";
import {
  Button,
  Container,
  Divider,
  Form,
  FormField,
  Header,
  Input,
  Menu,
  MenuItem,
  MenuMenu,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";

import * as othent from "@othent/kms";

import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import Footer from "../../components/footer/Footer";
import { useNavigate } from "react-router-dom";

const aoprojectsinfo = () => {
  const { AppId: paramAppId } = useParams();
  const AppId = paramAppId || "defaultAppId"; // Ensure AppId is always a valid string

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
      const data = Messages[0].Data;
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
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
