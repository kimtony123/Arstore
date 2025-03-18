local json = require("json")
local math = require("math")




-- This process details.
PROCESS_NAME = "aos aostoreP"
PROCESS_ID = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

-- Reviews Table process
PROCESS_NAME_REVIEW_TABLE = "aos Reviews_Table"
PROCESS_ID_REVIEW_TABLE = "-E8bZaG3KJMNqwCCcIqFKTVzqNZgXxqX9Q32I_M3-Wo"


-- Bug Reports Table process
PROCESS_NAME_BUG_REPORT_TABLE = "aos Bug_Report_Table"
PROCESS_ID_BUG_REPORT_TABLE  = "x_CruGONBzwAOJoiTJ5jSddG65vMpRw9uMj9UiCWT5g"


-- Helpful Table process
PROCESS_NAME_HELPFUL_TABLE = "aos Helpful_Table"
PROCESS_ID_HELPFUL_TABLE = "bQVmkwCFW7K2hIcVslihAt4YjY1RIkEkg5tXpZDGbbw"


-- DevForum Table process
PROCESS_NAME_DEV_FORUM_TABLE = "aos DevForumTable"
PROCESS_ID_DEV_FORUM_TABLE = "V7KLJ9Fc48sb6VstzR3JPSymVhrF7dlP-Vt4W25-7bo"


-- Feature Requests details
PROCESS_NAME_FEATURE_REQUEST_TABLE = "aos featureRequestsTable"
PROCESS_ID_FEATURE_REQUEST_TABLE = "YGoIdaqLZauaH3aNLKyWdoFHTg0Voa5O3NhCMWKHRtY"

-- This flag Table details
PROCESS_NAME_FLAG_TABLE = "aos Flag_Table"
PROCESS_ID_FLAG_TABLE = "BpGlNnMA09jM-Sfh6Jldswhp5AnGTCST4MxG2Dk-ABo"



-- Favorites process details
PROCESS_NAME_FAVORITES_TABLE = "aos Favorites_Table"
PROCESS_ID_FAVORITES_TABLE  = "2aXLWDFCbnxxBb2OyLmLlQHwPnrpN8dDZtB9Y9aEdOE"

-- Airdrops process details
PROCESS_NAME = "aos Airdrops_Table"
PROCESS_ID_AIRDROP_TABLE = "XkAtx1XJse3MMv4MrT5aRQbBu7_i-gTOE7kNmZj6Z8o"

-- Tips  process details
PROCESS_NAME = "aos TipsTable"
PROCESS_ID_TIPS_TABLE = "LkCdB2PkYRl4zTChv1DiTtiLqr5Qpu0cJ6V6mvHUnOo"


AOS_POINTS = "vv8WuNF3bD9MG9tL4zguinQSobFFLDGQJtw_-yyoVl0"


-- tables 
Apps = Apps or {}
Transactions  = Transactions or {}

AosPoints = AosPoints or {}
-- Counters variables 
AppCounter  = AppCounter or 0
TransactionCounter = TransactionCounter or 0
MessageCounter  = MessageCounter or 0

-- Status Variables
ReviewStatus = ReviewStatus or false
HelpfulStatus  = HelpfulStatus or false
BugStatus = BugStatus or false
DevForumStatus = DevForumStatus or false

-- Callback Variables
FetchreviewsCallback = nil
FetchhelpfulCallback = nil
FetchbugreportsCallback = nil
FetchdevforumCallback  = nil
FetchfeaturetableCallback = nil
FetchflagtableCallback  = nil
FetchunhelpfullCallback = nil
FetchfavoritesCallback = nil
FetchairdropsCallback = nil
FetchtipsCallback  = nil

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


-- Function to generate a unique App ID
function GenerateAppId()
    AppCounter = AppCounter + 1
    return "TX" .. tostring(AppCounter)
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

function AddReviewTable(appId, user, username, profileUrl, callback)
    ao.send({
        Target = PROCESS_ID_REVIEW_TABLE,
        Tags = {
            { name = "Action",     value = "AddReviewTableX" },
            { name = "appId",   value = tostring(appId) },
            { name = "user",  value = tostring(user) },
            { name = "username", value = tostring(username) },
            { name = "profileUrl", value = tostring(profileUrl) }
        }
    })
    -- Save the callback to be called later
    FetchreviewsCallback = callback
end

function DeleteAppReviews(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_REVIEW_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchreviewsCallback = callback
end

function ChangeownerReviewTable(appId, newowner,currentowner, callback)
    ao.send({
        Target = PROCESS_ID_REVIEW_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner",   value = tostring(newowner) },
              { name = "currentowner",   value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchreviewsCallback = callback
end


function AddHelpfulTable(appId , user,callback)
    ao.send({
        Target = PROCESS_ID_HELPFUL_TABLE,
        Tags = {
            { name = "Action", value = "AddHelpfulTableX" },
            { name = "appId",  value = tostring(appId) },
            { name = "user", value = tostring(user) },
        }
    })
     -- Save the callback to be called later
    FetchhelpfulCallback = callback
end

function ChangeownerHelpful(appId, newowner,currentowner, callback)
    ao.send({
        Target = PROCESS_ID_HELPFUL_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner",   value = tostring(newowner) },
            { name = "currentowner",   value = tostring(currentowner) },
       
        }
    })
    -- Save the callback to be called later
    FetchbugreportsCallback = callback
end

function DeleteAppHelpful(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_HELPFUL_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchhelpfulCallback = callback
end


function AddBugReportTable(appId, user, profileUrl, username, callback)
    ao.send({
        Target = PROCESS_ID_BUG_REPORT_TABLE,
        Tags = {
            { name = "Action",   value = "AddBugReportTable" },
            { name = "appId",  value = tostring(appId) },
            { name = "user",    value = tostring(user) },
            { name = "username",  value = tostring(username) },
            { name = "profileUrl", value = tostring(profileUrl) },
        }
    })
    -- Save the callback to be called later
    FetchbugreportsCallback = callback
end

function DeleteAppBugReport(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_BUG_REPORT_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchhelpfulCallback = callback
end


function ChangeownerBugReport(appId, newowner,currentowner, callback)
    ao.send({
        Target = PROCESS_ID_BUG_REPORT_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner",   value = tostring(newowner) },
            { name = "currentowner",   value = tostring(currentowner) },
       
        }
    })
    -- Save the callback to be called later
    FetchbugreportsCallback = callback
end


function AddDevForumTable(appId, user, profileUrl, username, callback)
    ao.send({
        Target = PROCESS_ID_DEV_FORUM_TABLE,
        Tags = {
            { name = "Action",     value = "AddDevForumTable" },
            { name = "appId",      value = tostring(appId) },
            { name = "user",       value = tostring(user) },
            { name = "username",   value = tostring(username) },
            { name = "profileUrl", value = tostring(profileUrl) }
        }
    })
    -- Save the callback to be called later
    FetchdevforumCallback = callback
end

function DeleteAppDevForum(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_DEV_FORUM_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchhelpfulCallback = callback
end

function ChangeownerDevForum(appId, newowner,currentowner, callback)
    ao.send({
        Target = PROCESS_ID_DEV_FORUM_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner",   value = tostring(newowner) },
            { name = "currentowner",   value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchdevforumCallback = callback
end

function AddFeatureRequestTable(appId, user, profileUrl, username, callback)
    ao.send({
        Target = PROCESS_ID_FEATURE_REQUEST_TABLE,
        Tags = {
            { name = "Action", value = "AddfeatureRequestsTable" },
            { name = "appId",  value = tostring(appId) },
            { name = "user",  value = tostring(user) },
            { name = "username", value = tostring(username) },
            { name = "profileUrl",value = tostring(profileUrl) }
        }
    })
    -- Save the callback to be called later
    FetchfeaturetableCallback = callback
end

function DeleteAppFeatureRequest(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_FEATURE_REQUEST_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchfeaturetableCallback = callback
end

function ChangeownerFeatureRequest(appId, newowner, currentowner, callback)
    ao.send({
        Target = PROCESS_ID_FEATURE_REQUEST_TABLE,
        Tags = {
            { name = "Action",  value = "ChangeAppownership" },
            { name = "appId",   value = tostring(appId) },
            { name = "newowner",value = tostring(newowner) },
            { name = "currentowner", value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchfeaturetableCallback = callback
end


function AddFlagTable(appId, user, callback)
    ao.send({
        Target = PROCESS_ID_FLAG_TABLE,
        Tags = {
            { name = "Action", value = "AddFlagTableX" },
            { name = "appId",  value = tostring(appId) },
            { name = "user",   value = tostring(user) },
        }
    })
    -- Save the callback to be called later
    FetchflagtableCallback = callback
end

function DeleteAppFlag(appId,owner, callback)
    ao.send({
        Target = PROCESS_ID_FLAG_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",   value = tostring(owner) },
           }
    })
    -- Save the callback to be called later
    FetchflagtableCallback = callback
end



function AddFavoriteTable(appId, user, appName,companyName,protocol,projectType,appIconUrl,websiteUrl, callback)
    ao.send({
        Target = PROCESS_ID_FAVORITES_TABLE,
        Tags = {
            { name = "Action",  value = "AddFavoritesTableX" },
            { name = "appId",   value = tostring(appId) },
            { name = "user",    value = tostring(user) },
            { name = "appName", value = tostring(appName) },
            { name = "companyName", value = tostring(companyName) },
            { name = "protocol", value = tostring(protocol) },
            { name = "projectType", value = tostring(projectType) },
            { name = "appIconUrl",  value = tostring(appIconUrl) },
            { name = "websiteUrl", value = tostring(websiteUrl) },
        }
    })
    -- Save the callback to be called later
    FetchfavoritesCallback = callback
end



function AddAirdropTable(appId ,user , profileUrl ,username, appIconUrl,  appName , callback)
    ao.send({
        Target = PROCESS_ID_AIRDROP_TABLE,
        Tags = {
            { name = "Action",  value = "AddAirdropsTable" },
            { name = "appId",   value = tostring(appId) },
            { name = "user",    value = tostring(user) },
            { name = "profileUrl", value = tostring(profileUrl) },
            { name = "username", value = tostring(username) },
            { name = "appIconUrl",  value = tostring(appIconUrl) },
            { name = "appName", value = tostring(appName) },
        }
    })
    -- Save the callback to be called later
    FetchairdropsCallback = callback
end


function AddTipsTable( appId ,appName ,user ,appIconUrl ,tokenId ,tokenName, ticker, denomination, callback)
    ao.send({
        Target = PROCESS_ID_TIPS_TABLE,
        Tags = {
            { name = "Action",  value = "AddTipsTable" },
            { name = "appId",   value = tostring(appId) },
            { name = "user",    value = tostring(user) },
            { name = "tokenId", value = tostring(tokenId) },
            { name = "tokenName", value = tostring(tokenName) },
            { name = "appIconUrl",  value = tostring(appIconUrl) },
            { name = "ticker", value = tostring(ticker) },
            { name = "denomination", value = tostring(denomination) },
            { name = "appName", value = tostring(appName) },
        }
    })

  
    -- Save the callback to be called later
    FetchtipsCallback = callback
end


function DeleteAppFavorite(appId, owner, callback)
    ao.send({
        Target = PROCESS_ID_FAVORITES_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",  value = tostring(owner) },
        }
    })
    -- Save the callback to be called later
    FetchfavoritesCallback = callback
end


function DeleteAppAirdrops(appId, owner, callback)
    ao.send({
        Target = PROCESS_ID_AIRDROP_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",  value = tostring(owner) },
        }
    })
    -- Save the callback to be called later
    FetchairdropsCallback = callback
end

function DeleteAppTips(appId, owner, callback)
    ao.send({
        Target = PROCESS_ID_TIPS_TABLE,
        Tags = {
            { name = "Action", value = "DeleteApp" },
            { name = "appId",  value = tostring(appId) },
            { name = "owner",  value = tostring(owner) },
        }
    })
    -- Save the callback to be called later
    FetchtipsCallback = callback
end

function ChangeownerFavorites(appId, newowner, currentowner, callback)
    ao.send({
        Target = PROCESS_ID_FAVORITES_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner", value = tostring(newowner) },
            { name = "currentowner",value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchfavoritesCallback = callback
end

function ChangeownerAirdrops(appId, newowner, currentowner, callback)
    ao.send({
        Target = PROCESS_ID_AIRDROP_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner", value = tostring(newowner) },
            { name = "currentowner",value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchairdropsCallback = callback
end

function ChangeownerTips(appId, newowner, currentowner, callback)
    ao.send({
        Target = PROCESS_ID_TIPS_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner", value = tostring(newowner) },
            { name = "currentowner",value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchtipsCallback = callback
end

function ChangeownerFlag(appId, newowner, currentowner, callback)
    ao.send({
        Target = PROCESS_ID_FLAG_TABLE,
        Tags = {
            { name = "Action", value = "ChangeAppownership" },
            { name = "appId",  value = tostring(appId) },
            { name = "newowner", value = tostring(newowner) },
            { name = "currentowner",value = tostring(currentowner) },
        }
    })
    -- Save the callback to be called later
    FetchflagtableCallback = callback
end


function FinalizeProject(user, appId, appName, description, currentTime, username, profileUrl, protocol,
                websiteUrl,
                twitterUrl,
                discordUrl,
                coverUrl,
                bannerUrls,
                companyName,
                appIconUrl,
                projectType)
    

    
    -- Ensure Apps table and its sub-table are properly initialized
    if not Apps or type(Apps) ~= "table" then
        Apps = { apps = {}, count = 0, countHistory = {} }
    elseif not Apps.apps or type(Apps.apps) ~= "table" then
        Apps.apps = {}
    end

    -- Ensure global tables are initialized
    AosPoints = AosPoints or {}
    Transactions = Transactions or {}

        -- Create the aosPoints table for this AppId
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

  

    Apps.apps[appId] = {
    appId = appId,
    owner = user,
    appName = appName,
    username = username,
    description = description,
    createdTime = currentTime,
    protocol = protocol,
    websiteUrl = websiteUrl,
    twitterUrl = twitterUrl,
    discordUrl = discordUrl,
    coverUrl = coverUrl,
    profileUrl = profileUrl,
    bannerUrls = bannerUrls,
    companyName = companyName,
    appIconUrl = appIconUrl,
    projectType = projectType,
    AosPoints = AosPoints[appId]}
    AosPoints[appId].status = true
  -- Reset statuses and DataCount
    ReviewStatus = false
    DataCount = 0

    Apps.count = Apps.count + 1
    table.insert(Apps.countHistory, { time = currentTime, count = Apps.count })

    local transactionType = "Project Creation."
    local amount = 0
    local points = 5
    LogTransaction(user, appId, transactionType, amount, currentTime, points)

  print("Apps table after update: " .. TableToJson(Apps))

end

-- In ReviewsResponse handler:
Handlers.add(
  "ReviewsRespons",
  Handlers.utils.hasMatchingTag("Action", "ReviewsRespons"),
  function(m)
    local xData = m.Data
    if not xData then
      print("No data received in response.")
      return
    end
    if xData == "true" then
    ReviewStatus = true
    DataCount = DataCount + 1
    print("Updated Review Response:", xData)
    -- Check if we have reached the required count
    if DataCount >= 9 and globalFinalizeProjectCallback then
      globalFinalizeProjectCallback()
    end
    end
  end
)

-- In UpvotesResponse handler:
Handlers.add(
  "HelpfulRespons",
  Handlers.utils.hasMatchingTag("Action", "HelpfulRespons"),
  function(m)

    if m.From == PROCESS_ID_HELPFUL_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in Helpful response.")
          return
        end
      if xData == "true" then
          HelpfulStatus = true
          DataCount = DataCount + 1
          print("Updated Helpful Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
      
  end
)


-- In UpvotesResponse handler:
Handlers.add(
  "BugRespons",
  Handlers.utils.hasMatchingTag("Action", "BugRespons"),
  function(m)

    if m.From == PROCESS_ID_BUG_REPORT_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in Helpful response.")
          return
        end
      if xData == "true" then
          BugStatus = true
          DataCount = DataCount + 1
          print("Updated Bug  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
      
  end
)

-- In UpvotesResponse handler:
Handlers.add(
  "DevForumRespons",
  Handlers.utils.hasMatchingTag("Action", "DevForumRespons"),
  function(m)

    if m.From == PROCESS_ID_DEV_FORUM_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in DevForum Table response.")
          return
        end
      if xData == "true" then
          DevForumStatus = true
          DataCount = DataCount + 1
          print("Updated Dev Forum  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
      
  end
)

-- In UpvotesResponse handler:
Handlers.add(
  "FeatureRequestRespons",
  Handlers.utils.hasMatchingTag("Action", "FeatureRequestRespons"),
  function(m)

    if m.From == PROCESS_ID_FEATURE_REQUEST_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in feature Table response.")
          return
        end
      if xData == "true" then
          DataCount = DataCount + 1
          print("Updated Feature Table  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
      
  end
)

-- In FlagTable handler:
Handlers.add(
  "FlagRespons",
  Handlers.utils.hasMatchingTag("Action", "FlagRespons"),
  function(m)

    if m.From == PROCESS_ID_FLAG_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in flag  Table response.")
          return
        end
      if xData == "true" then
          DevForumStatus = true
          DataCount = DataCount + 1
          print("Updated  flag  Table  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
  end
)


-- In Favorites handler:
Handlers.add(
  "FavoriteRespons",
  Handlers.utils.hasMatchingTag("Action", "FavoriteRespons"),
  function(m)

    if m.From == PROCESS_ID_FAVORITES_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in Favorites Table response.")
          return
        end
      if xData == "true" then
          DataCount = DataCount + 1
          print("Updated Favorites Table  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
  end
)

-- In Airdops handler:
Handlers.add(
  "AirdropRespons",
  Handlers.utils.hasMatchingTag("Action", "AirdropRespons"),
  function(m)

    if m.From == PROCESS_ID_AIRDROP_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in Airdrop Table response.")
          return
        end
      if xData == "true" then
          DataCount = DataCount + 1
          print("Updated Airdrop Table  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
  end
)


-- In Tips handler:
Handlers.add(
  "TipsRespons",
  Handlers.utils.hasMatchingTag("Action", "TipsRespons"),
  function(m)

    if m.From == PROCESS_ID_TIPS_TABLE then
        local xData = m.Data
        if not xData then
          print("No data received in Tips Table response.")
          return
        end
      if xData == "true" then
          DataCount = DataCount + 1
          print("Updated Tips Table  Response:", xData)
          -- Check if we have reached the required count
          if DataCount >= 9 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
  end
)



Handlers.add(
    "AddProjectZ",
    Handlers.utils.hasMatchingTag("Action", "AddProjectZ"),
    function(m)
      local appId = GenerateAppId()
      local currentTime = getCurrentTime(m)
      local user = m.From
      local appName = m.Tags.appName
      local description = m.Tags.description
      local username = m.Tags.username
      local profileUrl = m.Tags.profileUrl
      local protocol = m.Tags.protocol
      local websiteUrl = m.Tags.websiteUrl
      local twitterUrl = m.Tags.twitterUrl
      local discordUrl = m.Tags.discordUrl
      local coverUrl = m.Tags.coverUrl
      local bannerUrls = json.decode(m.Tags.bannerUrls)
      local companyName = m.Tags.companyName
      local appIconUrl = m.Tags.appIconUrl
      local projectType = m.Tags.projectType
        local tokenId = m.Tags.tokenId
        local tokenName = m.Tags.tokenName
        local ticker = m.Tags.ticker
        local denomination = m.Tags.denomination



        
      
    if not ValidateField(profileUrl, "profileUrl", m.From) then return end
   --if not ValidateField(tokenId, "tokenId", m.From) then return end
    -- if not ValidateField(tokenName, "tokenName", m.From) then return end
    --  if not ValidateField(tokenDenomination, "tokenDenomination", m.From) then return end
    -- if not ValidateField(tokenTicker, "tokenTicker", m.From) then return end
      
    if not ValidateField(projectType, "projectType", m.From) then return end

    if not ValidateField(appIconUrl, "appIconUrl", m.From) then return end

    if not ValidateField(companyName, "companyName", m.From) then return end

    if not ValidateField(coverUrl, "coverUrl", m.From) then return end

    if not ValidateField(discordUrl, "discordUrl", m.From) then return end

    if not ValidateField(twitterUrl, "twitterUrl", m.From) then return end

    if not ValidateField(websiteUrl, "websiteUrl", m.From) then return end

    if not ValidateField(protocol, "protocol", m.From) then return end

    if not ValidateField(appId, "appId", m.From) then return end

    if not ValidateField(username, "username", m.From) then return end

    if not ValidateField(user, "user", m.From) then return end

       -- Check if at least one banner is provided
    if #bannerUrls == 0 then
        local response = { code = 404, message = "failed", data = "At least one BannerUrl is required." }
        ao.send({ Target = m.From, Data = tableToJson(response) })
        return
    end

    DataCount = 0
  
    AddReviewTable(appId, user, username, profileUrl,nil)
    AddHelpfulTable(appId, user, nil)
    AddBugReportTable(appId, user,profileUrl,username,nil)
    AddDevForumTable(appId, user, profileUrl, username, nil)
    AddFeatureRequestTable(appId, user, profileUrl, username, nil)
    AddFlagTable(appId , user,nil) 
    AddFavoriteTable(appId, user, appName,companyName,protocol,projectType,appIconUrl,websiteUrl,nil)
    AddTipsTable( appId ,appName ,user ,appIconUrl ,tokenId ,tokenName, ticker, denomination, nil) 
    AddAirdropTable(appId ,user , profileUrl ,username, appIconUrl,  appName , nil) 
   


   FinalizeProject(user, appId, appName, description, currentTime, username, profileUrl, protocol,
                websiteUrl,
                twitterUrl,
                discordUrl,
                coverUrl,
                bannerUrls,
                companyName,
                appIconUrl,
                projectType)
    SendSuccess(user, "Project Added Succesfully.")
      end
)


Handlers.add(
    "FetchAllApps",
    Handlers.utils.hasMatchingTag("Action", "FetchAllApps"),
    function(m)

    if not Apps or not Apps.apps or next(Apps.apps) == nil then
        SendFailure(m.From, "Apps are nil")
    end

        local filteredApps = {}
        for appId, app in pairs(Apps.apps) do
            filteredApps[appId] = {
                appId = app.appId,
                appName = app.appName,
                description = app.description,
                companyName = app.companyName,
                projectType = app.projectType,
                websiteUrl = app.websiteUrl,
                appIconUrl = app.appIconUrl,
                createdTime = app.createdTime
            }
        end

        -- Check if at least one App exists is provided
        if #filteredApps == 0 then
           SendFailure(m.From, "Apps fetching failed!.")
        end
       
        SendSuccess(m.From, filteredApps)
        end
)

Handlers.add(
    "getMyApps",
    Handlers.utils.hasMatchingTag("Action", "getMyApps"),
    function(m)
        local owner = m.From

        if not Apps or not Apps.apps or next(Apps.apps) == nil then
        SendFailure(m.From, "Apps are nil")
        end

        -- Filter apps owned by the user from the nested 'apps' table
        local filteredApps = {}
        for AppId, App in pairs(Apps.apps) do
            if App.owner == owner then
                filteredApps[AppId] = {
                appId = app.appId,
                appName = app.appName,
                description = app.description,
                companyName = app.companyName,
                projectType = app.projectType,
                websiteUrl = app.websiteUrl,
                appIconUrl = app.appIconUrl,
                createdTime = app.createdTime
                }
            end
        end
        -- Check if at least one App exists is provided
        if #filteredApps == 0 then
           SendFailure(m.From, "Apps fetching failed!.")
        end
        SendSuccess(m.From, filteredApps)
        end
)



Handlers.add(
    "TransferAppownership",
    Handlers.utils.hasMatchingTag("Action", "TransferAppownership"),
    function(m)
        local appId = m.Tags.AppId
        local newowner = m.Tags.Newowner
        local currentowner = m.From
        local currentTime = GetCurrentTime()


        if not ValidateField(appId, "appId", m.From) then return end

        if not ValidateField(newowner, "newowner", m.From) then return end

        
        -- Check if the user making the request is the current owner
        if Apps.app[appId].owner ~= currentowner then
            SendFailure(m.From , "You are not the App owner.")
            return
        end

        ChangeownerReviewTable(appId, newowner,currentowner, nil)
        ChangeownerFeatureRequest(appId, newowner,currentowner, nil)
        ChangeownerDevForum(appId, newowner, currentowner, nil)
        ChangeownerBugReport(appId, newowner, currentowner, nil)
        ChangeownerFavorites(appId, newowner,currentowner, nil)
        ChangeownerHelpful(appId, newowner,currentowner, nil)
        ChangeownerAirdrops(appId, newowner,currentowner, nil)
        ChangeownerTips(appId, newowner,currentowner, nil)
        ChangeownerFlag(appId, newowner,currentowner, nil)
        
        -- Transfer ownership
        Apps.app[appId].owner = newowner
        local transactionType = "Changed App OwnwerShip."
        local amount = 0
        LogTransaction(currentowner, appId, transactionType, amount, currentTime)

        local transactionType = "Received App ownership."
        local amount = 0
        LogTransaction(newowner, appId, transactionType, amount, currentTime)
        SendSuccess(m.From, "Project Ownership changed Succesfully.")
    end
)


Handlers.add(
    "DeleteApp",
    Handlers.utils.hasMatchingTag("Action", "DeleteApp"),
    function(m)
        
        local appId = m.Tags.AppId
        local owner = m.From
        local currentTime = GetCurrentTime()
        -- Check if the user making the request is the current owner
        if Apps.app[appId].owner ~= owner then
           SendFailure(m.From , "You aint the owner of the project")
            return
        end

         if not ValidateField(appId, "appId", m.From) then return end

        if not ValidateField(owner, "owner", m.From) then return end

        --DeleteAppAirdrop(appId, owner, nil)
        DeleteAppBugReport(appId, owner, nil)
        DeleteAppDevForum(appId, owner, nil)
        DeleteAppFeatureRequest(appId, owner, nil)
        DeleteAppFlag(appId, owner, nil)
        DeleteAppHelpful(appId, owner, nil)
        DeleteAppReviews(appId, owner, nil)
        DeleteAppFavorite(appId, owner, nil)
        DeleteAppAirdrops(appId, owner, nil)
        DeleteAppTips(appId, owner, nil)
        Apps.app[appId] = nil

        local transactionType = "Received App ownership."
        local amount = 0
        LogTransaction(owner, appId, transactionType, amount, currentTime)
        SendSuccess(m.From, "Project Deleted  Succesfully.")
        end
)


Handlers.add(
    "UpdateAppDetails",
    Handlers.utils.hasMatchingTag("Action", "UpdateAppDetails"),
    function(m)
        local appId = m.Tags.AppId
        local updateOption = m.Tags.updateOption
        local newValue = m.Tags.NewValue
        local currentowner = m.From
        local currentTime = GetCurrentTime()

        if not ValidateField(appId, "appId", m.From) then return end

        if not ValidateField(updateOption, "updateOption", m.From) then return end

        if not ValidateField(newValue, "newValue", m.From) then return end

        -- Check if the app exists
        if not Apps.app[appId] then
            SendFailure(m.From , "App not Found")
            return
        end

        -- Check if the user making the request is the current owner
        if Apps[appId].owner ~= currentowner then
            SendFailure(m.From , "You are not the Owner of this App")
            return
        end

        -- List of valid fields that can be updated
        local validUpdateOptions = {
            ownerUserName = true,
            AppName = true,
            Description = true,
            Protocol = true,
            WebsiteUrl = true,
            TwitterUrl = true,
            DiscordUrl = true,
            CoverUrl = true,
            profileUrl = true,
            CompanyName = true,
            AppIconUrl = true,
        }

        if not validUpdateOptions[updateOption] then
            SendFailure(m.From , "Invalid Update Option.")
            return
        end

        -- **Initialize missing field if necessary**
        if Apps.app[appId][updateOption] == nil then
            Apps.app[appId][updateOption] = ""
        end

        -- Perform the update
        Apps[appId][updateOption] = newValue
        local transactionType = "Updated.".. updateOption
        local amount = 0
        local points = 1
        LogTransaction(m.From, appId, transactionType, amount, currentTime, points)
        SendSuccess(m.From, " Update Succesful.")
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
                user_transactions[#user_transactions + 1] = transaction
            end
        end

        -- Check if at least one banner is provided
        if #user_transactions == 0 then
            SendFailure(m.From, "You do not have any transactions")
          return
        end
        SendSuccess(m.From , user_transactions)
        end
)


Handlers.add(
    "GetAosPointsTable",
    Handlers.utils.hasMatchingTag("Action", "GetAosPointsTable"),
    function(m)
        local caller = m.From

        print("Here is the caller Process ID"..caller)

        if AOS_POINTS ~= caller then
           SendFailure(m.From, "Only the AosPoints process can call this handler.")
            return
        end

        
        AosPoints = AosPoints or {}

        ao.send({
            Target = ARS,
            Action = "MainAosRespons",
            Data = TableToJson(AosPoints)
        })
        -- Send success response
        print("Successfully Added Bug Report Table table")
    end
)



Handlers.add(
    "ClearApps",
    Handlers.utils.hasMatchingTag("Action", "ClearApps"),
    function(m)
      Apps.apps = {}
    end
)

Handlers.add(
    "ResetDataCount",
    Handlers.utils.hasMatchingTag("Action", "ResetDataCount"),
    function(m)
      DataCount = 0
    end
)

