import React from "react";
import {
  FaSearch,
  FaStar,
  FaHandshake,
  FaShieldAlt,
  FaComments,
  FaRobot,
  FaTasks,
} from "react-icons/fa";

const Benefits = () => {
  const benefits = [
    {
      id: 1,
      icon: <FaSearch className="w-12 h-12 mx-auto" />,
      title: "Effortless Discovery",
      description:
        "Aostore makes it easy to find and explore projects on the Permaweb. No more navigating a fragmented ecosystem—everything you need is in one place.",
      style: "bg-gradient-to-r from-cyan-500 to-blue-500",
    },
    {
      id: 2,
      icon: <FaStar className="w-12 h-12 mx-auto" />,
      title: "Build Your Reputation",
      description:
        "Earn AOS tokens and points for your contributions. Your reputation grows as you engage, creating opportunities for recognition and rewards.",
      style: "bg-gradient-to-r from-purple-500 to-pink-500",
    },
    {
      id: 3,
      icon: <FaHandshake className="w-12 h-12 mx-auto" />,
      title: "Global Collaboration",
      description:
        "Connect with projects and users worldwide. Aostore fosters collaboration through airdrops, tasks, and community-driven initiatives.",
      style: "bg-gradient-to-r from-green-500 to-teal-500",
    },
    {
      id: 4,
      icon: <FaShieldAlt className="w-12 h-12 mx-auto" />,
      title: "Ecosystem Protection",
      description:
        "Our unique airdrop formula ensures tokens go to engaged users, reducing the risk of market dumps and promoting a healthier ecosystem.",
      style: "bg-gradient-to-r from-yellow-500 to-orange-500",
    },
    {
      id: 5,
      icon: <FaComments className="w-12 h-12 mx-auto" />,
      title: "Direct Communication",
      description:
        "Projects can interact directly with their communities. Share updates, gather feedback, and build trust through transparent communication.",
      style: "bg-gradient-to-r from-red-500 to-pink-500",
    },
    {
      id: 6,
      icon: <FaRobot className="w-12 h-12 mx-auto" />,
      title: "AI-Powered Insights",
      description:
        "Our AI agent analyzes reviews and generates actionable insights, helping project owners improve and grow their platforms.",
      style: "bg-gradient-to-r from-indigo-500 to-blue-500",
    },
    {
      id: 7,
      icon: <FaTasks className="w-12 h-12 mx-auto" />,
      title: "Drive Engagement",
      description:
        "Create tasks to engage your community and reward participation. From social media follows to bug reports, Aostore makes it easy to connect.",
      style: "bg-gradient-to-r from-teal-500 to-green-500",
    },
  ];

  return (
    <div
      name="benefits" // Update the ID to match the navbar link
      className="bg-gradient-to-b from-gray-800 to-black w-full min-h-screen"
    >
      <div className="max-w-screen-lg mx-auto p-4 flex flex-col justify-center w-full h-full text-white">
        <div>
          <p className="text-4xl font-bold border-b-4 border-gray-500 p-2 inline">
            Why Choose Aostore?
          </p>
          <p className="py-6">
            Aostore isn’t just a platform—it’s a gateway to a stronger, more
            connected Arweave ecosystem. Here’s what you gain:
          </p>
        </div>

        {/* Benefits Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 py-8">
          {benefits.map(({ id, icon, title, description, style }) => (
            <div
              key={id}
              className={`p-6 rounded-lg transform transition-all duration-300 hover:scale-105 ${style}`}
            >
              <div className="text-center">
                <div className="text-white">{icon}</div>
                <h3 className="text-xl font-bold mt-4 mb-2">{title}</h3>
                <p className="text-gray-200 text-sm">{description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Benefits;
