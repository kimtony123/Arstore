import React from "react";

import { FaWallet } from "react-icons/fa";

interface OverviewProps {
  arsBalance: number;
}

const OverviewSection: React.FC<OverviewProps> = ({ arsBalance }) => {
  const walletAddress = localStorage.getItem("walletAddress");

  return (
    <div className="w-full text-white p-2 sm:p-6 mb-4 md:mb-8 flex flex-col sm:flex-row justify-center sm:justify-between lg:items-center shadow-lg border-b border-b-neutral-700">
      {/* Left Section - Wallet Info */}
      <div className="ml-6 lg:ml-0 flex justify-start items-start md:space-x-4 my-3">
        <div className="p-2 bg-neutral-700 rounded-full hidden md:block">
          <FaWallet size="15" />
        </div>
        <div className="tems-start text-start">
          <p className="text-gray-400 text-sm">Your Wallet / Balance</p>
          <div className="flex items-center space-x-2">
            <h2 className="text-xl font-semibold">
              {walletAddress
                ? `${walletAddress.substring(0, 5)}...${walletAddress.substring(
                    walletAddress.length - 3
                  )}`
                : ""}
            </h2>
            <div className="flex space-x-3 mt-2">
              <span className="text-green-400 text-xs md:text-sm lg:text-md font-bold">
                ARS: {arsBalance}
              </span>
            </div>
            {/* <span className="text-green-400 text-3xl font-bold">/Aoc {aocBalance}</span> */}
          </div>
          {/* <p className="text-gray-400 text-sm">You Take 7.46% Less Than (Past 2 Months)</p> */}
        </div>
      </div>

      {/* Center Section - Market or Weather Info */}
      <div className="ml-6 lg:ml-0 flex flex-col items-start">
        <div className="flex space-x-4">
          {/* <div className="text-start text-sm">
                        <p className="text-gray-400">Location</p>
                        <h3 className="text-xs font-semibold ">New York</h3>
                    </div> */}
        </div>

        {/* Dropdown for selecting weather options */}
        {/* <div>
                    <select className="bg-neutral-800 text-white text-sm p-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                        onChange={(event) => { updateWeatherOption(event.target.value) }}
                    >
                        <option className='text-xs' value="temperature">Temperature (°C)</option>
                        <option className='text-xs' value="rainfall">Rainfall (mm)</option>
                    </select>
                </div> */}
      </div>
    </div>
  );
};

export default OverviewSection;
