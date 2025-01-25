import { useEffect, useState } from "react";
import {
  Container,
  Divider,
  Card,
  CardGroup,
  Header,
  CardContent,
  CardHeader,
  CardMeta,
  Image,
  Button,
  Loader,
} from "semantic-ui-react";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";

// Home Component
interface FavoriteAppData {
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
  const [isloadingFavoriteApps, setLoadingFavoriteApps] = useState(true);
  const [FavoriteApps, setFavoriteApps] = useState<FavoriteAppData[]>([]);

  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const navigate = useNavigate();

  useEffect(() => {
    const fetchFavoriteApps = async () => {
      setLoadingFavoriteApps(true);
      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "getFavoriteApps" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching favorite apps: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No messages returned from AO. Please try later.");
          return;
        }

        const data = JSON.parse(Messages[0].Data);
        console.log(data);
        setFavoriteApps(Object.values(data));
      } catch (error) {
        console.error("Error fetching favorite apps:", error);
      } finally {
        setLoadingFavoriteApps(false);
      }
    };

    (async () => {
      await fetchFavoriteApps();
    })();
  }, []);

  const handleProjectInfo = (appId: string) => {
    navigate(`/project/${appId}`);
  };

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container textAlign="center">
        {isloadingFavoriteApps ? (
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              height: "60vh",
            }}
          >
            <Loader active inline="centered" size="large">
              Loading your favorite apps...
            </Loader>
          </div>
        ) : FavoriteApps.length > 0 ? (
          <>
            <Header as="h1" textAlign="center">
              Favorite Projects.
            </Header>
            <CardGroup itemsPerRow={3}>
              {FavoriteApps.map((app, index) => (
                <Card key={index}>
                  <Image src={app.AppIconUrl} wrapped ui={false} />
                  <CardContent>
                    <CardHeader>{app.AppName}</CardHeader>
                    <Divider />
                    <CardMeta>{app.CompanyName}</CardMeta>
                  </CardContent>
                  <CardContent extra>
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
                  </CardContent>
                </Card>
              ))}
            </CardGroup>
          </>
        ) : (
          <>
            <Container>
              <Header as="h4" color="grey" textAlign="center">
                You have not added any apps as favorites.
              </Header>
            </Container>
          </>
        )}
      </Container>
      <Footer />
    </div>
  );
};

export default Home;
