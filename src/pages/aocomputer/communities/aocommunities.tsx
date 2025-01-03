import classNames from "classnames";

import {
  MenuItem,
  Menu,
  Container,
  Grid,
  Divider,
  CardGroup,
  Card,
  Icon,
  Button,
} from "semantic-ui-react";
import { useNavigate } from "react-router-dom";
import Footer from "../../../components/footer/Footer";

const aocommunities = () => {
  const navigate = useNavigate();
  const handleClickmemecoins = () => {
    navigate("/Aomemecoins");
  };
  const handleClickcommunities = () => {
    navigate("/Aocommunities");
  };

  const handleAddAoprojects = () => {
    navigate("/Addaoprojects");
  };

  const extra = (
    <>
      <a>
        <Icon name="thumbs up" />
        Ratings : 17
      </a>
      <Button primary>Visit Site.</Button>
    </>
  );

  return (
    <div
      className={classNames(
        "content text-black dark:text-white flex flex-col h-full justify-between"
      )}
    >
      <div className="text-white flex flex-col items-center lg:items-start">
        <Container>
          <Menu>
            <MenuItem onClick={handleClickcommunities} name="communities">
              AO communities.
            </MenuItem>
            <MenuItem name="memecoins" onClick={handleClickmemecoins}>
              AO memecoins.
            </MenuItem>
          </Menu>
          <Divider />

          <Grid>
            <Divider />
            AOC Balance: <span className="font-bold"> Communities.</span>
            <Divider />
            <Button
              onClick={handleAddAoprojects}
              floated="right"
              primary
              size="large"
            >
              Add AO Project.
            </Button>
            <CardGroup itemsPerRow={4}>
              <Card
                size="small"
                image="AO.svg"
                header="ao Computer"
                meta="Company : Foward Research"
                description="Category : Developer Tooling"
                extra={extra}
              />

              <Card
                size="small"
                image="AO.svg"
                header="ao Computer"
                meta="Company : Foward Research"
                description="Category : Developer Tooling"
                extra={extra}
              />
              <Card
                size="small"
                image="AO.svg"
                header="ao Computer"
                meta="Company : Foward Research"
                description=" Category : Developer Tooling"
                extra={extra}
              />
              <Card
                size="small"
                image="AO.svg"
                header="ao Computer"
                meta="Company : Foward Research"
                description="Category : Developer Tooling"
                extra={extra}
              />
              <Card
                size="small"
                image="AO.svg"
                header="ao Computer"
                meta="Company : Foward Research"
                description="Category : Developer Tooling"
                extra={extra}
              />
            </CardGroup>
          </Grid>
          <Divider />
          <Divider />
        </Container>
        <Container>
          <Grid>
            <Divider />
            AOC Balance: <span className="font-bold"> Ratings.</span>
            <Divider />
            <CardGroup>
              <Card fluid color="red" header="Option 1" />
              <Card fluid color="orange" header="Option 2" />
              <Card fluid color="yellow" header="Option 3" />
            </CardGroup>
          </Grid>
        </Container>
        <Divider />
      </div>
      <Footer />
    </div>
  );
};

export default aocommunities;
