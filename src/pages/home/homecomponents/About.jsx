import React from "react";
import { FaExclamationTriangle, FaLightbulb } from "react-icons/fa";

const ProblemSolution = () => {
  return (
    <div
      name="problem-solution" // Update the ID to match the navbar link
      className="h-screen w-full bg-gradient-to-b from-black via-gray-900 to-gray-800"
    >
      <div className="max-w-screen-lg mx-auto flex flex-col justify-center h-full px-4">
        {/* Section Header */}
        <h2 className="text-3xl sm:text-5xl font-bold text-white text-center mb-12">
          Playstore for Arweave and aocomputer Ecosystem.
        </h2>

        {/* Problem & Solution Container */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
          {/* Left Side - Problem */}
          <div className="flex flex-col items-center md:items-end text-center md:text-right">
            {/* Problem Icon */}
            <div className="text-cyan-500 text-6xl mb-4">
              <FaExclamationTriangle />
            </div>

            {/* Problem Content */}
            <h3 className="text-2xl font-bold text-white mb-4">The Problem</h3>
            <p className="text-gray-400 text-lg">
              The Arweave ecosystem lacks an **information layer**, making it
              difficult for users to discover projects, share feedback, and
              collaborate effectively. Without a centralized platform, projects
              struggle to engage their communities, and users are left
              navigating a noisy, fragmented ecosystem.
            </p>
          </div>

          {/* Right Side - Solution */}
          <div className="flex flex-col items-center md:items-start text-center md:text-left">
            {/* Solution Icon */}
            <div className="text-cyan-500 text-6xl mb-4">
              <FaLightbulb />
            </div>

            {/* Solution Content */}
            <h3 className="text-2xl font-bold text-white mb-4">The Solution</h3>
            <p className="text-gray-400 text-lg">
              Aostore provides the **information layer** Arweave needs. It
              enables users to discover, review, and rate projects, while
              project owners can engage with their communities, reward
              contributions, and build trust through transparency and
              collaboration.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProblemSolution;
