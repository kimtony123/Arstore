import { useEffect, useState } from "react";
import {
  Button,
  Container,
  Divider,
  Table,
  Image,
  Loader,
  Header,
  Grid,
  GridRow,
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
  const [deletingApp, setDeletingApp] = useState(false);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  // Function to reload the page.
  function reloadPage(forceReload = false): void {
    if (forceReload) {
      // Force reload from the server
      location.href = location.href;
    } else {
      // Reload using the cache
      location.reload();
    }
  }

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
      reloadPage(true);
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
        {loadingApps ? (
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              height: "60vh",
            }}
          >
            <Loader active inline="centered" size="large">
              Loading your apps...
            </Loader>
          </div>
        ) : apps.length > 0 ? (
          <>
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
            <Header textAlign="center" as="h1">
              {" "}
              My Apps.
            </Header>
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
                        loading={deletingApp}
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
          </>
        ) : (
          <>
            <Grid textAlign="center">
              <GridRow>
                <Header as="h1" color="red" textAlign="center">
                  You have not created any projects
                </Header>
              </GridRow>
              <GridRow>
                <Header as="h2" color="green" textAlign="center">
                  Create one Here
                </Header>
              </GridRow>
              <GridRow>
                <Button
                  onClick={handleAddAoprojects}
                  floated="right"
                  icon="add circle"
                  primary
                  size="large"
                >
                  Add Project.
                </Button>
              </GridRow>
            </Grid>
          </>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
