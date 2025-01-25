import classNames from "classnames";
import * as othent from "@othent/kms";
import React, { useState, useEffect } from "react";
import { FaSpinner } from "react-icons/fa";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import {
  Container,
  Divider,
  CardGroup,
  Card,
  Button,
  Tab,
  TabPane,
  Header,
  Loader,
} from "semantic-ui-react";
import { useNavigate } from "react-router-dom";
import Footer from "../../../components/footer/Footer";

// Define a Projects interface to type-check project data
interface Project {
  ProjectName: string;
  CompanyName: string;
  ProjectType: string;
  ratings: number;
  AppId: string;
  AppIconUrl: string;
  WebsiteUrl: string;
  AppName: string;
}

const aocommunities = () => {
  const projectTypes = [
    "Infrastructure",
    "community",
    "Analytics",
    "DEFI",
    "Developer Tooling",
    "Email",
    "Exchanges",
    "Gaming",
    "Incubators",
    "Memecoins",
    "News and Knowledge",
    "NFTs and Metaverse",
    "Publishing",
    "Social",
    "Storage",
    "Wallet",
  ];

  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeProjectType, setActiveProjectType] = useState(projectTypes[0]);
  const [errorMessage, setErrorMessage] = useState("");
  const [activeIndex, setActiveIndex] = useState(0); // New state to track the active tab index

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  useEffect(() => {
    getProject(activeProjectType);
  }, [activeProjectType]);

  const getProject = async (projectType: string) => {
    const protocol = "Arweave";
    setLoading(true);
    try {
      const messageResponse = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "GetProjectTypesAo" },
          { name: "Protocol", value: String(protocol) },
          { name: "ProjectType", value: String(projectType) },
        ],
        signer: createDataItemSigner(othent),
      });

      const resultResponse = await result({
        message: messageResponse,
        process: ARS,
      });

      const { Messages, Error } = resultResponse;

      if (Error) {
        setErrorMessage("Error fetching apps: " + Error);
        return;
      }

      if (!Messages || Messages.length === 0) {
        setErrorMessage("No messages returned from AO. Please try later.");
        return;
      }
      const data = JSON.parse(Messages[0].Data);
      setProjects(Object.values(data));
      setErrorMessage("");
    } catch (error) {
      setErrorMessage("Error fetching apps. Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  const panes = projectTypes.map((type) => ({
    menuItem: type,
    render: () => (
      <TabPane attached={false}>
        <Container>
          {loading ? (
            <div style={{ textAlign: "center", marginTop: "40px" }}>
              <FaSpinner className="spinner" size={70} />
            </div>
          ) : errorMessage ? (
            <Header as="h4" color="red" textAlign="center">
              {errorMessage}
            </Header>
          ) : (
            <>
              <Header>{type} Projects</Header>
              <Divider />
              <Button
                onClick={handleAddAoprojects}
                floated="right"
                primary
                size="large"
              >
                Add AO Project
              </Button>
              <Divider />
              <CardGroup>
                {projects.map((app, index) => (
                  <Card
                    size="mini"
                    key={index}
                    image={app.AppIconUrl}
                    header={app.AppName}
                    meta={app.CompanyName}
                    description={app.ProjectType}
                    extra={
                      <>
                        <a
                          href={app.WebsiteUrl}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          Visit Site
                        </a>
                        <Divider />
                        <Button
                          primary
                          onClick={() => handleProjectInfo(app.AppId)}
                        >
                          App Info
                        </Button>
                      </>
                    }
                  />
                ))}
              </CardGroup>
            </>
          )}
        </Container>
      </TabPane>
    ),
  }));

  const handleTabChange = (e: any, { activeIndex }: any) => {
    setActiveIndex(activeIndex); // Update activeIndex
    setActiveProjectType(projectTypes[activeIndex]); // Update activeProjectType
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      {loading ? (
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "60vh",
          }}
        >
          <Loader active inline="centered" size="large">
            Loading Arweave projects...
          </Loader>
        </div>
      ) : projects.length > 0 ? (
        <>
          <Tab
            menu={{
              secondary: true,
              pointing: true,
              style: { display: "flex", flexWrap: "nowrap" },
            }}
            panes={panes}
            activeIndex={activeIndex} // Controlled Tab
            onTabChange={handleTabChange}
          />

          <Divider />
        </>
      ) : (
        <>
          <Container>
            <Header as="h1" color="red" textAlign="center">
              There are no projects in this category Click another Tab!
            </Header>
            <Tab
              menu={{
                secondary: true,
                pointing: true,
                style: { display: "flex", flexWrap: "nowrap" },
              }}
              panes={panes}
              activeIndex={activeIndex} // Controlled Tab
              onTabChange={handleTabChange}
            />
          </Container>
        </>
      )}
      <Footer />
    </div>
  );
};

export default aocommunities;
