import React from "react";
import { FaGithub, FaTwitter } from "react-icons/fa";

const Footer = () => {
  return (
    <div className="w-full pb-8 px-4 md:px-8 flex items-center flex-wrap justify-center space-x-5">
      <div>
        <a
          type="button"
          className="text-white bg-[#1da1f2] hover:bg-[#1da1f2]/90 focus:ring-4 
                        focus:outline-none focus:ring-[#1da1f2]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center 
                        inline-flex items-center dark:focus:ring-[#1da1f2]/55"
          href="https://x.com/ar_aostore"
          target="_blank"
          rel="noopener noreferrer"
        >
          Twitter
          <FaTwitter className="w-3.5 h-3.5 text-white ml-2" />
        </a>
      </div>
      <div className="text-xl font-bold text-center flex flex-col justify-center py-2.5">
        <a
          href="https://ao.arweave.dev/"
          target="_blank"
          rel="noopener noreferrer"
        >
          <img className="h-12 w-12" src="AO.svg" alt="ACO logo" />
        </a>
      </div>

      <div>
        <a
          type="button"
          className="text-white bg-[#24292F] hover:bg-[#24292F]/90 focus:ring-4 
                        focus:outline-none focus:ring-[#24292F]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center 
                        inline-flex items-center dark:focus:ring-gray-500 dark:hover:bg-[#050708]/30"
          href="https://github.com/kimtony123/Arstore"
          target="_blank"
          rel="noopener noreferrer"
        >
          <FaGithub className="w-3.5 h-3.5 text-white me-2" />
          Github
        </a>
      </div>
    </div>
  );
};

export default Footer;
