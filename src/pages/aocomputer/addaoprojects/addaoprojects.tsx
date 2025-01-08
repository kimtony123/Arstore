import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  Container,
  Divider,
  DropdownProps,
  Form,
  FormField,
  FormSelect,
  Input,
  TextArea,
} from "semantic-ui-react";
import * as othent from "@othent/kms";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";

import Footer from "../../../components/footer/Footer";

const addaoprojects = () => {
  const [appName, setAppname] = useState("");
  const [description, setDescription] = useState("");
  const [websiteUrl, setWebsiteUrl] = useState("");
  const [discordUrl, setDiscordUrl] = useState("");
  const [twitterUrl, setTwitterUrl] = useState("");
  const [coverUrl, setCoverUrl] = useState("");
  const [banner1Url, setBanner1Url] = useState("");
  const [banner2Url, setBanner2Url] = useState("");
  const [banner3Url, setBanner3Url] = useState("");
  const [banner4Url, setBanner4Url] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [appIconUrl, setAppIconUrl] = useState("");
  const [isaddproject, setIsAddProject] = useState(false);
  const [selectedProtocol, setSelectedProtocol] = useState<string | undefined>(
    undefined
  );
  const [protocolValue, setProtocolValue] = useState<string | undefined>();
  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  // Check if user has connected to Arweave Wallet
  const username = localStorage.getItem("username");
  const profileUrl = localStorage.getItem("profileUrl");

  const projectOptions = [
    { key: "1", text: "Analytics", value: "analytics" },
    { key: "2", text: "Community", value: "community" },
    { key: "3", text: "DEFI", value: "DEFI" },
    { key: "4", text: "Developer Tooling", value: "Developer Tooling" },
    { key: "5", text: "Email", value: "Email" },
    { key: "6", text: "Exchanges", value: "Exchanges" },
    { key: "7", text: "Gaming", value: "Gaming" },
    { key: "8", text: "Incubators", value: "Incubators" },
    { key: "9", text: "Infrastructure", value: "Infrastructure" },
    { key: "10", text: "Memecoins", value: "Memecoins" },
    { key: "11", text: "News and Knowledge", value: "News and Knowledge" },
    { key: "12", text: "Nfts and Metaverse", value: "Nfts and Metaverse" },
    { key: "13", text: "Publishing", value: "Publishing" },
    { key: "14", text: "Social", value: "Social" },
    { key: "15", text: "Storage", value: "Storage" },
    { key: "16", text: "Wallet", value: "Wallet" },
  ];

  const handleProtocolChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProtocolValue(value);
  };

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

  const protocolOptions = [
    { key: "1", text: "aocomputer", value: "aocomputer" },
    { key: "2", text: "Arweave", value: "Arweave" },
  ];

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    switch (name) {
      case "appName":
        setAppname(value);
        break;
      case "description":
        setDescription(value);
        break;
      case "coverUrl":
        setCoverUrl(value);
        break;
      case "banner1Url":
        setBanner1Url(value);
        break;
      case "banner2Url":
        setBanner2Url(value);
        break;
      case "banner3Url":
        setBanner3Url(value);
        break;
      case "banner4Url":
        setBanner4Url(value);
        break;
      case "companyName":
        setCompanyName(value);
        break;
      case "appIconUrl":
        setAppIconUrl(value);
        break;
      case "websiteUrl":
        setWebsiteUrl(value);
        break;
      case "discordUrl":
        setDiscordUrl(value);
        break;
      case "twitterUrl":
        setTwitterUrl(value);
        break;
      default:
        break;
    }
  };

  // In addproject function, use these values directly
  const addproject = async () => {
    setIsAddProject(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "AddApp" },
          { name: "AppName", value: String(appName) },
          { name: "description", value: String(description) },
          { name: "protocol", value: String(protocolValue) }, // Updated to use protocolValue
          { name: "projectType", value: String(projectTypeValue) }, // Updated to use projectTypeValue
          { name: "websiteUrl", value: String(websiteUrl) },
          { name: "twitterUrl", value: String(twitterUrl) },
          { name: "discordUrl", value: String(discordUrl) },
          { name: "coverUrl", value: String(coverUrl) },
          { name: "banner1Url", value: String(banner1Url) },
          { name: "banner2Url", value: String(banner2Url) },
          { name: "banner3Url", value: String(banner3Url) },
          { name: "banner4Url", value: String(banner4Url) },
          { name: "companyName", value: String(companyName) },
          { name: "appIconUrl", value: String(appIconUrl) },
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
        alert("Error Adding Project:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
      setAppname("");
      setBanner1Url("");
      setBanner2Url("");
      setBanner3Url("");
      setBanner4Url("");
      setCompanyName("");
      setAppIconUrl("");
      setCoverUrl("");
      setDescription("");
      setWebsiteUrl("");
      setTwitterUrl("");
      setDiscordUrl("");
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setIsAddProject(false);
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
          <h1> Add Your Project to aocomputer.</h1>
          <Form>
            <FormField required>
              <label>Name of the App.</label>
              <Input
                type="text"
                name="appName"
                value={appName}
                onChange={handleInputChange}
                placeholder="App name"
              />
            </FormField>
            <FormField required>
              <label>Brief Description of The App.</label>
              <Input
                type="text"
                name="description"
                value={description}
                onChange={handleInputChange}
                placeholder="App name"
              />
            </FormField>
            <FormField required>
              <label>Enter your project Website Link.</label>
              <Input
                type="text"
                name="websiteUrl"
                value={websiteUrl}
                onChange={handleInputChange}
                placeholder="Website Url"
              />
            </FormField>
            <FormField required>
              <label>Enter your project Twittter Link.</label>
              <Input
                type="text"
                name="twitterUrl"
                value={twitterUrl}
                onChange={handleInputChange}
                placeholder="Twitter Link"
              />
            </FormField>
            <FormField required>
              <label>Enter your project Discord Link.</label>
              <Input
                type="text"
                name="discordUrl"
                value={discordUrl}
                onChange={handleInputChange}
                placeholder="Discord Link"
              />
            </FormField>
            <FormField required>
              <label>Cover Image TXID</label>
              <Input
                type="text"
                name="coverUrl"
                value={coverUrl}
                onChange={handleInputChange}
                placeholder="CoverImage TXID"
              />
            </FormField>

            <FormField required>
              <label>Protocol</label>
              <FormSelect
                options={protocolOptions}
                placeholder="Protocol"
                value={selectedProtocol}
                onChange={handleProtocolChange}
              />
            </FormField>
            <FormField required>
              <label>Project Type</label>
              <FormSelect
                options={projectOptions}
                placeholder="Project Type"
                value={selectedProjectType}
                onChange={handleProjectTypeChange}
              />
            </FormField>

            <FormField required>
              <label>Banner 1 Image TXID.</label>
              <Input
                type="text"
                name="banner1Url"
                value={banner1Url}
                onChange={handleInputChange}
                placeholder="Banner 1 url"
              />
            </FormField>
            <FormField required>
              <label>Banner 2 Image TXID</label>
              <Input
                type="text"
                name="banner2Url"
                value={banner2Url}
                onChange={handleInputChange}
                placeholder="Banner 2 url"
              />
            </FormField>
            <FormField required>
              <label>Banner 3 Image TXID</label>
              <Input
                type="text"
                name="banner3Url"
                value={banner3Url}
                onChange={handleInputChange}
                placeholder="Banner 3 url"
              />
            </FormField>
            <FormField required>
              <label>Banner 4 Image TXID</label>
              <Input
                type="text"
                name="banner4Url"
                value={banner4Url}
                onChange={handleInputChange}
                placeholder="Banner 4 url"
              />
            </FormField>
            <FormField required>
              <label> Company/Team name </label>
              <Input
                type="text"
                name="companyName"
                value={companyName}
                onChange={handleInputChange}
                placeholder="company name"
              />
            </FormField>
            <FormField required>
              <label>App Icon TXID.</label>
              <Input
                type="text"
                name="appIconUrl"
                value={appIconUrl}
                onChange={handleInputChange}
                placeholder="App Icon url"
              />
            </FormField>
            <Divider />
            <Button
              loading={isaddproject}
              size="large"
              onClick={addproject}
              primary
            >
              Submit
            </Button>
          </Form>
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default addaoprojects;
