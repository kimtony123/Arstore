import React, { useState, useEffect } from "react";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";

import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import OverviewSection from "../../components/walletOverview/WalletOverview";
import {
  Container,
  Grid,
  GridRow,
  Header,
  Loader,
  Table,
} from "semantic-ui-react";

const WalletPage: React.FC = () => {
  const ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk";

  interface Tag {
    name: string;
    value: string;
  }

  interface Transaction {
    user: string;
    transactionid: string;
    amount: string;
    type: string;
    balance: string;
    timestamp: string;
  }

  const [arsBalance, setArsBalance] = useState(0);

  const [transactionlist, setTransactionDetails] = useState<Transaction[]>([]);
  const [isLoadingData, setIsLoadingData] = useState(true); // New loading state for fetching data

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
      }
    };

    // Fetch transaction history after balances
    const fetchTransactions = async () => {
      const messageResponse = await message({
        process: ARS,
        tags: [{ name: "Action", value: "view_transactions" }],
        signer: createDataItemSigner(othent), // Use othent signer
      });
      const { Messages, Error } = await result({
        message: messageResponse,
        process: ARS,
      });

      if (Error) {
        alert("Error fetching transactions:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = JSON.parse(Messages[0].Data);
      const transactionData = Object.entries(data).map(([name, details]) => {
        const typedDetails: Transaction = details as Transaction;
        return {
          user: typedDetails.user,
          transactionid: typedDetails.transactionid,
          amount: String(typedDetails.amount),
          type: typedDetails.type,
          balance: String(typedDetails.balance),
          timestamp: new Date(typedDetails.timestamp).toLocaleString("en-US", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
            hour12: false, // Use 24-hour format
          }),
        };
      });
      setTransactionDetails(transactionData);
      setIsLoadingData(false); // Stop loading for data
    };

    (async () => {
      await fetchArsBalance();
      await fetchTransactions();
    })();
  }, []);

  useEffect(() => {
    // Fetch balances and transactions in sequence
  }, []);

  return (
    <div className="content text-black h-full dark:text-white">
      {isLoadingData ? (
        <div className="flex justify-center h-full items-center">
          <FaSpinner className="animate-spin text-3xl" />{" "}
          {/* Loading Spinner */}
        </div>
      ) : (
        <>
          <OverviewSection arsBalance={arsBalance} />
          <Container>
            <Grid centered>
              <GridRow>
                <Header as="h1" dividing>
                  Rewards.
                </Header>
                {isLoadingData ? (
                  <Loader
                    active
                    inline="centered"
                    content="Loading Leaderboard..."
                  />
                ) : (
                  <Table celled>
                    <Table.Header>
                      <Table.Row>
                        <Table.HeaderCell>tID.</Table.HeaderCell>
                        <Table.HeaderCell>User.</Table.HeaderCell>
                        <Table.HeaderCell>Amount.</Table.HeaderCell>
                        <Table.HeaderCell>Type.</Table.HeaderCell>
                        <Table.HeaderCell>ARS points.</Table.HeaderCell>
                        <Table.HeaderCell>Timestamp.</Table.HeaderCell>
                      </Table.Row>
                    </Table.Header>

                    <Table.Body>
                      {transactionlist.map((transaction, index) => (
                        <Table.Row key={index}>
                          <Table.Cell>{transaction.transactionid}</Table.Cell>
                          <Table.Cell>
                            {transaction.user.substring(0, 8)}
                          </Table.Cell>
                          <Table.Cell>{transaction.amount}</Table.Cell>
                          <Table.Cell>{transaction.type}</Table.Cell>
                          <Table.Cell>{transaction.balance}</Table.Cell>
                          <Table.Cell>{transaction.timestamp}</Table.Cell>
                        </Table.Row>
                      ))}
                    </Table.Body>
                  </Table>
                )}
              </GridRow>
            </Grid>
          </Container>
        </>
      )}
    </div>
  );
};

export default WalletPage;
