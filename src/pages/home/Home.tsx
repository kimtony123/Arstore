import { useEffect, useState } from "react";

import { Container, Divider } from "semantic-ui-react";

import About from "./homecomponents/About";
import Contact from "./homecomponents/Contact";
import Experience from "./homecomponents/Experience";
import HomeLink from "./homecomponents/HomeLink";
import NavBar from "./homecomponents/NavBar";
import SocialLinks from "./homecomponents/SocialLinks";
import Ao from "./homecomponents/ao";
import Footer from "../../components/footer/Footer";
import classNames from "classnames";

const Home = () => {
  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <Container>
        <NavBar />
        {/* Static Landing Page */}
        <HomeLink />
        <About />
        <Experience />
        <Ao />
        <Contact />
      </Container>
    </div>
  );
};

export default Home;
