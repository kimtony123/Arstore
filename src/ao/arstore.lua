local json = require("json")
local math = require("math")


-- Credentials token
ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk"


Apps =  Apps or {}
reviewsTable = reviewsTable or {}
upvotesTable = upvotesTable or {}
downvotesTable = downvotesTable or {}
featureRequestsTable = featureRequestsTable or {}
bugsReportsTable = bugsReportsTable or {}
favoritesTable =  favoritesTable or {}
ratingsTable = ratingsTable or  {}
helpfulRatingsTable = helpfulRatingsTable or {}
unHelpfulRatingsTable = unHelpfulRatingsTable or  {}
flagTable = flagTable or {}
transactions = transactions or {}
verifiedUsers = verifiedUsers or {}
points  = points or {}
transactionCounter    = transactionCounter or 0
arsPoints = arsPoints or {}
AppCounter  = AppCounter or 0
ReviewCounter = ReviewCounter or 0
ReplyCounter          = ReplyCounter or 0



-- Function to get the current time in milliseconds
function getCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end


-- Function to generate a unique App ID
function generateAppId()
    AppCounter = AppCounter + 1
    return "TX" .. tostring(AppCounter)
end

-- Function to generate a unique review ID
function generateReviewId()
    ReviewCounter = ReviewCounter + 1
    return "TX" .. tostring(ReviewCounter)
end

-- Function to generate a unique transaction ID
function generateTransactionId()
    transactionCounter = transactionCounter + 1
    return "TX" .. tostring(transactionCounter)
end

-- Function to generate a unique transaction ID
function generateReplyId()
    ReplyCounter = ReplyCounter + 1
    return "TX" .. tostring(ReplyCounter)
end


function tableToJson(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        local valueType = type(value)
        if valueType == "table" then
            value = tableToJson(value)
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



function createAppLeaderboard(Apps)
  local leaderboard = {}

  -- Define category weights (you can tweak these)
  local categoryWeights = {
    ["Infrastructure"] = 2.0,
    ["Developer Tooling"] = 1.8,
    ["DEFI"] = 1.6,
    ["Social"] = 1.4,
    ["Gaming"] = 1.4,
    ["Community"] = 1.2,
    ["News and Knowledge"] = 1.2,
    ["Publishing"] = 1.2,
    ["Wallet"] = 1.2,
    ["Analytics"] = 1.1,
    ["Email"] = 1.0,
    ["Exchanges"] = 1.0,
    ["Incubators"] = 1.0,
    ["Storage"] = 1.0,
    ["Entertainment"] = 0.9,
    ["Nfts and Metaverse"] = 0.9,
    ["Memecoins"] = 0.5
  }

  -- Iterate through appData to calculate scores for each app
  for appID, app in pairs(Apps) do
    local categoryWeight = categoryWeights[app.ProjectType] or 1.0

    -- Access the correct values inside the tables
    local upvotes = app.Upvotes and app.Upvotes.count or 0
    local downvotes = app.Downvotes and app.Downvotes.count or 0
    local comments = app.Comments and app.Comments.count or 0
    local reviews = app.Reviews and app.Reviews.count or 0
    local ratings = app.Ratings and app.Ratings.count or 0
    local featureRequests = app.FeatureRequests and app.FeatureRequests.count or 0
    local bugsReports = app.BugsReports and app.BugsReports.count or 0
    local favorites = app.Favorites and #app.Favorites or 0
    local helpfulRatings = app.HelpfulRatings and app.HelpfulRatings.count or 0
    local unHelpfulRatings = app.UnHelpfulRatings and app.UnHelpfulRatings.count or 0

    -- Scoring weights (you can tweak these)
    local upvoteWeight = 1.0
    local downvotePenalty = 0.5
    local commentWeight = 0.8
    local reviewWeight = 1.2
    local ratingWeight = 1.5
    local featureRequestWeight = 1.1
    local bugReportPenalty = 0.8
    local favoriteWeight = 0.9
    local helpfulRatingWeight = 1.3
    local unhelpfulRatingPenalty = 0.7

    -- Calculate raw score
    local rawScore =
      (upvotes * upvoteWeight) -
      (downvotes * downvotePenalty) +
      (comments * commentWeight) +
      (reviews * reviewWeight) +
      (ratings * ratingWeight) +
      (featureRequests * featureRequestWeight) -
      (bugsReports * bugReportPenalty) +
      (favorites * favoriteWeight) +
      (helpfulRatings * helpfulRatingWeight) -
      (unHelpfulRatings * unhelpfulRatingPenalty)

    -- Apply category multiplier
    local finalScore = rawScore * categoryWeight
    
    -- Add app data to leaderboard
    leaderboard[appID] = {
      name = app.AppName,
      score = finalScore,
      category = app.ProjectType,
      upvotes = upvotes,
      downvotes = downvotes,
      comments = comments,
      reviews = reviews,
      ratings = ratings,
      featureRequests = featureRequests,
      bugsReports = bugsReports,
      favorites = favorites,
      helpfulRatings = helpfulRatings,
        unHelpfulRatings = unHelpfulRatings,
        AppIconUrl = app.AppIconUrl
      
    }
  end

  -- Convert leaderboard table into a sortable array
  local sortableLeaderboard = {}
  for appID, stats in pairs(leaderboard) do
    table.insert(sortableLeaderboard, { AppID = appID, stats = stats })
  end

  -- Sort the leaderboard by score (descending)
  table.sort(sortableLeaderboard, function(a, b)
    return a.stats.score > b.stats.score
  end)

  -- Assign ranks after sorting
  for rank, app in ipairs(sortableLeaderboard) do
    app.rank = rank
  end

  return sortableLeaderboard
end


Handlers.add(
    "AddAddress",
    Handlers.utils.hasMatchingTag("Action", "AddAddress"),
    function(m)
        local userId = m.From
        local address = m.Tags.address

        -- Validate input
        if not userId or not address then
            ao.send({ Target = m.From, Data = "userId or address is missing." })
            return
        end

        -- Initialize the verifiedUsers table if it doesn't exist
        verifiedUsers = verifiedUsers or {}

        -- Check if the user already exists in the table
        if not verifiedUsers[userId] then
            verifiedUsers[userId] = {
                addresses = {}
            }
        end
        -- Add the address to the user's record
        table.insert(verifiedUsers[userId].addresses, address)

        ao.send({ Target = m.From, Data = "Address added successfully for user: " .. userId })
    end
)


Handlers.add(
    "AddApp",
    Handlers.utils.hasMatchingTag("Action", "AddApp"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppName", "description", "protocol", "websiteUrl", "twitterUrl",
            "discordUrl", "coverUrl", "banner1Url", "banner2Url", "banner3Url",
            "banner4Url", "companyName", "appIconUrl",  "projectType", "username","profileUrl"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local currentTime = getCurrentTime(m)
        local AppId = generateAppId()
        local ReviewId = generateReviewId()
        local replyId = generateReplyId()
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl

    
        -- Initialize reviewsTable for the app
        reviewsTable[AppId] = {
        reviews = {
            {
            reviewId = ReviewId,
            user = user,
            username = username,
            comment = "Great app!",
            rating = 5,
            timestamp = currentTime,
            profileUrl = profileUrl,
            upvotes = 1,
            downvotes = 0,
            helpfulVotes = 1,
            unhelpfulVotes = 0,
            voters = {
                upvoted = {user = user},
                downvoted = {},
                foundHelpful = {user = user},
                foundUnhelpful = {}
            },
            replies = { -- Replies are stored here
                {
                    replyId = replyId,
                    user = user,
                    comment = "Thank you for your feedback!",
                    timestamp = currentTime,
                    upvotes = 1,
                    downvotes = 0,
                    voters = {
                    upvoted = {user = user },
                    downvoted = {},
                    foundHelpful = {user = user},
                    foundUnhelpful = {},}}}}}}

        upvotesTable[AppId] = { user = user, username = username, count = 1, currentTime = currentTime }
        downvotesTable[AppId] = { count = 0, user = user, currentTime = currentTime }
        featureRequestsTable[AppId] = { user = user, username = username, currentTime = currentTime, count = 0, comment = "" }
        bugsReportsTable[AppId] = { user = user, username = username, currentTime = currentTime, count = 0, comment = "" }
        favoritesTable[AppId] = { user = user , currentTime = currentTime }
        ratingsTable[AppId] = { user = user, rating = 5, currentTime = currentTime }
        helpfulRatingsTable[AppId] = { rating = 1, user = user, currentTime = currentTime }
        unHelpfulRatingsTable[AppId] = { rating = 0, user = user, currentTime = currentTime }
        flagTable[AppId] = { count = 0, user = user, currentTime = currentTime }

        -- Create the App record
        Apps[AppId] = {
            AppId = AppId,
            Owner = user,
            OwnerUserName = username,
            AppName = m.Tags.AppName,
            Description = m.Tags.description,
            Protocol = m.Tags.protocol,
            WebsiteUrl = m.Tags.websiteUrl,
            TwitterUrl = m.Tags.twitterUrl,
            DiscordUrl = m.Tags.discordUrl,
            CoverUrl = m.Tags.coverUrl,
            profileUrl = profileUrl,
            BannerUrls = {
                m.Tags.banner1Url,
                m.Tags.banner2Url,
                m.Tags.banner3Url,
                m.Tags.banner4Url
            },
            CompanyName = m.Tags.companyName,
            AppIconUrl = m.Tags.appIconUrl,
            Reviews = reviewsTable,
            Ratings = ratingsTable,
            Upvotes = upvotesTable,
            Downvotes = downvotesTable,
            FeatureRequests = featureRequestsTable,
            BugsReports = bugsReportsTable,
            ProjectType = m.Tags.projectType,
            CreatedTime = currentTime,
            Favorites = favoritesTable,
            HelpfulRatings = helpfulRatingsTable,
            UnHelpfulRatings = unHelpfulRatingsTable,
            Comments = commentsTable,
            FlagTable = flagTable,
        }

        -- Award points to the user
        local points = 100
        if arsPoints[user] then
            arsPoints[user].points = arsPoints[user].points + points
        else
            arsPoints[user] = { user = user, points = points }
        end

        -- Transfer tokens to the user
        local amount = 500
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        local balance = arsPoints[user].points

        -- Record the transaction
        if not transactions then transactions = {} end
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "App Creation",
            amount = amount,
            points = balance,
            timestamp = currentTime
        })

        -- Debugging: Print the Apps table
        print("Apps table after update: " .. tableToJson(Apps))

        -- Send success message to the user
        ao.send({ Target = m.From, Data = "Successfully Created The App" })
    end
)


Handlers.add(
    "GetProjectTypesAo",
    Handlers.utils.hasMatchingTag("Action", "GetProjectTypesAo"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = { "ProjectType", "Protocol" }

        for _, tag in ipairs(requiredTags) do
            if not m.Tags[tag] or m.Tags[tag] == "" then
                print("Error: " .. tag .. " is nil or empty.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        -- Extract projectType and protocol from m.Tags
        local projectType = m.Tags.ProjectType
        local protocol = m.Tags.Protocol
        print(projectType)
        print(protocol)
        -- Initialize a table to store filtered results
        local filteredApps = {}

        -- Loop through the Apps table and filter based on projectType and protocol
        for AppId, appDetails in pairs(Apps) do
            if appDetails.ProjectType == projectType and appDetails.Protocol == protocol then
                -- Include only relevant fields in the response
                filteredApps[AppId] = {
                    AppId = appDetails.AppId,
                    AppName = appDetails.AppName,
                    CompanyName = appDetails.CompanyName,
                    WebsiteUrl = appDetails.WebsiteUrl,
                    ProjectType = appDetails.ProjectType,
                    Protocol = appDetails.Protocol,
                    AppIconUrl = appDetails.AppIconUrl
                }
            end
        end

        -- Check if any apps were found
        if next(filteredApps) == nil then
            ao.send({ Target = m.From, Data = {} })
        else
            -- Send the filtered apps as a response
            ao.send({ Target = m.From, Data = tableToJson(filteredApps) })
        end
    end
)


Handlers.add(
    "DeleteApp",
    Handlers.utils.hasMatchingTag("Action", "DeleteApp"),
    function(m)
        -- Check if the required AppId tag is present
        if not m.Tags.AppId or m.Tags.AppId == "" then
            print("Error: AppId is nil or empty.")
            ao.send({ Target = m.From, Data = "AppId is missing or empty." })
            return
        end

        local appId = m.Tags.AppId

        -- Check if the app exists
        if not Apps[appId] then
            print("Error: App with AppId " .. appId .. " not found.")
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Get the app owner
        local appOwner = Apps[appId].Owner

        -- Check if the caller is the app owner or the process admin
        if m.From == appOwner or m.From == env.Process.Id then
            -- Delete the app from the Apps table
            Apps[appId] = nil

            -- Delete the app's data from associated tables
            reviewsTable[appId] = nil
            upvotesTable[appId] = nil
            downvotesTable[appId] = nil
            featureRequestsTable[appId] = nil
            bugsReportsTable[appId] = nil
            favoritesTable[appId] = nil
            ratingsTable[appId] = nil
            helpfulRatingsTable[appId] = nil
            unHelpfulRatingsTable[appId] = nil
            commentsTable[appId] = nil
            flagTable[appId] = nil

            -- Debugging: Print confirmation
            print("App with AppId " .. appId .. " and all associated data deleted successfully.")

            -- Send success message
            ao.send({ Target = m.From, Data = "Successfully deleted the app and all associated data." })
        else
            -- If the caller is not the owner or admin, send an error message
            print("Unauthorized delete attempt by " .. m.From)
            ao.send({ Target = m.From, Data = "You are not the app owner or admin." })
        end
    end
)


Handlers.add(
    "AppInfo",
    Handlers.utils.hasMatchingTag("Action", "AppInfo"),
    function(m)
        -- Check if the required AppId tag is present
        if not m.Tags.AppId or m.Tags.AppId == "" then
            print("Error: AppId is nil or empty.")
            ao.send({ Target = m.From, Data = "AppId is missing or empty." })
            return
        end

        -- Extract the AppId from the message
        local AppId = m.Tags.AppId

        -- Check if the Apps table exists and contains the requested AppId
        if not Apps or next(Apps) == nil or not Apps[AppId] then
            print("App with AppId " .. AppId .. " not found.")
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Fetch the app details
        local appDetails = Apps[AppId]

        -- Prepare the response with all relevant app details
        local AppInfoResponse = {
            AppId = appDetails.AppId,
            AppName = appDetails.AppName,
            Description = appDetails.Description,
            Protocol = appDetails.Protocol,
            WebsiteUrl = appDetails.WebsiteUrl,
            TwitterUrl = appDetails.TwitterUrl,
            DiscordUrl = appDetails.DiscordUrl,
            CoverUrl = appDetails.CoverUrl,
            BannerUrls = appDetails.BannerUrls,
            CompanyName = appDetails.CompanyName,
            AppIconUrl = appDetails.AppIconUrl,
            Reviews = appDetails.Reviews,
            Ratings = appDetails.Ratings,
            Upvotes = appDetails.Upvotes,
            Downvotes = appDetails.Downvotes,
            FeatureRequests = appDetails.FeatureRequests,
            BugsReports = appDetails.BugsReports,
            ProjectType = appDetails.ProjectType,
            CreatedTime = appDetails.CreatedTime,
            Favorites = appDetails.Favorites
        }

        -- Send the app info as a JSON response
        ao.send({ Target = m.From, Data = tableToJson(AppInfoResponse) })

        -- Debugging: Print the app info to the console
        print("App Info for AppId " .. AppId .. ": " .. tableToJson(AppInfoResponse))
    end
)





Handlers.add(
    "getFavoriteApps",
    Handlers.utils.hasMatchingTag("Action", "getFavoriteApps"),
    function(m)
        local filteredFavorites = {}

        -- Loop through the favoritesTable to find the user's favorites
        for AppId, favorite in pairs(favoritesTable) do
            if favorite.user == m.From then
                -- Retrieve the app details from the Apps table
                local appDetails = Apps[AppId]
                if appDetails then
                    -- Format the app details to include only the required fields
                    filteredFavorites[AppId] = {
                        AppIconUrl = appDetails.AppIconUrl,
                        AppName = appDetails.AppName,
                        CompanyName = appDetails.CompanyName,
                        ProjectType = appDetails.ProjectType,
                        WebsiteUrl = appDetails.WebsiteUrl
                    }
                end
            end
        end

        -- Send the filtered favorites back to the user
        ao.send({ Target = m.From, Data = tableToJson(filteredFavorites) })
    end
)




Handlers.add(
    "getMyApps",
    Handlers.utils.hasMatchingTag("Action", "getMyApps"),
    function(m)
        local owner = m.From

        -- Check if the Apps table is empty
        if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")
            ao.send({ Target = owner, Data = "No apps found." })
            return
        end

        -- Filter apps owned by the user
        local filteredApps = {}
        for AppId, App in pairs(Apps) do
            if App.Owner == owner then
                filteredApps[AppId] = {
                    AppId = App.AppId,
                    AppName = App.AppName,
                    Description = App.Description,
                    CompanyName = App.CompanyName,
                    ProjectType = App.ProjectType,
                    WebsiteUrl = App.WebsiteUrl,
                    AppIconUrl = App.AppIconUrl,
                    CreatedTime = App.CreatedTime
                }
            end
        end

        -- Send the filtered apps to the user
        ao.send({ Target = owner, Data = tableToJson(filteredApps) })
    end
)

Handlers.add(
    "fetch_app_leaderboard",
    Handlers.utils.hasMatchingTag("Action", "fetch_app_leaderboard"),
    function(m)
      
        -- Create the leaderboard
        local leaderboard = createAppLeaderboard(Apps)
        
        -- Debugging: Print leaderboard before converting it to JSON
        print("App Leaderboard Table: ")
        for _, app in ipairs(leaderboard) do
            local name = app.stats.name or "Unknown"
            local score = app.stats.score or 0.0
            local category = app.stats.category or "Uncategorized"
            local upvotes = app.stats.upvotes or 0
            local comments = app.stats.comments or 0
            local activeUsers = app.stats.activeUsers or 0
            local developerActivity = app.stats.developerActivity or 0

            print(string.format("AppID: %s, Name: %s, Score: %.2f, Category: %s, Upvotes: %d, Comments: %d, Active Users: %d, Developer Activity: %d", 
                app.AppID, name, score, category, upvotes, comments, activeUsers, developerActivity))
        end

        -- Convert the leaderboard table to JSON and send it to the user
        local jsonData = tableToJson(leaderboard)
        print("App Leaderboard JSON: " .. jsonData) -- Debugging: Print the JSON data
        ao.send({ Target = m.From, Data = jsonData })
    end
)


Handlers.add(
    "AddReviewApp",
    Handlers.utils.hasMatchingTag("Action", "AddReviewApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = {
            "username", "profileUrl", "AppId", "comment", "rating"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local appId = m.Tags.AppId
        local comment = m.Tags.comment
        local user = m.From
        local username = m.Tags.username
        local profileUrl = m.Tags.profileUrl
        local rating = tonumber(m.Tags.rating)
        local currentTime = getCurrentTime(m)

        -- Validate rating
        if not rating or rating < 1 or rating > 5 then
            ao.send({ Target = m.From, Data = "Invalid rating. Please provide a rating between 1 and 5." })
            return
        end

        -- Check if the app exists
        if not reviewsTable[appId] then
            reviewsTable[appId] = { reviews = {} }
        end

        -- Prevent duplicate reviews by the same user
        for _, review in ipairs(reviewsTable[appId].reviews) do
            if review.user == user then
                ao.send({ Target = m.From, Data = "You have already reviewed this app." })
                return
            end
        end

        -- Generate unique ID for the review
        local reviewId = generateReviewId()

        -- Add the new review
        table.insert(reviewsTable[appId].reviews, {
            reviewId = reviewId,
            user = user,
            username = username,
            comment = comment,
            rating = rating,
            timestamp = currentTime,
            profileUrl = profileUrl,
            upvotes = 1,
            downvotes = 0,
            helpfulVotes = 1,
            unhelpfulVotes = 0,
            voters = {
                upvoted = {user},
                downvoted = {},
                foundHelpful = {user},
                foundUnhelpful = {}
            },
            replies = {}
        })

        -- Optional: Notify app owner about new review
        local appOwner = Apps[appId] and Apps[appId].Owner
        if appOwner then
            ao.send({ Target = appOwner, Data = "New review added by " .. username .. "." })
        end

        ao.send({ Target = m.From, Data = "Review added successfully." })
    end
)


-- Add Helpful Rating Handler
Handlers.add(
    "HelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "HelpfulRating"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppId"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user has already marked the rating as helpful
        if helpfulRatingsTable[AppId] and helpfulRatingsTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Mark the rating as helpful
        helpfulRatingsTable[AppId] = helpfulRatingsTable[AppId] or {}
        helpfulRatingsTable[AppId][user] = true

        -- Increment the helpful count
        helpfulRatingsTable[AppId].rating = (helpfulRatingsTable[AppId].rating or 0) + 1

        -- Add time 
        helpfulRatingsTable[AppId].currentTime = currentTime

        ao.send({ Target = m.From, Data = "Thank you for your feedback!" })
    end
)

-- Add Unhelpful Rating Handler
Handlers.add(
    "UnhelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "UnhelpfulRating"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppId"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user has already marked the rating as unhelpful
        if unHelpfulRatingsTable[AppId] and unHelpfulRatingsTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as unhelpful." })
            return
        end

        -- Mark the rating as unhelpful
        unHelpfulRatingsTable[AppId] = unHelpfulRatingsTable[AppId] or {}
        unHelpfulRatingsTable[AppId][user] = true

        -- Increment the unhelpful count
        unHelpfulRatingsTable[AppId].rating = (unHelpfulRatingsTable[AppId].rating or 0) + 1

           -- Add time
        unHelpfulRatingsTable[AppId].currentTime = currentTime

        ao.send({ Target = m.From, Data = "Thank you for your feedback!" })
    end
)



-- Add Upvote Handler
Handlers.add(
    "UpvoteApp",
    Handlers.utils.hasMatchingTag("Action", "UpvoteApp"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppId"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end
        
        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if user has already upvoted
        if upvotesTable[AppId] and upvotesTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already upvoted this app." })
            return
        end

        -- Add upvote
        upvotesTable[AppId] = upvotesTable[AppId] or {}
        upvotesTable[AppId][user] = true

        -- Increment count
        upvotesTable[AppId].rating = (upvotesTable[AppId].rating or 0) + 1
             -- 
        upvotesTable[AppId].currentTime = currentTime

        ao.send({ Target = m.From, Data = "Upvote successful!" })
    end
)

-- Add Downvote Handler
Handlers.add(
    "DownvoteApp",
    Handlers.utils.hasMatchingTag("Action", "DownvoteApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppId"
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end
        local AppId = m.Tags.AppId
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Allow downvoting twice
        if downvotesTable[AppId] and downvotesTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already downvoted this app twice." })
            return
        end

        -- Track downvotes per user
        downvotesTable[AppId] = downvotesTable[AppId] or {}
        downvotesTable[AppId][user] = (downvotesTable[AppId][user] or 0) + 1

        --Add time
        downvotesTable[AppId].currentTime = currentTime

        -- Check if user has already upvoted
        if downvotesTable[AppId] and downvotesTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already downvoted this app." })
            return
        end

          -- Increment count
        downvotesTable[AppId].rating = (downvotesTable[AppId].rating or 0) + 1

        ao.send({ Target = m.From, Data = "Downvote successful!" })
    end
)


Handlers.add(
    "AddReviewReply",
    Handlers.utils.hasMatchingTag("Action", "AddReviewReply"),
    function(m)
        -- Check required tags
        local requiredTags = { "AppId", "ReviewId", "username", "comment" ,"profileUrl"}
        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local comment = m.Tags.comment
        local user = m.From
        local profileUrl = m.From.profileUrl
        local username = m.From.username
        local currentTime = getCurrentTime(m)

        -- Check if the app exists
        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Check if the user is the app owner
        if Apps[appId].Owner ~= user then
            ao.send({ Target = m.From, Data = "Only the app owner can reply to reviews." })
            return
        end

        -- Find the review by ID
        if not reviewsTable[appId] or not reviewsTable[appId].reviews then
            ao.send({ Target = m.From, Data = "Reviews not found for this app." })
            return
        end

        local targetReview
        for _, review in ipairs(reviewsTable[appId].reviews) do
            if review.reviewId == reviewId then
                targetReview = review
                break
            end
        end

        if not targetReview then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end

        -- Generate a unique ID for the reply
        local replyId = generateReplyId()

        -- Add the reply to the review
        if not targetReview.replies then
            targetReview.replies = {}
        end

      table.insert(reviewsTable[appId].reviews, {
        reviewId = reviewId,
        user = user,
        username = username,
        comment = comment,
        rating = ratingsTable[appId][user].rating,
        timestamp = currentTime,
        profileUrl = profileUrl,
        upvotes = 1,
        downvotes = 0,
        helpfulVotes = 1,
        unhelpfulVotes = 0,
        voters = {
        upvoted = {user = user},
        downvoted = {},
        foundHelpful = {user = user},
        foundUnhelpful = {}
            },
        replies = {}})


        -- Notify the review author
        local reviewAuthor = targetReview.user
        ao.send({ Target = reviewAuthor, Data = "The app owner has replied to your review." })

        ao.send({ Target = m.From, Data = "Reply added successfully." })
    end
)





Handlers.add(
    "MarkHelpfulReview",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user already marked it as helpful
        if review.voters.foundHelpful[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as helpful." })
            return
        end

        -- Update helpful vote count and record the voter
        review.helpfulVotes = review.helpfulVotes + 1
        review.voters.foundHelpful[user] = true

        ao.send({ Target = m.From, Data = "Review marked as helpful successfully." })
    end
)

Handlers.add(
    "MarkUnhelpfulReview",
    Handlers.utils.hasMatchingTag("Action", "MarkUnhelpfulReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user already marked it as unhelpful
        if review.voters.foundUnhelpful[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as unhelpful." })
            return
        end

        -- Update unhelpful vote count and record the voter
        review.unhelpfulVotes = review.unhelpfulVotes + 1
        review.voters.foundUnhelpful[user] = true

        ao.send({ Target = m.From, Data = "Review marked as unhelpful successfully." })
    end
)

Handlers.add(
    "UpvoteReview",
    Handlers.utils.hasMatchingTag("Action", "UpvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user has already upvoted
        if review.voters.upvoted[user] then
            ao.send({ Target = m.From, Data = "You have already upvoted this review." })
            return
        end

        -- Update the upvote count and mark the user as an upvoter
        review.upvotes = review.upvotes + 1
        review.voters.upvoted[user] = true

        ao.send({ Target = m.From, Data = "Review upvoted successfully." })
    end
)

Handlers.add(
    "DownvoteReview",
    Handlers.utils.hasMatchingTag("Action", "DownvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From

        -- Check if the app and review exist
        if not reviewsTable[appId] or not reviewsTable[appId].reviews[reviewId] then
            ao.send({ Target = m.From, Data = "App or review not found." })
            return
        end

        local review = reviewsTable[appId].reviews[reviewId]

        -- Check if the user has already downvoted
        if review.voters.downvoted[user] then
            ao.send({ Target = m.From, Data = "You have already downvoted this review." })
            return
        end

        -- Update the downvote count and record the voter
        review.downvotes = review.downvotes + 1
        review.voters.downvoted[user] = true

        ao.send({ Target = m.From, Data = "Review downvoted successfully." })
    end
)


Handlers.add(
    "TransferAppOwnership",
    Handlers.utils.hasMatchingTag("Action", "TransferAppOwnership"),
    function(m)
        local appId = m.Tags.AppId
        local newOwner = m.Tags.NewOwner
        local currentOwner = m.From

        -- Validate input
        if not appId or not newOwner then
            ao.send({ Target = m.From, Data = "AppId or NewOwner is missing." })
            return
        end

        -- Check if the app exists
        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Check if the user making the request is the current owner
        if Apps[appId].Owner ~= currentOwner then
            ao.send({ Target = m.From, Data = "You are not the owner of this app." })
            return
        end

        -- Transfer ownership
        Apps[appId].Owner = newOwner
        ao.send({ Target = m.From, Data = "Ownership transferred to " .. newOwner })
    end
)


Handlers.add(
    "UpdateAppDetails",
    Handlers.utils.hasMatchingTag("Action", "UpdateAppDetails"),
    function(m)
        local appId = m.Tags.AppId
        local updateOption = m.Tags.UpdateOption
        local newValue = m.Tags.NewValue
        local currentOwner = m.From

        -- Validate input
        if not appId or not updateOption or not newValue then
            ao.send({ Target = m.From, Data = "AppId, UpdateOption, or NewValue is missing." })
            return
        end

        -- Check if the app exists
        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        -- Check if the user making the request is the current owner
        if Apps[appId].Owner ~= currentOwner then
            ao.send({ Target = m.From, Data = "You are not the owner of this app." })
            return
        end

        -- Update the requested field
        local validUpdateOptions = {
            appName = true,
            description = true,
            websiteUrl = true,
            discordUrl = true,
            twitterUrl = true,
            coverUrl = true,
            banner1Url = true,
            banner2Url = true,
            banner3Url = true,
            banner4Url = true,
            companyName = true,
            appIconUrl = true
        }

        if not validUpdateOptions[updateOption] then
            ao.send({ Target = m.From, Data = "Invalid UpdateOption." })
            return
        end

        -- Perform the update
        Apps[appId][updateOption] = newValue
        ao.send({ Target = m.From, Data = updateOption .. " updated successfully." })
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
        for _, transaction in ipairs(transactions) do
            -- Skip nil transactions
            if transaction ~= nil and transaction.user == user then
                table.insert(user_transactions, transaction)
            end
        end
        
        -- Send the filtered transactions back to the user
        ao.send({ Target = user, Data = tableToJson(user_transactions) })
    end
)