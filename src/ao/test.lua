-- Function to get balances for all qualified users across token process IDs
function getBalances(qualifiedUsers, tokenProcessIds)
    local balances = {}

    -- Initialize balances structure
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        balances[tokenProcessId] = {}
    end

    -- Loop through users and tokens to fetch balances
    for _, userId in ipairs(qualifiedUsers) do
        for _, tokenProcessId in ipairs(tokenProcessIds) do
            -- Send the request for the balance
            ao.send({
                Target = tokenProcessId,
                Tags = {
                    Action = "Balance",
                    Target = userId
                }
            })

            -- Wait for the response to populate the Inbox (optional delay for async handling)
            os.execute("sleep 0.1") -- Small delay to ensure Inbox is populated

            -- Check Inbox for response
            local balance = 0
            local foundResponse = false
            for i = #Inbox, 1, -1 do -- Start from the latest message
                local message = Inbox[i]
                if message.Target == tokenProcessId and message.Tags and message.Tags.Target == userId then
                    if message.Data then
                        balance = tonumber(message.Data) or 0 -- Extract and convert the balance
                        foundResponse = true
                    end
                    break
                end
            end

            if not foundResponse then
                print(string.format("No balance found for User: %s, Token: %s", userId, tokenProcessId))
            else
                print(string.format("Fetched Balance -> Token: %s, User: %s, Balance: %d", tokenProcessId, userId, balance))
            end

            -- Save balance in the balances table
            balances[tokenProcessId][userId] = balance
        end
    end

    return balances
end

-- Handler to call the getBalances function and log results
Handlers.add('getBalance', Handlers.utils.hasMatchingTag("Action", "getBalance"),
  function()
    -- Initialize and define inputs
    local qualifiedUsers = {
        "YFTAMEk2OebK84ZuqG94h81VpjSfzyzTV6Mvzk4HL8M",
        "i0PITA1jhOWA_PIb-Zqk5N9JzcQibDJDHDOpr0yqZIM",
        "xLCweWomoFQvOlO9nD2zYxghAgIGljoCaeYNVCO2nhA"
    }
    local tokenProcessIds = {
        "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18",
        "5d91yO7AQxeHr3XNWIomRsfqyhYbeKPG2awuZd-EyH4"
    }

    -- Fetch balances
    local balances = getBalances(qualifiedUsers, tokenProcessIds)

    -- Debug: Log the final balances structure
    for tokenId, userBalances in pairs(balances) do
        print("Token ID: " .. tokenId)
        for userId, balance in pairs(userBalances) do
            print(string.format("User: %s, Balance: %d", userId, balance))
        end
    end
  end
)
