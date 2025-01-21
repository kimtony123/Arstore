import { useEffect, useState } from "react";

import { Divider } from "semantic-ui-react";

import About from "./homecomponents/About";
import Contact from "./homecomponents/Contact";
import Experience from "./homecomponents/Experience";
import HomeLink from "./homecomponents/HomeLink";
import NavBar from "./homecomponents/NavBar";
import SocialLinks from "./homecomponents/SocialLinks";
import Ao from "./homecomponents/ao";

import classNames from "classnames";

const Home = () => {
  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <NavBar />
      {/* Static Landing Page */}
      <HomeLink />
      <Divider />
      <About />
      <Divider />
      <Experience />
      <Divider />
      <Ao />
      <SocialLinks />
      <Divider />
      <Ao />
      <Ao />
      <Contact />
    </div>
  );
};

export default Home;
