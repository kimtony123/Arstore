import React, { useState, useEffect } from "react";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";

import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import OverviewSection from "../../components/walletOverview/WalletOverview";
import {
  Button,
  Container,
  Divider,
  Grid,
  GridRow,
  Header,
} from "semantic-ui-react";

const WalletPage: React.FC = () => {
  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  interface Tag {
    name: string;
    value: string;
  }

  const [arsBalance, setArsBalance] = useState(0);
  const [isLoadingClaim, setIsLoadingClaim] = useState(false);
  const [isLoadingData, setIsLoadingData] = useState(true); // New loading state for fetching data

  // Function to reload the page.
  function reloadPage(forceReload = false): void {
    if (forceReload) {
      // Force reload from the server
      location.href = location.href;
    } else {
      // Reload using the cache
      location.reload();
    }
  }

  // Fetch transaction history after balances
  const fetchClaim = async () => {
    setIsLoadingClaim(true);
    const messageResponse = await message({
      process: ARS,
      tags: [{ name: "Action", value: "claim" }],
      signer: createDataItemSigner(othent), // Use othent signer
    });
    const { Messages, Error } = await result({
      message: messageResponse,
      process: ARS,
    });

    if (Error) {
      alert("Error Claiming:" + Error);
      return;
    }
    if (!Messages || Messages.length === 0) {
      alert("No messages were returned from ao. Please try later.");
      return;
    }
    const data = Messages[0].Data;
    alert(data);
    setIsLoadingClaim(false); // Stop spinner for Claim
  };

  useEffect(() => {
    const fetchArsBalance = async () => {
      try {
        setIsLoadingData(true); // Start loading for data
        // Fetch AOC balance first
        const aocMessageResponse = await message({
          process: ARS,
          tags: [{ name: "Action", value: "Balance" }],
          signer: createDataItemSigner(othent),
        });

        const aocResult = await result({
          message: aocMessageResponse,
          process: ARS,
        });

        if (!aocResult.Error) {
          const aocBalanceTag = aocResult.Messages?.[0].Tags.find(
            (tag: Tag) => tag.name === "Balance"
          );
          setArsBalance(aocBalanceTag?.value);
        }
      } catch (error) {
        console.error("Error fetching balances or transactions:", error);
      } finally {
        setIsLoadingData(false); // Stop loading for data
      }
    };
    fetchArsBalance(); // Fetch balances and transactions in sequence
  }, []);

  return (
    <div className="content text-black h-full dark:text-white">
      {isLoadingData ? (
        <div className="flex justify-center h-full items-center h-64">
          <FaSpinner className="animate-spin text-3xl" />{" "}
          {/* Loading Spinner */}
        </div>
      ) : (
        <>
          <OverviewSection arsBalance={arsBalance} />
          <Container>
            <Button
              loading={isLoadingClaim}
              size="large"
              onClick={fetchClaim}
              primary
              floated="right"
            >
              Claim
            </Button>
            <Grid centered>
              <GridRow>
                <Header as="h1" dividing>
                  Statistics
                </Header>
              </GridRow>
            </Grid>
          </Container>
        </>
      )}
    </div>
  );
};

export default WalletPage;
