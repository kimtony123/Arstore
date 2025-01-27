import React from "react";
import {
  FaInfoCircle,
  FaStar,
  FaHandshake,
  FaShieldAlt,
  FaComments,
  FaRobot,
  FaTasks,
} from "react-icons/fa";

const KeyFeatures = () => {
  const features = [
    {
      id: 1,
      icon: <FaInfoCircle className="w-20 h-20 mx-auto" />,
      title: "Informational Layer",
      description:
        "Discover, review, and rate projects on the Permaweb. Provide valuable insights for the community.",
      style: "shadow-cyan-500",
    },
    {
      id: 2,
      icon: <FaStar className="w-20 h-20 mx-auto" />,
      title: "Reputation Layer",
      description:
        "Earn AOS tokens and points for your contributions. Build your reputation across the ecosystem.",
      style: "shadow-blue-500",
    },
    {
      id: 3,
      icon: <FaHandshake className="w-20 h-20 mx-auto" />,
      title: "Collaboration Layer",
      description:
        "Participate in airdrops and ecosystem tasks. Collaborate with projects and other users.",
      style: "shadow-purple-500",
    },
    {
      id: 4,
      icon: <FaShieldAlt className="w-20 h-20 mx-auto" />,
      title: "Protection Layer",
      description:
        "Our airdrop formula discourages 'paper hands,' reducing the risk of market dumps.",
      style: "shadow-green-500",
    },
    {
      id: 5,
      icon: <FaComments className="w-20 h-20 mx-auto" />,
      title: "Communication Layer",
      description:
        "Projects can communicate directly with users. Share feedback, bug reports, or feature requests.",
      style: "shadow-pink-500",
    },
    {
      id: 6,
      icon: <FaRobot className="w-20 h-20 mx-auto" />,
      title: "AI Agent Component",
      description:
        "Analyzes reviews and generates insights for project owners. Automates responses to similar reviews.",
      style: "shadow-orange-500",
    },
    {
      id: 7,
      icon: <FaTasks className="w-20 h-20 mx-auto" />,
      title: "Tasks Component",
      description:
        "Projects can create tasks (e.g., 'Follow us on Twitter') to drive engagement and reward users.",
      style: "shadow-yellow-500",
    },
  ];

  return (
    <div
      name="features" // Update the ID to match the navbar link
      className="bg-gradient-to-b from-gray-800 to-black w-full min-h-screen"
    >
      <div className="max-w-screen-lg mx-auto p-4 flex flex-col justify-center w-full h-full text-white">
        <div>
          <p className="text-4xl font-bold border-b-4 border-gray-500 p-2 inline">
            Key Features
          </p>
          <p className="py-6">
            Explore the 7 core components that make Aostore the information
            layer for the Arweave ecosystem:
          </p>
        </div>

        {/* Cards Container */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 text-center py-8 px-4">
          {features.map(({ id, icon, title, description, style }) => (
            <div
              key={id}
              className={`relative shadow-md hover:scale-105 duration-500 py-4 rounded-lg ${style}`}
            >
              <div className="h-40 flex flex-col justify-center items-center">
                {icon}
                <p className="mt-4 text-xl font-bold">{title}</p>
              </div>
              <div className="absolute inset-0 flex flex-col justify-center items-center bg-gray-800 rounded-lg text-white opacity-0 hover:opacity-100 transition-opacity duration-500 px-4 py-8">
                <p className="text-sm">{description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default KeyFeatures;
