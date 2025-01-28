import React, { useState, useEffect } from "react";
import * as othent from "@othent/kms";
import { message, createDataItemSigner, result } from "@permaweb/aoconnect";
import { useNavigate } from "react-router-dom";
import Footer from "../../components/footer/Footer";
import { FaSpinner } from "react-icons/fa"; // Spinner Icon
import OverviewSection from "../../components/walletOverview/WalletOverview";
import {
  Button,
  Container,
  Divider,
  Grid,
  GridColumn,
  GridRow,
  Header,
  Loader,
  Table,
  Form,
  FormSelect,
  FormField,
  Input,
  DropdownProps,
  Statistic,
  StatisticLabel,
  StatisticValue,
  Image,
} from "semantic-ui-react";

const WalletPage: React.FC = () => {
  const ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18";
  const AOS = "KdSVyVyL72FskV8f3jfW3SCI8PV5d8LDvYBhcYqVYzg";
  interface Tag {
    name: string;
    value: string;
  }

  interface Transaction {
    user: string;
    transactionid: string;
    amount: number;
    type: string;
    balance: number;
    timestamp: string;
  }

  const [arsBalance, setArsBalance] = useState(0);
  const [arsPoints, setArsPoints] = useState(0);
  const [bcatBalance, setbcatBalance] = useState(0);

  const [receiverAddress, setReceiversAddress] = useState("");
  const [amount, setAmount] = useState("");
  const [transactionlist, setTransactionDetails] = useState<Transaction[]>([]);

  const updateOptions = [
    {
      key: "1",
      text: "AOS",
      value: "KdSVyVyL72FskV8f3jfW3SCI8PV5d8LDvYBhcYqVYzg",
    },
    {
      key: "2",
      text: "BenCat",
      value: "5d91yO7AQxeHr3XNWIomRsfqyhYbeKPG2awuZd-EyH4",
    },
  ];
  const [isLoadingData, setIsLoadingData] = useState(true); // New loading state for fetching data
  const [isLoadingArsPoints, setIsLoadingArsPoints] = useState(true);
  const [isLoadingBcatBalance, setIsLoadingBcatBalance] = useState(true);

  const [transfer, setTransfer] = useState(false);

  const navigate = useNavigate();

  const [projectTypeValue, setProjectTypeValue] = useState<
    string | undefined
  >();
  const [selectedProjectType, setSelectedProjectType] = useState<
    string | undefined
  >(undefined);

  const handleProjectTypeChange = (
    _: React.SyntheticEvent<HTMLElement, Event>,
    data: DropdownProps
  ) => {
    const value = data.value as string | undefined;
    setProjectTypeValue(value);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    switch (name) {
      case "receiver":
        setReceiversAddress(value);
        break;
      case "amount":
        setAmount(value);
        break;
      default:
        break;
    }
  };

  useEffect(() => {
    const fetchArsBalance = async () => {
      try {
        setIsLoadingData(true); // Start loading for data
        // Fetch AOC balance first
        const aocMessageResponse = await message({
          process: AOS,
          tags: [{ name: "Action", value: "Balance" }],
          signer: createDataItemSigner(othent),
        });

        const aocResult = await result({
          message: aocMessageResponse,
          process: AOS,
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
        setIsLoadingData(false);
      }
    };

    const fetchBcatBalance = async () => {
      const BCAT = "5d91yO7AQxeHr3XNWIomRsfqyhYbeKPG2awuZd-EyH4";
      try {
        setIsLoadingBcatBalance(true); // Start loading for data
        // Fetch AOC balance first
        const aocMessageResponse = await message({
          process: BCAT,
          tags: [{ name: "Action", value: "Balance" }],
          signer: createDataItemSigner(othent),
        });

        const aocResult = await result({
          message: aocMessageResponse,
          process: BCAT,
        });

        if (!aocResult.Error) {
          const aocBalanceTag = aocResult.Messages?.[0].Tags.find(
            (tag: Tag) => tag.name === "Balance"
          );
          setbcatBalance(aocBalanceTag?.value);
        }
      } catch (error) {
        console.error("Error fetching balances or transactions:", error);
      } finally {
        setIsLoadingBcatBalance(false);
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
          amount: typedDetails.amount,
          type: typedDetails.type,
          balance: typedDetails.balance,
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

    const fetchArsPoints = async () => {
      setIsLoadingArsPoints(true);
      try {
        const getTradeMessage = await message({
          process: ARS,
          tags: [{ name: "Action", value: "FetchArsPoints" }],
          signer: createDataItemSigner(othent),
        });
        const { Messages, Error } = await result({
          message: getTradeMessage,
          process: ARS,
        });

        if (Error) {
          alert("Error Getting ArsPoints:" + Error);
          return;
        }
        if (!Messages || Messages.length === 0) {
          alert("No messages were returned from ao. Please try later.");
          return;
        }
        const data = Messages[0].Data;
        setArsPoints(data);
      } catch (error) {
        alert("There was an error in the fetch process: " + error);
        console.error(error);
      } finally {
        setIsLoadingArsPoints(false);
      }
    };

    (async () => {
      await fetchArsBalance();
      await fetchTransactions();
      await fetchArsPoints();
      await fetchBcatBalance();
    })();
  }, []);
  useEffect(() => {
    // Fetch balances and transactions in sequence
  }, []);

  const TransferTokens = async () => {
    setTransfer(true);
    const value = parseInt(amount);
    const Amount = value * 1000000000000;
    try {
      const getTradeMessage = await message({
        process: projectTypeValue,
        tags: [
          { name: "Action", value: "Transfer" },
          { name: "Recipient", value: String(receiverAddress) },
          { name: "Quantity", value: String(Amount) },
        ],

        signer: createDataItemSigner(othent),
      });
      const { Messages, Error } = await result({
        message: getTradeMessage,
        process: projectTypeValue,
      });

      if (Error) {
        alert("Error Updating Project:" + Error);
        return;
      }
      if (!Messages || Messages.length === 0) {
        alert("No messages were returned from ao. Please try later.");
        return;
      }
      const data = Messages[0].Data;
      alert(data);
      setReceiversAddress("");
      setAmount("");
    } catch (error) {
      alert("There was an error in the trade process: " + error);
      console.error(error);
    } finally {
      setTransfer(false);
    }
  };

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
              <Grid columns="equal">
                <GridColumn textAlign="left">
                  <Statistic>
                    <Image
                      size="small"
                      src="AO.png"
                      className="circular inline"
                    />
                    <StatisticValue>
                      {" "}
                      {(arsBalance * 0.000000000001).toFixed(1)}
                    </StatisticValue>
                  </Statistic>
                </GridColumn>
                <GridColumn textAlign="right">
                  <Statistic>
                    <Image
                      size="small"
                      src="Bcat.jpg"
                      className="circular inline"
                    />

                    <StatisticValue>
                      {(bcatBalance * 0.000000000001).toFixed(1)}
                    </StatisticValue>
                  </Statistic>
                </GridColumn>
              </Grid>

              <Divider />
              <GridRow>
                <Header textAlign="center" as="h4">
                  {" "}
                  Transfer Tokens.{" "}
                </Header>
              </GridRow>
              <GridRow>
                <Form>
                  <FormField required>
                    <label>Token</label>
                    <FormSelect
                      options={updateOptions}
                      placeholder="Token"
                      value={selectedProjectType}
                      onChange={handleProjectTypeChange}
                    />
                  </FormField>
                  <FormField required>
                    <label>Receivers Address.</label>
                    <Input
                      type="text"
                      name="receiver"
                      value={receiverAddress}
                      onChange={handleInputChange}
                      placeholder="Receivers Address. "
                    />
                  </FormField>
                  <FormField required>
                    <label>Amount</label>
                    <Input
                      type="number"
                      name="amount"
                      value={amount}
                      onChange={handleInputChange}
                      placeholder="Amount"
                    />
                  </FormField>
                  <Button
                    loading={transfer}
                    color="green"
                    onClick={() => TransferTokens()}
                  >
                    {" "}
                    Transfer Token.
                  </Button>
                </Form>
              </GridRow>
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
                          <Table.Cell>
                            {(transaction.amount * 0.000000000001).toFixed(1)}
                          </Table.Cell>
                          <Table.Cell>{transaction.type}</Table.Cell>
                          <Table.Cell>{transaction.timestamp}</Table.Cell>
                        </Table.Row>
                      ))}
                    </Table.Body>
                  </Table>
                )}
              </GridRow>
            </Grid>
          </Container>
          <Footer />
        </>
      )}
    </div>
  );
};

export default WalletPage;
