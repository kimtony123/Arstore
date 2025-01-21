import React from "react";

import html from "../../../assets/BFB.webp";
import css from "../../../assets/mass.webp";
import javascript from "../../../assets/security.webp";
import reactImage from "../../../assets/IOT.webp";
import nextjs from "../../../assets/decent.webp";
import tailwind from "../../../assets/interconnected.webp";

const Experience = () => {
  const cards = [
    {
      id: 1,
      src: html,
      title: "Smart Cities",
      description:
        "The emergence of smart cities like Bahrain's blockchain initiatives highlights the demand for secure IoT solutions.",
      style: "shadow-orange-500",
    },
    {
      id: 2,
      src: css,
      title: "Mass Surveillance",
      description:
        "Current IoT devices have been used for surveillance without consent, raising privacy concerns.",
      style: "shadow-blue-500",
    },
    {
      id: 3,
      src: javascript,
      title: "Hacking Risks",
      description:
        "Centralized IoT systems are vulnerable to hacking, leading to stolen sensitive data.",
      style: "shadow-yellow-500",
    },
    {
      id: 4,
      src: reactImage,
      title: "Rising IoT Adoption",
      description:
        "The increasing use of IoT devices demands scalable and secure frameworks.",
      style: "shadow-blue-600",
    },
    {
      id: 5,
      src: nextjs,
      title: "Data Integrity",
      description:
        "Decentralized solutions ensure data integrity and reduce risks associated with centralized storage.",
      style: "shadow-sky-400",
    },
    {
      id: 6,
      src: tailwind,
      title: "Future-Proofing",
      description:
        "Blockchain-integrated IoT prepares us for the future of connected systems and secure interactions.",
      style: "shadow-white",
    },
  ];

  return (
    <div
      name="why now"
      className="bg-gradient-to-b from-gray-800 to-black w-full min-h-screen"
    >
      <div className="max-w-screen-lg mx-auto p-4 flex flex-col justify-center w-full h-full text-white">
        <div>
          <p className="text-4xl font-bold border-b-4 border-gray-500 p-2 inline">
            Why Now?
          </p>
          <p className="py-6">
            Explore the reasons driving the adoption of secure IoT systems
            today:
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

export default Experience;
