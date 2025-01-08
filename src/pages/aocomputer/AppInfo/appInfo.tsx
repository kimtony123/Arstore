import classNames from "classnames";
import React, { useState, useEffect } from "react";
import {
  Button,
  Card,
  CardGroup,
  CommentGroup,
  CommentMetadata,
  CommentText,
  Container,
  Divider,
  DropdownProps,
  Form,
  FormField,
  FormSelect,
  FormTextArea,
  Grid,
  GridColumn,
  GridRow,
  Header,
  Icon,
  Input,
  List,
  ListContent,
  ListDescription,
  ListHeader,
  ListIcon,
  ListItem,
  Loader,
  Statistic,
  StatisticLabel,
  StatisticValue,
  TextArea,
} from "semantic-ui-react";
import { useParams } from "react-router-dom";

import { Comment as SUIComment } from "semantic-ui-react";

import * as othent from "@othent/kms";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import RatingsBarChart from "./ratingsBarChart";
import Footer from "../../../components/footer/Footer";

// AlternatingCards Component
interface Card {
  title: string;
  content: string;
  buttonText: string;
  buttonAction: () => void;
}
const AlternatingCards = ({ apps }: { apps: AppData[] }) => {
  const [activeCard, setActiveCard] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      goToNextCard();
    }, 5000);
    return () => clearInterval(interval);
  }, [activeCard]);

  const goToNextCard = () => {
    setIsTransitioning(true);
    setTimeout(() => setIsTransitioning(false), 500);
    setActiveCard((prevCard) => (prevCard + 1) % apps.length);
  };

  return (
    <div className="relative mt-8">
      <div className="w-full overflow-hidden">
        <div
          className={`flex px-2 transition-transform duration-500 ease-in-out ${
            isTransitioning ? "transform" : ""
          }`}
          style={{ transform: `translateX(-${activeCard * 100}%)` }}
        >
          {apps.map((app, index) => (
            <div
              key={index}
              className="min-w-full p-6 bg-gradient-to-tl from-gray-800 to-transparent rounded-xl ml-2 mr-2 first:ml-0 shadow-lg text-md md:text-lg"
            >
              <h3 className="xl:text-2xl font-semibold mb-4">{app.AppName}</h3>
              <p className="text-gray-400 mb-6">{app.Description}</p>
              <button
                onClick={() => window.open(app.WebsiteUrl, "_blank")}
                className="bg-white text-black px-4 py-2 rounded-full font-medium"
              >
                Visit Site
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

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
  Ratings: Array;
  AppId: string;
  BannerUrls: Array;
  CreatedTime: number;
  DiscordUrl: string;
  Downvotes: Array;
  Protocol: string;
  Reviews: Array;
  TwitterUrl: string;
  Upvotes: Array;
}

interface LeaderboardEntry {
  name: any;
  ratings: any;
  rank: any;
  AppIconUrl: any;
}

const aoprojectsinfo = () => {
  const ratingsData = {
    1: 20,
    2: 10,
    3: 15,
    4: 25,
    5: 30,
  };

  const { AppId } = useParams();
  const [apps, setAppInfo] = useState<AppData[]>([]);
  const [getProjectInfo, setGetProjectInfo] = useState("");
  const [loadingApps, setLoadingApps] = useState(true);
  const [loadingAppInfo, setLoadingAppInfo] = useState(true);
  const [isloadingSimilarApps, setLoadingSimilarApps] = useState(true);
  const [similarApps, setSimilarApps] = useState<LeaderboardEntry[]>([]);
  const [rating, setRating] = useState(0); // ✅ State to hold the rating value
  const [selectedProtocol, setSelectedProtocol] = useState<string | undefined>(
    undefined
  );
  const [protocolValue, setProtocolValue] = useState<string | undefined>();

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  // AlternatingCards Component
  interface Card {
    title: string;
    content: string;
    buttonText: string;
    buttonAction: () => void;
  }

  const AlternatingCards = ({ apps }: { apps: AppData[] }) => {
    const [activeCard, setActiveCard] = useState(0);
    const [isTransitioning, setIsTransitioning] = useState(false);

    useEffect(() => {
      const interval = setInterval(() => {
        goToNextCard();
      }, 5000);
      return () => clearInterval(interval);
    }, [activeCard]);

    const goToNextCard = () => {
      setIsTransitioning(true);
      setTimeout(() => setIsTransitioning(false), 500);
      setActiveCard((prevCard) => (prevCard + 1) % apps.length);
    };

    return (
      <div className="relative mt-8">
        <div className="w-full overflow-hidden">
          <div
            className={`flex px-2 transition-transform duration-500 ease-in-out ${
              isTransitioning ? "transform" : ""
            }`}
            style={{ transform: `translateX(-${activeCard * 100}%)` }}
          >
            {apps.map((app, index) => (
              <div
                key={index}
                className="min-w-full p-6 bg-gradient-to-tl from-gray-800 to-transparent rounded-xl ml-2 mr-2 first:ml-0 shadow-lg text-md md:text-lg"
              >
                <h3 className="xl:text-2xl font-semibold mb-4">
                  {app.AppName}
                </h3>
                <p className="text-gray-400 mb-6">{app.Description}</p>
                <p className="text-gray-400 mb-6">{app.Ratings}</p>
                <button
                  onClick={() => window.open(app.WebsiteUrl, "_blank")}
                  className="bg-white text-black px-4 py-2 rounded-full font-medium"
                >
                  Visit Site
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
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

    const fetchSimilarApps = async () => {
      setLoadingSimilarApps(true);

      try {
        const messageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "fetch_app_leaderboar" }],
          signer: createDataItemSigner(othent),
        });

        const resultResponse = await result({
          message: messageResponse,
          process: ARS,
        });

        const { Messages, Error } = resultResponse;

        if (Error) {
          alert("Error fetching Similar Apps: " + Error);
          return;
        }

        if (!Messages || Messages.length === 0) {
          alert("No Apps data returned from AO.");
          return;
        }

        // Parse and map the leaderboard data
        const data: Record<string, any> = JSON.parse(Messages[0].Data);
        console.log(data);
        const mappedLeaderboard = Object.values(data)
          .slice(0, 15) // Get top 15 apps
          .map((app) => ({
            rank: app.rank,
            ratings: app.stats.ratings || 0,
            name: app.stats.name,
            AppIconUrl: app.stats.AppIconUrl || "", // Default to empty string if not available
          }));
        setSimilarApps(mappedLeaderboard);
      } catch (error) {
        console.error("Error fetching leaderboard:", error);
      } finally {
        setLoadingSimilarApps(false);
      }
    };

    (async () => {
      await fetchSimilarApps();
      await fetchAppInfo();
    })();
  }, [AppId]);

  const src = "AO.svg";

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          {loadingApps ? (
            <Loader active inline="centered" content="Loading Apps..." />
          ) : (
            <AlternatingCards apps={apps} />
          )}
          <Divider />
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aoprojectsinfo;
