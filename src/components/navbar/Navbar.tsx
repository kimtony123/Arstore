import React, { useState, useEffect } from "react";
import { FaBell, FaAngleDoubleRight, FaSpinner } from "react-icons/fa";
import { SparklesIcon, Bars3Icon, XMarkIcon } from "@heroicons/react/24/solid";
import classNames from "classnames";
import { useLocation } from "react-router-dom";

import { PermissionType } from "arconnect";
import { connect, disconnect } from "@othent/kms";

const permissions: PermissionType[] = [
  "ACCESS_ADDRESS",
  "SIGNATURE",
  "SIGN_TRANSACTION",
  "DISPATCH",
];

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
  const [address, setAddress] = useState<string | null>(null);
  const [username, setUsername] = useState<string | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [profilePic, setProfilePic] = useState<string | null>(null);
  const [isSigningIn, setIsSigningIn] = useState(false); // New state for sign-in loading
  const [isSigningOut, setIsSigningOut] = useState(false); // New state for sign-out loading

  const handleConnect = async () => {
    setIsSigningIn(true); // Start loading spinner for sign-in
    try {
      const res = await connect();
      setAddress(res.walletAddress);
      setProfilePic(res.picture);
      setUsername(res.name);

      // Save to localStorage
      localStorage.setItem("walletAddress", res.walletAddress);
      localStorage.setItem("profilePic", res.picture);
      localStorage.setItem("username", res.name);

      setIsConnected(true);
    } catch (error) {
      console.error("Connection failed", error);
    } finally {
      setIsSigningIn(false); // Stop loading spinner for sign-in
    }
  };

  const handleDisconnect = async () => {
    setIsSigningOut(true); // Start loading spinner for sign-out
    try {
      await disconnect();
      setAddress(null);
      setProfilePic(null);
      setUsername(null);

      // Remove from localStorage
      localStorage.removeItem("walletAddress");
      localStorage.removeItem("profilePic");
      localStorage.removeItem("username");

      setIsConnected(false);
    } catch (error) {
      console.error("Disconnection failed", error);
    } finally {
      setIsSigningOut(false); // Stop loading spinner for sign-out
    }
  };
  // Capitalize the first letter
  const capitalizeFirstLetter = (text: string) => {
    return text.charAt(0).toUpperCase() + text.slice(1);
  };

  // Remove the leading slash
  const cleanPathname = pathname.startsWith("/") ? pathname.slice(1) : pathname;

  // Handle Sidebar Collapse Toggle
  const handleCollapseToggle = () => {
    setIsCollapsed(!isCollapsed);
  };

  return (
    <nav
      className={classNames(
        "text-sm md:text-lg flex items-center justify-between p-3 md:p-4 shadow-md border-b border-b-neutral-700 transition-all duration-300",
        {
          "bg-black": theme == "dark",
          "bg-gray-900": theme == "light",
        }
      )}
    >
      <div className="flex items-center space-x-2">
        <div className="activity-icon-container rounded-lg p-2 md:p-3 bg-emerald-600 ">
          <SparklesIcon className="size-4 md:size-5" />
        </div>
        <FaAngleDoubleRight className="size-3" />
        <div className="font-bold text-white">
          {cleanPathname !== ""
            ? capitalizeFirstLetter(cleanPathname)
            : "Overview"}
        </div>
      </div>
      {/* </div> */}

      <div className="flex items-center space-x-3 md:space-x-4">
        {/* <div className="text-white hidden md:block">ArConnect</div> */}
        {isConnected && (
          <div className="flex items-center space-x-3">
            {profilePic && (
              <img
                src={profilePic}
                alt="Profile picture"
                className="w-8 h-8 rounded-full"
              />
            )}
            {username && (
              <span className="text-white font-medium">{username}</span>
            )}
            {address && (
              <div className="flex items-center space-x-2">
                <span className="text-gray-300 text-xs md:text-sm truncate">
                  {address}
                </span>
                <button
                  type="button"
                  onClick={() => {
                    navigator.clipboard.writeText(address);
                    alert("Wallet address copied to clipboard!");
                  }}
                  className="text-blue-500 hover:text-white transition"
                >
                  Copy
                </button>
              </div>
            )}
          </div>
        )}
        <label className="relative inline-flex cursor-pointer items-center">
          <input
            id="switch-2"
            type="checkbox"
            className="peer sr-only"
            checked={isConnected} // Bind to connection state
            onChange={isConnected ? handleDisconnect : handleConnect}
            disabled={isSigningOut}
          />
          <label htmlFor="switch-2" className="hidden"></label>
          <div
            className="peer h-3 md:h-4 w-9 md:w-11 rounded-full bg-slate-500 after:absolute after:-top-1 after:left-0 after:h-5 after:w-5 md:after:h-6 md:after:w-6 after:rounded-full 
          after:border after:border-gray-300 after:bg-white after:transition-all after:content-[''] peer-checked:bg-amber-400 peer-checked:after:translate-x-full 
          peer-focus:ring-emerald-600"
          ></div>
        </label>
        {/* <label className="relative inline-flex cursor-pointer items-center">
                    <input id="switch" type="checkbox" className="peer sr-only" />
                    <label htmlFor="switch" className="hidden"></label>
                    <div className="peer h-6 w-11 rounded-full bg-slate-200 after:absolute after:left-[2px] after:top-0.5 after:h-5 after:w-5 after:rounded-full  after:bg-white after:transition-all after:content-[''] peer-checked:bg-emerald-600 peer-checked:after:translate-x-full peer-focus:ring-green-300"></div>
                </label> */}

        <div
          className={classNames("flex md:hidden text-center", {
            "p-1 border border-red-400 rounded-lg text-red-400 shadow shadow-red-600":
              !isCollapsed,
          })}
        >
          <button onClick={handleCollapseToggle}>
            {isCollapsed ? (
              <Bars3Icon className="size-6 transition-transform duration-300 ease-in-out" />
            ) : (
              <XMarkIcon className="size-3 transition-transform duration-300 ease-in-out" />
            )}
          </button>
        </div>

        {/* <FaBell className="text-white" /> */}
      </div>
    </nav>
  );
};

export default Navbar;
