import { useEffect } from "react";
import { message, createDataItemSigner } from "@permaweb/aoconnect";
import * as othent from "@othent/kms";

const useCronTick = (process: string) => {
  useEffect(() => {
    const performCronActions = async () => {
      try {
        const signer = createDataItemSigner(othent); // Create Othent signer

        // Step 1: Check expired contracts
        const checkExpiredContracts = await message({
          process,
          tags: [{ name: "Action", value: "Cron" }],
          signer,
        });
        console.log(
          "Expired contracts checked successfully",
          checkExpiredContracts
        );

        // Step 2: Fetch prices to complete trades
        const completeTrade = await message({
          process,
          tags: [{ name: "Action", value: "completeTrade" }],
          signer,
        });
        console.log("Trades completed successfully", completeTrade);

        // Step 3: Close positions
        const closePositions = await message({
          process,
          tags: [{ name: "Action", value: "Close-Positions" }],
          signer,
        });
        console.log("Positions closed successfully", closePositions);
      } catch (error) {
        console.error("Error performing cron actions:", error);
      }
    };

    // Execute the actions sequentially every 100 seconds (adjust if needed)
    const intervalId = setInterval(performCronActions, 1000000);

    return () => clearInterval(intervalId);
  }, [process]);
};

export default useCronTick;
