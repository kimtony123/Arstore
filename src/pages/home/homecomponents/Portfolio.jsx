import React from "react";
import S1 from "../../../assets/portfolio/s1.gif";
import S2 from "../../../assets/portfolio/S2.gif";
import S3 from "../../../assets/portfolio/S3.gif";
import S4 from "../../../assets/portfolio/S4.webp";
import S5 from "../../../assets/portfolio/S5.gif";
import S6 from "../../../assets/portfolio/S6.gif";
import S7 from "../../../assets/portfolio/s7.gif";
import S8 from "../../../assets/portfolio/S8.gif";
import S9 from "../../../assets/portfolio/S9.gif";
import S10 from "../../../assets/portfolio/S10.gif";

const Portfolio = () => {
  const portfolios = [
    {
      id: 1,
      src: S1,
      title: " Calculator Dapp",
      description:
        " A simple Dapp that sums two numbers on Ros2 using a process on ao-computer.",
      status: "Complete",
    },
    {
      id: 2,
      src: S2,
      title: "Turtle Sim Navigation",
      description:
        "Navigate a turtle in a 2D environment on ROS using an AO process.",
      status: "Pending",
    },
    {
      id: 3,
      src: S3,
      title: "Object Detection",
      description:
        "Spawn an AO process that detects objects using a simulated robot in Gazebo.",
      status: "Pending",
    },
    {
      id: 4,
      src: S4,
      title: "Path Planning",
      description:
        "Implement path planning algorithms for a mobile robot using an AO process.",
      status: "Pending",
    },
    {
      id: 5,
      src: S5,
      title: "Slam Mapping",
      description: "Spawn a new 2D model on ROS using an AO process.",
      status: "Pending",
    },
    {
      id: 6,
      src: S6,
      title: "Teleoperation",
      description:
        "Spawn an AO process that allows control of a robot using keyboard or joystick inputs.",
      status: "Pending",
    },
    {
      id: 7,
      src: S7,
      title: "Sensor Fusion",
      description:
        "Create a Lua process that combines data from multiple sensors for better accuracy.",
      status: "Pending",
    },
    {
      id: 8,
      src: S8,
      title: "Arm Manipulation",
      description:
        "Spawn an AO process that controls a robotic arm to pick and place objects.",
      status: "Pending",
    },
    {
      id: 9,
      src: S9,
      title: "Voice Control",
      description:
        "Spawn an AO process that controls a robot using voice commands.",
      status: "Pending",
    },
    {
      id: 10,
      src: S10,
      title: "Automated docking.",
      description:
        "Spawn an AO process that makes a robot return to a docking station autonomously.",
      status: "Pending",
    },
  ];
  const demoUrl = "https://youtu.be/Ihpc0bb_1sw";
  const codeUrl = "https://github.com/kimtony123/calculator-dapp";
  const moreInfoUrl = "https://calculatordapp.netlify.app/";

  return (
    <div
      name="projects"
      className="bg-gradient-to-b from-black to-gray-800 w-full text-white min-h-screen"
    >
      <div className="max-w-screen-lg p-4 mx-auto flex flex-col justify-center w-[90%] h-full">
        <div className="pb-8">
          <p className="text-4xl font-bold inline border-b-4 border-gray-500">
            Projects
          </p>
          <p className="py-6">Explore ongoing and completed projects:</p>
        </div>

        <div className="grid sm:grid-cols-2 md:grid-cols-3 gap-8 px-12 sm:px-0">
          {portfolios.map(({ id, src, title, description, status }) => (
            <div
              key={id}
              className="relative shadow-md shadow-gray-600 rounded-lg group overflow-hidden"
            >
              {/* Image and Title */}
              <img
                src={src}
                alt={title}
                className="rounded-t-lg w-full duration-200 group-hover:scale-105"
              />
              <div className="p-4 bg-gray-900">
                <h3 className="text-lg font-bold">{title}</h3>
                <p
                  className={`text-sm mt-2 ${
                    status === "Complete" ? "text-green-400" : "text-red-400"
                  }`}
                >
                  {status}
                </p>
              </div>

              {/* Hover effect for description */}
              <div className="absolute inset-0 bg-gray-800 bg-opacity-90 flex flex-col justify-center items-center text-center opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-4">
                <p className="text-sm mb-4">{description}</p>
                <div className="flex space-x-4">
                  <a
                    href={demoUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`px-4 py-2 bg-blue-500 text-white rounded-lg ${
                      status !== "Complete"
                        ? "opacity-50 cursor-not-allowed"
                        : "hover:bg-blue-600"
                    }`}
                    disabled={status !== "Complete"}
                  >
                    Youtube Demo.
                  </a>
                  <a
                    href={codeUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`px-4 py-2 bg-green-500 text-white rounded-lg ${
                      status !== "Complete"
                        ? "opacity-50 cursor-not-allowed"
                        : "hover:bg-green-600"
                    }`}
                    disabled={status !== "Complete"}
                  >
                    Github.
                  </a>
                  <a
                    href={moreInfoUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`px-4 py-2 bg-gray-700 text-white rounded-lg ${
                      status !== "Complete"
                        ? "opacity-50 cursor-not-allowed"
                        : "hover:bg-gray-800"
                    }`}
                    disabled={status !== "Complete"}
                  >
                    AO-DAPP.
                  </a>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Portfolio;
