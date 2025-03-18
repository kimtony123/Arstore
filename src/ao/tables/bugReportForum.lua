local json = require("json")


-- This process details
PROCESS_NAME = "aos Bug_Report_Table"
PROCESS_ID = "x_CruGONBzwAOJoiTJ5jSddG65vMpRw9uMj9UiCWT5g"


-- Main aostore  process details
PROCESS_NAME_MAIN = "aos aostoreP "
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"


-- Credentials token
ARS = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- tables 
BugsReportsTable = BugsReportsTable or {}
AosPoints  = AosPoints or {}
Transactions = Transactions or {}

-- counters variables
BugReportCounter = BugReportCounter or 0
ReplyCounter = ReplyCounter or 0
TransactionCounter  = TransactionCounter or 0


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

-- Function to generate a unique review ID
function GenerateBugReportId()
    BugReportCounter = BugReportCounter + 1
    return "TX" .. tostring(BugReportCounter)
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



Handlers.add(
    "AddBugReportTable",
    Handlers.utils.hasMatchingTag("Action", "AddBugReportTable"),
    function(m)
        local currentTime = GetCurrentTime(m)
        local bugReportId = GenerateBugReportId()
        local replyId = GenerateReplyId()
        local appId = m.Tags.appId
        local user  = m.From
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
        BugsReportsTable = BugsReportsTable or {}
        AosPoints = AosPoints or {}
        Transactions = Transactions or {}

        BugsReportsTable[appId] = {
            appId = appId,
            status = false,
            owner = user,
            mods = { [user] = { permissions = {replyBugReport = true, },  time = currentTime } },
            requests = {
            [bugReportId] = {
            bugReportId = bugReportId,
            user = user,
            profileUrl = profileUrl,
            edited = false,
            rank = "Architect",
            time = currentTime,
            username = username,
            comment = "Change the UI",
            header = "Front End Bug",
            status = "Open", -- Tracks status (e.g., "Open", "In Progress", "Resolved")
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
            replies = {
                [replyId] = {
                    replyId = replyId,
                    profileUrl = profileUrl,
                    username = username,
                    comment = "We will start working on that bug ASAP.",
                    timestamp = currentTime,
                    edited = false,
                    Rank = "Architect",
                    user = user,
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
                }
            },
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = { [user] = { time = currentTime, count = 1 } }
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

        BugsReportsTable[#BugsReportsTable + 1] = {
            BugsReportsTable[appId]
        }

        AosPoints[#AosPoints + 1] = {
            AosPoints[appId]
        }

        local transactionType = "Project Creation."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
       
        -- Update statuses to true after creation
        BugsReportsTable[appId].status = true
        AosPoints[appId].status = true

        local status = true

         ao.send({
            Target = ARS,
            Action = "BugRespons",
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
        
        -- Ensure appId exists in BugsReportsTable
        if BugsReportsTable[appId] == nil then
            SendFailure(m.From ,"App doesnt exist for  specified " )
            return
        end

        -- Check if the user making the request is the current owner
        if BugsReportsTable[appId].owner ~= owner then
            SendFailure(m.From, "You are not the Owner of the App.")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(owner, "owner", m.From) then return end
        local transactionType = "Deleted Project."
        local amount = 0
        local points = 0
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        BugsReportsTable[appId] = nil
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
        
        -- Ensure appId exists in BugsReportsTable
        if BugsReportsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(newOwner, "newOwner", m.From) then return end
        if not ValidateField(currentOwner, "currentOwner", m.From) then return end

        -- Check if the user making the request is the current owner
        if BugsReportsTable[appId].owner ~= currentOwner then
            SendFailure(m.From , "You are not the owner of this app.")
            return
        end

        -- Transfer ownership
        BugsReportsTable[appId].owner = newOwner
        BugsReportsTable[appId].mods[currentOwner] = newOwner

        local transactionType = "Transfered app succesfully."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
    end
)




Handlers.add(
    "AddBugReport",
    Handlers.utils.hasMatchingTag("Action", "AddBugReport"),
    function(m)

        local appId = m.Tags.appId
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local bugReportId = GenerateBugReportId()
        local currentTime = GetCurrentTime(m)

        -- Ensure appId exists in BugsReportsTable
        if BugsReportsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end


        -- Get or initialize the app entry in the target table
        local targetEntry = BugsReportsTable[appId]

        -- Add user and update count
        targetEntry.users[user] = { voted = true, time = currentTime }
        targetEntry.count = targetEntry.count + 1
        
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        
        -- Add the new entry

        targetEntry.requests[#targetEntry.requests + 1] = {
            bugReportId = bugReportId,
            user = user,
            username = username,
            edited = false,
            rank = "Architect",
            comment = comment,
            timestamp = currentTime,
            profileUrl = profileUrl,
            replies = {},
        }
        
        local transactionType = "Added Bug Report."
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Bug Reported Succesfully")
      end
)

Handlers.add(
    "AddBugReportReply",
    Handlers.utils.hasMatchingTag("Action", "AddBugReportReply"),
    function(m)

        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = GetCurrentTime(m)


        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(username, "username", m.From) then return end
        if not ValidateField(profileUrl, "profileUrl", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end


        -- Ensure appId exists in BugsReportsTable
        if BugsReportsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        -- Check if the user is the app owner
        if not BugsReportsTable[appId] or BugsReportsTable[appId].owner ~= user or BugsReportsTable[appId].mods[user] ~= user then
            SendFailure(m.From, "Only the app owner or Mods can reply to bug reports.")
        end

        -- Locate the specific bug report in the requests list
        local bugReportEntry = nil
        for _, report in ipairs(BugsReportsTable[appId].requests) do
            if report.bugReportId == bugReportId then -- Match based on TableId (or BugReportId)
                bugReportEntry = report
                break
            end
        end

        -- Handle case where the bug report is not found
        if bugReportEntry == nil then
            SendFailure(m.From , "Bug report not found for the specified AppId and BugReportId.")
            return
        end

        -- Check if the user has already replied to this bug report
        for _, reply in ipairs(bugReportEntry.replies) do
            if reply.user == user then
                SendFailure(m.From, "You have already replied to this bug report.")
            end
        end

        -- Generate a unique ID for the reply
        local replyId = GenerateReplyId()

        bugReportEntry.replies[#bugReportEntry.replies + 1] =  {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        }
        
        local transactionType = "Replied To Bug Report"
        local amount = 0
        local points = 5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From , "Replied Succesfully")

     end
)


Handlers.add(
    "EditBugReport",
    Handlers.utils.hasMatchingTag("Action", "EditBugReport"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        local providedRank = m.Tags.rank
        local header = m.Tags.header

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        if not ValidateField(providedRank, "providedRank", m.From) then return end
        if not ValidateField(header, "header", m.From) then return end


        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "Bug Report doesnt exist for  specified AppId..")
            return
        end

        local feature =  BugsReportsTable[appId].requests[bugReportId]

        if not feature.user ~= user then
            SendFailure(m.From, "Only the owner can edit this bug report")
        end
        
        local finalRank = DetermineUserRank(m.From,appId, providedRank)

        feature.header = header
        feature.rank = finalRank
        feature.comment = comment
        feature.edited = true
        feature.currentTime = currentTime

        local transactionType = "Edited Bug Report  Succesfully."
        local amount = 0
        local points = -5
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Bug report  edited Succesfully." )   
    end
)


Handlers.add(
    "DeleteBugReportPost",
    Handlers.utils.hasMatchingTag("Action", "DeleteBugReportPost"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
     
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
      

        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "Requests doesnt exist for  specified bugReportId..")
            return
        end

        local bugReport =  BugsReportsTable[appId].requests[bugReportId]

        if not bugReport.user ~= user then
            SendFailure(m.From, "Only the owner can Delete the DevForumPost")
        end

        local targetEntry = BugsReportsTable[appId]
        
        -- requests Effect.
        targetEntry.users[user] = {time = currentTime }
        targetEntry.count = targetEntry.count - 1
        targetEntry.countHistory[#targetEntry.countHistory + 1] = { time = currentTime, count = targetEntry.count }
        

        local transactionType = "Deleted feature Succesfully."
        local amount = 0
        local points = -10
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        bugReport = nil
        SendSuccess(m.From , "feature Edited Succesfully." )   
    end
)



Handlers.add(
    "MarkUnhelpfulBugReport",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulBugReport"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end

        if BugsReportsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "BugReport  doesnt exist for  specified bugReportId..")
            return
        end

        local devForum =  BugsReportsTable[appId].requests[bugReportId]

        local unhelpfulData = devForum.voters.foundUnhelpful
        local helpfulData = devForum.voters.foundHelpful

        if unhelpfulData.users[user].voted then
            SendFailure(m.From, "You have already marked this BugReport as unhelpful.")
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

        local transactionType = "Marked Bug Report post Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked Bug Report post Unhelpful")
        end
)


Handlers.add(
    "MarkHelpfulDevForum",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulDevForum"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end


        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "bugReport  post doesnt exist for  specified AppId..")
            return
        end

        local devForum =  BugsReportsTable[appId].requests[bugReportId]

        local helpfulData = devForum.voters.foundHelpful
       
        local unhelpfulData = devForum.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this bug Report as helpful.")
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
        local transactionType = "Marked BugReport post  Helpful"
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
        local bugReportId = m.Tags.bugReportId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
       
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if BugsReportsTable[appId] == nil then
            SendFailure(m.From, "App doesnt exist for  specified AppId..")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local devForum =  BugsReportsTable[appId].requests[bugReportId].replies[replyId]

        local unhelpfulData = devForum.voters.foundUnhelpful
        local helpfulData = devForum.voters.foundHelpful

        if unhelpfulData.users[user].voted then
            SendFailure(m.From, "You have already marked this Bug Report reply as unhelpful.")
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

        local transactionType = "Marked BugReport reply Unhelpful."
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked BugReport reply  Unhelpful")
        end
)


Handlers.add(
    "MarkHelpfulDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "BugReport doesnt exist for  specified AppId..")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local feature =  BugsReportsTable[appId].requests[bugReportId].replies[replyId] 

        local helpfulData = feature.voters.foundHelpful
       
        local unhelpfulData = feature.voters.foundUnhelpful
        
        if helpfulData.users[user].voted then
            SendFailure(m.From , "You already marked this BugReport reply as helpful.")
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
        local transactionType = "Marked  BugReport reply Helpful"
        local amount = 0
        local points = 3
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)  
        SendSuccess(m.From , "Marked the  BugReport reply as Helpful Succesfully" )   
    end
)


Handlers.add(
    "EditDevForumReply",
    Handlers.utils.hasMatchingTag("Action", "EditDevForumReply"),
    function(m)
        local appId = m.Tags.appId
        local bugReportId = m.Tags.bugReportId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local comment = m.Tags.comment
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end
        if not ValidateField(comment, "comment", m.From) then return end
        
        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "featureId doesnt exist for  specified AppId..")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  BugsReportsTable[appId].requests[bugReportId].replies[replyId] 

        if not reply.user ~= user or BugsReportsTable[appId].owner ~= user or BugsReportsTable[appId].mod[user] ~= user then
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
        local bugReportId = m.Tags.bugReportId
        local replyId = m.Tags.replyId
        local user = m.From
        local currentTime = GetCurrentTime(m) -- Ensure you have a function to get the current timestamp
        
        if not ValidateField(appId, "appId", m.From) then return end
        if not ValidateField(bugReportId, "bugReportId", m.From) then return end
        if not ValidateField(replyId, "replyId", m.From) then return end

        if not BugsReportsTable[appId] then
            SendFailure(m.From, "App not found...")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId] == nil then
            SendFailure(m.From, "BugReport doesnt exist for  specified AppId..")
            return
        end

        if BugsReportsTable[appId].requests[bugReportId].replies[replyId] == nil then
            SendFailure(m.From, "replyId doesnt exist for  specified AppId..")
            return
        end

        local reply =  BugsReportsTable[appId].requests[bugReportId].replies[replyId] 

        if not reply.user ~= user or BugsReportsTable[appId].owner ~= user then
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
    "FetchBugReports",
    Handlers.utils.hasMatchingTag("Action", "FetchBugReports"),
    function(m)
        local appId = m.Tags.appId

        if not ValidateField(appId, "appId", m.From) then return end

        -- Ensure appId exists in BugsReportsTable
         if BugsReportsTable[appId] == nil then
             SendFailure(m.From , "App not Found.")
            return
        end
        -- Fetch the info
        local bugReportsInfo = BugsReportsTable[appId].requests

        -- Check if there are reviews
        if not bugReportsInfo or #bugReportsInfo == 0 then
            SendFailure(m.From , "No bug Reports Found for this AppId.")
          return
        end
        SendSuccess(m.From , bugReportsInfo)
        end
)

Handlers.add(
    "GetBugReportCount",
    Handlers.utils.hasMatchingTag("Action", "GetBugReportCount"),
    function(m)
        local appId = m.Tags.appId

        if not ValidateField(appId, "appId", m.From) then return end
        -- Ensure appId exists in BugsReportsTable
        if BugsReportsTable[appId] == nil then
            SendFailure(m.From , "App not Found.")
            return
        end
        local count = BugsReportsTable[appId].count or 0
        SendSuccess(m.From , count)
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
    "ClearBugReportTable",
    Handlers.utils.hasMatchingTag("Action", "ClearBugReportTable"),
    function(m)
        BugsReportsTable = {}
    end
)