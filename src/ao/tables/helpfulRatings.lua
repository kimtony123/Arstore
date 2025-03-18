
local json = require("json")



-- This process details
PROCESS_NAME = "aos Helpful_Table"
PROCESS_ID = "bQVmkwCFW7K2hIcVslihAt4YjY1RIkEkg5tXpZDGbbw"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostore_main"
PROCESS_ID_MAIN = "QT_bqv-thVbp_uPFuotxpDu1FDpppXDs1aEre23HX_c"


-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
AosPoints = AosPoints or {}
Transactions = Transactions or {}
HelpfulRatingsTable = HelpfulRatingsTable or {}
UnhelpfulRatingsTable = UnhelpfulRatingsTable or {}


-- counters variables
TransactionCounter  = TransactionCounter or 0


-- Function to get the current time in milliseconds
function GetCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end

-- Function to generate a unique transaction ID
function GenerateTransactionId()
    TransactionCounter = TransactionCounter + 1
    return "TX" .. tostring(TransactionCounter)
end



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




Handlers.add(
    "AddHelpfulTableX",
    Handlers.utils.hasMatchingTag("Action", "AddHelpfulTableX"),
    function(m)
        local currentTime = getCurrentTime(m)
        local appId = m.Tags.appId
        local user = m.From
        local caller = m.From
        
        print("Here is the caller Process ID" .. caller)
        
        if ARS ~= caller then
            return SendFailure(m.From, "Only the Main process can call this handler.")
        end

         -- Field validation examples
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(user, "user", m.From) then return end
       

        -- Ensure global tables are initialized
        HelpfulRatingsTable = HelpfulRatingsTable or {}
        UnhelpfulRatingsTable = UnhelpfulRatingsTable or {}
        AosPoints = AosPoints or {}
        
        HelpfulRatingsTable[appId] = {
            appId = appId,
            owner = user,
            status = false,
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { rated = true , time = currentTime }
            }
        }

        UnhelpfulRatingsTable[appId] = {
            appId = appId,
            owner = user,
            status = false,
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { rated = false , time = currentTime }
            }
        }

        -- Create the AosPoints table for this appId
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

        HelpfulRatingsTable[#HelpfulRatingsTable + 1] = {
            HelpfulRatingsTable[appId]
        }

        UnhelpfulRatingsTable[#UnhelpfulRatingsTable + 1] = {
            UnhelpfulRatingsTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }
        
        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    
        
        -- Update statuses to true after creation
        HelpfulRatingsTable[appId].status = true
        AosPoints[appId].status = true

        local status = true
        -- Send responses back
        ao.send({
            Target = ARS,
            Action = "HelpfulRespons",
            Data = tostring(status)
        })
        print("Successfully Added Helpful Rating table")
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

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end

        
        -- Ensure appId exists in FlagTable
        if HelpfulRatingsTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if HelpfulRatingsTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end

         if UnhelpfulRatingsTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

         -- Check if the user making the request is the current owner
        if UnhelpfulRatingsTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end

        HelpfulRatingsTable[appId] = nil
        UnhelpfulRatingsTable[appId] = nil
        FeatureRequestsTable[appId] = nil
        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
      
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

             
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        
        -- Ensure appId exists in FlagTable
        if HelpfulRatingsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        -- Ensure appId exists in FlagTable
        if UnhelpfulRatingsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
   
        -- Check if the user making the request is the current owner
        if HelpfulRatingsTable[appId].owner ~= currentOwner then
            SendFailure(m.From, "You are not the owner of this app.")
            return
        end

         if UnhelpfulRatingsTable[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        HelpfulRatingsTable[appId].owner = newOwner
        HelpfulRatingsTable[appId].mods[currentOwner] = newOwner

        UnhelpfulRatingsTable[appId].owner = newOwner
        UnhelpfulRatingsTable[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    end
)





Handlers.add(
    "HelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "HelpfulRatingApp"),
    function(m)

        local appId = m.Tags.appId
        local user = m.From
        local currentTime = GetCurrentTime(m)

         -- Get the app data for helpful and unhelpful ratings
        local appHData = HelpfulRatingsTable[appId]
        local appUhData = UnhelpfulRatingsTable[appId]

        -- Check if the user has already marked the rating as helpful
        if appHData.users[user].rated then
            SendFailure(m.From , "You have already marked this rating as helpful.")
            return
        end

        -- Check if the user has previously marked the app as unhelpful
        if appUhData.users[user].rated then
            -- Remove the user from the unhelpful users table
            appUhData.users[user] = nil
            -- Decrement the unhelpful count
            appUhData.count = appUhData.count - 1

            appUhData.countHistory[#appUhData.countHistory + 1] = { time = currentTime, count = appHData.count }
            
            local transactionType = "Previously Rated Unhelpful App."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        end

        -- Add the user to the helpful users table
        appHData.users[user] = { rated = true, time = currentTime }
        -- Increment the helpful count
        appHData.count = appHData.count + 1
        -- Log the count change in helpful count history

         appHData.countHistory[#appHData.countHistory + 1] = { time = currentTime, count = appHData.count }
        
        local transactionType = " Rated App Helpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
     SendSuccess(m.From , "Rated Helpful Successfully!")
    end
)



-- Add Helpful Rating Handler
Handlers.add(
    "UnhelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "UnhelpfulRatingApp"),
    function(m)


        local appId = m.Tags.appId
        local user = m.From
        local currentTime = GetCurrentTime(m)

        -- Get the app data for helpful and unhelpful ratings
        local appHData = HelpfulRatingsTable[appId]
        local appUhData = UnhelpfulRatingsTable[appId]

        -- Check if the user has already marked the rating as unhelpful
        if appUhData.users[user].rated then
            SendFailure (m.From , "You have already marked this rating as helpful.")
            return
        end

        -- Check if the user has previously marked the app as helpful
        if appHData.users[user].rated then
            -- Remove the user from the helpful users table
            appHData.users[user] = nil
            -- Decrement the helpful count
            appHData.count = appHData.count - 1

            appHData.countHistory[#appHData.countHistory + 1] = { time = currentTime, count = appHData.count }

            local transactionType = "Previously Rated helpful App."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        end

        -- Add the user to the unhelpful users table
        appUhData.users[user] = { rated = true, time = currentTime }
        -- Increment the unhelpful count
        appUhData.count = appUhData.count + 1

        appUhData.countHistory[#appUhData.countHistory + 1] = { time = currentTime, count = appHData.count }

        local transactionType = " Rated App Helpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Rated Unhelpful Successfully!")
        end
)


Handlers.add(
    "GetHelpfulCount",
    Handlers.utils.hasMatchingTag("Action", "GetHelpfulCount"),
    function(m)
        local appId = m.Tags.appId
       if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in FlagTable
        if HelpfulRatingsTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = HelpfulRatingsTable[appId].count or 0
        SendSuccess(m.From , count)
    end
)


Handlers.add(
    "GetUnHelpfulCount",
    Handlers.utils.hasMatchingTag("Action", "GetUnHelpfulCount"),
    function(m)
        local appId = m.Tags.appId
       if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in FlagTable
        if UnhelpfulRatingsTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = UnhelpfulRatingsTable[appId].count or 0
        SendSuccess(m.From , count)
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




Handlers.add(
    "ClearHelpfulTable",
    Handlers.utils.hasMatchingTag("Action", "ClearHelpfulTable"),
    function(m)
        HelpfulRatingsTable = {}
    end
)



Handlers.add(
    "ClearUnHelpfulTable",
    Handlers.utils.hasMatchingTag("Action", "ClearUnHelpfulTable"),
    function(m)
        UnhelpfulRatingsTable = {}
    end
)