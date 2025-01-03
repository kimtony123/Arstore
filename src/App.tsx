import { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Sidebar from "./components/sidebar/Sidebar";
import Navbar from "./components/navbar/Navbar";
import Home from "./pages/home/Home";
import Aomemecoins from "./pages/aocomputer/memecoins/aomemecoins";
import WalletConnectError from "./components/alerts/WalletConnectError";
import Aocommunities from "./pages/aocomputer/communities/aocommunities";
import Addaoprojects from "./pages/aocomputer/addaoprojects/addaoprojects";
import WalletPage from "./pages/wallet/WalletPage";
import "./App.css";

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
              path="aomemecoins"
              element={walletAddress ? <Aomemecoins /> : <WalletConnectError />}
            />
            <Route
              path="Aocommunities"
              element={
                walletAddress ? <Aocommunities /> : <WalletConnectError />
              }
            />
            <Route
              path="Addaoprojects"
              element={
                walletAddress ? <Addaoprojects /> : <WalletConnectError />
              }
            />
            <Route
              path="wallet"
              element={walletAddress ? <WalletPage /> : <WalletConnectError />}
            />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
