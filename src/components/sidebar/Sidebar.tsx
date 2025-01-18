import "./Sidebar.css";
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaWallet,
  FaErlang,
  FaCoins,
  FaAsymmetrik,
  FaInbox,
} from "react-icons/fa";
import {
  Squares2X2Icon,
  HomeIcon,
  SunIcon,
  MoonIcon,
  TrophyIcon,
} from "@heroicons/react/24/outline";
import { Tooltip } from "react-tooltip";
import classNames from "classnames";

interface SidebarBarProps {
  theme: string;
  updateTheme: (theme: string) => void;
  activeIndex: number;
  updateActiveIndex: (activeIndex: number) => void;
  isCollapsed: boolean;
}

const Sidebar: React.FC<SidebarBarProps> = ({
  theme,
  updateTheme,
  activeIndex,
  updateActiveIndex,
  isCollapsed,
}) => {
  const navigate = useNavigate();

  const toggleTheme = () => {
    const newTheme = theme === "dark" ? "light" : "dark";
    updateTheme(newTheme);
    document.documentElement.classList.remove("dark", "light");
    document.documentElement.classList.add(newTheme);
    localStorage.setItem("theme", newTheme);
  };

  const menuItems = [
    { icon: <HomeIcon className="size-4 md:size-5" />, tooltip: "Home" },
    {
      icon: <FaAsymmetrik className="size-4 md:size-5" />,
      tooltip: "favorites",
    },

    {
      icon: <FaInbox className="size-4 md:size-5" />,
      tooltip: "messages",
    },

    {
      icon: <Squares2X2Icon className="size-4 md:size-5" />,
      tooltip: "aocomputer",
    },
    {
      icon: <Squares2X2Icon className="size-4 md:size-5" />,
      tooltip: "arweave",
    },
    { icon: <FaWallet className="size-4 md:size-5" />, tooltip: "Wallet" },
    {
      icon: <TrophyIcon className="size-4 md:size-5" />,
      tooltip: "LeaderBoard",
    },
    { icon: <FaCoins className="size-4 md:size-5" />, tooltip: "airdrops" },

    { icon: <FaErlang className="size-4 md:size-5" />, tooltip: "myapps" },
  ];

  return (
    <div
      className={classNames(
        "sidebar h-screen md:flex flex-col w-15 md:w-20 justify-between text-white shadow-lg border-r border-r-neutral-700 transition-colors duration-300 ease-in-out",
        {
          hidden: isCollapsed,
          flex: !isCollapsed,
          "bg-black": theme === "dark",
          "bg-gray-900": theme === "light",
        }
      )}
    >
      <div className="flex flex-col">
        <div className="py-3 px-2 md:py-4 md:px-3 flex items-center justify-center">
          <img className="logo" src="AO.svg" alt="Arstore logo" />
        </div>
        <div className="flex-grow flex flex-col items-center space-y-2">
          {menuItems.map((item, index) => (
            <SidebarIcon
              key={index}
              icon={item.icon}
              tooltip={item.tooltip}
              isActive={index === activeIndex}
              theme={theme}
              onClick={() => {
                updateActiveIndex(index);
                localStorage.setItem("activeIndex", index.toString());
                navigate(
                  item.tooltip === "Home" ? "/" : item.tooltip.toLowerCase()
                );
              }}
            />
          ))}
        </div>
      </div>
      <div>
        <div className="py-3 px-2 flex items-center justify-center">
          {/* Add lightmode dark mode toggle shitch here */}
          <button
            onClick={toggleTheme}
            className={classNames(
              "flex items-center justify-center p-2 bg-neutral-700- text-white rounded-full transition-colors duration-300",
              {
                "border border-amber-400 text-amber-400": theme == "light",
                "border border-neutral-400 text-neutral-300": theme == "dark",
              }
            )}
          >
            {theme === "light" ? (
              <SunIcon className="size-4 md:size-5" />
            ) : (
              <MoonIcon className="size-4 md:size-5" />
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

interface SidebarIconProps {
  icon: JSX.Element;
  tooltip: string;
  isActive: boolean;
  theme: string;
  onClick: () => void;
}

const SidebarIcon: React.FC<SidebarIconProps> = ({
  icon,
  tooltip,
  isActive,
  theme,
  onClick,
}) => (
  <div
    onClick={onClick}
    className={classNames(
      "sidebar-icon group relative flex items-center justify-center rounded-lg p-2 md:p-3 transition-colors duration-300 cursor-pointer",
      {
        "border border-amber-400 text-amber-300": isActive,
        // 'bg-neutral-200': isActive && theme === 'dark',
        // 'bg-neutral-500': isActive && theme === 'light',
        "hover:bg-neutral-700": !isActive && theme === "dark",
        "hover:bg-neutral-500": !isActive && theme === "light",
      }
    )}
    data-tooltip-id={tooltip}
    data-tooltip-content={tooltip}
  >
    {icon}
    <Tooltip id={tooltip} place="right" variant="dark" className="solid" />
  </div>
);

export default Sidebar;
