import { useEffect, useState } from "react";
import {
  Container,
  Divider,
  Header,
  Grid,
  Segment,
  GridColumn,
  Image,
  Message,
  GridRow,
  Menu,
  MenuItem,
  MenuMenu,
  Loader,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

// Home Component
interface MessagesData {
  AppName: string;
  AppIconUrl: string;
  Company: string;
  Header: string;
  Message: string;
  LinkInfo: string;
  currentTime: number;
}

const Home = () => {
  const [isloadingmessages, setisLoadingMessages] = useState(true);
  const [MessageList, setMessageList] = useState<MessagesData[]>([]);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchMessages = async () => {
      setisLoadingMessages(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "GetUserInbox" }],
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
      await fetchMessages();
    })();
  }, []);

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + " " + date.toLocaleTimeString();
  };

  const handleMessages = () => {
    navigate("/messages");
  };

  const handleFeatureRequests = () => {
    navigate("/featurerequests");
  };

  const handleBugReports = () => {
    navigate("/bugreports");
  };
  const handleUserStats = () => {
    navigate("/userstats");
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
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
              Loading Messages...
            </Loader>
          </div>
        ) : (
          <>
            <Menu pointing>
              <MenuItem onClick={handleMessages} name="Messages" />
              <MenuItem
                onClick={handleFeatureRequests}
                name="Feature Requests."
              />
              <MenuMenu position="right">
                <MenuItem onClick={handleBugReports} name="Bug Reports." />
                <MenuItem onClick={handleUserStats} name="My statistics." />
              </MenuMenu>
            </Menu>
            <Header as="h1" textAlign="center">
              Messages
            </Header>
            <Divider />
            {MessageList.length > 0 ? (
              MessageList.map((app, index) => (
                <Segment key={index} inverted tertiary>
                  <Grid columns="equal">
                    <GridColumn>
                      <Image size="small" src={app.AppIconUrl} />
                      <Header textAlign="center">{app.AppName}</Header>
                    </GridColumn>
                    <GridColumn width={13}>
                      <Grid columns="equal">
                        <GridColumn width={11}>
                          <Header as="h1" textAlign="center">
                            {app.Header}
                          </Header>
                        </GridColumn>
                        <GridColumn>
                          <Header as="h5" textAlign="right">
                            {formatDate(app.currentTime)}
                          </Header>
                        </GridColumn>
                      </Grid>
                      <Grid>
                        <GridRow>
                          <Message compact>{app.Message}</Message>
                        </GridRow>
                        <GridRow>
                          <a
                            href={app.LinkInfo}
                            target="_blank"
                            rel="noopener noreferrer"
                          >
                            More info
                          </a>
                        </GridRow>
                      </Grid>
                    </GridColumn>
                  </Grid>
                </Segment>
              ))
            ) : (
              <Header as="h4" color="grey" textAlign="center">
                You have no messages.
              </Header>
            )}
          </>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
