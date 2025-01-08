import React, { useState, useEffect } from "react";
import { FaGoogle, FaAngleDoubleRight } from "react-icons/fa";
import { SparklesIcon, Bars3Icon, XMarkIcon } from "@heroicons/react/24/solid";
import classNames from "classnames";
import { useLocation } from "react-router-dom";
import * as othent from "@othent/kms";
import { connect, disconnect } from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";

interface NavbarProps {
  theme: string;
  isCollapsed: boolean;
  setIsCollapsed: (isCollapsed: boolean) => void;
}

const Navbar: React.FC<NavbarProps> = ({
  theme,
  isCollapsed,
  setIsCollapsed,
}) => {
  const locationURL = useLocation();
  const { pathname } = locationURL;

  // State variables
  const [address, setAddress] = useState<string | null>(null);
  const [username, setUsername] = useState<string | null>(null);
  const [profilePic, setProfilePic] = useState<string | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isAddingVerified, setIsAddingVerified] = useState(false);

  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  // Load saved connection details on page load
  useEffect(() => {
    const savedAddress = localStorage.getItem("walletAddress");
    const savedProfilePic = localStorage.getItem("profilePic");
    const savedUsername = localStorage.getItem("username");

    if (savedAddress) {
      setAddress(savedAddress);
      setProfilePic(savedProfilePic);
      setUsername(savedUsername);
      setIsConnected(true);
    }
  }, []);

  // Function to add address for trading
  const addVerified = async (walletAddress: string) => {
    setIsAddingVerified(true);
    try {
      const tradeMessage = await message({
        process: ARS,
        tags: [
          { name: "Action", value: "AddAddress" },
          { name: "address", value: walletAddress },
        ],
        signer: createDataItemSigner(othent),
      });

      const { Messages, Error } = await result({
        message: tradeMessage,
        process: ARS,
      });

      if (Error) {
        alert("Error adding address: " + Error);
        return;
      }

      if (!Messages || Messages.length === 0) {
        alert("No messages returned. Please try again later.");
        return;
      }

      alert(Messages[0].Data);
    } catch (error) {
      alert("Error during verification process: " + error);
      console.error(error);
    } finally {
      setIsAddingVerified(false);
    }
  };

  // Handle user connection
  const handleConnect = async () => {
    setIsSigningIn(true);
    try {
      const res = await connect();
      const walletAddress = res.walletAddress;

      setAddress(walletAddress);
      setProfilePic(res.picture);
      setUsername(res.name);

      // Save connection details
      localStorage.setItem("walletAddress", walletAddress);
      localStorage.setItem("profilePic", res.picture);
      localStorage.setItem("username", res.name);

      setIsConnected(true);

      // Add the address for trading
      await addVerified(walletAddress);
    } catch (error) {
      console.error("Connection failed", error);
    } finally {
      setIsSigningIn(false);
    }
  };

  // Handle user disconnection
  const handleDisconnect = async () => {
    setIsSigningIn(true);
    try {
      await disconnect();
      setAddress(null);
      setProfilePic(null);
      setUsername(null);

      // Remove saved connection details
      localStorage.removeItem("walletAddress");
      localStorage.removeItem("profilePic");
      localStorage.removeItem("username");

      setIsConnected(false);
    } catch (error) {
      console.error("Disconnection failed", error);
    } finally {
      setIsSigningIn(false);
    }
  };

  // Toggle sidebar collapse
  const handleCollapseToggle = () => {
    setIsCollapsed(!isCollapsed);
  };

  // Capitalize the first letter
  const capitalizeFirstLetter = (text: string) =>
    text.charAt(0).toUpperCase() + text.slice(1);

  // Remove leading slash from pathname
  const cleanPathname = pathname.startsWith("/") ? pathname.slice(1) : pathname;

  return (
    <nav
      className={classNames(
        "flex items-center justify-between p-4 bg-gray-800 shadow-lg",
        {
          "bg-black text-white": theme === "dark",
          "bg-gray-100 text-black": theme === "light",
        }
      )}
    >
      {/* Left Section */}
      <div className="flex items-center space-x-4">
        <div className="bg-emerald-600 p-2 rounded-lg">
          <SparklesIcon className="h-6 w-6 text-white" />
        </div>
        <FaAngleDoubleRight className="text-gray-400" />
        <div className="font-bold text-white">
          {cleanPathname !== ""
            ? capitalizeFirstLetter(cleanPathname)
            : "Overview"}
        </div>
      </div>

      {/* Right Section */}
      <div className="flex items-center space-x-4">
        {isConnected && (
          <div className="flex items-center space-x-3">
            {profilePic && (
              <img
                src={profilePic}
                alt="Profile"
                className="w-10 h-10 rounded-full border border-gray-300"
              />
            )}
            {username && (
              <span className="text-white font-medium">{username}</span>
            )}
            {address && (
              <div className="flex items-center space-x-2">
                <span className="text-gray-400 text-xs">{address}</span>
                <button
                  className="text-blue-500 hover:text-white"
                  onClick={() => {
                    navigator.clipboard.writeText(address);
                    alert("Wallet address copied!");
                  }}
                >
                  Copy
                </button>
              </div>
            )}
          </div>
        )}

        {/* Google Sign-In Button */}
        <button
          onClick={isConnected ? handleDisconnect : handleConnect}
          className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
          disabled={isSigningIn}
        >
          <FaGoogle className="h-5 w-5" />
          <span>{isConnected ? "Sign Out" : "Sign In via Google"}</span>
        </button>

        {/* Mobile Sidebar Toggle */}
        <div className="md:hidden">
          <button onClick={handleCollapseToggle}>
            {isCollapsed ? (
              <Bars3Icon className="h-6 w-6 text-white" />
            ) : (
              <XMarkIcon className="h-6 w-6 text-white" />
            )}
          </button>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
