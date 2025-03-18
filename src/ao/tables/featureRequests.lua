local json = require("json")


-- This process details
PROCESS_NAME = "aos FeatureRequestsTable"
PROCESS_ID = "YGoIdaqLZauaH3aNLKyWdoFHTg0Voa5O3NhCMWKHRtY"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostoreP "
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"


-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
FeatureRequestsTable = FeatureRequestsTable or {}
AosPoints  = AosPoints or {}
Transactions = Transactions or {}

-- counters variables
FeatureRequestCounter = FeatureRequestCounter or 0
ReplyCounter = ReplyCounter or 0
TransactionCounter  = TransactionCounter or 0



-- Function to get the current time in milliseconds
function GetCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end

-- Function to generate a unique Dev forum ID
function GeneratefeatureRequestId()
    FeatureRequestCounter = FeatureRequestCounter + 1
    return "TX" .. tostring(FeatureRequestCounter)
end

-- Function to generate a unique transaction ID
function GenerateTransactionId()
    TransactionCounter = TransactionCounter + 1
    return "TX" .. tostring(TransactionCounter)
end

-- Function to generate a unique transaction ID
function GenerateReplyId()
    ReplyCounter = ReplyCounter + 1
    return "TX" .. tostring(ReplyCounter)
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

function DetermineUserRank(user, appId, providedRank)
    
    -- Get app data with safety checks
    local appData = FeatureRequestsTable[appId] or {}
    local owner = appData.owner
    local mods = appData.mods or {}

    -- Determine rank priority
    if user == owner then
        return "Architect" -- Highest priority
    elseif mods[user] then
        return "Agent"     -- Secondary priority
    else
        return providedRank -- Default/fallback rank
    end
end



Handlers.add(
    "AddFeatureRequestsTable",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureRequestsTable"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local featureRequestId  = GeneratefeatureRequestId()
        local replyId = GenerateReplyId()
        local appId = m.Tags.appId
        local user  = m.Tags.user
        local profileUrl = m.Tags.profileUrl
        local username = m.Tags.username
        local caller = m.From
        
        print("Here is the caller Process ID"..caller)

        if ARS ~= caller then
           SendFailure(m.From, "Only the Main process can call this handler.")
        end
        -- Field validation examples
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(user, "user", m.From) then return end

        -- Ensure global tables are initialized
        FeatureRequestsTable = FeatureRequestsTable or {}
        AosPoints = AosPoints or {}
        Transactions = Transactions or {}

        FeatureRequestsTable[appId] = {
            appId = appId,
            status = false,
            owner = user,
            mods = { [user] = { permissions = {replyFeatureRequests = true, },  time = currentTime } },
            requests = {
                [featureRequestId] = {
                featureRequestId = featureRequestId,
                user = user,
                time = currentTime,
                rank = "Architect",
                edited = false,
                profileUrl = profileUrl,
                username = username,
                comment = "Hey, how do I get started on aocomputer?",
                header = "Integration and Dependencies",
                -- Thread status and history tracking
                status = "Open",  -- Possible values: Open, Resolved, Closed
                statusHistory = { { time = currentTime, status = "Open" } },
                voters = {
                        foundHelpful = { 
                            count = 1,
                            countHistory = { { time = currentTime, count = 1 } },
                            users = { [user] = {voted = true, time = currentTime } }
                        },
                        foundUnhelpful = { 
                            count = 0,
                            countHistory = { { time = currentTime, count = 0 } },
                            users = { [user] = {voted = false, time = currentTime } }
                        }
                    },
                -- Replies stored as a table with replyId as the key
                replies = {
                [replyId] = {
                    replyId = replyId,
                    user = user,
                    profileUrl = profileUrl,
                    edited = false,
                    username = username,
                    rank = "Architect",
                    comment = "Hey, here is a link to get you started.",
                    timestamp = currentTime,
                    voters = {
                        foundHelpful = { 
                            count = 1,
                            countHistory = { { time = currentTime, count = 1 } },
                            users = { [user] = {voted = true, time = currentTime } }
                        },
                        foundUnhelpful = { 
                            count = 0,
                            countHistory = { { time = currentTime, count = 0 } },
                            users = { [user] = {voted = false, time = currentTime } }
                        }
                    },
                    
                }
            }
        }},
    count = 1,
    countHistory = { { time = currentTime, count = 1 } },
    users = { [user] = { time = currentTime } }
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

        FeatureRequestsTable[#FeatureRequestsTable + 1] = {
            FeatureRequestsTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    
        FeatureRequestsTable[appId].status = true
        AosPoints[appId].status = true

        local status = true
        -- Send responses back
        ao.send({
            Target = ARS,
            Action = "FeatureRequestRespons",
            Data = tostring(status)
        })
        print("Successfully Added Feature Request table")
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
        
        -- Ensure appId exists in FeatureRequestsTable
        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if FeatureRequestsTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end
        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
      
        FeatureRequestsTable[appId] = nil
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
        
        -- Ensure appId exists in FeatureRequestsTable
        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if FeatureRequestsTable[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        FeatureRequestsTable[appId].owner = newOwner
        FeatureRequestsTable[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    end
)


Handlers.add(
    "AddFeatureRequest",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureRequest"),
    function(m)

        local appId = m.Tags.appId
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local featureRequestId = GeneratefeatureRequestId()
        local currentTime = GetCurrentTime(m)
        local providedRank = m.Tags.rank
        local header = m.Tags.header

        -- Ensure appId exists in FeatureRequestsTable
        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified appId..")
            return
        end

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
        if not ValidateField(header, "header", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end


        -- Get or initialize the app entry in the target table
        local targetEntry = FeatureRequestsTable[appId]

        -- Add user and update count
        targetEntry.users[user] = { time = currentTime }
        targetEntry.count = targetEntry.count + 1
        
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
       
        -- Add the new entry
        local finalRank = DetermineUserRank(m.From,appId, providedRank)

        targetEntry.requests[featureRequestId] = {
            featureRequestId = featureRequestId,
            user = user,
            username = username,
            edited = false,
            rank = finalRank,
            comment = comment,
            header = header,
            status = "Open",
            timestamp = currentTime,
            profileUrl = profileUrl,
            replies = {},
        }

        targetEntry.requests.statusHistory[#targetEntry.requests.statusHistory + 1] = { time = currentTime, status = "Open" }

        
        local transactionType = "Added Feature Request."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Feature Requests Added Succesfully")      
  end
)






Handlers.add(
    "AddFeatureRequestReply",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureRequestReply"),
    function(m)

        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = GetCurrentTime(m)
        local replyId = GenerateReplyId()
        local providedRank = m.Tags.rank

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end

        -- Ensure appId exists in FeatureRequestsTable
        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId][featureRequestId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified featureRequestId..")
            return
        end

        -- Check if the user is the app owner
        if FeatureRequestsTable[appId].owner ~= user or FeatureRequestsTable[appId].mods[user] ~= user then
            SendFailure(m.From, "Only the app owner or Mods can reply to bug reports.")
        end

        -- Locate the specific bug report in the requests list
        local featureRequestEntry = FeatureRequestsTable[appId][featureRequestId]


        -- Check if the user has already replied to this bug report
        for _, reply in ipairs(featureRequestEntry.replies) do
            if reply.user == user then
                SendFailure(m.From, "You have already replied to this bug report.")
            end
        end

        local finalRank = DetermineUserRank(m.From,appId, providedRank)

        featureRequestEntry.replies[replyId] =  {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            edited = false,
            rank = finalRank,
            username = username,
            comment = comment,
            timestamp = currentTime
        }

        featureRequestEntry.status = "Closed"
        
        local transactionType = "Replied To Feature Requests"
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Replied Succesfully")
         end
)




Handlers.add(
    "EditFeatureRequest",
    Handlers.utils.hasMatchingTag("Action", "EditFeatureRequest"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        local providedRank = m.Tags.rank
        local header = m.Tags.header

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end
        if not ValidateField(header, "header", m.From) then return end


        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId]

        if not feature.user ~= user then
            SendFailure(m.From, "Only the owner can Edit A feature")
        end
        
        local finalRank = DetermineUserRank(m.From,appId, providedRank)


        feature.header = header
        feature.rank = finalRank
        feature.comment = comment
        feature.edited = true
        feature.currentTime = currentTime

        local transactionType = "Edited feature Succesfully."
        local amount = 0
        local points = -5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "feature Edited Succesfully." )   
    end
)


Handlers.add(
    "Deletefeature",
    Handlers.utils.hasMatchingTag("Action", "Deletefeature"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
     
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
      

        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId]

        if not feature.user ~= user then
            SendFailure(m.From, "Only the owner can Delete the feature")
        end

        local targetEntry = FeatureRequestsTable[appId]
        
        -- requests Effect.

        targetEntry.users[user] = { time = currentTime }
        targetEntry.count = targetEntry.count - 1
        
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        
        local transactionType = "Deleted feature Succesfully."
        local amount = 0
        local points = -10
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        feature = nil
        SendSuccess(m.From , "feature Edited Succesfully." )   
    end
)



Handlers.add(
    "MarkUnhelpfulfeature",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulfeature"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end

        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId]

        local unhelpfulData = feature.voters.foundUnhelpful
        local helpfulData = feature.voters.foundHelpful

        if unhelpfulData.users[user].voted then
            SendFailure(m.From, "You have already marked this feature as unhelpful.")
            return
        end

        if helpfulData.users[user].voted then
            helpfulData.users[user] = nil
            helpfulData.count = helpfulData.count - 1

            helpfulData.countHistory[#helpfulData.countHistory + 1] = { time = currentTime, count = helpfulData.count }
            
            local transactionType = "Switched vote to unhelpful."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        end

        unhelpfulData.users[user] = { voted = true, time = currentTime }
        unhelpfulData.count = unhelpfulData.count + 1

        unhelpfulData.countHistory[#unhelpfulData.countHistory + 1] = { time = currentTime, count = unhelpfulData.count }

        local transactionType = "Marked feature Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked feature Unhelpful")
        end
)

Handlers.add(
    "MarkHelpfulfeature",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulfeature"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end


        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId]

        local helpfulData = feature.voters.foundHelpful
       
        local unhelpfulData = feature.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this feature as helpful.")
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1

            unhelpfulData.countHistory[#unhelpfulData.countHistory + 1] = { time = currentTime, count = unhelpfulData.count }
            
            local transactionType = "Switched vote to helpful."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
       
        end

        helpfulData.users[user] = { voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        helpfulData.countHistory[#helpfulData.countHistory + 1] = { time = currentTime, count =helpfulData.count }
        local transactionType = "Marked feature Helpful"
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked the feature Helpful Succesfully" )   
    end
)


Handlers.add(
    "MarkUnhelpfulfeatureReply",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulfeatureReply"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId]

        local unhelpfulData = feature.voters.foundUnhelpful
        local helpfulData = feature.voters.foundHelpful

        if unhelpfulData.users[user].voted then
            SendFailure(m.From, "You have already marked this feature as unhelpful.")
            return
        end

        if helpfulData.users[user].voted then
            helpfulData.users[user] = nil
            helpfulData.count = helpfulData.count - 1

            helpfulData.countHistory[#helpfulData.countHistory + 1] = { time = currentTime, count = helpfulData.count }
            
            local transactionType = "Switched vote to unhelpful."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        end

        unhelpfulData.users[user] = { voted = true, time = currentTime }
        unhelpfulData.count = unhelpfulData.count + 1

        unhelpfulData.countHistory[#unhelpfulData.countHistory + 1] = { time = currentTime, count = unhelpfulData.count }

        local transactionType = "Marked feature Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked feature Unhelpful")
        end
)


Handlers.add(
    "MarkHelpfulfeatureReply",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulfeatureReply"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local feature =  FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] 

        local helpfulData = feature.voters.foundHelpful
       
        local unhelpfulData = feature.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this feature as helpful.")
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1

            unhelpfulData.countHistory[#unhelpfulData.countHistory + 1] = { time = currentTime, count = unhelpfulData.count }
            
            local transactionType = "Switched vote to helpful."
            local amount = 0
            local points = -5
            LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
    
        end

        helpfulData.users[user] = { voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        helpfulData.countHistory[#helpfulData.countHistory + 1] = { time = currentTime, count =helpfulData.count }
        local transactionType = "Marked reply Helpful"
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked the reply as Helpful Succesfully" )   
    end
)


Handlers.add(
    "EditfeatureReply",
    Handlers.utils.hasMatchingTag("Action", "EditfeatureReply"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end

        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "featureId doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] 

        if not reply.user ~= user or FeatureRequestsTable[appId].owner ~= user or FeatureRequestsTable[appId].mod[user] ~= user then
            SendFailure(m.From, "Only the owner , mod or other mods can edit a reply. ")
        end

        reply.comment = comment
        reply.edited = true
        local transactionType = "Edited Reply.."
        local amount = 0
        local points = -3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Edited Reply Succesfully." )   
    end
)


Handlers.add(
    "DeletefeatureReply",
    Handlers.utils.hasMatchingTag("Action", "DeletefeatureReply"),
    function(m)
        local appId = m.Tags.appId
        local featureRequestId = m.Tags.featureRequestId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(featureRequestId, "featureRequestId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not FeatureRequestsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        if FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  FeatureRequestsTable[appId].requests[featureRequestId].replies[replyId] 

        if not reply.user ~= user or FeatureRequestsTable[appId].owner ~= user then
            SendFailure(m.From, "Only the owner , mod or other mods can edit a reply. ")
        end
        local transactionType = "Deleted  Reply.."
        local amount = 0
        local points = -3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        reply = nil
        SendSuccess(m.From , "Deleted Reply. " )   
    end
)






Handlers.add(
    "FetchrequestsData",
    Handlers.utils.hasMatchingTag("Action", "FetchrequestsData"),
    function(m)
        local appId = m.Tags.appId

         if not ValidateField(appId, "appId", m.From) then return end

        -- Ensure appId exists in FeatureRequestsTable
         if FeatureRequestsTable[appId] == nil then
             SendFailure(m.From , "App not Found.")
            return
        end
        -- Fetch the info
        local devForumInfo = FeatureRequestsTable[appId].requests

        -- Check if there are requests
        if not devForumInfo or #devForumInfo == 0 then
            SendFailure(m.From , "No Data Found in Dev Forum.")
          return
        end
        SendSuccess(m.From , devForumInfo)
    end
)


Handlers.add(
    "GetFeatureRequestCount",
    Handlers.utils.hasMatchingTag("Action", "GetFeatureRequestCount"),
    function(m)
        local appId = m.Tags.appId
         if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in FeatureRequestsTable
        if FeatureRequestsTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = FeatureRequestsTable[appId].count or 0
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
    "FeautureRequestTable",
    Handlers.utils.hasMatchingTag("Action", "FeautureRequestTable"),
    function(m)
        FeatureRequestsTable = {}
    end
)