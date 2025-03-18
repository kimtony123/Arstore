local json = require("json")


-- This process details
PROCESS_NAME = "aos TipsTable"
PROCESS_ID = "LkCdB2PkYRl4zTChv1DiTtiLqr5Qpu0cJ6V6mvHUnOo"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostoreP "
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
Tokens = Tokens or {}
AosPoints = AosPoints or {}
Transactions = Transactions or {}
TransactionCounter = TransactionCounter or 0




Tips = Tips  or {}
TipsTransactions = TipsTransactions or {}
TipsTransactionCounter = TipsTransactionCounter or 0


-- Function to generate a unique transaction ID
function GenerateTransactionId()
    TransactionCounter = TransactionCounter + 1
    return "TX" .. tostring(TransactionCounter)
end

-- Function to generate a unique transaction ID
function GenerateTipTransactionId()
    TipsTransactionCounter = TipsTransactionCounter + 1
    return "TX" .. tostring(TipsTransactionCounter)
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


-- Helper function to log  Tip transactions
function LogTipsTransaction(user, appId, transactionType, amount, currentTime,points,appName,appIconUrl)
    local transactionId = GenerateTipTransactionId()
    AosPoints[appId].users[user] = AosPoints[appId].users[user].points + points
    local currentPoints = AosPoints[appId].users[user] or 0 -- Add error handling if needed
    TipsTransactions[#TipsTransactions + 1] = {
            user = user,
            transactionid = transactionId,
            transactionType = transactionType,
            amount = amount,
            points = currentPoints,
            timestamp = currentTime,
            appName = appName,
            appIconUrl = appIconUrl
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


function GetBalance(userId, tokenProcessId)
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
        balance = (tonumber(Inbox[#Inbox].Data) or 0)
    else
        print("No data in Inbox for Token Process ID:", tokenProcessId)
    end
    return balance
end


Handlers.add(
    "AddTipsTable",
    Handlers.utils.hasMatchingTag("Action", "AddTipsTable"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local appId = m.Tags.appId
        local appName = m.Tags.appName
        local caller = m.From
        local user = m.Tags.user
        local appIconUrl = m.Tags.appIconUrl
        local tokenId = m.Tags.tokenId
        local tokenName = m.Tags.tokenName
        local tokenTicker = m.Tags.ticker
        local tokenDenomination = m.Tags.denomination

         if ARS ~= caller then
           SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end

        if not ValidateField(appName, "appName", m.From) then return end
        --if not ValidateField(tokenId, "tokenId", m.From) then return end
       -- if not ValidateField(tokenName, "tokenName", m.From) then return end
      --  if not ValidateField(tokenDenomination, "tokenDenomination", m.From) then return end
       -- if not ValidateField(tokenTicker, "tokenTicker", m.From) then return end
        if not ValidateField(appIconUrl, "appIconUrl", m.From) then return end
        if not ValidateField(user, "user", m.From) then return end


        -- Ensure global tables are initialized
        Tokens = Tokens or {}
        AosPoints = AosPoints or {}
        Transactions = Transactions or {}

        Tokens[appId] ={
            owner = user,
            appName = appName,
            appIconUrl = appIconUrl,
            tokenDenomination =  tokenDenomination ,
            tokenTicker =  tokenTicker ,
            tokenName = tokenName,
            tokenId = tokenId
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

        Tokens[#Tokens + 1] = {
            Tokens[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(user, appId, transactionType, amount, currentTime,points)
        local status = true
        -- Send responses back
        ao.send({
            Target = ARS,
            Action = "TipsRespons",
            Data = tostring(status)
        })
        print("Successfully Added Tips  table")
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
        
        -- Ensure appId exists in Tokens
        if Tokens[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if Tokens[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end

        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        Tokens[appId] = nil
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
        
        -- Ensure appId exists in Tokens
        if Tokens[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if Tokens[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        Tokens[appId].owner = newOwner
        Tokens[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
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
    "GetTokenBalance",
    Handlers.utils.hasMatchingTag("Action", "GetTokenBalance"),
    function(m)
        -- Extract parameters
        local appId = m.Tags.appId
        local userId = m.From

        -- Validate required fields
        if not ValidateField(appId, "appId", userId) then return end

        -- Check if appId exists in Tokens
        local tokenData = Tokens[appId]
        if  tokenData == nil then
            return SendFailure(userId, "Invalid appId: Token data not found")
        end

        -- Extract token denomination and process ID
        local tokenDenomination = tonumber(tokenData.tokenDenomination)
        local tokenProcessId = tokenData.tokenProcessId

        -- Validate tokenDenomination
        if type(tokenDenomination) ~= "number" or tokenDenomination < 0 then
            return SendFailure(userId, "Invalid token denomination")
        end

        -- Fetch raw balance from the token process
        local rawBalance = GetBalance(userId, tokenProcessId)

        if rawBalance == nil then
            return SendFailure(userId, "Failed to fetch balance")
        end

        -- Convert raw balance to human-readable format
        local formattedBalance = rawBalance / (10 ^ tokenDenomination)

        -- Send success response with the formatted balance
        SendSuccess(userId, string.format("Your balance is %.6f tokens", formattedBalance))
    end
)


Handlers.add(
    "TipsEarned ",
    Handlers.utils.hasMatchingTag("Action", "TipsEarned "),
    function(m)
        local appId = m.Tags.appId
        local user = m.From
        local amount = m.Tags.amount
        local currentTime = GetCurrentTime(m)
        -- Validate required fields
        if not ValidateField(appId, "appId", user) then return end

        -- Check if appId exists in Tokens
        local tokenData = Tokens[appId]
        if  tokenData == nil then
            return SendFailure(user, "Invalid appId: Token data not found")
        end

        local appIconUrl = tokenData.appIconUrl
        local appName = tokenData.appName
        local transactionType = "Project Creation."
        local amount = amount 
        local points = 5
        LogTipsTransaction(user, appId, transactionType, amount, currentTime,points,appName,appIconUrl)
    end
)

Handlers.add(
    "GetUserTipsStatistics",
    Handlers.utils.hasMatchingTag("Action", "GetUserTipsStatistics"),
    function(m)
        local userId = m.Tags.user

        -- Check if TipsTransactions table exists
        if not TipsTransactions or #TipsTransactions == 0 then
            return SendFailure(m.From, "Transactions table not found.")
        end

        -- Initialize user statistics
        local userStatistics = {
            totalEarnings = 0,
            tokens = {} -- Grouped by appName
        }

        -- Loop through the transactions table to gather user's data
        for _, transaction in pairs(TipsTransactions) do
            if transaction.user == userId then
                -- Extract token details
                local appName = transaction.appName
                local appIconUrl = transaction.appIconUrl
                local amount = transaction.amount

                -- Initialize token entry if it doesn't exist
                if  userStatistics.tokens[appName] == nil then
                    userStatistics.tokens[appName] = {
                        appName = appName,
                        appIconUrl = appIconUrl,
                        totalEarnings = 0,
                        transactions = {}
                    }
                end

                -- Add transaction details to the token entry
                local tokenEntry = userStatistics.tokens[appName]
                tokenEntry.transactions[#tokenEntry.transactions + 1] = {
                    amount = amount,
                    time = transaction.timestamp
                }

                -- Increment token-specific total earnings
                tokenEntry.totalEarnings = tokenEntry.totalEarnings + amount
                -- Increment overall total earnings
                userStatistics.totalEarnings = userStatistics.totalEarnings + amount
            end
        end

        -- Check if the user has any transactions
        if userStatistics.tokens == 0 then
            return SendFailure(m.From, "You have no earnings.")
        end

        -- Send success response with user statistics
        SendSuccess(m.From, userStatistics)
    end
)