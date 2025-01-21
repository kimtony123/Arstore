import React from "react";

import html from "../../../assets/luaa.jpg";
import css from "../../../assets/protocol.jpg";
import javascript from "../../../assets/ao.png";
import reactImage from "../../../assets/arweavex.jpg";
import nextjs from "../../../assets/scalability.jpg";
import tailwind from "../../../assets/default.svg";

const Ao = () => {
  const cards = [
    {
      id: 1,
      src: html,
      title: "Lua for Robotics",
      description:
        "Most robotics projects like Arduino pilot use Lua, so robotics programmers won't need to learn a new language.",
      style: "shadow-orange-500",
    },
    {
      id: 2,
      src: css,
      title: "Monetize Your IoT Dapp",
      description:
        "Easily monetize your IOT DApp with tokens using protocol.land, integrating blockchain and IoT seamlessly.",
      style: "shadow-blue-500",
    },
    {
      id: 3,
      src: javascript,
      title: "Modular Architecture.",
      description:
        "Ao supports concurrent computation, ensuring fast processing for your IoT applications just like ROS2.",
      style: "shadow-yellow-500",
    },
    {
      id: 4,
      src: reactImage,
      title: "Permanent Data Logs",
      description:
        "Data logs from IOT devices are permanently stored on Arweave, ensuring secure and unalterable storage.",
      style: "shadow-blue-600",
    },
    {
      id: 5,
      src: nextjs,
      title: "Scalability",
      description:
        "Ao's architecture allows you to scale your IoT applications easily, even with large amounts of data and devices.",
      style: "shadow-sky-400",
    },
    {
      id: 6,
      src: tailwind,
      title: "ao-robotics",
      description:
        "ao-robotics allows your process to access ROS2 , giving you access to the best robotic packages.",
      style: "shadow-white",
    },
  ];

  return (
    <div
      name="why ao"
      className="bg-gradient-to-b from-gray-800 to-black w- min-h-screen"
    >
      <div className="max-w-screen-lg mx-auto p-4 flex flex-col justify-center w-[90%] h-full text-white">
        <div>
          <p className="text-4xl font-bold border-b-4 border-gray-500 p-2 inline">
            Why ao?
          </p>
          <p className="py-6">
            Key features of aocomputer that make it ideal for your IoT projects:
          </p>
        </div>

        {/* Cards Container */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 text-center py-8 px-4">
          {cards.map(({ id, src, title, description, style }) => (
            <div
              key={id}
              className={`relative shadow-md hover:scale-105 duration-500 py-4 rounded-lg ${style}`}
            >
              <div className="h-40 flex flex-col justify-center items-center">
                <img src={src} alt="" className="w-20 mx-auto" />
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

export default Ao;
