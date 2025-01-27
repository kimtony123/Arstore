

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




local json = require("json")
local math = require("math")


-- Credentials token
ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"
AOSAI = "7wea_1MSDmZMm1Om9N8vdrkay9V9O8vscmSVO-2XdEY"


Apps =  Apps or {}
reviewsTable = reviewsTable or {}
upvotesTable = upvotesTable or {}
downvotesTable = downvotesTable or {}
featureRequestsTable = featureRequestsTable or {}
bugsReportsTable = bugsReportsTable or {}
favoritesTable =  favoritesTable or {}
ratingsTable = ratingsTable or  {}
helpfulRatingsTable = helpfulRatingsTable or {}
unHelpfulRatingsTable = unHelpfulRatingsTable or  {}
flagTable = flagTable or {}
verifiedUsers = verifiedUsers or {}
transactions = transactions or {}
taskTable = taskTable or {}
points = points or {}
airdropTable = airdropTable or {}
arsPoints = arsPoints or {}
newTable = newTable or {}
inboxTable = inboxTable or {}
devForumTable = devForumTable or {}
AppCounter  = AppCounter or 0
ReviewCounter = ReviewCounter or 0
ReplyCounter = ReplyCounter or 0
AidropCounter = AidropCounter or 0
transactionCounter  = transactionCounter or 0
DevForumCounter = DevForumCounter or 0
TableIdCounter = TableIdCounter or 0
NewTableCounter = NewTableCounter or 0
TasksCounter = TasksCounter or 0

-- Function to get the current time in milliseconds
function getCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end


-- Function to generate a unique App ID
function generateAppId()
    AppCounter = AppCounter + 1
    return "TX" .. tostring(AppCounter)
end


-- Function to generate a unique review ID
function generateReviewId()
    ReviewCounter = ReviewCounter + 1
    return "TX" .. tostring(ReviewCounter)
end

-- Function to generate a unique transaction ID
function generateTransactionId()
    transactionCounter = transactionCounter + 1
    return "TX" .. tostring(transactionCounter)
end

-- Function to generate a unique transaction ID
function generateReplyId()
    ReplyCounter = ReplyCounter + 1
    return "TX" .. tostring(ReplyCounter)
end

-- Function to generate a unique transaction ID
function generateReplyId()
    ReplyCounter = ReplyCounter + 1
    return "TX" .. tostring(ReplyCounter)
end

-- Function to generate a unique transaction ID
function generateAirdropId()
    AidropCounter = AidropCounter + 1
    return "TX" .. tostring(AidropCounter)
end

-- Function to generate a unique Dev forum ID
function generateDevForumId()
    DevForumCounter = DevForumCounter + 1
    return "TX" .. tostring(DevForumCounter)
end

-- Function to generate a unique bug ID
function generateTableId()
    TableIdCounter = TableIdCounter + 1
    return "TX" .. tostring(TableIdCounter)
end

-- Function to generate a unique NEW UPDATE ID
function generateNewUpdateId()
    NewTableCounter = NewTableCounter + 1
    return "TX" .. tostring(NewTableCounter)
end

-- Function to generate a unique NEW Task ID
function generateTaskId()
    TasksCounter = TasksCounter + 1
    return "TX" .. tostring(TasksCounter)
end


function tableToJson(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        local valueType = type(value)
        if valueType == "table" then
            value = tableToJson(value)
            table.insert(result, string.format('"%s":%s', key, value))
        elseif valueType == "string" then
            table.insert(result, string.format('"%s":"%s"', key, value))
        elseif valueType == "number" then
            table.insert(result, string.format('"%s":%d', key, value))
        elseif valueType == "function" then
            table.insert(result, string.format('"%s":"%s"', key, tostring(value)))
        end
    end

    local json = "{" .. table.concat(result, ",") .. "}"
    return json
end


-- Fetch the user's points data safely
 function getOrInitializeUserPoints(user)
    -- Ensure arsPoints is initialized
    arsPoints = arsPoints or {}

    -- Check if the user already exists in arsPoints
    if not arsPoints[user] then
        arsPoints[user] = { user = user, points = 0 }
    end

    -- Return the user's data
    return arsPoints[user]
end


function generateRatingsChart(ratingsTableEntry)
    -- Initialize a table to store the ratings count
    local ratingsData = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0 }

    -- Ensure countHistory exists and process it
    if ratingsTableEntry and ratingsTableEntry.countHistory then
        for _, record in ipairs(ratingsTableEntry.countHistory) do
            -- Validate and update ratings
            local rating = record.rating
            if ratingsData[rating] ~= nil then
                ratingsData[rating] = ratingsData[rating] + 1
            else
                print("Invalid rating found:", rating)
            end
        end
    else
        print("Invalid or missing countHistory in ratingsTableEntry")
    end

    return ratingsData
end



-- Function to get the balance of a specific user for a specific token
function getBalance(userId, tokenProcessId)
    local balance = 0

    -- Simulating a handler call to fetch balance
    Handlers.call("balance", {
        Tags = { Recipient = userId, Target = tokenProcessId },
        reply = function(response)
            if response and response.Balance then
                balance = tonumber(response.Balance) or 0
            end
        end
    })

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




Handlers.add(
    "AddApp",
    Handlers.utils.hasMatchingTag("Action", "AddApp"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppName", "description", "protocol", "websiteUrl", "twitterUrl",
            "discordUrl", "coverUrl", "banner1Url", "banner2Url", "banner3Url",
            "banner4Url", "companyName", "appIconUrl", "projectType", "username", "profileUrl"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local currentTime = getCurrentTime(m)
        local AppId = generateAppId()
        local ReviewId = generateReviewId()
        local replyId = generateReplyId()
        local tableId = generateTableId()
        local devForumId = generateDevForumId()
        local newTableId = generateNewUpdateId()
        local taskId = generateTaskId()
        local airdropId = generateAirdropId()
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl

        -- Initialize tables for the app
        reviewsTable[AppId] = {
        reviews = {
                {
                    reviewId = ReviewId,
                    user = user,
                    username = username,
                    comment = "Great app!",
                    rating = 5,
                    timestamp = currentTime,
                    profileUrl = profileUrl,
                    voters = {
                                upvoted = {
                                    count = 1,
                                    countHistory = { {  time = currentTime, count = 1 } },
                                    users = {[user] = { time = currentTime }}
                                    },
                                downvoted = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = { time = currentTime }}},
                                foundHelpful = { 
                                    count = 1,
                                    countHistory = { { time = currentTime, count = 1 } },
                                    users = {[user] = { time = currentTime }} },
                            
                                foundUnhelpful = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = { time = currentTime }}}
                                
                                },
                    replies = {
                        {
                            replyId = replyId,
                            user = user,
                            profileUrl = profileUrl,
                            username = username,
                            comment = "Thank you for your feedback!",
                            timestamp = currentTime,
                        }
                    }
                } },
                count = 1,
                countHistory = { { time = currentTime, count = 1 } },
                users = {[user] = { time = currentTime }} 
        }

        upvotesTable[AppId] = {
        count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { time = currentTime }
            }
        }

        downvotesTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { time = currentTime }
            }
        }

        featureRequestsTable[AppId] = {
            requests = {{
            TableId = tableId,
            user = user,
            time = currentTime,
            profileUrl = profileUrl,
            username = username,
            comment =" Add AI",
            replies = {
                        {
                            replyId = replyId,
                            user = user,
                            profileUrl = profileUrl,
                            username = username,
                            comment = "We will Add that feature soon",
                            timestamp = currentTime,
                        }
                    },
            }},
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { time = currentTime }},
        }

        bugsReportsTable[AppId] = {
            requests = {{
            TableId = tableId,
            user = user,
            profileUrl = profileUrl,
            time = currentTime,
            username = username,
            comment ="Change the UI",
            replies = {
                        {
                            replyId = replyId,
                            user = user,
                            profileUrl = profileUrl,
                            username = username,
                            comment = "We will Start working on that Bug Asap.",
                            timestamp = currentTime,
                        }
                    },

            } },
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {[user] = { time = currentTime}},
           
        }

        airdropTable[AppId] = {
            airdrops = {{
            airdropId = airdropId,
            Owner = user,
            appId = AppId,
            tokenId = ARS,
            amount = 5,
            timestamp = currentTime,
            appname = m.Tags.AppName,
            status = "Pending",
            airdropsReceivers = "reviewsTable",
            startTime = currentTime,
            endTime = currentTime + 3600,
            Description = "Review and rate Our project between today and 8th Febraury and Earn tokens"
            } },
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {[user] = { time = currentTime}},
           
        }
            
        devForumTable[AppId] = {
            requests = {{
            devForumId = devForumId,
            user = user,
            time = currentTime,
            profileUrl = profileUrl,
            username = username,
            comment ="Hey How Do I get started on aocomputer?",
            header = "Integration and Dependencies",
            replies = {
                        {
                            replyId = replyId,
                            user = user,
                            profileUrl = profileUrl,
                            username = username,
                            comment = "Hey, Here is a link to get you started.",
                            timestamp = currentTime,                        }
                    },
            }},
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {[user] = { time = currentTime}},
            }
            
        favoritesTable[AppId] = {
         count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { time = currentTime }
            }
           
        }

        ratingsTable[AppId] = {
            Totalratings = 5,
            count = 1,
            countHistory = { { time = currentTime, count = 1 , rating = 5} },
            users = {
                [user] = { time = currentTime }
            }
        }

        helpfulRatingsTable[AppId] = {
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { time = currentTime }
            }
        }

        unHelpfulRatingsTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { time = currentTime }
            }
        }

        flagTable[AppId] = {
           count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { time = currentTime }
            }
        }

        newTable[AppId] = {
            requests = {{
            newTableId = newTableId,
            comment = "Launched on aostore",
            }},
            count = 1,
            countHistory = { { time = currentTime, count = 1} },
            users = {[user] = { time = currentTime }},
            currentTime = currentTime
        }
         taskTable[AppId] = {
            requests = {{
            taskId = taskId,
            link = "https://x.com/aoTheComputer",
            task = "Follow , Retweet and Like our twitter page",
            comment = "Launched on aostore",
            }},
            count = 1,
            status = true,
            countHistory = { { time = currentTime, count = 1} },
            users = {[user] = { time = currentTime }},
            currentTime = currentTime
        }

        local ratingsChart = generateRatingsChart(ratingsTable[AppId])

        -- Create the App record
        Apps[AppId] = {
            AppId = AppId,
            Owner = user,
            OwnerUserName = username,
            AppName = m.Tags.AppName,
            Description = m.Tags.description,
            Protocol = m.Tags.protocol,
            WebsiteUrl = m.Tags.websiteUrl,
            TwitterUrl = m.Tags.twitterUrl,
            DiscordUrl = m.Tags.discordUrl,
            CoverUrl = m.Tags.coverUrl,
            profileUrl = profileUrl,
            BannerUrl1 = m.Tags.banner1Url,
            BannerUrl2 = m.Tags.banner2Url,
            BannerUrl3 = m.Tags.banner3Url,
            BannerUrl4 = m.Tags.banner4Url,
            CompanyName = m.Tags.companyName,
            AppIconUrl = m.Tags.appIconUrl,
            ProjectType = m.Tags.projectType,
            CreatedTime = currentTime,
            Reviews = reviewsTable[AppId],
            Ratings = ratingsTable[AppId],
            TotalRatings = ratingsTable[AppId],
            Upvotes = upvotesTable[AppId],
            Downvotes = downvotesTable[AppId],
            Favorites = favoritesTable[AppId],
            HelpfulRatings = helpfulRatingsTable[AppId],
            UnHelpfulRatings = unHelpfulRatingsTable[AppId],
            FeatureRequests = featureRequestsTable[AppId],
            BugsReports = bugsReportsTable[AppId],
            FlagTable = flagTable[AppId],
            WhatsNew = newTable[AppId],
            LastUpdated = newTable[AppId],
            DeveloperActivity = devForumTable[AppId],
            RatingsChart = ratingsChart
        }

        local points = 100
        -- Ensure arsPoints[user] is initialized
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
            -- Update points
        arsPoints[user].points = arsPoints[user].points + points
        -- Safely access points
        
        local amount = 10
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        local transactionId = generateTransactionId()
        local currentPoints = arsPoints[user].points
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "App Creation",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging: Print the Apps table
        print("Apps table after update: " .. tableToJson(Apps))

        -- Send success message
        ao.send({ Target = m.From, Data = "Successfully Created The Project." })
    end
)


Handlers.add(
    "AddAddress",
    Handlers.utils.hasMatchingTag("Action", "AddAddress"),
    function(m)
        local userId = m.From
        local currentTime = getCurrentTime(m)

        -- Validate input
        if not userId then
            ao.send({ Target = m.From, Data = "userId is missing." })
            return
        end


           -- Check if the user already exists in the verifiedUsers list
        if verifiedUsers.users[userId] then
            ao.send({ Target = m.From, Data = "Welcome back, user: " .. userId })
            return
        end
        
        -- Add the new user to the verifiedUsers table
        verifiedUsers.users[userId] = {
            time = currentTime
        }

        -- Increment the count of verified users
        verifiedUsers.count = verifiedUsers.count + 1

        -- Update the countHistory
        table.insert(verifiedUsers.countHistory, { time = currentTime, count = verifiedUsers.count })

        -- Confirm the address has been added
        ao.send({ Target = m.From, Data = "Address added successfully for new user: " .. userId })
    end
)


Handlers.add(
    "GetProjectTypesAo",
    Handlers.utils.hasMatchingTag("Action", "GetProjectTypesAo"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = { "ProjectType", "Protocol" }

        for _, tag in ipairs(requiredTags) do
            if not m.Tags[tag] or m.Tags[tag] == "" then
                print("Error: " .. tag .. " is nil or empty.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        -- Extract projectType and protocol from m.Tags
        local projectType = m.Tags.ProjectType
        local protocol = m.Tags.Protocol
        print(projectType)
        print(protocol)
        -- Initialize a table to store filtered results
        local filteredApps = {}

        -- Loop through the Apps table and filter based on projectType and protocol
        for AppId, appDetails in pairs(Apps) do
            if appDetails.ProjectType == projectType and appDetails.Protocol == protocol then
                -- Include only relevant fields in the response
                filteredApps[AppId] = {
                    AppId = appDetails.AppId,
                    AppName = appDetails.AppName,
                    CompanyName = appDetails.CompanyName,
                    WebsiteUrl = appDetails.WebsiteUrl,
                    ProjectType = appDetails.ProjectType,
                    Protocol = appDetails.Protocol,
                    AppIconUrl = appDetails.AppIconUrl
                }
            end
        end

        -- Check if any apps were found
        if next(filteredApps) == nil then
            ao.send({ Target = m.From, Data = {} })
        else
            -- Send the filtered apps as a response
            ao.send({ Target = m.From, Data = tableToJson(filteredApps) })
        end
    end
)

Handlers.add(
    "DeleteApp",
    Handlers.utils.hasMatchingTag("Action", "DeleteApp"),
    function(m)
        -- Check if the required AppId tag is present
        if not m.Tags.AppId or m.Tags.AppId == "" then
            print("Error: AppId is nil or empty.")
            ao.send({ Target = m.From, Data = "AppId is missing or empty." })
            return
        end

        local appId = m.Tags.AppId

        -- Check if the app exists
        if not Apps[appId] then
            print("Error: App with AppId " .. appId .. " not found.")
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Get the app owner
        local appOwner = Apps[appId].Owner

        -- Check if the caller is the app owner or the process admin
        if m.From == appOwner or m.From == env.Process.Id then
            -- Delete the app from the Apps table
            Apps[appId] = nil

            -- Delete the app's data from associated tables
            reviewsTable[appId] = nil
            upvotesTable[appId] = nil
            downvotesTable[appId] = nil
            featureRequestsTable[appId] = nil
            bugsReportsTable[appId] = nil
            favoritesTable[appId] = nil
            ratingsTable[appId] = nil
            helpfulRatingsTable[appId] = nil
            unHelpfulRatingsTable[appId] = nil
            flagTable[appId] = nil
            devForumTable[appId] = nil
            newTable[appId] = nil
            airdropTable[appId] = nil
            taskTable[appId] = nil
            -- Send success message
            ao.send({ Target = m.From, Data = "Successfully deleted the app, all associated data, and airdrops." })
        else
            -- If the caller is not the owner or admin, send an error message
            print("Unauthorized delete attempt by " .. m.From)
            ao.send({ Target = m.From, Data = "You are not the app owner or admin." })
        end
    end
)


Handlers.add(
    "AppInfo",
    Handlers.utils.hasMatchingTag("Action", "AppInfo"),
    function(m)
        -- Check if the required AppId tag is present
        if not m.Tags.AppId or m.Tags.AppId == "" then
            print("Error: AppId is nil or empty.")
            ao.send({ Target = m.From, Data = "AppId is missing or empty." })
            return
        end

        -- Extract the AppId from the message
        local AppId = m.Tags.AppId

        -- Check if the Apps table exists and contains the requested AppId
        if not Apps or next(Apps) == nil or not Apps[AppId] then
            print("App with AppId " .. AppId .. " not found.")
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Fetch the app details
        local appDetails = Apps[AppId]

        -- Prepare the response with all relevant app details
        local AppInfoResponse = {
            AppId = appDetails.AppId,
            AppName = appDetails.AppName,
            Description = appDetails.Description,
            Protocol = appDetails.Protocol,
            WebsiteUrl = appDetails.WebsiteUrl,
            TwitterUrl = appDetails.TwitterUrl,
            DiscordUrl = appDetails.DiscordUrl,
            CoverUrl = appDetails.CoverUrl,
            CompanyName = appDetails.CompanyName,
            AppIconUrl = appDetails.AppIconUrl,
            Reviews =  appDetails.Reviews,
            Ratings = appDetails.Ratings,
            RatingsCount = appDetails.RatingsCount,
            Upvotes = appDetails.Upvotes,
            Downvotes = appDetails.Downvotes,
            FeatureRequests = appDetails.FeatureRequests,
            BugsReports = appDetails.BugsReports,
            ProjectType = appDetails.ProjectType,
            CreatedTime = appDetails.CreatedTime,
            Favorites = appDetails.Favorites,
            Flags = appDetails.FlagTable,
            HelpfulRatings = appDetails.HelpfulRatings,
            UnHelpfulRatings = appDetails.UnHelpfulRatings,
            WhatsNew = appDetails.WhatsNew,
            BannerUrl1 = appDetails.BannerUrl1,
            BannerUrl2 = appDetails.BannerUrl2,
            BannerUrl3 = appDetails.BannerUrl3,
            BannerUrl4 = appDetails.BannerUrl4,
            LastUpdated = appDetails.LastUpdated,
            RatingsChart = appDetails.RatingsChart
        }

        -- Send the app info as a JSON response
        ao.send({ Target = m.From, Data = tableToJson(AppInfoResponse) })

        -- Debugging: Print the app info to the console
        print("App Info for AppId " .. AppId .. ": " .. tableToJson(AppInfoResponse))
    end
)



Handlers.add(
    "FetchAppReviews",
    Handlers.utils.hasMatchingTag("Action", "FetchAppReviews"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the reviews table
        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "No reviews found for this app." })
            return
        end

        -- Fetch the reviews
        local appReviews = reviewsTable[appId].reviews

        -- Check if there are reviews
        if not appReviews or #appReviews == 0 then
            ao.send({ Target = m.From, Data = "No reviews available for this app." })
            return
        end

        -- Convert reviews to JSON for sending
        local reviewsJson = tableToJson(appReviews)

        -- Send the reviews back to the user
        ao.send({
            Target = m.From,
            Data = reviewsJson
        })
    end
)

Handlers.add(
    "FetchAppFeatureRequests",
    Handlers.utils.hasMatchingTag("Action", "FetchAppFeatureRequests"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the feature requests table
        if not featureRequestsTable[appId] then
            ao.send({ Target = m.From, Data = "No feature requests found for this app." })
            return
        end

        -- Fetch the feature requests
        local featureRequests = featureRequestsTable[appId].requests

        -- Check if there are feature requests
        if not featureRequests or #featureRequests == 0 then
            ao.send({ Target = m.From, Data = "No feature requests available for this app." })
            return
        end

        -- Convert feature requests to JSON for sending
        local featureRequestsJson = tableToJson(featureRequests)

        -- Send the feature requests back to the user
        ao.send({
            Target = m.From,
            Data = featureRequestsJson
        })
    end
)


Handlers.add(
    "FetchAppBugReports",
    Handlers.utils.hasMatchingTag("Action", "FetchAppBugReports"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the bug reports table
        if not bugsReportsTable[appId] then
            ao.send({ Target = m.From, Data = "No bug reports found for this app." })
            return
        end

        -- Extract the bug report entry for the given appId
        local bugReport = bugsReportsTable[appId].requests

        -- Ensure that the bug report contains the expected fields
        if not bugReport.comment or not bugReport.time then
            ao.send({ Target = m.From, Data = "Incomplete bug report data for this app." })
            return
        end

        -- Collect the relevant fields into a structured table
        local reportData = {
            appId = appId,
            bugReportId = bugReport.bugReportId,
            user = bugReport.user,
            comment = bugReport.comment,
            time = bugReport.time,
            count = bugReport.count,
            username = bugReport.username,
            profileUrl = bugReport.profileUrl,
            replies = bugReport.replies,
        }

        -- Convert the data to JSON
        local reportJson = tableToJson(reportData)

        -- Send the bug report back to the user
        ao.send({
            Target = m.From,
            Data = reportJson
        })
    end
)


Handlers.add(
    "getFavoriteApps",
    Handlers.utils.hasMatchingTag("Action", "getFavoriteApps"),
    function(m)
        local filteredFavorites = {}

        -- Loop through the favoritesTable to find the user's favorites
        for AppId, favorite in pairs(favoritesTable) do
            -- Check if the user exists in the `users` table for the current AppId
            if favorite.users[m.From] then
                -- Retrieve the app details from the Apps table
                local appDetails = Apps[AppId]
                if appDetails then
                    -- Format the app details to include only the required fields
                    filteredFavorites[AppId] = {
                        AppIconUrl = appDetails.AppIconUrl,
                        AppId = AppId,
                        AppName = appDetails.AppName,
                        CompanyName = appDetails.CompanyName,
                        ProjectType = appDetails.ProjectType,
                        WebsiteUrl = appDetails.WebsiteUrl
                    }
                end
            end
        end

        -- Send the filtered favorites back to the user
        ao.send({ Target = m.From, Data = tableToJson(filteredFavorites) })
    end
)



Handlers.add(
    "getMyApps",
    Handlers.utils.hasMatchingTag("Action", "getMyApps"),
    function(m)
        local owner = m.From

        -- Check if the Apps table is empty
        if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")
            ao.send({ Target = owner, Data = "No apps found." })
            return
        end

        -- Filter apps owned by the user
        local filteredApps = {}
        for AppId, App in pairs(Apps) do
            if App.Owner == owner then
                filteredApps[AppId] = {
                    AppId = App.AppId,
                    AppName = App.AppName,
                    Description = App.Description,
                    CompanyName = App.CompanyName,
                    ProjectType = App.ProjectType,
                    WebsiteUrl = App.WebsiteUrl,
                    AppIconUrl = App.AppIconUrl,
                    CreatedTime = App.CreatedTime
                }
            end
        end

        -- Send the filtered apps to the user
        ao.send({ Target = owner, Data = tableToJson(filteredApps) })
    end
)




Handlers.add(
    "AddReviewAppN",
    Handlers.utils.hasMatchingTag("Action", "AddReviewAppN"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "username", "profileUrl", "AppId", "comment", "rating" }
        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local rating = tonumber(m.Tags.rating)
        local currentTime = getCurrentTime(m)

        -- Validate rating
        if not rating or rating < 1 or rating > 5 then
            ao.send({ Target = m.From, Data = "Invalid rating. Please provide a rating between 1 and 5." })
            return
        end

        -- Initialize reviewsTable[appId] if not exists
        reviewsTable[appId] = reviewsTable[appId] or {
            count = 0,
            users = {},
            countHistory = {},
            reviews = {}
        }

        -- Initialize ratingsTable[appId] if not exists
        ratingsTable[appId] = ratingsTable[appId] or {
            count = 0,
            Totalratings = 0,
            users = {},
            countHistory = {}
        }

        local reviews = reviewsTable[appId]
        local ratings = ratingsTable[appId]

        -- Prevent duplicate ratings
        if reviews.users[user] then
            local points = -30
            arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
            arsPoints[user].points = arsPoints[user].points + points
            local currentPoints = arsPoints[user].points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Already Reviewed Project.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
            ao.send({ Target = m.From, Data = "You have already reviewed this Project." })
            return
        end

        -- Add review and update review table
        reviews.users[user] = { time = currentTime }
        reviews.count = reviews.count + 1
        table.insert(reviews.countHistory, { time = currentTime, count = reviews.count })

        -- Generate unique ID for the review
        local reviewId = generateReviewId()
        table.insert(reviews.reviews, {
            reviewId = reviewId,
            user = user,
            username = username,
            comment = comment,
            rating = rating,
            timestamp = currentTime,
            profileUrl = profileUrl,
            voters = {
                upvoted = {
                    count = 1,
                    countHistory = { { time = currentTime, count = 1 } },
                    users = { [user] = { time = currentTime } }
                },
                downvoted = {
                    count = 0,
                    countHistory = { { time = currentTime, count = 0 } },
                    users = {}
                },
                foundHelpful = {
                    count = 1,
                    countHistory = { { time = currentTime, count = 1 } },
                    users = { [user] = { time = currentTime } }
                },
                foundUnhelpful = {
                    count = 0,
                    countHistory = { { time = currentTime, count = 0 } },
                    users = {}
                }
            },
            replies = {}
        })

        -- Update points for the user and the app owner
        local points = 100
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        arsPoints[user].points = arsPoints[user].points + points

        local AppOwner = Apps[appId].Owner
        local AppPoints = 50
        arsPoints[AppOwner] = arsPoints[AppOwner] or { user = AppOwner, points = 0 }
        arsPoints[AppOwner].points = arsPoints[AppOwner].points + AppPoints

        -- Update ratings table
        ratings.users[user] = { time = currentTime }
        ratings.count = ratings.count + 1
        ratings.Totalratings = ratings.Totalratings + rating
        table.insert(ratings.countHistory, { time = currentTime, count = ratings.count, rating = rating })

        ao.send({ Target = m.From, Data = "Review added successfully." })
    end
)





-- Add Helpful Rating Handler
Handlers.add(
    "UnhelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "UnhelpfulRatingApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Get the app data for helpful and unhelpful ratings
        local appHData = helpfulRatingsTable[AppId]
        local appUhData = unHelpfulRatingsTable[AppId]

        -- Check if the user has already marked the rating as unhelpful
        if appUhData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as helpful
        if appHData.users[user] then
            -- Remove the user from the helpful users table
            appHData.users[user] = nil
            -- Decrement the helpful count
            appHData.count = appHData.count - 1

            -- Log the count change in helpful count history
            table.insert(appHData.countHistory, { time = currentTime, count = appHData.count })

            -- Deduct points for switching ratings
            local points = -200
              -- Get or initialize the user's points data
            local userPointsData = getOrInitializeUserPoints(user)
            -- Deduct points
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Rated Helpful.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the unhelpful users table
        appUhData.users[user] = { voted = true, time = currentTime }
        -- Increment the unhelpful count
        appUhData.count = appUhData.count + 1
        -- Log the count change in unhelpful count history
        table.insert(appUhData.countHistory, { time = currentTime, count = appUhData.count })

        -- Deduct points for marking an app as unhelpful
        local points = 100
        -- Ensure arsPoints[user] is initialized
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        -- Update points
        arsPoints[user].points = arsPoints[user].points + points
        -- Safely access points
        local currentPoints = arsPoints[user].points
        local amount = 3 -- Deduction of tokens for unhelpful rating
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "UnHelpful Rating.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging
        print("Unhelpful vote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully marked this app as unhelpful." })
    end
)


Handlers.add(
    "HelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "HelpfulRatingApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

         -- Get the app data for helpful and unhelpful ratings
        local appHData = helpfulRatingsTable[AppId]
        local appUhData = unHelpfulRatingsTable[AppId]

        -- Check if the user has already marked the rating as helpful
        if appHData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as unhelpful
        if appUhData.users[user] then
            -- Remove the user from the unhelpful users table
            appUhData.users[user] = nil
            -- Decrement the unhelpful count
            appUhData.count = appUhData.count - 1

            -- Log the count change in unhelpful count history
            table.insert(appUhData.countHistory, { time = currentTime, count = appUhData.count })

            -- Deduct points for switching ratings
            local points = -200
            -- Get or initialize the user's points data
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Rated Unhelpful.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the helpful users table
        appHData.users[user] = { voted = true, time = currentTime }
        -- Increment the helpful count
        appHData.count = appHData.count + 1
        -- Log the count change in helpful count history
        table.insert(appHData.countHistory, { time = currentTime, count = appHData.count })

        -- Reward points for marking an app as helpful
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 5 -- Reward tokens for helpful rating
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Rating.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging
        print("Helpful vote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully marked this app as helpful." })
    end
)


Handlers.add(
    "UpvoteApp",
    Handlers.utils.hasMatchingTag("Action", "UpvoteApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Get the app data for upvotes and downvotes
        local appUpData = upvotesTable[AppId]
        local appDownData = downvotesTable[AppId]

        -- Check if the user has already Upvoted the project
        if appUpData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as downvoted
        if appDownData.users[user] then
            -- Remove the user from the downvotes table
            appDownData.users[user] = nil
            -- Decrement the downvote count
            appDownData.count = appDownData.count - 1

            -- Log the count change in downvote count history
            table.insert(appDownData.countHistory, { time = currentTime, count = appDownData.count })

            -- Deduct points for switching ratings
            local points = -200
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Downvoted.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the upvotes table
        appUpData.users[user] = { voted = true, time = currentTime }
        -- Increment the upvote count
        appUpData.count = appUpData.count + 1
        -- Log the count change in upvote count history
        table.insert(appUpData.countHistory, { time = currentTime, count = appUpData.count })

        -- Reward points for upvoting
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 5 -- Reward tokens for upvoting
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Upvote.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging
        print("Upvote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully upvoted this app." })
    end
)

Handlers.add(
    "DownvoteApp",
    Handlers.utils.hasMatchingTag("Action", "DownvoteApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

       

        -- Get the app data for upvotes and downvotes
        local appUpData = upvotesTable[AppId]
        local appDownData = downvotesTable[AppId]

        -- Check if the user has already downvoted the App.
        if appDownData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as upvoted
        if appUpData.users[user] then
            -- Remove the user from the upvotes table
            appUpData.users[user] = nil
            -- Decrement the upvote count
            appUpData.count = appUpData.count - 1

            -- Log the count change in upvote count history
            table.insert(appUpData.countHistory, { time = currentTime, count = appUpData.count })

            -- Deduct points for switching ratings
            local points = -200
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Upvoted.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the downvotes table
        appDownData.users[user] = { voted = true, time = currentTime }
        -- Increment the downvote count
        appDownData.count = appDownData.count + 1
        -- Log the count change in downvote count history
        table.insert(appDownData.countHistory, { time = currentTime, count = appDownData.count })

        -- Deduct points for downvoting
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 3 -- Deduction of tokens for downvoting
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Downvote.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging
        print("Downvote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully downvoted this app." })
    end
)

Handlers.add(
    "FetchArsPoints",
    Handlers.utils.hasMatchingTag("Action", "FetchArsPoints"),
    function(m)

        local userId = m.From

        -- Fetch the user's arsPoints from the table
        local userPointsData = arsPoints[userId]

        if userPointsData then
            -- User exists, send back their arsPoints
            ao.send({
                Target = m.From,
                Data = string.format(" ArsPoints: %d", userPointsData.points)
            })
        else
            -- User not found in arsPoints
            print("Error: User not found in arsPoints.")
            ao.send({
                Target = m.From,
                Data = "Error: User not found in arsPoints."
            })
        end
    end
)



Handlers.add(
    "AddAppToFavorites",
    Handlers.utils.hasMatchingTag("Action", "AddAppToFavorites"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Ensure the app exists in the favorites table
        favoritesTable[AppId] = favoritesTable[AppId] or { users = {}, count = 0, countHistory = {} }
        local appFav = favoritesTable[AppId]

        -- Check if the user has already added this app to favorites
        if appFav.users[user] then
            local points = -30
            -- Deduct points for unnecessary action
            arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
            arsPoints[user].points = arsPoints[user].points + points
            local currentPoints = arsPoints[user].points

            -- Log the penalty transaction
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Already Added to Favorites.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })

            ao.send({ Target = m.From, Data = "You have already added this app to your favorites. Points deducted for unnecessary action." })
            return
        end

        -- Add the user to the favorites table
        appFav.users[user] = { voted = true, time = currentTime }
        appFav.count = appFav.count + 1

        -- Log the count change in favorites history
        table.insert(appFav.countHistory, { time = currentTime, count = appFav.count })

        -- Reward points and tokens for a first-time addition
        local points = 70
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        arsPoints[user].points = arsPoints[user].points + points
        local currentPoints = arsPoints[user].points
        local amount = 5

        -- Send reward tokens
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        -- Log the reward transaction
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Added to Favorites.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging and confirmation message
        print("App added to favorites successfully!")
        ao.send({ Target = m.From, Data = "You have successfully added this app to your favorites and earned rewards." })
    end
)




Handlers.add(
    "AddReviewReply",
    Handlers.utils.hasMatchingTag("Action", "AddReviewReply"),
    function(m)
        -- Check required tags
        local requiredTags = { "AppId", "ReviewId", "username", "comment", "profileUrl" }
        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user is the app owner
        if not Apps[appId] or Apps[appId].Owner ~= user then
            ao.send({ Target = m.From, Data = "Only the app owner can reply to reviews." })
            return
        end

        -- Find the target app and review
        if not reviewsTable[appId] or not reviewsTable[appId].reviews then
            ao.send({ Target = m.From, Data = "Reviews not found for this app." })
            return
        end

        local targetReview
        for _, review in ipairs(reviewsTable[appId].reviews) do
            if review.reviewId == reviewId then
                targetReview = review
                break
            end
        end

        if not targetReview then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end

        -- Check if the user has already replied to this review
        if targetReview.replies then
            for _, reply in ipairs(targetReview.replies) do
                if reply.user == user then
                    ao.send({ Target = m.From, Data = "You have already replied to this review." })
                    return
                end
            end
        else
            targetReview.replies = {} -- Initialize replies table if not present
        end

        -- Generate a unique ID for the reply
        local replyId = generateReplyId()

        -- Add the reply to the target review
        table.insert(targetReview.replies, {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Reply added successfully." })
    end
)

Handlers.add(
    "MarkUnhelpfulReview",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end

        local unhelpfulData = review.voters.foundUnhelpful
        local helpfulData = review.voters.foundHelpful

        if unhelpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this review as unhelpful." })
            return
        end

        if helpfulData.users[user] then
            helpfulData.users[user] = nil
            helpfulData.count = helpfulData.count - 1
            table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

            local points = -50
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to unhelpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        unhelpfulData.users[user] = {username = username, voted = true, time = currentTime }
        unhelpfulData.count = unhelpfulData.count + 1
        table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

        local points = -20
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 0
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Marked Review as Unhelpful.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as unhelpful successfully." })
    end
)


Handlers.add(
    "MarkHelpfulReview",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end


        local helpfulData = review.voters.foundHelpful
       
        local unhelpfulData = review.voters.foundUnhelpful
        
        if helpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as helpful." })
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1
            table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

            local points = -100
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to helpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

        local points = 50
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Review  Rating.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as helpful successfully." })
    end
)




Handlers.add(
    "MarkUpvoteReview",
    Handlers.utils.hasMatchingTag("Action", "MarkUpvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end


        local helpfulData = review.voters.upvoted
       
        local unhelpfulData = review.voters.downvoted
        
        if helpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You already Upvoted this review." })
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1
            table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

            local points = -100
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to helpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

        local points = 50
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Review  Rating.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as helpful successfully." })
    end
)



Handlers.add(
    "MarkDownvoteReview",
    Handlers.utils.hasMatchingTag("Action", "MarkDownvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end

        local unhelpfulData = review.voters.downvoted
        local helpfulData = review.voters.upvoted

        if unhelpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You have already Downvoted this project." })
            return
        end

        if helpfulData.users[user] then
            helpfulData.users[user] = nil
            helpfulData.count = helpfulData.count - 1
            table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

            local points = -50
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to unhelpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        unhelpfulData.users[user] = {username = username, voted = true, time = currentTime }
        unhelpfulData.count = unhelpfulData.count + 1
        table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

        local points = -20
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 0
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Marked Review as Unhelpful.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as unhelpful successfully." })
    end
)




Handlers.add(
    "UpvoteReview",
    Handlers.utils.hasMatchingTag("Action", "UpvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user has already upvoted
        if review.voters.upvoted[user] then
            ao.send({ Target = m.From, Data = "You have already upvoted this review." })
            return
        end

        -- Update the upvote count and mark the user as an upvoter
        review.upvotes = review.upvotes + 1
        review.voters.upvoted[user] = true

        ao.send({ Target = m.From, Data = "Review upvoted successfully." })
    end
)

Handlers.add(
    "DownvoteReview",
    Handlers.utils.hasMatchingTag("Action", "DownvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user has already downvoted
        if review.voters.downvoted[user] then
            ao.send({ Target = m.From, Data = "You have already downvoted this review." })
            return
        end

        -- Update the downvote count and record the voter
        review.downvotes = review.downvotes + 1
        review.voters.downvoted[user] = true

        ao.send({ Target = m.From, Data = "Review downvoted successfully." })
    end
)


Handlers.add(
    "TransferAppOwnership",
    Handlers.utils.hasMatchingTag("Action", "TransferAppOwnership"),
    function(m)
        local appId = m.Tags.AppId
        local newOwner = m.Tags.NewOwner
        local currentOwner = m.From

        -- Validate input
        if not appId or not newOwner then
            ao.send({ Target = m.From, Data = "AppId or NewOwner is missing." })
            return
        end

        -- Check if the app exists
        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Check if the user making the request is the current owner
        if Apps[appId].Owner ~= currentOwner then
            ao.send({ Target = m.From, Data = "You are not the owner of this app." })
            return
        end

        -- Transfer ownership
        Apps[appId].Owner = newOwner
        ao.send({ Target = m.From, Data = "Ownership transferred to " .. newOwner })
    end
)


Handlers.add(
    "UpdateAppDetails",
    Handlers.utils.hasMatchingTag("Action", "UpdateAppDetails"),
    function(m)

         -- Check if all required m.Tags are present
        local requiredTags = {
        "NewValue", "AppId", "UpdateOption",
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local updateOption = m.Tags.UpdateOption
        local newValue = m.Tags.NewValue
        local currentOwner = m.From

        -- Validate input
        if not appId or not updateOption or not newValue then
            ao.send({ Target = m.From, Data = "AppId, UpdateOption, or NewValue is missing." })
            return
        end

        -- Check if the app exists
        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Check if the user making the request is the current owner
        if Apps[appId].Owner ~= currentOwner then
            ao.send({ Target = m.From, Data = "You are not the owner of this app." })
            return
        end

        -- Update the requested field
        local validUpdateOptions = {
            OwnerUserName = true,
            AppName = true,
            Description = true,
            Protocol = true,
            WebsiteUrl = true,
            TwitterUrl = true,
            DiscordUrl = true,
            CoverUrl = true ,
            profileUrl = true,
            CompanyName = true,
            AppIconUrl = true,
            BannerUrl1 = true,
            BannerUrl2 = true,
            BannerUrl3 = true,
            BannerUrl4 = true,
        }

        if not validUpdateOptions[updateOption] then
            ao.send({ Target = m.From, Data = "Invalid UpdateOption." })
            return
        end

        -- Perform the update
        Apps[appId][updateOption] = newValue
        ao.send({ Target = m.From, Data = updateOption .. " updated successfully." })
    end
)



-- Handler to view all transactions
Handlers.add(
    "view_transactions",
    Handlers.utils.hasMatchingTag("Action", "view_transactions"),
    function(m)
        local user = m.From
        local user_transactions = {}
        
        -- Filter transactions for the specific user
        for _, transaction in ipairs(transactions) do
            -- Skip nil transactions
            if transaction ~= nil and transaction.user == user then
                table.insert(user_transactions, transaction)
            end
        end
        
        -- Send the filtered transactions back to the user
        ao.send({ Target = user, Data = tableToJson(user_transactions) })
    end
)


Handlers.add(
    "SendNotificationToInbox",
    Handlers.utils.hasMatchingTag("Action", "SendNotificationToInbox"),
    function(m)
        local appId = m.Tags.AppId
        local message = m.Tags.Message
        local Header = m.Tags.Header
        local LinkInfo = m.Tags.LinkInfo
        local sender = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        

        -- Check for required parameters
        if not appId or not message then
            ao.send({ Target = m.From, Data = "AppId and Message are required." })
            return
        end

        -- Verify that the app exists
        local appDetails = Apps[appId]
        if not appDetails then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Verify that the sender is the owner of the app
        if appDetails.Owner ~= sender then
            ao.send({ Target = m.From, Data = "You are not authorized to send messages for this app." })
            return
        end

        -- Check if the app has any favorites
        local favorites = favoritesTable[appId]
        if not favorites or not favorites.users then
            ao.send({ Target = m.From, Data = "No users have favorited this app." })
            return
        end

        -- Send the message to each user's inbox
        for userId, _ in pairs(favorites.users) do
            -- Function to initialize a user's inbox if it doesn't exist
            local function initializeUserInbox(userId)
                inboxTable[userId] = inboxTable[userId] or {}
            end

            initializeUserInbox(userId)

            table.insert(inboxTable[userId], {
                AppId = appId,
                AppName = appDetails.AppName,
                AppIconUrl = appDetails.AppIconUrl,
                Message = message,
                Header = Header,
                LinkInfo = LinkInfo,
                currentTime = currentTime
            })
        end

        -- Confirm the notifications were sent
        ao.send({ Target = m.From, Data = "Message successfully added to the inbox of all users who favorited your app." })
    end
)


Handlers.add(
    "GetUserInbox",
    Handlers.utils.hasMatchingTag("Action", "GetUserInbox"),
    function(m)
        local userId = m.From

        -- Check if the user has any messages in their inbox
        local userInbox = inboxTable[userId] or {}

        -- Return the user's inbox as a JSON object
        ao.send({ Target = userId, Data = tableToJson(userInbox) })
    end
)



Handlers.add(
    "FetchFeatureRequestUserDataM",
    Handlers.utils.hasMatchingTag("Action", "FetchFeatureRequestUserDataM"),
    function(m)
        local userId = m.From -- Get the ID of the user who called the function

        -- Initialize a table to store all relevant feature requests for the user
        local userFeatureRequests = {}

        -- Iterate over all feature requests in the featureRequestsTable
        for featureId, featureEntry in pairs(featureRequestsTable) do
            -- Iterate through the requests for this feature
            for _, request in ipairs(featureEntry.requests or {}) do
                if request.user == userId then -- Match the request's user to the calling userId
                    -- Collect user-specific data for this request
                    table.insert(userFeatureRequests, {
                        featureRequestId = featureId,
                        username = request.username, -- Use username from the request
                        time = request.time or request.timestamp, -- Use timestamp or time field
                        comment = request.comment, -- Main description of the feature request
                        replies = request.replies, -- Include all replies for this feature request
                        profileUrl = request.profileUrl, -- User's profile URL
                        tableId = request.TableId -- Include TableId if present
                    })
                end
            end
        end

        -- Handle the case where no feature requests are found for the user
        if #userFeatureRequests == 0 then
            print("No feature requests or replies found for user " .. userId)
            ao.send({ Target = m.From, Data = "No feature requests or replies found for the user." })
            return
        end

        -- Convert the userFeatureRequests table to JSON for sending
        local userFeatureRequestsJson = tableToJson(userFeatureRequests)

        -- Debugging: Print and send the collected data
        print("Feature Request User Data for user " .. userId .. ":", userFeatureRequestsJson)
        ao.send({ Target = m.From, Data = userFeatureRequestsJson })
    end
)



Handlers.add(
    "FetchBugReportUserDataM",
    Handlers.utils.hasMatchingTag("Action", "FetchBugReportUserDataM"),
    function(m)
        local userId = m.From -- Get the ID of the user who called the function

        -- Initialize a table to store all relevant bug reports for the user
        local userBugReports = {}

        -- Iterate over all bug reports in the bugsReportsTable
        for bugId, bugEntry in pairs(bugsReportsTable) do
            -- Iterate through the requests for this bug report
            for _, request in ipairs(bugEntry.requests or {}) do
                if request.user == userId then -- Match the request's user to the calling userId
                    -- Collect user-specific data for this request
                    table.insert(userBugReports, {
                        bugReportId = bugId,
                        username = request.username, -- Use username from the request
                        time = request.time or request.timestamp, -- Use timestamp or time field
                        comment = request.comment, -- Main description of the bug
                        replies = request.replies, -- Include all replies for this bug report
                        profileUrl = request.profileUrl, -- User's profile URL
                        tableId = request.TableId -- Include TableId if present
                    })
                end
            end
        end

        -- Handle the case where no bug reports are found for the user
        if #userBugReports == 0 then
            print("No bug reports or replies found for user " .. userId)
            ao.send({ Target = m.From, Data = "No bug reports or replies found for the user." })
            return
        end

        -- Convert the userBugReports table to JSON for sending
        local userBugReportsJson = tableToJson(userBugReports)

        -- Debugging: Print and send the collected data
        print("Bug Report User Data for user " .. userId .. ":", userBugReportsJson)
        ao.send({ Target = m.From, Data = userBugReportsJson })
    end
)




Handlers.add(
    "FetchFeaturesDataN",
    Handlers.utils.hasMatchingTag("Action", "FetchFeaturesDataN"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the featureRequestsTable table
        if not featureRequestsTable[appId] then
            ao.send({ Target = m.From, Data = "No info found for this app." })
            return
        end

        -- Fetch the info
        local featuresInfo = featureRequestsTable[appId].requests

        -- Check if there are reviews
        if not featuresInfo or #featuresInfo == 0 then
            ao.send({ Target = m.From, Data = "No info available for this app." })
            return
        end

        -- Convert reviews to JSON for sending
        local reviewsJson = tableToJson(featuresInfo)
        -- Send the reviews back to the user
        ao.send({
            Target = m.From,
            Data = reviewsJson
        })
    end
)

Handlers.add(
    "AddFeatureRequestReply",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureRequestReply"),
    function(m)
        -- Validate required tags
        local requiredTags = { "AppId", "FeatureRequestId", "username", "comment", "profileUrl" }
        for _, tag in ipairs(requiredTags) do
            if not m.Tags[tag] or m.Tags[tag] == "" then
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local featureRequestId = m.Tags.FeatureRequestId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user is the app owner
        if not Apps[appId] or Apps[appId].Owner ~= user then
            ao.send({ Target = m.From, Data = "Only the app owner can reply to feature requests." })
            return
        end

        -- Find the target feature request in the featureRequestsTable
        local featureRequestEntry = nil
        if featureRequestsTable[appId] and featureRequestsTable[appId].requests then
            for _, request in ipairs(featureRequestsTable[appId].requests) do
                if request.TableId == featureRequestId then
                    featureRequestEntry = request
                    break
                end
            end
        end

        if not featureRequestEntry then
            ao.send({ Target = m.From, Data = "Feature request not found for the specified AppId and FeatureRequestId." })
            return
        end

        -- Check if the user has already replied to this feature request
        for _, reply in ipairs(featureRequestEntry.replies) do
            if reply.user == user then
                ao.send({ Target = m.From, Data = "You have already replied to this feature request." })
                return
            end
        end

        -- Generate a unique ID for the reply
        local replyId = generateReplyId()

        -- Add the reply to the feature request
        table.insert(featureRequestEntry.replies, {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        })

        -- Confirm success
        ao.send({ Target = m.From, Data = "Reply added successfully." })
    end
)





Handlers.add(
    "FetchBugReportsN",
    Handlers.utils.hasMatchingTag("Action", "FetchBugReportsN"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the devForumTable table
        if not bugsReportsTable[appId] then
            ao.send({ Target = m.From, Data = "No info found for this app." })
            return
        end

        -- Fetch the info
        local bugReportsInfo = bugsReportsTable[appId].requests

        -- Check if there are reviews
        if not bugReportsInfo or #bugReportsInfo == 0 then
            ao.send({ Target = m.From, Data = "No info available for this app." })
            return
        end

        -- Convert reviews to JSON for sending
        local reviewsJson = tableToJson(bugReportsInfo)

        -- Send the reviews back to the user
        ao.send({
            Target = m.From,
            Data = reviewsJson
        })
    end
)


Handlers.add(
    "AddBugReportReply",
    Handlers.utils.hasMatchingTag("Action", "AddBugReportReply"),
    function(m)
        -- Validate required tags
        local requiredTags = { "AppId", "BugReportId", "username", "comment", "profileUrl" }
        for _, tag in ipairs(requiredTags) do
            if not m.Tags[tag] or m.Tags[tag] == "" then
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local bugReportId = m.Tags.BugReportId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user is the app owner
        if not Apps[appId] or Apps[appId].Owner ~= user then
            ao.send({ Target = m.From, Data = "Only the app owner can reply to bug reports." })
            return
        end

        -- Ensure appId exists in bugsReportsTable
        if not bugsReportsTable[appId] or not bugsReportsTable[appId].requests then
            ao.send({ Target = m.From, Data = "No bug reports found for the specified AppId." })
            return
        end

        -- Locate the specific bug report in the requests list
        local bugReportEntry = nil
        for _, report in ipairs(bugsReportsTable[appId].requests) do
            if report.TableId == bugReportId then -- Match based on TableId (or BugReportId)
                bugReportEntry = report
                break
            end
        end

        -- Handle case where the bug report is not found
        if not bugReportEntry then
            ao.send({ Target = m.From, Data = "Bug report not found for the specified AppId and BugReportId." })
            return
        end

        -- Check if the user has already replied to this bug report
        for _, reply in ipairs(bugReportEntry.replies) do
            if reply.user == user then
                ao.send({ Target = m.From, Data = "You have already replied to this bug report." })
                return
            end
        end

        -- Generate a unique ID for the reply
        local replyId = generateReplyId()

        -- Add the reply to the bug report
        table.insert(bugReportEntry.replies, {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        })

        -- Confirm success
        ao.send({ Target = m.From, Data = "Reply added successfully." })
    end
)





Handlers.add(
    "GetUserStatistics",
    Handlers.utils.hasMatchingTag("Action", "GetUserStatistics"),
    function(m)
        local userId = m.From

        if not userId then
            ao.send({ Target = m.From, Data = "UserId is required." })
            return
        end

        -- Check if transactions table exists
        if not transactions then
            ao.send({ Target = m.From, Data = "Error: Transactions table not found." })
            return
        end

        -- Initialize user statistics
        local userStatistics = {
            totalEarnings = 0,
            transactions = {}
        }

        -- Flag to track if user has transactions
        local hasTransactions = false

        -- Loop through the transactions table to gather user's data
        for _, transaction in pairs(transactions) do
            if transaction.user == userId then
                hasTransactions = true
                -- Add transaction details to the statistics
                table.insert(userStatistics.transactions, {
                    amount = transaction.amount,
                    time = transaction.timestamp
                })
                -- Increment total earnings
                userStatistics.totalEarnings = userStatistics.totalEarnings + transaction.amount
            end
        end

        -- If no transactions found, return early
        if not hasTransactions then
            ao.send({ Target = m.From, Data = "You have no earnings." })
            return
        end

        -- Send the user statistics back to the requester
        ao.send({
            Target = m.From,
            Data = tableToJson(userStatistics)
        })
    end
)


Handlers.add(
    "DepositConfirmedN",
    Handlers.utils.hasMatchingTag("Action", "DepositConfirmedN"),
    function(m)
        local userId = m.From
        local appId = m.Tags.AppId
        local tokenId = m.Tags.processId
        local amount = tonumber(m.Tags.Amount)

        -- Validate input
        if not appId or not tokenId or not amount then
            ao.send({ Target = m.From, Data = "AppId, processId, or Amount is missing." })
            return
        end

        -- Check if the App exists
        local app = Apps[appId]
        if not app then
            ao.send({ Target = m.From, Data = "Invalid AppId: " .. tostring(appId) })
            return
        end

        -- Validate ownership: only the App Owner can call this handler
        if app.Owner ~= userId then
            ao.send({ Target = m.From, Data = "You are not authorized to perform this action. Only the App Owner can confirm deposits." })
            return
        end

        local Appname = app.AppName or "Unknown"
        local currentTime = getCurrentTime(m)
        local airdropId = generateAirdropId()
        local status = "Pending"

        -- Insert the new airdrop into the appId's airdrops list
        table.insert(airdropTable[appId].airdrops, {
            timestamp = currentTime,
            status = status,
            airdropId = airdropId,
            appId = appId,
            appname = Appname,
            Owner = userId,
            amount = amount,
            tokenId = tokenId
        })

        -- Update count and history
        airdropTable[appId].count = (airdropTable[appId].count or 0) + 1
        table.insert(airdropTable[appId].countHistory, {
            count = airdropTable[appId].count,
            time = currentTime
        })

        -- Send confirmation back to the App Owner
        ao.send({
            Target = m.From,
            Data = "Deposit confirmed for AppId: " .. appId .. ", ProcessId: " .. tokenId .. ", Amount: " .. amount
        })
    end
)





Handlers.add(
    "getAllAirdropsN",
    Handlers.utils.hasMatchingTag("Action", "getAllAirdropsN"),
    function(m)
      
        -- Check if the table is empty
        if next(airdropTable) == nil then
            print("Airdrop table is empty.")
            ao.send({ Target = m.From, Data = "{}" })
            return
        end

        -- Optionally flatten the data into a list
        local flatAirdrops = {}
        for appId, appData in pairs(airdropTable) do
            for _, airdrop in ipairs(appData.airdrops) do
                table.insert(flatAirdrops, airdrop)
            end
        end


        -- Send the response back
        ao.send({ Target = m.From, Data = tableToJson(flatAirdrops) })
    end
)


Handlers.add(
    "getAirdropsByAppId",
    Handlers.utils.hasMatchingTag("Action", "getAirdropsByAppId"),
    function(m)
        -- Extract AppId from the message tags
        local appId = m.Tags.AppId
        if not appId then
            ao.send({ Target = m.From, Data = "Error: AppId is required." })
            return
        end

        -- Ensure airdropTable exists
        if not airdropTable then
            airdropTable = {}
        end

        -- Check if the table contains the specified AppId
        local appAirdrops = airdropTable[appId]
        if not appAirdrops or not appAirdrops.airdrops or #appAirdrops.airdrops == 0 then
            print("No airdrops found for AppId: " .. appId)
            ao.send({ Target = m.From, Data = "{}" }) -- Send an empty JSON if no airdrops are found
            return
        end

        -- Create a response object with metadata
            AirdropData  = appAirdrops.airdrops
        

        -- Send the filtered data back to the user
        ao.send({ Target = m.From, Data = tableToJson(AirdropData) })
    end
)


Handlers.add(
    "getOwnerAirdropsN",
    Handlers.utils.hasMatchingTag("Action", "getOwnerAirdropsN"),
    function(m)
        local userId = m.From

        -- Check if the airdrops table exists
        if not airdropTable or next(airdropTable) == nil then
            ao.send({ Target = m.From, Data = "{}" }) -- Send an empty JSON if there are no airdrops
            return
        end

        -- Filter airdrops by owner
        local ownerAirdrops = {}
        for appId, appData in pairs(airdropTable) do
            if appData.airdrops then
                for _, airdrop in ipairs(appData.airdrops) do
                    if airdrop.Owner == userId then
                        table.insert(ownerAirdrops, airdrop)
                    end
                end
            end
        end

        -- Convert the filtered table to JSON and send it
        ao.send({ Target = m.From, Data = tableToJson(ownerAirdrops) })
    end
)





Handlers.add(
    "FetchAirdropDataN",
    Handlers.utils.hasMatchingTag("Action", "FetchAirdropDataN"),
    function(m)
        local user = m.From
        local AirdropId = m.Tags.airdropId

        print("airdropId: " .. (AirdropId or "nil") .. " is this")

        -- Validate input
        if not AirdropId then
            ao.send({ Target = m.From, Data = "AirdropId is missing." })
            return
        end

        -- Check if the Airdrop exists
        local airdropFound = nil
        for appId, appData in pairs(airdropTable) do
            if appData.airdrops then
                for _, airdrop in ipairs(appData.airdrops) do
                    if airdrop.airdropId == AirdropId then
                        airdropFound = airdrop
                        break
                    end
                end
            end
            if airdropFound then break end
        end

        if not airdropFound then
            ao.send({ Target = m.From, Data = "No such Airdrop found." })
            return
        end

        -- Send the Airdrop data back to the user
        ao.send({
            Target = m.From,
            Data = tableToJson(airdropFound)
        })
    end
)



Handlers.add(
    "FinalizeAirdropN",
    Handlers.utils.hasMatchingTag("Action", "FinalizeAirdropN"),
    function(m)
        local airdropId = m.Tags.airdropId
        local airdropsReceivers = m.Tags.airdropsreceivers
        local Description = m.Tags.Description
        local startTime = tonumber(m.Tags.startTime) -- Convert to number
        local endTime = tonumber(m.Tags.endTime) -- Convert to number

        print("Finalizing Airdrop with ID: " .. (airdropId or "nil"))

        -- Validate input
        if not airdropId then
            ao.send({ Target = m.From, Data = "AirdropId is missing." })
            return
        end
        if not airdropsReceivers then
            ao.send({ Target = m.From, Data = "AirdropsReceivers is missing." })
            return
        end
        if not startTime then
            ao.send({ Target = m.From, Data = "StartTime is missing or invalid." })
            return
        end
        if not endTime then
            ao.send({ Target = m.From, Data = "EndTime is missing or invalid." })
            return
        end

        -- Convert startTime and endTime to milliseconds
        startTime = startTime * 1000
        endTime = endTime * 1000

        -- Validate that endTime is greater than startTime
        if endTime <= startTime then
            ao.send({
                Target = m.From,
                Data = "EndTime must be greater than StartTime."
            })
            return
        end

        -- Look up the airdrop in the nested table structure
        local airdropFound = nil
        for appId, appData in pairs(airdropTable) do
            for _, airdrop in ipairs(appData.airdrops) do
                if airdrop.airdropId == airdropId then
                    airdropFound = airdrop
                    break
                end
            end
            if airdropFound then
                break
            end
        end

        -- Handle case where the airdrop was not found
        if not airdropFound then
            ao.send({ Target = m.From, Data = "No such Airdrop found with ID: " .. airdropId })
            return
        end

        -- Update the Airdrop with new information
        airdropFound.airdropsReceivers = airdropsReceivers
        airdropFound.startTime = startTime
        airdropFound.endTime = endTime
        airdropFound.status = "Ongoing" -- Update status to Ongoing
        airdropFound.Description = Description

        -- Confirm success
        ao.send({
            Target = m.From,
            Data = "Airdrop finalized successfully for ID: " .. airdropId
        })

        -- Log the updated Airdrop (Optional)
        print("Updated Airdrop: " .. tableToJson(airdropFound))
    end
)





Handlers.add(
    "GetAppStatistics",
    Handlers.utils.hasMatchingTag("Action", "GetAppStatistics"),
    function(m)
        local appId = m.Tags.AppId
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is required." })
            return
        end

        -- Helper function to extract statistics from a table
        local function extractStatistics(table, appId, tableName)
            local appDetails = Apps[appId] or { AppName = "Unknown", CreatedTime = "Unknown" }
            if table[appId] then
                return {
                    Title = tableName,
                    AppName = appDetails.AppName,
                    CreatedTime = appDetails.CreatedTime,
                    count = table[appId].count,
                    countHistory = table[appId].countHistory
                }
            else
                return {
                    Title = tableName,
                    AppName = appDetails.AppName,
                    CreatedTime = appDetails.CreatedTime,
                    count = 0,
                    countHistory = {}
                }
            end
        end

        -- Fetch statistics from all relevant tables
        local statistics = {
            reviews = extractStatistics(reviewsTable, appId, "Reviews Table"),
            upvotes = extractStatistics(upvotesTable, appId, "Upvotes Table"),
            downvotes = extractStatistics(downvotesTable, appId, "Downvotes Table"),
            featureRequests = extractStatistics(featureRequestsTable, appId, "Feature Requests Table"),
            favorites = extractStatistics(favoritesTable, appId, "Favorites Table"),
            ratings = extractStatistics(ratingsTable, appId, "Ratings Table"),
            helpfulRatings = extractStatistics(helpfulRatingsTable, appId, "Helpful Ratings Table"),
            unHelpfulRatings = extractStatistics(unHelpfulRatingsTable, appId, "Unhelpful Ratings Table"),
            flags = extractStatistics(flagTable, appId, "Flags Table"),
            DeveloperActivity = extractStatistics(devForumTable, appId, "DeveloperActivity")
        }
        -- Send the statistics back to the admin
        ao.send({
            Target = m.From,
            Data = tableToJson(statistics)
        })
    end
)


Handlers.add(
    "AskDevForumN",
    Handlers.utils.hasMatchingTag("Action", "AskDevForumN"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppId", "header", "username", "profileUrl", "comment",
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local appId = m.Tags.AppId
        local updateOption = m.Tags.header
        local currentTime = getCurrentTime(m)

        -- Validate input
        if not appId or not updateOption then
            ao.send({ Target = m.From, Data = "AppId or UpdateOption is missing." })
            return
        end

        -- Check if appId exists in devForumTable, initialize if missing
        if not devForumTable[appId] then
            devForumTable[appId] = {
                count = 0,
                users = {},
                countHistory = {},
                requests = {}
            }
        end

        -- Add user and update counts
        devForumTable[appId].users[user] = { time = currentTime }
        devForumTable[appId].count = devForumTable[appId].count + 1
        table.insert(devForumTable[appId].countHistory, { time = currentTime, count = devForumTable[appId].count })

        -- Generate unique ID for the devForumTable
        local DevForumId = generateDevForumId()

        -- Add the Dev Forum Data
        table.insert(devForumTable[appId].requests, {
            devForumId = DevForumId,
            user = user,
            username = username,
            comment = comment,
            timestamp = currentTime,
            header = updateOption,
            profileUrl = profileUrl,
            replies = {},
        })

        ao.send({ Target = m.From, Data = updateOption .. " updated successfully." })
    end
)




Handlers.add(
    "FetchDevForumDataN",
    Handlers.utils.hasMatchingTag("Action", "FetchDevForumDataN"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the devForumTable table
        if not devForumTable[appId] then
            ao.send({ Target = m.From, Data = "No info found for this app." })
            return
        end

        -- Fetch the info
        local devForumInfo = devForumTable[appId].requests

        -- Check if there are reviews
        if not devForumInfo or #devForumInfo == 0 then
            ao.send({ Target = m.From, Data = "No info available for this app." })
            return
        end

        -- Convert reviews to JSON for sending
        local reviewsJson = tableToJson(devForumInfo)

        -- Send the reviews back to the user
        ao.send({
            Target = m.From,
            Data = reviewsJson
        })
    end
)


Handlers.add(
    "AddFeatureorBugReport",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureorBugReport"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = {
            "username", "profileUrl", "AppId", "comment", "TableType"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local TableType = m.Tags.TableType
        local currentTime = getCurrentTime(m)

        -- Reference the correct table based on TableType
        local targetTable = nil
        if TableType == "bugsReportsTable" then
            targetTable = bugsReportsTable
        elseif TableType == "featureRequestsTable" then
            targetTable = featureRequestsTable
        else
            ao.send({ Target = m.From, Data = "Invalid TableType: " .. TableType })
            return
        end

        -- Get or initialize the app entry in the target table
        local targetEntry = targetTable[appId]

        -- Add user and update count
        targetEntry.users[user] = { voted = true, time = currentTime }
        targetEntry.count = targetEntry.count + 1
        table.insert(targetEntry.countHistory, { time = currentTime, count = targetEntry.count })

        -- Generate unique ID for the review or report
        local TableId = generateTaskId()

        -- Add the new entry
        table.insert(targetEntry.requests, {
            TableId = TableId,
            user = user,
            username = username,
            comment = comment,
            timestamp = currentTime,
            profileUrl = profileUrl,
            replies = {},
        })

        -- Update points and send transaction
        local points = 100
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        arsPoints[user].points = arsPoints[user].points + points

        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "FeatureRequest/BugReport",
            amount = amount,
            points = arsPoints[user].points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Your entry has been added successfully." })
    end
)





Handlers.add(
    "FetchAppComments",
    Handlers.utils.hasMatchingTag("Action", "FetchAppComments"),
    function(m)

        local AppId = m.Tags.AppId
        local userId = m.Tags.userId
        local TableType = m.Tags.TableType

        -- Check if the required AppId tag is present
        if not m.Tags.AppId then
            ao.send({ Target = m.From, Data = "AppId is missing or empty." })
            return
        end

        if not userId then
            ao.send({ Target = m.From, Data = "UserId is required." })
            return
        end

        if not TableType then
            ao.send({ Target = m.From, Data = "TableType is required." })
            return
        end

        local commentsTable = {
            requests = {
                ownerId = userId, -- Save the app owner's userId here
             comments = {}
            }
                 -- Initialize the comments array
        }

        -- Check if the user is the owner of the App
        if Apps[AppId].Owner ~= userId then
            ao.send({ Target = m.From, Data = "User is not the owner of the App." })
            return
        end

        -- Reference the correct table based on TableType
        local targetTable = nil
        if TableType == "bugsReportsTable" then
            targetTable = bugsReportsTable[AppId].requests
        elseif TableType == "reviewsTable" then
            targetTable = reviewsTable[AppId].reviews
        elseif TableType == "featureRequestsTable" then
            targetTable = featureRequestsTable[AppId].requests
        elseif TableType == "devForumTable" then
            targetTable = devForumTable[AppId].requests
        else
            ao.send({ Target = m.From, Data = "Invalid TableType: " .. TableType })
            return
        end
        local Entry = targetTable
        if not Entry then
            print("No data found for AppId " .. AppId)
            ao.send({ Target = m.From, Data = "No data found for the specified AppId." })
            return
        end

        -- Fetch all comments for the given AppId
        for _, review in ipairs(Entry) do
            if review.comment then
                table.insert(commentsTable.requests.comments, review.comment)
            end
        end

        -- Check if there are any comments
        if #commentsTable.comments == 0 then
            ao.send({ Target = m.From, Data = "No comments found for AppId: " .. AppId })
            return
        end

        -- Send the collected data back to the user
        ao.send({
            Target = AOSAI, -- Reply to the sender
            Action = "openTradesResponse",
            Data = json.encode(commentsTable)
        })
    end
)




-- Handler to get data from a specific table
Handlers.add(
    "getTableData",
    Handlers.utils.hasMatchingTag("Action", "getTableData"),
    function(m)
        local AppId = m.Tags.AppId
        local userId = m.Tags.userId
        local TableType = m.Tags.TableType

        -- Validate inputs
        if not AppId then
            ao.send({ Target = m.From, Data = "AppId is required." })
            return
        end

        if not userId then
            ao.send({ Target = m.From, Data = "UserId is required." })
            return
        end

        if not TableType then
            ao.send({ Target = m.From, Data = "TableType is required." })
            return
        end

        -- Check if the App exists
        if not Apps[AppId] then
            ao.send({ Target = m.From, Data = "App not found with AppId: " .. AppId })
            return
        end

        -- Check if the user is the owner of the App
        if Apps[AppId].owner ~= userId then
            ao.send({ Target = m.From, Data = "User is not the owner of the App." })
            return
        end

        -- Reference the correct table based on TableType
        local targetTable = nil
        if TableType == "bugsReportsTable" then
            targetTable = bugsReportsTable
        elseif TableType == "reviewsTable" then
            targetTable = reviewsTable
        elseif TableType == "featureRequestsTable" then
            targetTable = featureRequestsTable
        elseif TableType == "devForumTable" then
            targetTable = devForumTable
        else
            ao.send({ Target = m.From, Data = "Invalid TableType: " .. TableType })
            return
        end

        -- Check if the AppId exists in the target table
        local Entry = targetTable[AppId]
        if not Entry then
            print("No data found for AppId " .. AppId)
            ao.send({ Target = m.From, Data = "No data found for the specified AppId." })
            return
        end

        -- If the table contains multiple comments, loop through and collect them
        local comments = {}
        for _, record in pairs(Entry) do
            table.insert(comments, {
                appId = AppId,
                count = record.count,
                comment = record.comment,
                time = record.time,
                
            })
        end
        -- Send the collected data back to the user
        ao.send({
            Target = m.From, -- Reply to the sender
            Action = "openTradesResponse",
            Data = json.encode(comments)
        })
    end
)



Handlers.add(
    "GetAostoreStatistics",
    Handlers.utils.hasMatchingTag("Action", "GetAostoreStatistics"),
    function(m)
        -- Helper function to sum statistics across all tables
      local function sumStatistics(table, tableName)
    local totalCount = 0
    local totalHistory = {}
    
        for _, appData in pairs(table) do
        -- Check if appData is a table before attempting to index
        if type(appData) == "table" then
            -- Add count to total
            totalCount = totalCount + (appData.count or 0)
            
            -- Aggregate countHistory
            if appData.countHistory and type(appData.countHistory) == "table" then
                for _, historyItem in ipairs(appData.countHistory) do
                    if type(historyItem) == "table" then
                        local timestamp = historyItem.time
                        local count = historyItem.count or 0
                        
                        -- Here we sum counts for each timestamp
                        totalHistory[timestamp] = (totalHistory[timestamp] or 0) + count
                    end
                end
            end
        else
            -- If appData isn't a table, maybe it's just a count number?
            totalCount = totalCount + (appData or 0)
        end
         end

        return {
        Title = tableName,
        TotalCount = totalCount,
        TotalHistory = totalHistory
            }
        end
        -- Process all relevant tables
        local aostoreStatistics = {
            totalReviews = sumStatistics(reviewsTable, "Reviews Table"),
            totalUpvotes = sumStatistics(upvotesTable, "Upvotes Table"),
            totalDownvotes = sumStatistics(downvotesTable, "Downvotes Table"),
            totalFeatureRequests = sumStatistics(featureRequestsTable, "Feature Requests Table"),
            totalFavorites = sumStatistics(favoritesTable, "Favorites Table"),
            totalRatings = sumStatistics(ratingsTable, "Ratings Table"),
            totalHelpfulRatings = sumStatistics(helpfulRatingsTable, "Helpful Ratings Table"),
            totalUnHelpfulRatings = sumStatistics(unHelpfulRatingsTable, "Unhelpful Ratings Table"),
            totalFlags = sumStatistics(flagTable, "Flags Table"),
            totalDeveloperActivity = sumStatistics(devForumTable, "Developer Activity"),
            totalVerifiedUsers = sumStatistics(verifiedUsers, "Verified Users Table")
        }

        -- Send the aggregated aostore statistics back to the admin
        ao.send({
            Target = m.From,
            Data = tableToJson(aostoreStatistics)
        })
    end
)




Handlers.add(
    "completeAirdrops",
    Handlers.utils.hasMatchingTag("Action", "completeAirdrops"),
    function(m)
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Step 1: Look for all expired airdrops
        local expiredAirdrops = {}
        for appId, appData in pairs(airdropTable) do
            for _, airdrop in ipairs(appData.airdrops or {}) do
                if airdrop.endTime and tonumber(airdrop.endTime) <= currentTime then
                    table.insert(expiredAirdrops, airdrop)
                end
            end
        end

        -- Step 2: Loop through expired airdrops and check receivers
        local completedAirdrops = {}
        for _, airdrop in ipairs(expiredAirdrops) do
            local airdropReceivers = airdrop.airdropsReceivers or {}

            -- Step 3: Validate receivers and check time constraints
            local eligibleReceivers = {}
            for receiverId, receiverData in pairs(airdropReceivers) do
                if receiverData.time and tonumber(receiverData.time) >= tonumber(airdrop.startTime) 
                        and tonumber(receiverData.time) <= tonumber(airdrop.endTime) then
                    table.insert(eligibleReceivers, {
                        userId = receiverId,
                        amount = receiverData.amount or 0
                    })
                end
            end

            -- Mark the airdrop as completed and save eligible receivers
            airdrop.status = "Completed"
            table.insert(completedAirdrops, {
                airdropId = airdrop.airdropId,
                eligibleReceivers = eligibleReceivers
            })

            -- Optional: Log completed airdrops (for debugging)
            print("Airdrop completed: " .. airdrop.airdropId)
        end

        -- Optional: Log and respond with the summary of completed airdrops
        local responseMessage = "Completed Airdrops: " .. #completedAirdrops
        print(responseMessage)
        ao.send({ Target = m.From, Data = responseMessage })

        -- Additional logic: Transfer tokens to eligible receivers
        for _, completedAirdrop in ipairs(completedAirdrops) do
            for _, receiver in ipairs(completedAirdrop.eligibleReceivers) do
                -- Transfer tokens (implement your token transfer logic here)
                print("Transferring " .. receiver.amount .. " tokens to user: " .. receiver.userId)
            end
        end
    end
)


function getBalance(userId, tokenProcessId)
    local balance = 0

    ao.send({
        Target = tokenProcessId,
        Tags = {
            Action = "Balance",
            Target = userId
        }
    })

    -- Debug log to verify the latest Inbox entry
    if Inbox[#Inbox] then
        print("Latest Inbox Entry: ", Inbox[#Inbox].Data, "From Token Process ID:", tokenProcessId)
        balance = tonumber(Inbox[#Inbox].Data) or 0
    else
        print("No data in Inbox for Token Process ID:", tokenProcessId)
    end
    return balance
end






-- Function to calculate the weighted airdrop amount based on balances across multiple token process IDs and ARSPoints
function calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount, arsPoints)
    local totalBalancesByToken = {} -- To track total balances per token
    local userBalancesByToken = {} -- To track each user's balance for each token
    local userFinalWeights = {} -- To track the final weights for all users
    local airdropPercentage = 0.8 -- 80% of the total amount to be distributed
    local weightedAirdropAmount = totalAirdropAmount * airdropPercentage
    
    -- Step 2: Fetch balances for all users across all token processes
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        totalBalancesByToken[tokenProcessId] = 0
        userBalancesByToken[tokenProcessId] = {}

        for _, userId in ipairs(qualifiedUsers) do
            -- Fetch balance for the user-token combination
            local balance = getBalance(userId, tokenProcessId)

            -- Update balances
            userBalancesByToken[tokenProcessId][userId] = balance
            totalBalancesByToken[tokenProcessId] = totalBalancesByToken[tokenProcessId] + balance
        end
    end

    -- Step 3: Include ARSPoints in weight calculation
    local totalArsPoints = 0
    for _, userId in ipairs(qualifiedUsers) do
        totalArsPoints = totalArsPoints + (arsPoints[userId] or 0)
    end

    -- Step 4: Calculate each user's final weight across all token processes and ARSPoints
    for _, userId in ipairs(qualifiedUsers) do
        userFinalWeights[userId] = 0

        -- Calculate weight from token balances
        for _, tokenProcessId in ipairs(tokenProcessIds) do
            local userBalance = userBalancesByToken[tokenProcessId][userId] or 0
            local totalBalanceForToken = totalBalancesByToken[tokenProcessId]
            local tokenWeight = 0.2 -- Each token process is weighted equally (20%)

            -- Calculate the weight for this user for this token process
            if totalBalanceForToken > 0 then
                local weight = (userBalance / totalBalanceForToken) * tokenWeight
                userFinalWeights[userId] = userFinalWeights[userId] + weight
            end
        end

        -- Calculate weight from ARSPoints
        local arsPointsWeight = 0.2 -- ARSPoints have a 20% weight
        if totalArsPoints > 0 then
            local userArsPoints = arsPoints[userId] or 0
            local weight = (userArsPoints / totalArsPoints) * arsPointsWeight
            userFinalWeights[userId] = userFinalWeights[userId] + weight
        end
    end

    -- Step 5 & 6: Calculate the airdrop amount for each user based on their weight
    for userId, weight in pairs(userFinalWeights) do
        local userAirdropAmount = weight * weightedAirdropAmount

        -- Debug: Log the calculated amount for each user
        print(string.format("Airdrop Amount -> User: %s, Weight: %.4f, Receives: %.2f", userId, weight, userAirdropAmount))

        -- Step 7: Distribute tokens to the user
        distributeTokens(userId, userAirdropAmount)
    end
end

-- Mock ARSPoints table (newly added)
local arsPoints = {
    ["user1"] = 100, -- Positive ARSPoints
    ["user2"] = -50, -- Negative ARSPoints (posts nonsense)
    ["user3"] = 200 -- High ARSPoints
}

-- Mock function to fetch token balances for a user
function getBalance(userId, tokenProcessId)
    -- Simulated balances for testing
    local mockBalances = {
        ["token1"] = { ["user1"] = 100, ["user2"] = 300, ["user3"] = 600 },
        ["token2"] = { ["user1"] = 200, ["user2"] = 400, ["user3"] = 400 },
        ["token3"] = { ["user1"] = 150, ["user2"] = 250, ["user3"] = 600 },
        ["token4"] = { ["user1"] = 50, ["user2"] = 50, ["user3"] = 300 }
    }
    return mockBalances[tokenProcessId] and mockBalances[tokenProcessId][userId] or 0
end

-- Mock function to distribute tokens to a user
function distributeTokens(userId, amount)
    if amount > 0 then
        print(string.format("Distributed %.2f tokens to %s", amount, userId))
    else
        print(string.format("No tokens distributed to %s due to zero balance or weight.", userId))
    end
end

-- Run the calculation
Handlers.add('completeAirdropXp', Handlers.utils.hasMatchingTag("Action", "completeAirdropXp"),
  function()
    -- Initialize and define inputs
    local qualifiedUsers = { "user1", "user2", "user3" }
    local tokenProcessIds = { "token1", "token2", "token3", "token4" }
    local totalAirdropAmount = 10000

    -- Call the airdrop calculation function
    calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount, arsPoints)

    -- Debug: Confirm the handler execution is complete
    print("Airdrop Calculation Completed")
  end
)



-- Function to calculate the weighted airdrop amount based on balances across multiple token process IDs

function calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount)
    local totalBalancesByToken = {} -- Track total balances by token
    local userBalancesByToken = {} -- Track user balances per token
    local distributedAmounts = {} -- Track distributed amounts per user
    print("Starting Airdrop Calculation...")

    -- Initialize total balances for each token
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        totalBalancesByToken[tokenProcessId] = 0
    end

    -- Fetch user balances for each token
    for _, userId in ipairs(qualifiedUsers) do
        userBalancesByToken[userId] = {}
        for _, tokenProcessId in ipairs(tokenProcessIds) do
            local balance = getBalance(userId, tokenProcessId)
            print("Fetched balance for User:", userId, "Token:", tokenProcessId, "Balance:", balance)
            
            userBalancesByToken[userId][tokenProcessId] = balance
            totalBalancesByToken[tokenProcessId] = totalBalancesByToken[tokenProcessId] + balance
        end
    end

    -- Debug: Print total balances by token
    print("Total Balances By Token:", tableToJson(totalBalancesByToken))

    -- Debug: Print user balances by token
    print("User Balances By Token:", tableToJson(userBalancesByToken))

    -- Calculate weights and distribute amounts
    for _, userId in ipairs(qualifiedUsers) do
        local userTotalWeightedAmount = 0
        for _, tokenProcessId in ipairs(tokenProcessIds) do
            local userBalance = userBalancesByToken[userId][tokenProcessId]
            local totalBalanceForToken = totalBalancesByToken[tokenProcessId]
            local weight = (totalBalanceForToken > 0) and (userBalance / totalBalanceForToken) or 0
            local weightedAmount = weight * totalAirdropAmount * 0.8 * 0.25 -- Each token is 25% weighted
            userTotalWeightedAmount = userTotalWeightedAmount + weightedAmount

            print("User:", userId, "Token:", tokenProcessId, "Weight:", weight, "Weighted Amount:", weightedAmount)
        end

        distributedAmounts[userId] = userTotalWeightedAmount
        print("User:", userId, "Total Weighted Amount:", userTotalWeightedAmount)
    end

    -- Distribute amounts to users
    for userId, amount in pairs(distributedAmounts) do
        print("Distributing", amount, "to User:", userId)
        -- Add your token transfer logic here
    end

    print("Airdrop Calculation Completed.")
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


-- Step 7: Pass the winners table to the distributeTokens function
distributeTokens(winners, airdropTokenId)

-- Updated distributeTokens function
function distributeTokens(userId,AirdropAmount, airdropTokenId)
    local i = 1
    while i <= #winners do
        local winner = winners[i]

        if winner.amount > 0 then
            print(string.format("Distributing %.2f tokens of Token ID: %s to %s", winner.amount, airdropTokenId, winner.userId))
            
             ao.send({
                Target = airdropTokenId,
                Action = "Transfer",
                Quantity = tostring(winner.amount),
                Recipient = tostring(winner.userId)
            })
            
            if Inbox[#Inbox].Data == 'Debit-Notice' then
            local success = true  
            else
                local success = false
            end
            if success then
                print(string.format("Successfully distributed tokens to %s. Removing from winners list.", winner.userId))
                table.remove(winners, i) -- Remove winner from the list
            else
                print(string.format("Failed to distribute tokens to %s. Retrying...", winner.userId))
                i = i + 1 -- Move to the next user in case of failure
            end
        else
            print(string.format("No tokens distributed to %s due to zero balance or negative weight.", winner.userId))        end
    end
end



Handlers.add(
    "completeAirdrops",
    Handlers.utils.hasMatchingTag("Action", "completeAirdrops"),
    function(m)
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Step 1: Look for all expired airdrops
        local expiredAirdrops = {}
        for appId, appData in pairs(airdropTable) do
            for _, airdrop in ipairs(appData.airdrops or {}) do
                if airdrop.endTime and tonumber(airdrop.endTime) <= currentTime then
                    table.insert(expiredAirdrops, airdrop)
                end
            end
        end

        -- Step 2: Loop through expired airdrops and check receivers
        local completedAirdrops = {}
        for _, airdrop in ipairs(expiredAirdrops) do
            local airdropReceivers = airdrop.airdropsReceivers or {}

            -- Step 3: Validate receivers and check time constraints
            local qualifiedUsers = {}
            for receiverId, receiverData in pairs(airdropReceivers) do
                if receiverData.time and tonumber(receiverData.time) >= tonumber(airdrop.startTime)
                    and tonumber(receiverData.time) <= tonumber(airdrop.endTime) then
                    table.insert(qualifiedUsers, {
                        userId = receiverId,
                    })
                end
            end
            local totalAirdropAmount = airdrop.amount
            local airdropTokenId = airdrop.tokenId

            
             local tokenProcessIds = { "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18", "xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10", "5d91yO7AQxeHr3XNWIomRsfqyhYbeKPG2awuZd-EyH4" }
            calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount, airdropTokenId)

            -- Mark the airdrop as completed and save eligible receivers
            airdrop.status = "Completed"
            table.insert(completedAirdrops, {
                airdropId = airdrop.airdropId,
                eligibleReceivers = eligibleReceivers
            })

            -- Optional: Log completed airdrops (for debugging)
            print("Airdrop completed: " .. airdrop.airdropId)
        end

        -- Optional: Log and respond with the summary of completed airdrops
        local responseMessage = "Completed Airdrops: " .. #completedAirdrops
        print(responseMessage)
        ao.send({ Target = m.From, Data = responseMessage })

        
    end
)




-- Function to calculate the weighted airdrop amount based on balances across multiple token process IDs and ARSPoints
function calculateAirdropWithMultipleTokens(qualifiedUsers, tokenProcessIds, totalAirdropAmount, arsPoints)
    local totalBalancesByToken = {} -- To track total balances per token
    local userBalancesByToken = {} -- To track each user's balance for each token
    local userFinalWeights = {} -- To track the final weights for all users
    local airdropPercentage = 0.8 -- 80% of the total amount to be distributed
    local weightedAirdropAmount = totalAirdropAmount * airdropPercentage
    
    -- Step 2: Fetch balances for all users across all token processes
    for _, tokenProcessId in ipairs(tokenProcessIds) do
        totalBalancesByToken[tokenProcessId] = 0
        userBalancesByToken[tokenProcessId] = {}

        for _, userId in ipairs(qualifiedUsers) do
            -- Fetch balance for the user-token combination
            local balance = getBalance(userId, tokenProcessId)

            -- Update balances
            userBalancesByToken[tokenProcessId][userId] = balance
            totalBalancesByToken[tokenProcessId] = totalBalancesByToken[tokenProcessId] + balance
        end
    end

    -- Step 3: Include ARSPoints in weight calculation
    local totalArsPoints = 0
    for _, userId in ipairs(qualifiedUsers) do
        totalArsPoints = totalArsPoints + (arsPoints[userId] or 0)
    end

    -- Step 4: Calculate each user's final weight across all token processes and ARSPoints
    for _, userId in ipairs(qualifiedUsers) do
        userFinalWeights[userId] = 0

        -- Calculate weight from token balances
        for _, tokenProcessId in ipairs(tokenProcessIds) do
            local userBalance = userBalancesByToken[tokenProcessId][userId] or 0
            local totalBalanceForToken = totalBalancesByToken[tokenProcessId]
            local tokenWeight = 0.2 -- Each token process is weighted equally (20%)

            -- Calculate the weight for this user for this token process
            if totalBalanceForToken > 0 then
                local weight = (userBalance / totalBalanceForToken) * tokenWeight
                userFinalWeights[userId] = userFinalWeights[userId] + weight
            end
        end

        -- Calculate weight from ARSPoints
        local arsPointsWeight = 0.2 -- ARSPoints have a 20% weight
        if totalArsPoints > 0 then
            local userArsPoints = arsPoints[userId] or 0
            local weight = (userArsPoints / totalArsPoints) * arsPointsWeight
            userFinalWeights[userId] = userFinalWeights[userId] + weight
        end
    end

    -- Step 5 & 6: Calculate the airdrop amount for each user based on their weight
    for userId, weight in pairs(userFinalWeights) do
        local userAirdropAmount = weight * weightedAirdropAmount

        -- Debug: Log the calculated amount for each user
        print(string.format("Airdrop Amount -> User: %s, Weight: %.4f, Receives: %.2f", userId, weight, userAirdropAmount))

        -- Step 7: Distribute tokens to the user
        distributeTokens(userId, userAirdropAmount)
    end
end







