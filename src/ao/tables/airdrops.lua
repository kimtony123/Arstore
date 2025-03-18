local json = require("json")


-- This process details
PROCESS_NAME = "aos Airdrops_Table"
PROCESS_ID = "XkAtx1XJse3MMv4MrT5aRQbBu7_i-gTOE7kNmZj6Z8o"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostoreP "
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"


-- Feature Requests details
PROCESS_NAME_FEATURE_REQUEST_TABLE = "aos featureRequestsTable"
PROCESS_ID_FEATURE_REQUEST_TABLE = "YGoIdaqLZauaH3aNLKyWdoFHTg0Voa5O3NhCMWKHRtY"


-- Favorites process details
PROCESS_NAME_FAVORITES_TABLE = "aos Favorites_Table"
PROCESS_ID_FAVORITES_TABLE  = "2aXLWDFCbnxxBb2OyLmLlQHwPnrpN8dDZtB9Y9aEdOE"


-- DevForum Table process
PROCESS_NAME_DEV_FORUM_TABLE = "aos DevForumTable"
PROCESS_ID_DEV_FORUM_TABLE = "V7KLJ9Fc48sb6VstzR3JPSymVhrF7dlP-Vt4W25-7bo"

-- Bug Reports Table process
PROCESS_NAME_BUG_REPORT_TABLE = "aos Bug_Report_Table"
PROCESS_ID_BUG_REPORT_TABLE  = "x_CruGONBzwAOJoiTJ5jSddG65vMpRw9uMj9UiCWT5g"


-- Reviews Table process
PROCESS_NAME_REVIEW_TABLE = "aos Reviews_Table"
PROCESS_ID_REVIEW_TABLE = "-E8bZaG3KJMNqwCCcIqFKTVzqNZgXxqX9Q32I_M3-Wo"

-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"



-- tables 
AirdropsTable = AirdropsTable or {}
AosPoints  = AosPoints or {}
ExpiredAirdrops = ExpiredAirdrops or {}
Transactions = Transactions or {}
AidropCounter = AidropCounter or 0


-- Helper function to log transactions
function LogTransaction(user, appId, transactionType, amount, currentTime, points)
    local transactionId = GenerateTransactionId()
    AosPoints[appId].users[user] = AosPoints[appId].users[user].points + points
    local currentPoints = AosPoints[appId].users[user] or 0 -- Add error handling if needed
    Transactions[#Transactions + 1] = {
            user = user,
            transactionid = transactionId,
            transactionType = transactionType,
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        }
end

-- Response helper functions
function SendSuccess(target, message)
    ao.send({
        Target = target,
        Data = TableToJson({
            code = 200,
            message = "success",
            data = message
        })
    })
end

function SendFailure(target, message)
    ao.send({
        Target = target,
        Data = TableToJson({
            code = 404,
            message = "failed",
            data = message
        })
    })
end



function ValidateField(value, fieldName, target)
    if not value then
        SendFailure(target, fieldName .. " is missing or empty")
        return false
    end
    return true
end


-- Function to get the current time in milliseconds
function GetCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end



-- Function to generate a unique transaction ID
function GenerateAirdropId()
    AidropCounter = AidropCounter + 1
    return "TX" .. tostring(AidropCounter)
end

Handlers.add(
    "AddAirdropsTable",
    Handlers.utils.hasMatchingTag("Action", "AddAirdropsTable"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local airdropId = GenerateAirdropId()
        local appId = m.Tags.appId
        local user  = m.Tags.user
        local profileUrl = m.Tags.profileUrl
        local username = m.Tags.username
        local appIconUrl = m.Tags.appIconUrl
        local appName = m.Tags.appName
        local caller = m.From


        print("Here is the caller Process ID"..caller)


        if ARS ~= caller then
           SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end
        -- Field validation examples
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(user, "user", m.From) then return end
        if not ValidateField(appIconUrl, "appIconUrl", m.From) then return end
        if not ValidateField(appName, "appName", m.From) then return end

        -- Ensure global tables are initialized
        AirdropsTable = AirdropsTable or {}
        AosPoints = AosPoints or {}
        Transactions = Transactions or {}

       AirdropsTable[appId] = {
  airdrops = {
    [airdropId] = {
      airdropId = airdropId,
      owner = user,
      appId = appId,
      tokenId = ARS,
      amount = 5,
      timestamp = currentTime,
      appName = appName,
      appIconUrl = appIconUrl,
      status = "Pending",  -- (Pending, Active, Completed)
      airdropsReceivers = "ReviewsTable",
      startTime = currentTime,
      endTime = currentTime + 3600,
      minAosPoints = 150,
      description = "Review and rate our project between today and 8th February and earn AirdropsTable ",
      unverifiedParticipants = { [user] = { time = currentTime, Eligible = false } },
      verifiedParticipants = {},
      claimedUsers = {}  -- To track users who have claimed rewards
    }
  },
  count = 1,
  countHistory = { { time = currentTime, count = 1 } },
}
        AosPoints[appId] = {
            appId = appId,
            status = false,
            totalPointsApp = 5,
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { time = currentTime , points = 5 }
            }
        }

        AirdropsTable[#AirdropsTable + 1] = {
            AirdropsTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
       
        -- Update statuses to true after creation
        AirdropsTable[appId].status = true
        AosPoints[appId].status = true

        local status = true

         ao.send({
            Target = ARS,
            Action = "AirdropRespons",
            Data = tostring(status)
        })
        -- Send success response
        print("Successfully Added Bug Report Table table")
    end
)


Handlers.add(
    "DeleteApp",
    Handlers.utils.hasMatchingTag("Action", "DeleteApp"),
    function(m)

        local appId = m.Tags.appId
        local owner = m.Tags.owner
        local caller = m.From
        local currentTime = GetCurrentTime(m)

        if ARS ~= caller then
            SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end
        
        -- Ensure appId exists in AirdropsTable 
        if AirdropsTable [appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if AirdropsTable [appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end

        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        AirdropsTable [appId] = nil
        print("Sucessfully Deleted App" )

    end
)

Handlers.add(
    "TransferAppOwnership",
    Handlers.utils.hasMatchingTag("Action", "TransferAppOwnership"),
    function(m)
        local appId = m.Tags.appId
        local newOwner = m.Tags.NewOwner
        local caller = m.From
        local currentTime = GetCurrentTime()
        local currentOwner = m.Tags.currentOwner

         -- Check if PROCESS_ID called this handler
        if ARS ~= caller then
            SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end
        
        -- Ensure appId exists in AirdropsTable 
        if AirdropsTable [appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if AirdropsTable [appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        AirdropsTable [appId].owner = newOwner
        AirdropsTable [appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    end
)




Handlers.add(
    "DepositConfirmedN",
    Handlers.utils.hasMatchingTag("Action", "DepositConfirmedN"),
    function(m)
        local userId = m.From
        local appId = m.Tags.appId
        local tokenId = m.Tags.tokenId
        local tokenName = m.Tags.tokenName
        local tokenTicker = m.Tags.ticker
        local tokenDenomination = m.Tags.denomination
        local amount = tonumber(m.Tags.amount)
        local currentTime = GetCurrentTime(m)
        local airdropId = GenerateAirdropId()


        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(tokenId, "tokenId", m.From) then return end
        if not ValidateField(tokenName, "tokenName", m.From) then return end
        if not ValidateField(tokenDenomination, "tokenDenomination", m.From) then return end
        if not ValidateField(tokenTicker, "tokenTicker", m.From) then return end
        if not ValidateField(amount, "amount", m.From) then return end

        

         -- Ensure appId exists in BugsReportsTable
        if AirdropsTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified App" )
            return
        end

        -- Check if the App exists
        local airdop  = AirdropsTable[appId]
        
        local appName = AirdropsTable[appId].appName
        local tokenDenomination = AirdropsTable[appId].tokenDenomination
        -- Validate ownership: only the App Owner can call this handler
        if airdop.owner ~= userId then
            SendFailure(m.From ,"You are not authorized to perform this action. Only the App Owner can confirm deposits." )
            return
        end

       
        local status = "Pending"

        -- Insert the new airdrop into the appId's airdrops list
        airdop.airdrops[airdropId] = {
            timestamp = currentTime,
            status = status,
            airdropId = airdropId,
            appId = appId,
            appName = appName,
            owner = userId,
            amount = amount,
            tokenId = tokenId,
            tokenDenomination = tokenDenomination
        }

        -- Update count and history
        airdop.count = (airdop.count or 0) + 1

        airdop.countHistory[#airdop.countHistory + 1] = {
            count = airdop.count,
            time = currentTime
        }

        local transactionType = " Airdop  Creation."
        local amount = 0
        local points = 200
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
       

        -- Send confirmation back to the App Owner
        SendSuccess(m.From, "Deposit confirmed for AppId: " .. appId .. ", ProcessId: " .. tokenId .. ", Amount: " .. amount)
        
    end
)





Handlers.add(
    "getAllAirdropsN",
    Handlers.utils.hasMatchingTag("Action", "getAllAirdropsN"),
    function(m)

        -- Check if the table is empty
        if AirdropsTable == nil then
            SendFailure(m.From , "Airdrops is empty.")
            return
        end

        -- Optionally flatten the data into a list
        local flatAirdrops = {}
        for appId, appData in pairs(AirdropsTable) do
            for _, airdrop in ipairs(appData.airdrops) do

            flatAirdrops[#flatAirdrops + 1] = airdrop
            end
        end

        SendSuccess (m.From , flatAirdrops)
      end
)


Handlers.add(
    "getAirdropsByAppId",
    Handlers.utils.hasMatchingTag("Action", "getAirdropsByAppId"),
    function(m)
        -- Extract AppId from the message tags
        local appId = m.Tags.appId

        if not ValidateField(appId, "appId", m.From) then return end

        -- Ensure appId exists in BugsReportsTable
         if AirdropsTable[appId] == nil then
             SendFailure(m.From , "Airdrops not Found.")
            return
        end
        -- Fetch the info
        local airdropsInfo = AirdropsTable[appId].airdrops

        -- Check if there are reviews
        if #airdropsInfo == 0 then
            SendFailure(m.From , "No bug Reports Found for this AppId.")
          return
        end
        SendSuccess(m.From , airdropsInfo)
        end
)


Handlers.add(
    "getOwnerAirdropsN",
    Handlers.utils.hasMatchingTag("Action", "getOwnerAirdropsN"),
    function(m)
        local userId = m.From

        -- Check if the airdrops table exists
        if AirdropsTable == nil then
            SendFailure(m.From , "Airdrops not Found.")
            return
        end

        -- Filter airdrops by owner
        local ownerAirdrops = {}
        for appId, appData in pairs(AirdropsTable) do
            if appData.airdrops then
                for _, airdrop in ipairs(appData.airdrops) do
                    if airdrop.owner == userId then
                    ownerAirdrops[#ownerAirdrops + 1] = airdrop
                    end
                end
            end
        end

        SendSuccess(m.From ,ownerAirdrops )
    end
)





Handlers.add(
    "FetchAirdropDataN",
    Handlers.utils.hasMatchingTag("Action", "FetchAirdropDataN"),
    function(m)
        local user = m.From
        local appId = m.Tags.appId 
        local airdropId = m.Tags.airdropId

      
        if not ValidateField(airdropId, "airdropId", m.From) then return end
        if not ValidateField(appId, "appId", m.From) then return end

        if AirdropsTable[appId].airdrops[airdropId]  == nil then
            SendFailure(m.From, "Airdrop does not exists for that AppId..")
            return
        end

        -- Check if the Airdrop exists
        local airdropFound = AirdropsTable[appId].airdrops[airdropId]
        

        SendSuccess(m.From ,airdropFound)

    end
)



Handlers.add(
    "FinalizeAirdropN",
    Handlers.utils.hasMatchingTag("Action", "FinalizeAirdropN"),
    function(m)
        local airdropId = m.Tags.airdropId
        local appId = m.Tags.appId
        local airdropsReceivers = m.Tags.airdropsreceivers
        local description = m.Tags.description
        local startTime = tonumber(m.Tags.startTime) -- Convert to number
        local endTime = tonumber(m.Tags.endTime) -- Convert to number
        local currentTime = GetCurrentTime(m)
        local minAosPoints = m.Tags.minAosPoints

        print("Finalizing Airdrop with ID: " .. (airdropId or "nil"))


        if not ValidateField(airdropId, "airdropId", m.From) then return end
        if not ValidateField(airdropsReceivers, "airdropsReceivers", m.From) then return end
        if not ValidateField(startTime, " startTime", m.From) then return end
        if not ValidateField(endTime, "endTime", m.From) then return end

        -- Convert startTime and endTime to milliseconds
        startTime = startTime * 1000
        endTime = endTime * 1000

        -- Validate that endTime is greater than startTime
        if endTime <= startTime then
            SendFailure(m.From , "EndTime must be greater than StartTime." )
            return
        end

        if AirdropsTable[appId].airdrops[airdropId]  == nil then
            SendFailure(m.From, "Airdrop does not exists for that AppId..")
            return
        end

        -- Check if the Airdrop exists
        local airdropFound = AirdropsTable[appId].airdrops[airdropId]
        
        -- Update the Airdrop with new information
        airdropFound.airdropsReceivers = airdropsReceivers
        airdropFound.startTime = startTime
        airdropFound.endTime = endTime
        airdropFound.status = "Ongoing" -- Update status to Ongoing
        airdropFound.description = description
        airdropFound.minAosPoints = minAosPoints
        local transactionType = " Airdop Finalization."
        local amount = 0
        local points = 100
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From ,"Airdrop finalized successfully for ID: " .. airdropId )
        -- Log the updated Airdrop (Optional)
        print("Updated Airdrop: " .. tableToJson(airdropFound))
    end
)


Handlers.add(
    "FinalizeAirdropN",
    Handlers.utils.hasMatchingTag("Action", "FinalizeAirdropN"),
    function(m)
        local airdropId = m.Tags.airdropId
        local appId = m.Tags.appId
     -- Convert to number
        local currentTime = GetCurrentTime(m)
        

        print("Finalizing Airdrop with ID: " .. (airdropId or "nil"))


        if not ValidateField(airdropId, "airdropId", m.From) then return end
        if not ValidateField(appId, "appId", m.From) then return end
      

        if AirdropsTable[appId].airdrops[airdropId]  == nil then
            SendFailure(m.From, "Airdrop does not exists for that AppId..")
            return
        end

        -- Check if the Airdrop exists
        local airdropFound = AirdropsTable[appId].airdrops[airdropId]
  
        if currentTime >= airdropFound.endTime then
            SendFailure(m.From , "Wait for Airdrop To expire." )
            return
        end
        local transactionType = "Deleted Airdrop."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        airdropFound = nil
        SendSuccess(m.From ,"Airdrop Deleted Successfully  ")
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
        for _, transaction in ipairs(Transactions) do
            -- Skip nil transactions
            if transaction ~= nil and transaction.user == user then
                user_transactions[#user_transactions + 1] =  transaction
            end
        end
           -- If no transactions found, return early
        if user_transactions == nil then
            SendFailure(m.From, "You have no transactions.")
            return
        end
        SendSuccess(m.From ,user_transactions )
        end
)


Handlers.add(
    "GetUserStatistics",
    Handlers.utils.hasMatchingTag("Action", "GetUserStatistics"),
    function(m)
        local userId = m.From

        -- Check if transactions table exists
        if not Transactions then
            SendFailure(m.From , "Transactions table not found.")
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
        for _, transaction in pairs(Transactions) do
            if transaction.user == userId then
                hasTransactions = true


                -- Add transaction details to the statistics

                userStatistics.transactions[#userStatistics.transactions + 1] =  {
                    amount = transaction.amount,
                    time = transaction.timestamp
                }
                -- Increment total earnings
                userStatistics.totalEarnings = userStatistics.totalEarnings + transaction.amount
            end
        end

        -- If no transactions found, return early
        if hasTransactions == nil then
            SendFailure(m.From, "You have no earnings.")
            return
        end
        SendSuccess (m.From , userStatistics)
      end
)

