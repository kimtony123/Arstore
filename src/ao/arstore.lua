local json = require("json")
local math = require("math")


-- Credentials token
ARS = "Gwx7lNgoDtObgJ0LC-kelDprvyv2zUdjIY6CTZeYYvk"

-- Table to track addresses that have requested tokens
RequestedAddresses = RequestedAddresses or {}

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
commentsTable =  commentsTable or {}



-- Initialize transaction ID counter
AppCounter = AppCounter or 0


-- Function to get the current time in milliseconds
function getCurrentTime(msg)
    return msg.Timestamp -- returns time in milliseconds
end


-- Function to generate a unique transaction ID
function generateAppId()
    AppCounter = AppCounter + 1
    return "TX" .. tostring(AppCounter)
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



-- Add App Handler Function
Handlers.add(
    "AddApp",
    Handlers.utils.hasMatchingTag("Action", "AddApp"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppName", "description", "protocol", "websiteUrl", "twitterUrl",
            "discordUrl", "coverUrl", "banner1Url", "banner2Url", "banner3Url",
            "banner4Url", "companyName", "appIconUrl", "appReviews", "appRatings",
            "upvotes", "downvotes", "featureRequests", "bugsReports", "projectType", "username"
        }

        -- Iterate over required tags and check for nil values
        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

        local currentTime = getCurrentTime(m)
        local AppId = generateAppId()
        local user = m.From
        local username = m.Tags.username

        -- Populate the tables with initial values
        reviewsTable[AppId] = { user, username, count = 0 ,currentTime }
        upvotesTable[AppId] = { user, username, count = 1 , currentTime}
        downvotesTable[AppId] = { count = 0 ,user,currentTime}
        featureRequestsTable[AppId] = { user, username, currentTime, count = 0, comments = {} }
        bugsReportsTable[AppId] = { user, username, currentTime ,count = 0, comments = {} }
        favoritesTable[AppId] = { user }
        ratingsTable[AppId] = { user, count = 0, currentTime }
        helpfulRatingsTable[AppId] = { count = 0, user,currentTime }
        unHelpfulRatingsTable[AppId] = { count = 0, user ,currentTime}
        commentsTable[AppId] = { count = 0, user , currentTime}

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
            Comments = commentsTable
        }

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
    "getApps",
    Handlers.utils.hasMatchingTag("Action", "getApps"),
    function(m)
        if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")
            ao.send({ Target = m.From, Data = "Apps table is empty or nil." }) -- Send an empty JSON if there are no trades
            return
        end
        ao.send({ Target = m.From, Data = tableToJson(Apps) })
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
    "OwnerApps",
    Handlers.utils.hasMatchingTag("Action", "OwnerApps"),
    function(m)
        if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")
            ao.send({ Target = m.From, Data = "Apps table is empty or nil." }) -- Send an empty JSON if there are no trades
            return
        end

        local filteredApps = {}
        for AppId, App in pairs(Apps) do
            if App.Owner == m.From then
                filteredApps[AppId] = App
            end
        end
        ao.send({ Target = m.From, Data = tableToJson(filteredApps) })
    end
)


Handlers.add(
    "AppTypeao",
    Handlers.utils.hasMatchingTag("Action", "Apptypeao"),
    function(m)
        if m.Tags.projectType then
            if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")

            ao.send({ Target = m.From, Data = {} }) -- Send an empty JSON if there are no trades
            return
            end
            local filteredApps = {}
            for AppId, App in pairs(Apps) do
            if App.projectType == m.Tags.projectType and App.protocol =="aocomputer" then
                filteredApps[AppId] = App
            end
            ao.send({ Target = m.From, Data = tableToJson(filteredApps) })  
            end
            else
            -- Print error message for missing tags
            print("Missing required tags for getting Data.")
            ao.send({ Target = m.From, Data = "Missing required tags for gettingData." })
            end   
        end 
)


Handlers.add(
    "AppTypear",
    Handlers.utils.hasMatchingTag("Action", "Apptypear"),
    function(m)
        if m.Tags.projectType then
            if not Apps or next(Apps) == nil then
            print("Apps table is empty or nil.")
            ao.send({ Target = m.From, Data = "Apps table is empty or nil." }) -- Send an empty JSON if there are no trades
            return
            end
            local filteredApps = {}
            for AppId, App in pairs(Apps) do
            if App.projectType == m.Tags.projectType and App.protocol =="aocomputer" then
                filteredApps[AppId] = App
            end
            ao.send({ Target = m.From, Data = tableToJson(filteredApps) })  
            end
            else
            -- Print error message for missing tags
            print("Missing required tags for getting Data.")
            ao.send({ Target = m.From, Data = "Missing required tags for gettingData." })
            end   
        end 
)



-- claim  Handler Function
Handlers.add(
    "claim",
    Handlers.utils.hasMatchingTag("Action", "claim"),
    function(Msg)
        local requesterAddress = Msg.From
        -- Check if the address has already requested tokens
        if RequestedAddresses[requesterAddress] then
            ao.send({Target = requesterAddress, Data = "Already requested tokens."})
        else
            -- Grant tokens and record the request
            local amount = 6
            ao.send({
                Target = ARS,
                Action = "Transfer",
                Quantity = tostring(amount),
                Recipient = requesterAddress,
            })
            print("Transferred: " .. amount .. " successfully to " .. requesterAddress)
            -- Record the address as having requested tokens
            RequestedAddresses[requesterAddress] = true
            -- Send a success message
            ao.send({Target = requesterAddress, Data = "Successfully recieved" .. amount..  "tokens."})
        end
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

-- Add Helpful Rating Handler
Handlers.add(
    "HelpfulRating",
    Handlers.utils.hasMatchingTag("Action", "HelpfulRating"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From

        -- Check if the user has already marked the rating as helpful
        if helpfulRatingsTable[AppId] and helpfulRatingsTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Mark the rating as helpful
        helpfulRatingsTable[AppId] = helpfulRatingsTable[AppId] or {}
        helpfulRatingsTable[AppId][user] = true

        -- Increment the helpful count
        helpfulRatingsTable[AppId].count = (helpfulRatingsTable[AppId].count or 0) + 1

        ao.send({ Target = m.From, Data = "Thank you for your feedback!" })
    end
)

-- Add Unhelpful Rating Handler
Handlers.add(
    "UnhelpfulRating",
    Handlers.utils.hasMatchingTag("Action", "UnhelpfulRating"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From

        -- Check if the user has already marked the rating as unhelpful
        if unHelpfulRatingsTable[AppId] and unHelpfulRatingsTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as unhelpful." })
            return
        end

        -- Mark the rating as unhelpful
        unHelpfulRatingsTable[AppId] = unHelpfulRatingsTable[AppId] or {}
        unHelpfulRatingsTable[AppId][user] = true

        -- Increment the unhelpful count
        unHelpfulRatingsTable[AppId].count = (unHelpfulRatingsTable[AppId].count or 0) + 1

        ao.send({ Target = m.From, Data = "Thank you for your feedback!" })
    end
)




-- Add Upvote Handler
Handlers.add(
    "UpvoteApp",
    Handlers.utils.hasMatchingTag("Action", "UpvoteApp"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From

        -- Check if user has already upvoted
        if upvotesTable[AppId] and upvotesTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already upvoted this app." })
            return
        end

        -- Add upvote
        upvotesTable[AppId] = upvotesTable[AppId] or {}
        upvotesTable[AppId][user] = true

        -- Increment count
        upvotesTable[AppId].count = (upvotesTable[AppId].count or 0) + 1

        ao.send({ Target = m.From, Data = "Upvote successful!" })
    end
)

-- Add Downvote Handler
Handlers.add(
    "DownvoteApp",
    Handlers.utils.hasMatchingTag("Action", "DownvoteApp"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From

        -- Allow downvoting twice
        if downvotesTable[AppId] and downvotesTable[AppId][user] then
            ao.send({ Target = m.From, Data = "You have already downvoted this app twice." })
            return
        end

        -- Track downvotes per user
        downvotesTable[AppId] = downvotesTable[AppId] or {}
        downvotesTable[AppId][user] = (downvotesTable[AppId][user] or 0) + 1

        -- Limit downvotes to 2 per user
        if downvotesTable[AppId][user] > 2 then
            downvotesTable[AppId][user] = 2
        else
            -- Increment count
            downvotesTable[AppId].count = (downvotesTable[AppId].count or 0) + 1
        end

        ao.send({ Target = m.From, Data = "Downvote successful!" })
    end
)

-- Add Rating Handler
Handlers.add(
    "RateApp",
    Handlers.utils.hasMatchingTag("Action", "RateApp"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From
        local rating = tonumber(m.Tags.Rating)

        -- Validate rating (e.g., between 1 and 5)
        if not rating or rating < 1 or rating > 5 then
            ao.send({ Target = m.From, Data = "Invalid rating. Please provide a rating between 1 and 5." })
            return
        end

        -- Allow user to rate multiple times (overwrite previous rating)
        ratingsTable[AppId] = ratingsTable[AppId] or {}
        ratingsTable[AppId][user] = rating

        ao.send({ Target = m.From, Data = "Rating submitted!" })
    end
)

-- Add Comment Handler
Handlers.add(
    "CommentApp",
    Handlers.utils.hasMatchingTag("Action", "CommentApp"),
    function(m)
        local AppId = m.Tags.AppId
        local user = m.From
        local comment = m.Tags.Comment

        -- Check if comment is empty
        if not comment or comment == "" then
            ao.send({ Target = m.From, Data = "Comment cannot be empty." })
            return
        end

        -- Add comment to comments table
        commentsTable[AppId] = commentsTable[AppId] or {}
        table.insert(commentsTable[AppId], { user = user, comment = comment })

        ao.send({ Target = m.From, Data = "Comment added!" })
    end
)