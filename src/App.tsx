import { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Sidebar from "./components/sidebar/Sidebar";
import Navbar from "./components/navbar/Navbar";
import Home from "./pages/home/Home";
import WalletConnectError from "./components/alerts/WalletConnectError";
import Aocomputer from "./pages/aocomputer/communities/aocomputer";
import Arweave from "./pages/arweave/communities/arweave";
import Addaoprojects from "./pages/aocomputer/addaoprojects/addaoprojects";
import WalletPage from "./pages/wallet/WalletPage";
import ProjectInfo from "./pages/aocomputer/AppInfo/appInfo";
import "./App.css";
import RatingsBarChart from "./pages/aocomputer/AppInfo/ratingsBarChart";
import Aostorestats from "./pages/aostorestats/aostorestats";
import MyApps from "./pages/myapps/myapps";
import AppReviews from "./pages/myapps/appReviews";
import AppStatsAdmin from "./pages/myapps/appStatistics";
import AppAirdrops from "./pages/myapps/airdrop/appAirdrops";
import AppUpdates from "./pages/myapps/appUpdates";
import Ownerchange from "./pages/myapps/changeOwner";
import Airdrops from "./pages/airdrops/airdrops";
import AirdropInfo from "./pages/myapps/airdrop/airdropInfo";
import Favorites from "./pages/favorites/favorites";
import UserMessages from "./pages/messages/messages";
import AppOwnerMessage from "./pages/myapps/message";
import BugReportsUser from "./pages/messages/breports";
import FeatureRequestUser from "./pages/messages/frequests";
import UserStats from "./pages/messages/userstats";
import AppStatsUser from "./pages/aocomputer/AppInfo/appstats";
import FeaturesBugsAdmin from "./pages/myapps/featurebugs";
import DevForum from "./pages/aocomputer/AppInfo/devforum";
import BugReportsAdmin from "./pages/myapps/bugsreport";
import AostoreAi from "./pages/myapps/aostoreai";
import TasksAdmin from "./pages/myapps/tasks";
import AppsAirdrops from "./pages/aocomputer/AppInfo/appAirdrops";
import AppAirdropInfo from "./pages/aocomputer/AppInfo/appAirdropInfo";

function App() {
  const [theme, setTheme] = useState("");
  const [activeIndex, setActiveIndex] = useState(0); //sidebar's active index
  const [isCollapsed, setIsCollapsed] = useState(true);

  // Load the Default theme into the local Storage
  useEffect(() => {
    // save the active index to local storage
    const savedIndex = localStorage.getItem("activeIndex");
    if (savedIndex) {
      setActiveIndex(Number(savedIndex));
    }

    // Add delay transition to root to match sidebar and navbar
    const root = document.getElementById("root");
    root?.classList.add("transition-colors");
    root?.classList.add("duration-300");

    // Check for saved user preference
    const savedTheme = localStorage.getItem("theme");
    if (savedTheme) {
      setTheme(savedTheme);
      document.documentElement.classList.add(savedTheme);
    } else {
      setTheme("dark");
      document.documentElement.classList.add("dark");
    }
  }, []);

  // Check if user has connected to Arweave Wallet
  const walletAddress = localStorage.getItem("walletAddress");

  return (
    <Router>
      <div className="flex h-screen w-screen">
        <Sidebar
          theme={theme}
          updateTheme={setTheme}
          activeIndex={activeIndex}
          updateActiveIndex={setActiveIndex}
          isCollapsed={isCollapsed}
        />
        <div className="nav-content flex-grow">
          <Navbar
            theme={theme}
            isCollapsed={isCollapsed}
            setIsCollapsed={setIsCollapsed}
          />
          {/* Pages Content go here */}
          <Routes>
            <Route path="/" element={<Home />} />

            <Route
              path="favorites"
              element={walletAddress ? <Favorites /> : <WalletConnectError />}
            />

            <Route
              path="messages"
              element={
                walletAddress ? <UserMessages /> : <WalletConnectError />
              }
            />

            <Route
              path="featurerequests"
              element={
                walletAddress ? <FeatureRequestUser /> : <WalletConnectError />
              }
            />
            <Route
              path="bugreports"
              element={
                walletAddress ? <BugReportsUser /> : <WalletConnectError />
              }
            />

            <Route
              path="userstats"
              element={walletAddress ? <UserStats /> : <WalletConnectError />}
            />

            <Route
              path="aocomputer"
              element={walletAddress ? <Aocomputer /> : <WalletConnectError />}
            />
            <Route
              path="arweave"
              element={walletAddress ? <Arweave /> : <WalletConnectError />}
            />
            <Route
              path="Addaoprojects"
              element={
                walletAddress ? <Addaoprojects /> : <WalletConnectError />
              }
            />
            <Route
              path="/project/:AppId"
              element={walletAddress ? <ProjectInfo /> : <WalletConnectError />}
            />

            <Route
              path="/projectdevinfo/:AppId"
              element={walletAddress ? <DevForum /> : <WalletConnectError />}
            />

            <Route
              path="/projectairdrops/:AppId"
              element={
                walletAddress ? <AppsAirdrops /> : <WalletConnectError />
              }
            />

            <Route
              path="/projectairdropsadmin/:AppId"
              element={walletAddress ? <AppAirdrops /> : <WalletConnectError />}
            />

            <Route
              path="/appairdropinfo/:AirdropId"
              element={
                walletAddress ? <AppAirdropInfo /> : <WalletConnectError />
              }
            />

            <Route
              path="/projectreviews/:AppId"
              element={walletAddress ? <AppReviews /> : <WalletConnectError />}
            />
            <Route
              path="/projectstats/:AppId"
              element={
                walletAddress ? <AppStatsAdmin /> : <WalletConnectError />
              }
            />
            <Route
              path="/projectstatsuser/:AppId"
              element={
                walletAddress ? <AppStatsUser /> : <WalletConnectError />
              }
            />
            <Route
              path="/projectfeaturesbugs/:AppId"
              element={
                walletAddress ? <FeaturesBugsAdmin /> : <WalletConnectError />
              }
            />

            <Route
              path="/projectbugreports/:AppId"
              element={
                walletAddress ? <BugReportsAdmin /> : <WalletConnectError />
              }
            />
            <Route
              path="/projectaostoreai/:AppId"
              element={walletAddress ? <AostoreAi /> : <WalletConnectError />}
            />
            <Route
              path="/projecttasks/:AppId"
              element={walletAddress ? <TasksAdmin /> : <WalletConnectError />}
            />
            <Route
              path="/projectairdrops/:AppId"
              element={walletAddress ? <AppAirdrops /> : <WalletConnectError />}
            />
            <Route
              path="/projectupdates/:AppId"
              element={walletAddress ? <AppUpdates /> : <WalletConnectError />}
            />

            <Route
              path="/ownerchange/:AppId"
              element={walletAddress ? <Ownerchange /> : <WalletConnectError />}
            />
            <Route
              path="/sendupdates/:AppId"
              element={
                walletAddress ? <AppOwnerMessage /> : <WalletConnectError />
              }
            />
            <Route
              path="/airdropinfo/:AirdropId"
              element={walletAddress ? <AirdropInfo /> : <WalletConnectError />}
            />
            <Route
              path="RatingsChart"
              element={
                walletAddress ? (
                  <RatingsBarChart ratingsData={{}} />
                ) : (
                  <WalletConnectError />
                )
              }
            />
            <Route
              path="wallet"
              element={walletAddress ? <WalletPage /> : <WalletConnectError />}
            />
            <Route
              path="aostorestats"
              element={
                walletAddress ? <Aostorestats /> : <WalletConnectError />
              }
            />
            <Route
              path="myapps"
              element={walletAddress ? <MyApps /> : <WalletConnectError />}
            />
            <Route
              path="airdrops"
              element={walletAddress ? <Airdrops /> : <WalletConnectError />}
            />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
