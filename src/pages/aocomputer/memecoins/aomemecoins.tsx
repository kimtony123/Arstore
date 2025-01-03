import React from "react";
import { Container, Menu, MenuItem } from "semantic-ui-react";
import {
  BrowserRouter,
  Route,
  Router,
  Routes,
  useNavigate,
  Link,
} from "react-router-dom";

const aomemecoins = () => {
  const navigate = useNavigate();

  const handleClickmemecoins = () => {
    navigate("/Aomemecoins");
  };

  const handleClickcommunities = () => {
    navigate("/Aocommunities");
  };

  return (
    <Container>
      <Menu>
        <MenuItem onClick={handleClickcommunities} name="communities">
          AO communities.
        </MenuItem>
        <MenuItem name="memecoins" onClick={handleClickmemecoins}>
          AO memecoins.
        </MenuItem>
      </Menu>
    </Container>
  );
};

export default aomemecoins;
