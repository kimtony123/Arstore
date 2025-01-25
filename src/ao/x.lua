

-- Load the Llama Herder library
Llama = require("@sam/Llama-Herder")


function CreatePrompt(systemPrompt, userContent)
    return [[<|system|>
]] .. systemPrompt .. [[<|end|>
<|user|>
]] .. userContent .. [[<|end|>
<|assistant|>
]]
end




local userContent = "Elon Musk"

local prompt = CreatePrompt(
  "Tell a joke on the given topic",
  userContent
);

JOKE_HISTORY = JOKE_HISTORY or {}

Llama.run(
  prompt,                  -- Your prompt
  2,                      -- Number of tokens to generate
  function(generated_text) -- Optional: A function to handle the response
    -- Match up until the first newline character
    local joke = generated_text:match("^(.-)\n")
  
    print("Joke: " .. joke)
    table.insert(JOKE_HISTORY, joke)
  end
)





Handlers.add(
    "getOpenTrades",
    Handlers.utils.hasMatchingTag("Action", "getOpenTrades"),
    function(m)
        local userId = m.Tags.userId
        local AppId = m.Tags.AppId
        local TableType = m.Tags.TableType

        if not AppId then
            ao.send({ Target = m.From, Data = "AppId is required." })
            return
        end
        
        print("UserId" .. userId .. "is this")
        print("appID" .. AppId .. "is this")
        print("TableType".. TableType .. "is this" )

        if not userId then
            ao.send({Target = m.From, Data = "UserId is required."})
            return
        end

        if not TableType then
            ao.send({Target = m.From, Data = "DataType is required."})
            return
        end

        -- Placeholder for the actual data source
        local reviewsTable = {
            -- Example data structure
            ["1"] = {id = 1, AppId = AppId, userId = userId, TableType = TableType},
            ["2"] = {id = 2, AppId = AppId, userId = userId, TableType = TableType}
        }

        ao.send({
            Target = m.From, -- Reply to the sender
            Action = "openTradesResponse",
            Data = json.encode(reviewsTable)
        })
    end
)



local json = require("json")
local math = require("math")

-- Function to get the current time in milliseconds
function getCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end



-- Function to get the balance of a specific user for a specific token
function getBalance(userId, tokenProcessId)
    local balance = 0

    -- Send the request for the balance
    ao.send({
        Target = tokenProcessId,
        Tags = {
            Action = "Balance",
            Target = userId
        }
    })

    -- Iterate through the Inbox to find the correct response
    for i = #Inbox, 1, -1 do -- Start from the latest message
        local message = Inbox[i]
        if message.Target == tokenProcessId and message.Data then
            balance = message.Data -- Extract and convert the balance
            print("This is your balance: " .. balance)
            return balance
        end
    end

    -- If no matching message is found, return 0 or an error message
    print("Balance not found for tokenProcessId: " .. tokenProcessId)
    return balance
end









-- Function to calculate the weighted amount based on balances of four assets
function calculateWeightedAmount(userId, tokenProcessIds, totalAirdropAmount)
    local totalBalance = 0
    local weights = {}
    local individualBalances = {}

    -- Fetch balances for each token
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        local balance = getBalance(userId, tokenProcessId)
        table.insert(individualBalances, balance)
        totalBalance = totalBalance + balance
    end

    -- Calculate weights for each asset (balance / totalBalance)
    for _, balance in ipairs(individualBalances) do
        local weight = (totalBalance > 0) and (balance / totalBalance) or 0
        table.insert(weights, weight)
    end

    -- Calculate the airdrop amount for this user (80% of total based on weights)
    local weightedAmount = 0
    for i, weight in ipairs(weights) do
        weightedAmount = weightedAmount + (weight * totalAirdropAmount * 0.8)
    end

    return weightedAmount
end





  Handlers.add('calculateAmount', Handlers.utils.hasMatchingTag("Action", "getBalance"),
  function() 
   local userId = "YFTAMEk2OebK84ZuqG94h81VpjSfzyzTV6Mvzk4HL8M"
   local tokenProcessId = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"
    calculateWeightedAmount(userId, tokenProcessIds, totalAirdropAmount)
  end)



  Handlers.add('getBalance', Handlers.utils.hasMatchingTag("Action", "getBalance"),
  function() 
   local userId = "YFTAMEk2OebK84ZuqG94h81VpjSfzyzTV6Mvzk4HL8M"
   local tokenProcessId = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"
    getBalance(userId,tokenProcessId) 
  end)





Handlers.add(
    "completeAirdrops",
    Handlers.utils.hasMatchingTag("Action", "completeAirdrops"),
    function(m)
        local user = m.From
        local currentTime = getCurrentTime(m)
        local tokenProcessIds = { "token1", "token2", "token3", "token4" } -- Replace with actual process IDs

        -- Step 1: Look for all expired airdrops
        local expiredAirdrops = {}
        for appId, appData in pairs(airdropTable) do
            for _, airdrop in ipairs(appData.airdrops or {}) do
                if airdrop.endTime and tonumber(airdrop.endTime) <= currentTime then
                    table.insert(expiredAirdrops, airdrop)
                end
            end
        end

        -- Step 2: Process each expired airdrop
        for _, airdrop in ipairs(expiredAirdrops) do
            local eligibleReceivers = {}

            -- Step 3: Validate receivers and calculate airdrop amount
            for receiverId, receiverData in pairs(airdrop.airdropsReceivers or {}) do
                if receiverData.time and tonumber(receiverData.time) >= tonumber(airdrop.startTime) 
                        and tonumber(receiverData.time) <= tonumber(airdrop.endTime) then                    table.insert(eligibleReceivers, {
                        userId = receiverId})
                end
            end



            -- Mark the airdrop as completed and log results
            airdrop.status = "Completed"
            print("Airdrop completed for ID: " .. airdrop.airdropId)
        end
    end
)
