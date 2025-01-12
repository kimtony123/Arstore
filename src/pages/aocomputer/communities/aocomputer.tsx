import classNames from "classnames";
import * as othent from "@othent/kms";
import React, { useState, useEffect } from "react";
import { FaSpinner } from "react-icons/fa";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import {
  MenuItem,
  Menu,
  Container,
  Grid,
  Divider,
  CardGroup,
  Card,
  Icon,
  Button,
  GridColumn,
  Tab,
  TabPane,
  Header,
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
    "Analytics",
    "Community",
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

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  useEffect(() => {
    getProject(activeProjectType);
    console.log(activeProjectType);
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
        alert("Error fetching apps: " + Error);
        return;
      }

      if (!Messages || Messages.length === 0) {
        alert("No messages returned from AO. Please try later.");
        return;
      }

      const data = JSON.parse(Messages[0].Data);
      console.log(data);
      setProjects(Object.values(data));
      setErrorMessage("");
    } catch (error) {
      console.error("Error fetching apps:", error);
    } finally {
      setLoading(false);
    }
  };

  const panes = projectTypes.map((type) => ({
    menuItem: type,
    render: () => (
      <TabPane attached={false}>
        <Container>
          <Header>{type} Project. </Header>
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
          {loading ? (
            <FaSpinner className="spinner" />
          ) : errorMessage ? (
            <>
              <Header> {errorMessage} </Header>
            </>
          ) : (
            <Card>
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
            </Card>
          )}
        </Container>
      </TabPane>
    ),
  }));

  const handleTabChange = (e: any, { activeIndex }: any) => {
    setActiveProjectType(projectTypes[activeIndex]);
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Tab
          menu={{ secondary: true, pointing: true }}
          panes={panes}
          onTabChange={handleTabChange}
        />
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aocommunities;
