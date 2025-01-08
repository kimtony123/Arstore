import { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Grid,
  GridColumn,
  GridRow,
  Table,
  Image,
  Loader,
  Card,
  CardGroup,
  Header,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

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
  AppId: string;
}

const Home = () => {
  const [apps, setApps] = useState<AppData[]>([]);
  const [loadingApps, setLoadingApps] = useState(true);
  const [deletingApp, setDeletingApp] = useState(true);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchApps = async () => {
      setLoadingApps(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "getMyApps" }],
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
        setApps(Object.values(data));
      } catch (error) {
        console.error("Error fetching my apps:", error);
      } finally {
        setLoadingApps(false);
      }
    };

    (async () => {
      await fetchApps();
    })();
  }, []);

  const deleteproject = async (AppId: string) => {
    if (!AppId) return;
    console.log(AppId);

    setDeletingApp(true);
    try {
      const getTradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "DeleteApp" },
          { name: "AppId", value: String(AppId) },
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
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setDeletingApp(false);
    }
  };

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  const handleProjectReviewsInfo = (appId: string) => {
    navigate(`/projectreviews/${appId}`);
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <Header as="h1"> My Apps. </Header>
        <Button
          onClick={handleAddAoprojects}
          floated="right"
          icon="add circle"
          primary
          size="large"
        >
          Add Project.
        </Button>
        <Divider />
        <Header> My Apps.</Header>

        {loadingApps ? (
          <Loader active inline="centered" content="Loading My Apps..." />
        ) : (
          <Table celled>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>App Icon.</Table.HeaderCell>
                <Table.HeaderCell> App Name.</Table.HeaderCell>
                <Table.HeaderCell>App Info.</Table.HeaderCell>
                <Table.HeaderCell>Website Link.</Table.HeaderCell>
                <Table.HeaderCell>Delete App.</Table.HeaderCell>
              </Table.Row>
            </Table.Header>

            <Table.Body>
              {apps.map((app, index) => (
                <Table.Row key={index}>
                  <Table.Cell>
                    <Image src={app.AppIconUrl} size="tiny" rounded />
                  </Table.Cell>
                  <Table.Cell>{app.AppName}</Table.Cell>

                  <Table.Cell>
                    {" "}
                    <Button
                      primary
                      onClick={() => handleProjectReviewsInfo(app.AppId)}
                    >
                      App Info
                    </Button>
                  </Table.Cell>
                  <Table.Cell>
                    <a
                      href={app.WebsiteUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Visit Site
                    </a>
                  </Table.Cell>
                  <Table.Cell>
                    {" "}
                    <Button
                      color="red"
                      onClick={() => deleteproject(app.AppId)}
                    >
                      Delete App.
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
