local json = require("json")
local math = require("math")



-- This process details.
PROCESS_NAME = "aos AosPoints"
PROCESS_ID_ = "vv8WuNF3bD9MG9tL4zguinQSobFFLDGQJtw_-yyoVl0"

AOS_POINTS = "vv8WuNF3bD9MG9tL4zguinQSobFFLDGQJtw_-yyoVl0"

-- Main  process details.
PROCESS_NAME = "aos aostoreP"
PROCESS_ID_MAIN = "8vRoa-BDMWaVzNS-aJPHLk_Noss0-x97j88Q3D4REnE"

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




-- tables 
Apps = Apps or {}

-- AosPoints Tables.

AosPointsMain = AosPointsMain or {}
AosPointsAirdrops = AosPointsAirdrops or {}
AosPointsBugReports = AosPointsBugReports or {}
AosPointsDevForum = AosPointsDevForum or {}
AosPointsFavorites = AosPointsFavorites or {}
AosPointsFeatures = AosPointsFeatures or {}
AosPointsFlags = AosPointsFlags or {}
AosPointsHelpful = AosPointsHelpful or {}
AosPointsTips = AosPointsTips or {}



Transactions  = Transactions or {}



AosPoints = AosPoints or {}
-- Counters variables 
AppCounter  = AppCounter or 0
TransactionCounter = TransactionCounter or 0
MessageCounter  = MessageCounter or 0


-- Callback Variables
FetchmainaosCallback = nil
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



function AddMainAosPoints( callback)
    ao.send({
        Target = PROCESS_ID,
        Tags = {
            { name = "Action", value = "GetAosPointsTable" },
        }
    })
    -- Save the callback to be called later
    FetchmainaosCallback = callback
end




function AddReviewTable( callback)
    ao.send({
        Target = PROCESS_ID_REVIEW_TABLE,
        Tags = {
            { name = "Action",     value = "AddReviewTableX" }
        }
    })
    -- Save the callback to be called later
    FetchreviewsCallback = callback
end


function AddHelpfulTable(callback)
    ao.send({
        Target = PROCESS_ID,
        Tags = {
            { name = "Action", value = "AddHelpfulTableX" },
        }
    })
     -- Save the callback to be called later
    FetchhelpfulCallback = callback
end


function AddBugReportTable( callback)
    ao.send({
        Target = PROCESS_ID_BUG_REPORT_TABLE,
        Tags = {
            { name = "Action",   value = "AddBugReportTable" },
        }
    })
    -- Save the callback to be called later
    FetchbugreportsCallback = callback
end


function AddDevForumTable( callback)
    ao.send({
        Target = PROCESS_ID_DEV_FORUM_TABLE,
        Tags = {
            { name = "Action",     value = "AddDevForumTable" },
        }
    })
    -- Save the callback to be called later
    FetchdevforumCallback = callback
end



function AddFeatureRequestTable( callback)
    ao.send({
        Target = PROCESS_ID_FEATURE_REQUEST_TABLE,
        Tags = {
            { name = "Action", value = "AddfeatureRequestsTable" },
        }
    })
    -- Save the callback to be called later
    FetchfeaturetableCallback = callback
end


function AddFlagTable( callback)
    ao.send({
        Target = PROCESS_ID_FLAG_TABLE,
        Tags = {
            { name = "Action", value = "AddFlagTableX" },
        }
    })
    -- Save the callback to be called later
    FetchflagtableCallback = callback
end


function AddFavoriteTable(callback)
    ao.send({
        Target = PROCESS_ID_FAVORITES_TABLE,
        Tags = {
            { name = "Action",  value = "AddFavoritesTableX" },}
    })
    -- Save the callback to be called later
    FetchfavoritesCallback = callback
end



function AddAirdropTable( callback)
    ao.send({
        Target = PROCESS_ID_AIRDROP_TABLE,
        Tags = {
            { name = "Action",  value = "AddAirdropsTable" },
        }
    })
    -- Save the callback to be called later
    FetchairdropsCallback = callback
end


function AddTipsTable( callback)
    ao.send({
        Target = PROCESS_ID_TIPS_TABLE,
        Tags = {
            { name = "Action",  value = "AddTipsTable" },
        }
    })
    -- Save the callback to be called later
    FetchtipsCallback = callback
end






-- In ReviewsResponse handler:
Handlers.add(
  "MainAosRespons",
  Handlers.utils.hasMatchingTag("Action", "MainAosRespons"),
  function(m)
    local xData = json.decode(m.Data)
    if  xData  == nil then
      print("No data received in Main response.")
      return
    end
    print("Updated AosMainPoints Response:", xData)
    AosPointsMain = xData
  end
)


-- In ReviewsResponse handler:
Handlers.add(
  "ReviewsRespons",
  Handlers.utils.hasMatchingTag("Action", "ReviewsRespons"),
  function(m)
    local xData = m.Data
    if not xData then
      print("No data received in Response response.")
      return
    end
    if xData == "true" then
    ReviewStatus = true
    DataCount = DataCount + 1
    print("Updated Review Response:", xData)
    -- Check if we have reached the required count
    if DataCount >= 8 and globalFinalizeProjectCallback then
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
              globalFinalizeProjectCallback()
          end
      end
    else
        ao.send({ Target = m.From, Data = "Wrong ProcessID" })
    end
  end
)


-- In Airdrop handler:
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
          if DataCount >= 8 and globalFinalizeProjectCallback then
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
    "GetAosPoints",
    Handlers.utils.hasMatchingTag("Action", "GetAosPoints"),
    function(m)
    
    DataCount = 0

    AddMainAosPoints(nil)

    SendSuccess(m.From, "Message Suucessfully sent.")
    
      end
)

Handlers.add(
    "GetAosPointsX",
    Handlers.utils.hasMatchingTag("Action", "GetAosPointsX"),
    function(m)
    
    DataCount = 0
  
    AddReviewTable(nil)
    AddHelpfulTable( nil)
    AddBugReportTable(nil)
    AddDevForumTable(nil)
    AddFeatureRequestTable(nil)
    AddFlagTable(nil) 
    AddFavoriteTable(nil)
    AddTipsTable(nil) 
    AddAirdropTable(nil) 

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
    "ResetDataCount",
    Handlers.utils.hasMatchingTag("Action", "ResetDataCount"),
    function(m)
      DataCount = 0
    end
)

