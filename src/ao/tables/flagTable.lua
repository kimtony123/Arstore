
local json = require("json")


-- This process details
PROCESS_NAME = "aos Flag_Table"
PROCESS_ID = "BpGlNnMA09jM-Sfh6Jldswhp5AnGTCST4MxG2Dk-ABo"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostore_main"
PROCESS_ID_MAIN = "QT_bqv-thVbp_uPFuotxpDu1FDpppXDs1aEre23HX_c"


-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
AosPoints = AosPoints or {}
Transactions = Transactions or {}
FlagTable = FlagTable or {}

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
    "AddFlagTableX",
    Handlers.utils.hasMatchingTag("Action", "AddFlagTableX"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local appId = m.Tags.appId
        local user  = m.Tags.user
        local caller = m.From

        print("Here is the caller Process ID" .. caller)

         if ARS ~= caller then
           SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end

         -- Field validation examples
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(user, "user", m.From) then return end
       
        
        -- Ensure global tables are initialized
        FlagTable = FlagTable or {}
        AosPoints = AosPoints or {}
        
        FlagTable[appId] = {
            appId = appId,
            owner = user, 
            status = false,
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { flagged = false, time = currentTime }
            }
        }

        -- Create the AosPoints table for this appId
        AosPoints[appId] = {
            appId = appId,
            status = false,
            totalPointsApp = 0,
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { time = currentTime , points = 0 }
            }
        }

        FlagTable[#FlagTable + 1] = {
            FlagTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    
        -- Update statuses to true after creation
        FlagTable[appId].status = true
        AosPoints[appId].status = true

        local status = true
        -- Send responses back
        ao.send({
            Target = ARS,
            Action = "FlagRespons",
            Data = tostring(status)
        })
        print("Successfully Added Flag table")
    end
)


Handlers.add(
    "DeleteApp",
    Handlers.utils.hasMatchingTag("Action", "DeleteApp"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local appId = m.Tags.appId
        local owner = m.Tags.owner
        local caller = m.From


        if ARS ~= caller then
            SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end
        
        -- Ensure appId exists in FlagTable
        if FlagTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if FlagTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end

        FlagTable[appId] = nil
        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)

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
        
        -- Ensure appId exists in FlagTable
        if FlagTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if FlagTable[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        FlagTable[appId].owner = newOwner
        FlagTable[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    end
)



Handlers.add(
    "FlagApp",
    Handlers.utils.hasMatchingTag("Action", "FlagApp"),
    function(m)
        -- Validate required tag
        if not m.Tags.appId then
            ao.send({ Target = m.From, Data = "appId is missing or empty." })
            return
        end

        local appId = m.Tags.appId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Ensure FlagTable is initialized
        FlagTable = FlagTable or {}

        if FlagTable[appId] == nil then
            SendFailure(m.From, "App not Found.")
            return
        end
        
        -- Check if the user has already flagged the App
        if FlagTable[appId].users[user] and FlagTable[appId].users[user].flagged then
            SendFailure(m.From , "You have already flagged this App.")
            return
        end

        -- Mark the user as flagged in the table
        FlagTable[appId].users[user] = { flagged = true, time = currentTime }

        -- Increment the flag count and record the new count in countHistory
        FlagTable[appId].count = FlagTable[appId].count + 1

         FlagTable[appId].countHistory[#FlagTable[appId].countHistory + 1] = { time = currentTime, count = FlagTable[appId].count }
        local transactionType = "Flagged Project."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Project flagged successfully.")
    end
)





Handlers.add(
    "GetFlagCount",
    Handlers.utils.hasMatchingTag("Action", "GetFlagCount"),
    function(m)
        local appId = m.Tags.appId
        if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in FlagTable
        if FlagTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = FlagTable[appId].count or 0
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
    "ClearFlagTable",
    Handlers.utils.hasMatchingTag("Action", "ClearFlagTable"),
    function(m)
        FlagTable = {}
    end
)

