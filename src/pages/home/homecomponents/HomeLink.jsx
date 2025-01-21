import React from "react";
import HeroImage from "../../../assets/default.png";
import { MdOutlineKeyboardArrowRight } from "react-icons/md";
import { Link } from "react-scroll";

const Home = () => {
  return (
    <div
      name="home"
      className="h-screen w-full bg-gradient-to-b from-black via-gray-900 to-gray-800"
    >
      <div className="max-w-screen-lg mx-auto flex flex-col md:flex-row items-center justify-center h-full px-4">
        {/* Left Content */}
        <div className="flex flex-col justify-center h-full md:w-1/4">
          <h2 className="text-3xl sm:text-5xl font-bold text-white">aostore</h2>

          <p className="text-gray-400 py-4 max-w-md text-lg">
            Supercharge your IOT and robotics projects with **AO-Robotics**.
            Unlock the power of ROS2 on the AOComputer network and access the
            **best robotic packages** for IoT and robotics development. Build
            smarter, faster, and more efficient robotic systems.
          </p>

          <div>
            <Link
              to="projects"
              smooth
              duration={500}
              className="group text-white w-fit px-6 py-3 my-2 flex items-center rounded-md bg-gradient-to-r from-cyan-500 to-blue-500 cursor-pointer shadow-lg shadow-cyan-500/50 hover:scale-105 transform transition duration-300"
            >
              Explore Projects
              <span className="group-hover:rotate-90 duration-300">
                <MdOutlineKeyboardArrowRight size={25} className="ml-1" />
              </span>
            </Link>
          </div>
        </div>

        {/* Right Content - Image */}
        <div className="mt-8 md:mt-0 md:w-1/2 flex justify-center">
          <img
            src={HeroImage}
            alt="Robotics"
            className="rounded-2xl mx-auto w-3/4 md:w-full hover:scale-105 transform transition duration-300 shadow-lg shadow-cyan-500/50"
          />
        </div>
      </div>
    </div>
  );
};

export default Home;
