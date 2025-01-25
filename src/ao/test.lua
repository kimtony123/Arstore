-- Function to calculate the weighted airdrop amount based on balances across multiple token process IDs


function calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount)
    local totalBalancesByToken = {} -- To track total balances per token
    local userBalancesByToken = {} -- To track each user's balance for each token
    local userFinalWeights = {} -- To track the final weights for all users
    local weightedAirdropAmount = totalAirdropAmount * 0.8 -- 80% of the total amount to be distributed

    print("Starting calculation of airdrop...")
    print("Qualified Users:", table.concat(qualifiedUsers, ", "))
    print("Token Process IDs:", table.concat(tokenProcessIds, ", "))

    -- Step 2: Fetch balances for all users across all token processes
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        totalBalancesByToken[tokenProcessId] = 0
        userBalancesByToken[tokenProcessId] = {}

        for _, userId in ipairs(qualifiedUsers) do
            -- Fetch balance for the user-token combination
            local balance = getBalance(userId, tokenProcessId)

            -- Debug: Print each fetched balance
            print("Fetched Balance -> User:", userId, "Token Process:", tokenProcessId, "Balance:", balance)

            -- Update balances
            userBalancesByToken[tokenProcessId][userId] = balance
            totalBalancesByToken[tokenProcessId] = totalBalancesByToken[tokenProcessId] + balance
        end
    end

    -- Debug: Log total balances for all token processes
    for tokenProcessId, totalBalance in pairs(totalBalancesByToken) do
        print("Total Balance for Token Process:", tokenProcessId, "is", totalBalance)
    end

    -- Step 4: Calculate each user's final weight across all token processes
    for _, userId in ipairs(qualifiedUsers) do
        userFinalWeights[userId] = 0

        for _, tokenProcessId in ipairs(tokenProcessIds) do
            local userBalance = userBalancesByToken[tokenProcessId][userId] or 0
            local totalBalanceForToken = totalBalancesByToken[tokenProcessId]
            local tokenWeight = 0.25 -- Each token process is weighted equally (25%)

            -- Calculate the weight for this user for this token process
            if totalBalanceForToken > 0 then
                local weight = (userBalance / totalBalanceForToken) * tokenWeight
                userFinalWeights[userId] = userFinalWeights[userId] + weight

                -- Debug: Log the weight calculation
                print("Calculated Weight -> User:", userId, "Token Process:", tokenProcessId, "Weight:", weight)
            else
                print("No balance for Token Process:", tokenProcessId, "Skipping weight calculation.")
            end
        end
    end

    -- Step 6 & 7: Calculate the airdrop amount for each user based on their weight
    for userId, weight in pairs(userFinalWeights) do
        local userAirdropAmount = weight * weightedAirdropAmount

        -- Debug: Log the calculated amount for each user
        print("Airdrop Amount -> User:", userId, "Weight:", weight, "Receives:", userAirdropAmount)

        -- Step 8: Distribute tokens to the user
        distributeTokens(userId, userAirdropAmount)
    end
end

-- Mock function to fetch token balances for a user
function getBalance(userId, tokenProcessId)
    -- Simulated balances for testing
    local mockBalances = {
        ["token1"] = { ["user1"] = 100, ["user2"] = 300, ["user3"] = 600 },
        ["token2"] = { ["user1"] = 200, ["user2"] = 400, ["user3"] = 400 },
        ["token3"] = { ["user1"] = 150, ["user2"] = 250, ["user3"] = 600 },
        ["token4"] = { ["user1"] = 50, ["user2"] = 50, ["user3"] = 300 }
    }
    local balance = mockBalances[tokenProcessId] and mockBalances[tokenProcessId][userId] or 0

    -- Debug: Log the fetched balance
    print("Fetching balance for User:", userId, "Token Process ID:", tokenProcessId, "Balance:", balance)
    return balance
end

-- Mock function to distribute tokens to a user
function distributeTokens(userId, amount)
    if amount > 0 then
        print("Distributed", amount, "tokens to", userId)
    else
        print("No tokens distributed to", userId, "due to zero balance or weight.")
    end
end



-- Run the calculation


Handlers.add('completeAirdropXp', Handlers.utils.hasMatchingTag("Action", "completeAirdropXp"),
  function()
    -- Initialize and define inputs
    local qualifiedUsers = { "user1", "user2", "user3" }
    local tokenProcessIds = { "token1", "token2", "token3", "token4" }
    local totalAirdropAmount = 10000

    -- Debug: Confirm inputs are initialized correctly
    print("Starting Airdrop Calculation")
    print("Qualified Users:", table.concat(qualifiedUsers, ", "))
    ao.send({
        
    })
    print("Token Process IDs:", table.concat(tokenProcessIds, ", "))
    print("Total Airdrop Amount:", totalAirdropAmount)

    -- Call the airdrop calculation function
    calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount)

    -- Debug: Confirm the handler execution is complete
    print("Airdrop Calculation Completed")
  end
)
