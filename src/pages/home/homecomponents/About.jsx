import React from "react";
import HeroImage from "../../../assets/humble-small.png";

const About = () => {
  return (
    <div
      name="ROS2"
      className="h-screen w-full bg-gradient-to-b from-black via-gray-900 to-gray-800"
    >
      <div className="max-w-screen-lg mx-auto flex flex-col items-center justify-center h-full px-4 md:flex-row">
        {/* Left Content */}
        <div className="flex flex-col justify-center h-full">
          <h2 className="text-3xl sm:text-5xl font-bold text-white">ROS2</h2>

          <p className="text-gray-400 py-4 max-w-md text-lg">
            ROS2 (Robot Operating System 2) is the cornerstone for the future of
            robotics. Its modular architecture enables developers to build
            smarter, scalable, and efficient robotic systems that adapt to
            real-world challenges seamlessly.
          </p>

          <p className="text-gray-400 py-4 max-w-md text-lg">
            On AOComputer, ROS2 becomes even more powerful. By combining the
            decentralized power of AO with ROS2's advanced libraries and
            frameworks, developers gain access to cutting-edge robotic packages
            and the opportunity to collaborate globally on innovative projects.
          </p>
        </div>

        {/* Right Content - Image */}
        <div className="mt-8 md:mt-0">
          <img
            src={HeroImage}
            alt="About ROS2"
            className="rounded-2xl mx-auto w-2/3 md:w-full hover:scale-105 transform transition duration-300 shadow-lg shadow-cyan-500/50"
          />
        </div>
      </div>
    </div>
  );
};

export default About;
