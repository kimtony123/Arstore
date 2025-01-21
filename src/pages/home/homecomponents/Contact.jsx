import React from "react";
import { FaGithub, FaTwitter } from "react-icons/fa";

const Footer = () => {
  return (
    <footer className="w-full bg-gradient-to-b from-black to-gray-800 p-4 text-white flex items-center justify-center space-x-8">
      {/* Twitter Link */}
      <a
        href="https://x.com/antonyk139"
        target="_blank"
        rel="noopener noreferrer"
        className="text-white bg-blue-500 hover:bg-blue-600 focus:ring-4 focus:ring-blue-400 font-medium rounded-lg text-sm px-5 py-2.5 flex items-center space-x-2 shadow-lg"
      >
        <span>Twitter</span>
        <FaTwitter className="w-5 h-5" />
      </a>

      {/* Placeholder for logo or central content */}
      <div className="text-center">
        <p className="text-lg font-bold">AO Robotics</p>
      </div>

      {/* GitHub Link */}
      <a
        href="https://protocol.land/#/user/1J_5LXOiHRZQtOYYyjL7CpG-SdAXMVtwkcsYo7-ky40"
        target="_blank"
        rel="noopener noreferrer"
        className="text-white bg-gray-800 hover:bg-gray-900 focus:ring-4 focus:ring-gray-700 font-medium rounded-lg text-sm px-5 py-2.5 flex items-center space-x-2 shadow-lg"
      >
        <FaGithub className="w-5 h-5" />
        <span>GitHub</span>
      </a>
    </footer>
  );
};

export default Footer;
