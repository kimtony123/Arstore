local json = require("json")
local math = require("math")



-- This process details
PROCESS_NAME = "aos Aostore_Users"
PROCESS_ID = "1gXCLjiClxoVn42xPvVtEG-veXSWUbQzIlzjoGMSAvw"

-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"


Transactions = Transactions or {}
Users = Users or {}

TransactionCounter = TransactionCounter or 0


RewardCountLottery = RewardCountLottery or 0
RewardCountSignUp = RewardCountSignUp or 0
-- Constants

 REWARD_PER_MILESTONE = 200
 MILESTONE_INTERVAL = 2000

-- Function to handle rewards
function HandleSignUpReward(userId, userCount)
    local gift

    -- Check if the user count matches a milestone
    if userCount > 0 and userCount % MILESTONE_INTERVAL == 0 then
        -- Milestone reward
        gift = REWARD_PER_MILESTONE

         -- Calculate amount in base units (assuming 1 token = 1000 units)
        local amount = gift * 1000
        -- Transfer tokens
        ao.send({
        Target = ARS,
        Action = "Transfer",
        Quantity = tostring(amount),
        Recipient = tostring(userId)})


        SendSuccess(userId, string.format("Congrats! You are user number %d and have won %d AOS tokens!", userCount, gift))
    else
        -- Regular sign-up reward
        gift = 10

          -- Calculate amount in base units (assuming 1 token = 1000 units)
        local amount = gift * 1000
        -- Transfer tokens
        ao.send({
        Target = ARS,
        Action = "Transfer",
        Quantity = tostring(amount),
        Recipient = tostring(userId)})
       
        SendSuccess(userId, "Sign Up Successful, Welcome to Aostore! Here is a gift" ..gift)
    end
    
    -- Update global counters
    if gift == REWARD_PER_MILESTONE then
        RewardCountLottery = RewardCountLottery + gift
    else
        RewardCountSignUp = RewardCountSignUp + gift
    end
end


function TableToJson(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        local valueType = type(value)
        if valueType == "table" then
            value = TableToJson(value)
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

-- Function to get the current time in milliseconds
function GetCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end

-- Function to generate a unique transaction ID
function GenerateTransactionId()
    TransactionCounter = TransactionCounter + 1
    return "TX" .. tostring(TransactionCounter)
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

-- Helper function to log transactions
function LogTransaction(user, transactionType, amount, currentTime)
    local transactionId = GenerateTransactionId()
    local points = 0 
    Transactions[#Transactions + 1] = {
            user = user,
            transactionid = transactionId,
            transactionType = transactionType,
            amount = amount,
            points = points,
            timestamp = currentTime
        }
end


Handlers.add(
    "AddAddress",
    Handlers.utils.hasMatchingTag("Action", "AddAddress"),
    function(m)
        local userId = m.From
        local currentTime = GetCurrentTime(m)

        Users = Users or {}
        Users.count = Users.count or 0
        Users.users = Users.users or {}
        Users.countHistory = Users.countHistory or {}

           -- Check if the user already exists in the verifiedUsers list
        if Users.users[userId] then
            SendSuccess(userId , "Welcome back, user: " .. userId)
            return
        end
        
        -- Add the new user to the verifiedUsers table
        Users.users[userId] = {
            time = currentTime 
        }

        -- Increment the count of verified users
        Users.count = Users.count + 1
        -- Update the countHistory
        table.insert(Users.countHistory, { time = currentTime, count = Users.count })
        
        local totalRewards = RewardCountLottery + RewardCountSignUp
        if totalRewards >= 2000000 then
            SendSuccess(userId, "Sign Up Succesful, Welcome to Aostore.") 
            return
        end
        
        local userCount = Users.count
        HandleSignUpReward(userId, userCount)
    end
)

