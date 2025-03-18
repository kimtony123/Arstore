local json = require("json")


-- This process details
PROCESS_NAME = "aos DevForumTable"
PROCESS_ID = "V7KLJ9Fc48sb6VstzR3JPSymVhrF7dlP-Vt4W25-7bo"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostoreP "
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"


-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
DevForumTable = DevForumTable or {}
AosPoints  = AosPoints or {}
Transactions = Transactions or {}

-- counters variables
DevForumCounter = DevForumCounter or 0
ReplyCounter = ReplyCounter or 0
TransactionCounter  = TransactionCounter or 0



-- Function to get the current time in milliseconds
function GetCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end

-- Function to generate a unique Dev forum ID
function GenerateDevForumId()
    DevForumCounter = DevForumCounter + 1
    return "TX" .. tostring(DevForumCounter)
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



-- Helper function to log Transactions
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
    local appData = DevForumTable[appId] or {}
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
    "AddDevForumTable",
    Handlers.utils.hasMatchingTag("Action", "AddDevForumTable"),
    function(m)
        local currentTime = getCurrentTime(m)
        local devForumId = generateDevForumId()
        local replyId = generateReplyId()
        local appId = m.Tags.appId
        local user  = m.Tags.user
        local profileUrl = m.Tags.profileUrl
        local username = m.Tags.username
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

        -- Ensure global tables are initialized
        DevForumTable = DevForumTable or {}
        AosPoints = AosPoints or {}
        Transactions = Transactions or {}

        DevForumTable[appId] = {
            appId = appId,
            status = false,
            owner = user,
            mods = { [user] = { permissions = {replyDevForum = true, },  time = currentTime } },
            requests = {
                [devForumId] = {
                devForumId = devForumId,
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
    users = { [user] = { time = currentTime , count = 1} }
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

        DevForumTable[#DevForumTable + 1] = {
            DevForumTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        DevForumTable[appId].status = true
        AosPoints[appId].status = true

        local status = true
        -- Send responses back
        ao.send({
            Target = ARS,
            Action = "DevForumRespons",
            Data = tostring(status)
        })
        print("Successfully Added Dev Forum Table table")
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

        -- Check if the user making the request is the current owner
        if DevForumTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end

        DevForumTable[appId] = nil
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
        local newOwner = m.Tags.newOwner
        local caller = m.From
        local currentTime = GetCurrentTime()
        local currentOwner = m.Tags.currentOwner

         -- Check if PROCESS_ID called this handler
        if ARS ~= caller then
            SendFailure(m.From, "Only the Main process can call this handler.")
            return
        end
        
        -- Ensure appId exists in DevForumTable
        if DevForumTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if DevForumTable[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        DevForumTable[appId].owner = newOwner
        DevForumTable[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
   
    end
)






Handlers.add(
    "AskDevForumN",
    Handlers.utils.hasMatchingTag("Action", "AskDevForumN"),
    function(m)
        
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local appId = m.Tags.appId
        local header = m.Tags.header
        local currentTime = GetCurrentTime(m)
        local devForumId = GenerateDevForumId()
        local providedRank = m.Tags.rank


        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(header, "header", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
       
        -- Check if appId exists in DevForumTable, initialize if missing
        if DevForumTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
        end
        
        local targetEntry = DevForumTable[appId]
         
        -- Add user and update count
        targetEntry.users[user] = { voted = true, time = currentTime }
        targetEntry.count = targetEntry.count + 1
        
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        
        local finalRank = DetermineUserRank(m.From,appId, providedRank)

        -- Add the new entry
        targetEntry.requests[devForumId] = {
            devForumId = devForumId,
            user = user,
            username = username,
            comment = comment,
            edited = false,
            rank = finalRank,
            timestamp = currentTime,
            header = header,
            profileUrl = profileUrl,
            replies = {},
        }
        local transactionType = "Added Dev Forum."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Question Added To Dev Forum")
       end
)


Handlers.add(
    "AddDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "AddDevForumReply"),
    function(m)

        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
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
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end

        -- Ensure appId exists in DevForumTable
        if DevForumTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        -- Check if the user is the app owner
        if DevForumTable[appId].owner ~= user or DevForumTable[appId].mods[user] ~= user then
            SendFailure(m.From, "Only the app owner or Mods can reply to bug reports.")
        end


         if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local devForumEntry =  DevForumTable[appId].requests[devForumId]


        -- Check if the user has already replied to this bug report
        for _, reply in ipairs(devForumEntry.replies) do
            if reply.user == user then
                SendFailure(m.From, "You have already replied to this bug report.")
            end
        end


        local finalRank = DetermineUserRank(m.From,appId, providedRank)


        devForumEntry.replies[replyId] =  {
            replyId = replyId,
            user = user,
            edited = false,
            rank = finalRank,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        }
        
        local transactionType = "Replied To Developer Report"
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Replied Succesfully")
         end
)




Handlers.add(
    "EditDevForumRequest",
    Handlers.utils.hasMatchingTag("Action", "EditDevForumRequest"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        local providedRank = m.Tags.rank
        local header = m.Tags.header

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end
        if not ValidateField(header, "header", m.From) then return end


        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        local feature =  DevForumTable[appId].requests[devForumId]

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
    "DeleteDevForumAsk",
    Handlers.utils.hasMatchingTag("Action", "DeleteDevForumAsk"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
     
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
      

        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "Requests doesnt exist for  specified devForumId..")
            return
        end

        local devForum =  DevForumTable[appId].requests[devForumId]

        if not devForum.user ~= user then
            SendFailure(m.From, "Only the owner can Delete the DevForumPost")
        end

        local targetEntry = DevForumTable[appId]
        
        -- requests Effect.
        targetEntry.users[user] = {time = currentTime }
        targetEntry.count = targetEntry.count - 1
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        

        local transactionType = "Deleted feature Succesfully."
        local amount = 0
        local points = -10
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        devForum = nil
        SendSuccess(m.From , "feature Edited Succesfully." )   
    end
)



Handlers.add(
    "MarkUnhelpfulDevForum",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulDevForum"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end

        if DevForumTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified DevForumId..")
            return
        end

        local devForum =  DevForumTable[appId].requests[devForumId]

        local unhelpfulData = devForum.voters.foundUnhelpful
        local helpfulData = devForum.voters.foundHelpful

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

        local transactionType = "Marked DevForum post Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked DevForum post Unhelpful")
        end
)

Handlers.add(
    "MarkHelpfulDevForum",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulDevForum"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end


        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "devForum post doesnt exist for  specified AppId..")
            return
        end

        local devForum =  DevForumTable[appId].requests[devForumId]

        local helpfulData = devForum.voters.foundHelpful
       
        local unhelpfulData = devForum.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this dev Forum as helpful.")
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
        local transactionType = "Marked DevForum post  Helpful"
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked the DevForum post  Helpful Succesfully" )   
    end
)


Handlers.add(
    "MarkUnhelpfulDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
       
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if DevForumTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if DevForumTable[appId].requests[devForumId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local devForum =  DevForumTable[appId].requests[devForumId].replies[replyId]

        local unhelpfulData = devForum.voters.foundUnhelpful
        local helpfulData = devForum.voters.foundHelpful

        if unhelpfulData.users[user].voted then
            SendFailure(m.From, "You have already marked this DevForum reply as unhelpful.")
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

        local transactionType = "Marked DevForum reply Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked DevForum reply  Unhelpful")
        end
)


Handlers.add(
    "MarkHelpfulDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        if DevForumTable[appId].requests[devForumId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local feature =  DevForumTable[appId].requests[devForumId].replies[replyId] 

        local helpfulData = feature.voters.foundHelpful
       
        local unhelpfulData = feature.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this DevForum reply as helpful.")
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

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        helpfulData.countHistory[#helpfulData.countHistory + 1] = { time = currentTime, count =helpfulData.count }
        local transactionType = "Marked  DevForum reply Helpful"
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked the  DevForum reply as Helpful Succesfully" )   
    end
)


Handlers.add(
    "EditDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "EditDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end

        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "featureId doesnt exist for  specified AppId..")
            return
        end

        if DevForumTable[appId].requests[devForumId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  DevForumTable[appId].requests[devForumId].replies[replyId] 

        if not reply.user ~= user or DevForumTable[appId].owner ~= user or DevForumTable[appId].mod[user] ~= user then
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
    "DeleteDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "DeleteDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local devForumId = m.Tags.devForumId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(devForumId, "devForumId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not DevForumTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if DevForumTable[appId].requests[devForumId] == nil then
            SendFailure(m.From, "feature doesnt exist for  specified AppId..")
            return
        end

        if DevForumTable[appId].requests[devForumId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  DevForumTable[appId].requests[devForumId].replies[replyId] 

        if not reply.user ~= user or DevForumTable[appId].owner ~= user then
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
    "FetchDevForumData",
    Handlers.utils.hasMatchingTag("Action", "FetchDevForumData"),
    function(m)
        local appId = m.Tags.appId


         if not ValidateField(appId, "appId", m.From) then return end

        -- Ensure appId exists in DevForumTable
         if DevForumTable[appId] == nil then
             SendFailure(m.From , "App not Found.")
            return
        end
        -- Fetch the info
        local devForumInfo = DevForumTable[appId].requests

        -- Check if there are reviews
        if not devForumInfo or #devForumInfo == 0 then
            SendFailure(m.From , "No Data Found in Dev Forum.")
          return
        end
        SendSuccess(m.From , devForumInfo)
    end
)

Handlers.add(
    "GetDevForumCount",
    Handlers.utils.hasMatchingTag("Action", "GetFeatureRequestCount"),
    function(m)
        local appId = m.Tags.appId

        if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in DevForumTable
        if DevForumTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = DevForumTable[appId].count or 0
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
    "ClearDevForumTable",
    Handlers.utils.hasMatchingTag("Action", "ClearDevForumTable"),
    function(m)
        DevForumTable = {}
    end
)