local json = require("json")
local math = require("math")


-- Credentials token
ARS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"


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
points = points or {}
Airdrops = Airdrops or {}
usersTable = usersTable or {}
arsPoints = arsPoints or {}
newTable = newTable or {}
AppCounter  = AppCounter or 0
ReviewCounter = ReviewCounter or 0
ReplyCounter = ReplyCounter or 0
AidropCounter = AidropCounter or 0
transactionCounter  = transactionCounter or 0

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

-- Function to generate a unique transaction ID
function generateReplyId()
    ReplyCounter = ReplyCounter + 1
    return "TX" .. tostring(ReplyCounter)
end

-- Function to generate a unique transaction ID
function generateAirdropId()
    AidropCounter = AidropCounter + 1
    return "TX" .. tostring(AidropCounter)
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


-- Fetch the user's points data safely
 function getOrInitializeUserPoints(user)
    -- Ensure arsPoints is initialized
    arsPoints = arsPoints or {}

    -- Check if the user already exists in arsPoints
    if not arsPoints[user] then
        arsPoints[user] = { user = user, points = 0 }
    end

    -- Return the user's data
    return arsPoints[user]
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
    "AddApp",
    Handlers.utils.hasMatchingTag("Action", "AddApp"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = {
            "AppName", "description", "protocol", "websiteUrl", "twitterUrl",
            "discordUrl", "coverUrl", "banner1Url", "banner2Url", "banner3Url",
            "banner4Url", "companyName", "appIconUrl", "projectType", "username", "profileUrl"
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

        -- Initialize tables for the app
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
                    voters = {
                                upvoted = {
                                    count = 1,
                                    countHistory = { {  time = currentTime, count = 1 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }}
                                    },
                                downvoted = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = {  username = username,voted = true, time = currentTime }}},
                                foundHelpful = { 
                                    count = 1,
                                    countHistory = { { time = currentTime, count = 1 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }} },
                            
                                foundUnhelpful = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }}}
                                
                                },
                    replies = {
                        {
                            replyId = replyId,
                            user = user,
                            profileUrl = profileUrl,
                            username = username,
                            comment = "Thank you for your feedback!",
                            timestamp = currentTime,
                            users = {[user] = { username = username, voted = true, time = currentTime }}         
                        }
                    },
                    count = 1,
                    countHistory = { { time = currentTime, count = 1 } },
                    users = {[user] = { voted = true, time = currentTime }}
                
                }
            }
        }

        upvotesTable[AppId] = {
        count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { username = username, voted = true, time = currentTime }
            }
        }

        downvotesTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { username = username, voted = false, time = currentTime }
            }
        }

        featureRequestsTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { username = username, voted = false, time = currentTime ,comment =""}
            }
        }

        bugsReportsTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { username = username, voted = false, time = currentTime, comment ="" }
            }
        }

        favoritesTable[AppId] = {
         count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { username = username, voted = true, time = currentTime }
            }
        }

        ratingsTable[AppId] = {
            Totalratings = 5,
            count = 1,
            countHistory = { { time = currentTime, count = 1 , rating = 5} },
            users = {
                [user] = { username = username, voted = true, time = currentTime }
            }
        }

        helpfulRatingsTable[AppId] = {
            count = 1,
            countHistory = { { time = currentTime, count = 1 } },
            users = {
                [user] = { username = username, voted = true, time = currentTime }
            }
        }

        unHelpfulRatingsTable[AppId] = {
            count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { username = username, voted = false, time = currentTime }
            }
        }

        flagTable[AppId] = {
           count = 0,
            countHistory = { { time = currentTime, count = 0 } },
            users = {
                [user] = { username = username, voted = false, time = currentTime }
            }
        }

        newTable[AppId] = {
            comment = "Launched on aostore",
            count = 1,
            countHistory = { { time = currentTime, count = 1} },
            users = {[user] = { username = username, voted = true, time = currentTime }},
            currentTime = currentTime
        }
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
            BannerUrl1 = m.Tags.banner1Url,
            BannerUrl2 = m.Tags.banner2Url,
            BannerUrl3 = m.Tags.banner3Url,
            BannerUrl4 = m.Tags.banner4Url,
            CompanyName = m.Tags.companyName,
            AppIconUrl = m.Tags.appIconUrl,
            ProjectType = m.Tags.projectType,
            CreatedTime = currentTime,
            Reviews = reviewsTable[AppId].count,
            Ratings = ratingsTable[AppId],
            TotalRatings = ratingsTable[AppId].Totalratings,
            Upvotes = upvotesTable[AppId].count,
            Downvotes = downvotesTable[AppId].count,
            Favorites = favoritesTable[AppId].count,
            HelpfulRatings = helpfulRatingsTable[AppId].count,
            UnHelpfulRatings = unHelpfulRatingsTable[AppId].count,
            FeatureRequests = featureRequestsTable[AppId].count,
            BugsReports = bugsReportsTable[AppId].count,
            FlagTable = flagTable[AppId].count,
            WhatsNew = newTable[AppId].comment,
            LastUpdated = newTable[AppId].currentTime
        }

        local points = 100
        -- Ensure arsPoints[user] is initialized
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
            -- Update points
        arsPoints[user].points = arsPoints[user].points + points
        -- Safely access points
        
        local amount = 10
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        local transactionId = generateTransactionId()
        local currentPoints = arsPoints[user].points
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "App Creation",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging: Print the Apps table
        print("Apps table after update: " .. tableToJson(Apps))

        -- Send success message
        ao.send({ Target = m.From, Data = "Successfully Created The App" })
    end
)



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
            CompanyName = appDetails.CompanyName,
            AppIconUrl = appDetails.AppIconUrl,
            Reviews =  appDetails.Reviews,
            Ratings = appDetails.Ratings,
            RatingsCount = appDetails.RatingsCount,
            Upvotes = appDetails.Upvotes,
            Downvotes = appDetails.Downvotes,
            FeatureRequests = appDetails.FeatureRequests,
            BugsReports = appDetails.BugsReports,
            ProjectType = appDetails.ProjectType,
            CreatedTime = appDetails.CreatedTime,
            Favorites = appDetails.Favorites,
            Flags = appDetails.FlagTable,
            HelpfulRatings = appDetails.HelpfulRatings,
            UnHelpfulRatings = appDetails.UnHelpfulRatings,
            WhatsNew = appDetails.WhatsNew,
            BannerUrl1 = appDetails.BannerUrl1,
            BannerUrl2 = appDetails.BannerUrl2,
            BannerUrl3 = appDetails.BannerUrl3,
            BannerUrl4 = appDetails.BannerUrl4,
            LastUpdated = appDetails.LastUpdated
            
        }

        -- Send the app info as a JSON response
        ao.send({ Target = m.From, Data = tableToJson(AppInfoResponse) })

        -- Debugging: Print the app info to the console
        print("App Info for AppId " .. AppId .. ": " .. tableToJson(AppInfoResponse))
    end
)



Handlers.add(
    "FetchAppReviews",
    Handlers.utils.hasMatchingTag("Action", "FetchAppReviews"),
    function(m)
        local appId = m.Tags.AppId

        -- Validate input
        if not appId then
            ao.send({ Target = m.From, Data = "AppId is missing." })
            return
        end

        -- Check if the app exists in the reviews table
        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "No reviews found for this app." })
            return
        end

        -- Fetch the reviews
        local appReviews = reviewsTable[appId].reviews

        -- Check if there are reviews
        if not appReviews or #appReviews == 0 then
            ao.send({ Target = m.From, Data = "No reviews available for this app." })
            return
        end

        -- Convert reviews to JSON for sending
        local reviewsJson = tableToJson(appReviews)

        -- Send the reviews back to the user
        ao.send({
            Target = m.From,
            Data = reviewsJson
        })
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
        -- Prevent duplicate reviews by the same user
        for _, review in ipairs(reviewsTable[appId].reviews) do
                if review.user == user then
                
                local points = -30
                -- Ensure arsPoints[user] is initialized
                arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
                -- Update points
                arsPoints[user].points = arsPoints[user].points + points
                -- Safely access points
                local currentPoints = arsPoints[user].points
                local transactionId = generateTransactionId()
                table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Already Reviewed Project.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
                })
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
            voters = {
                                upvoted = {
                                    count = 1,
                                    countHistory = { { time = currentTime, count = 1 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }}
                                    },
                                downvoted = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }}},
                                foundHelpful = { 
                                    count = 1,
                                    countHistory = { { time = currentTime, count = 1 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }} },
                            
                                foundUnhelpful = { 
                                    count = 0,
                                    countHistory = { { time = currentTime, count = 0 } },
                                    users = {[user] = { username = username, voted = true, time = currentTime }}}
                                
            },
            replies = {}
        })

        local points = 100
         -- Ensure arsPoints[user] is initialized
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        -- Update points
        arsPoints[user].points = arsPoints[user].points + points
        -- Safely access points
        local currentPoints = arsPoints[user].points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Rating.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        local AppOwner = Apps[appId].Owner
        local AppPoints = 200
         -- Ensure arsPoints[user] is initialized
        arsPoints[AppOwner] = arsPoints[AppOwner] or { user =AppOwner, points = 0 }
        -- Update points
        arsPoints[AppOwner].points = arsPoints[AppOwner].points + AppPoints
        -- Safely access points
        local OwnerCurrentPoints = arsPoints[AppOwner].points
        local OwnerAmount  = 30
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local OtransactionId = generateTransactionId()
        table.insert(transactions, {
            user = AppOwner,
            transactionid = OtransactionId,
            type = "Review Reward.",
            amount = OwnerAmount,
            points = OwnerCurrentPoints,
            timestamp = currentTime
        })

         local ratingTable = ratingsTable[appId]

          -- Prevent duplicate ratings
        if ratingTable.users[user] and ratingTable.users[user].voted then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Add review and update ratings
        ratingTable.users[user] = { voted = true, time = currentTime }
        ratingTable.count = ratingTable.count + 1
        ratingTable.Totalratings = ratingTable.Totalratings + rating
        table.insert(ratingTable.countHistory, { time = currentTime, count = ratingTable.count })

        ao.send({ Target = m.From, Data = "Review added successfully." })
    end
)




-- Add Helpful Rating Handler
Handlers.add(
    "UnhelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "UnhelpfulRatingApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

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

        -- Get the app data for helpful and unhelpful ratings
        local appHData = helpfulRatingsTable[AppId]
        local appUhData = unHelpfulRatingsTable[AppId]

        -- Check if the user has already marked the rating as unhelpful
        if appUhData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as helpful
        if appHData.users[user] then
            -- Remove the user from the helpful users table
            appHData.users[user] = nil
            -- Decrement the helpful count
            appHData.count = appHData.count - 1

            -- Log the count change in helpful count history
            table.insert(appHData.countHistory, { time = currentTime, count = appHData.count })

            -- Deduct points for switching ratings
            local points = -200
              -- Get or initialize the user's points data
            local userPointsData = getOrInitializeUserPoints(user)
            -- Deduct points
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Rated Helpful.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the unhelpful users table
        appUhData.users[user] = { voted = true, time = currentTime }
        -- Increment the unhelpful count
        appUhData.count = appUhData.count + 1
        -- Log the count change in unhelpful count history
        table.insert(appUhData.countHistory, { time = currentTime, count = appUhData.count })

        -- Deduct points for marking an app as unhelpful
        local points = 100
        -- Ensure arsPoints[user] is initialized
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        -- Update points
        arsPoints[user].points = arsPoints[user].points + points
        -- Safely access points
        local currentPoints = arsPoints[user].points
        local amount = 3 -- Deduction of tokens for unhelpful rating
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "UnHelpful Rating.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging
        print("Unhelpful vote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully marked this app as unhelpful." })
    end
)


Handlers.add(
    "HelpfulRatingApp",
    Handlers.utils.hasMatchingTag("Action", "HelpfulRatingApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

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

         -- Get the app data for helpful and unhelpful ratings
        local appHData = helpfulRatingsTable[AppId]
        local appUhData = unHelpfulRatingsTable[AppId]

        -- Check if the user has already marked the rating as helpful
        if appHData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as unhelpful
        if appUhData.users[user] then
            -- Remove the user from the unhelpful users table
            appUhData.users[user] = nil
            -- Decrement the unhelpful count
            appUhData.count = appUhData.count - 1

            -- Log the count change in unhelpful count history
            table.insert(appUhData.countHistory, { time = currentTime, count = appUhData.count })

            -- Deduct points for switching ratings
            local points = -200
            -- Get or initialize the user's points data
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Rated Unhelpful.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the helpful users table
        appHData.users[user] = { voted = true, time = currentTime }
        -- Increment the helpful count
        appHData.count = appHData.count + 1
        -- Log the count change in helpful count history
        table.insert(appHData.countHistory, { time = currentTime, count = appHData.count })

        -- Reward points for marking an app as helpful
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 5 -- Reward tokens for helpful rating
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Rating.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging
        print("Helpful vote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully marked this app as helpful." })
    end
)


Handlers.add(
    "UpvoteApp",
    Handlers.utils.hasMatchingTag("Action", "UpvoteApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

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

        -- Get the app data for upvotes and downvotes
        local appUpData = upvotesTable[AppId]
        local appDownData = downvotesTable[AppId]

        -- Check if the user has already Upvoted the project
        if appUpData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as downvoted
        if appDownData.users[user] then
            -- Remove the user from the downvotes table
            appDownData.users[user] = nil
            -- Decrement the downvote count
            appDownData.count = appDownData.count - 1

            -- Log the count change in downvote count history
            table.insert(appDownData.countHistory, { time = currentTime, count = appDownData.count })

            -- Deduct points for switching ratings
            local points = -200
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Downvoted.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the upvotes table
        appUpData.users[user] = { voted = true, time = currentTime }
        -- Increment the upvote count
        appUpData.count = appUpData.count + 1
        -- Log the count change in upvote count history
        table.insert(appUpData.countHistory, { time = currentTime, count = appUpData.count })

        -- Reward points for upvoting
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 5 -- Reward tokens for upvoting
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Upvote.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging
        print("Upvote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully upvoted this app." })
    end
)

Handlers.add(
    "DownvoteApp",
    Handlers.utils.hasMatchingTag("Action", "DownvoteApp"),
    function(m)

        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

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

       

        -- Get the app data for upvotes and downvotes
        local appUpData = upvotesTable[AppId]
        local appDownData = downvotesTable[AppId]

        -- Check if the user has already downvoted the App.
        if appDownData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this rating as helpful." })
            return
        end

        -- Check if the user has previously marked the app as upvoted
        if appUpData.users[user] then
            -- Remove the user from the upvotes table
            appUpData.users[user] = nil
            -- Decrement the upvote count
            appUpData.count = appUpData.count - 1

            -- Log the count change in upvote count history
            table.insert(appUpData.countHistory, { time = currentTime, count = appUpData.count })

            -- Deduct points for switching ratings
            local points = -200
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local currentPoints = userPointsData.points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Previously Upvoted.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })
        end

        -- Add the user to the downvotes table
        appDownData.users[user] = { voted = true, time = currentTime }
        -- Increment the downvote count
        appDownData.count = appDownData.count + 1
        -- Log the count change in downvote count history
        table.insert(appDownData.countHistory, { time = currentTime, count = appDownData.count })

        -- Deduct points for downvoting
        local points = 100
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local currentPoints = userPointsData.points
        local amount = 3 -- Deduction of tokens for downvoting
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Downvote.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })

        -- Debugging
        print("Downvote added successfully!")
        ao.send({ Target = m.From, Data = "You have successfully downvoted this app." })
    end
)

Handlers.add(
    "FetchArsPoints",
    Handlers.utils.hasMatchingTag("Action", "FetchArsPoints"),
    function(m)

        local userId = m.From

        -- Fetch the user's arsPoints from the table
        local userPointsData = arsPoints[userId]

        if userPointsData then
            -- User exists, send back their arsPoints
            ao.send({
                Target = m.From,
                Data = string.format(" ArsPoints: %d", userPointsData.points)
            })
        else
            -- User not found in arsPoints
            print("Error: User not found in arsPoints.")
            ao.send({
                Target = m.From,
                Data = "Error: User not found in arsPoints."
            })
        end
    end
)



Handlers.add(
    "AddAppToFavorites",
    Handlers.utils.hasMatchingTag("Action", "AddAppToFavorites"),
    function(m)
        -- Check if all required m.Tags are present
        local requiredTags = { "AppId" }

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

        -- Ensure the app exists in the favorites table
        favoritesTable[AppId] = favoritesTable[AppId] or { users = {}, count = 0, countHistory = {} }
        local appFav = favoritesTable[AppId]

        -- Check if the user has already added this app to favorites
        if appFav.users[user] then
            local points = -30
            -- Deduct points for unnecessary action
            arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
            arsPoints[user].points = arsPoints[user].points + points
            local currentPoints = arsPoints[user].points

            -- Log the penalty transaction
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Already Added to Favorites.",
                amount = 0,
                points = currentPoints,
                timestamp = currentTime
            })

            ao.send({ Target = m.From, Data = "You have already added this app to your favorites. Points deducted for unnecessary action." })
            return
        end

        -- Add the user to the favorites table
        appFav.users[user] = { voted = true, time = currentTime }
        appFav.count = appFav.count + 1

        -- Log the count change in favorites history
        table.insert(appFav.countHistory, { time = currentTime, count = appFav.count })

        -- Reward points and tokens for a first-time addition
        local points = 70
        arsPoints[user] = arsPoints[user] or { user = user, points = 0 }
        arsPoints[user].points = arsPoints[user].points + points
        local currentPoints = arsPoints[user].points
        local amount = 5

        -- Send reward tokens
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })

        -- Log the reward transaction
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Added to Favorites.",
            amount = amount,
            points = currentPoints,
            timestamp = currentTime
        })
        -- Debugging and confirmation message
        print("App added to favorites successfully!")
        ao.send({ Target = m.From, Data = "You have successfully added this app to your favorites and earned rewards." })
    end
)




Handlers.add(
    "AddReviewReply",
    Handlers.utils.hasMatchingTag("Action", "AddReviewReply"),
    function(m)
        -- Check required tags
        local requiredTags = { "AppId", "ReviewId", "username", "comment", "profileUrl" }
        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local username = m.Tags.username
        local comment = m.Tags.comment
        local profileUrl = m.Tags.profileUrl
        local user = m.From
        local currentTime = getCurrentTime(m)

        -- Check if the user is the app owner
        if not Apps[appId] or Apps[appId].Owner ~= user then
            ao.send({ Target = m.From, Data = "Only the app owner can reply to reviews." })
            return
        end

        -- Find the target app and review
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

        -- Check if the user has already replied to this review
        if targetReview.replies then
            for _, reply in ipairs(targetReview.replies) do
                if reply.user == user then
                    ao.send({ Target = m.From, Data = "You have already replied to this review." })
                    return
                end
            end
        else
            targetReview.replies = {} -- Initialize replies table if not present
        end

        -- Generate a unique ID for the reply
        local replyId = generateReplyId()

        -- Add the reply to the target review
        table.insert(targetReview.replies, {
            replyId = replyId,
            user = user,
            profileUrl = profileUrl,
            username = username,
            comment = comment,
            timestamp = currentTime
        })

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
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end


        local helpfulData = review.voters.foundHelpful
       
        local unhelpfulData = review.voters.foundUnhelpful
        
        if helpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as helpful." })
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1
            table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

            local points = -100
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to helpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

        local points = 50
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Review  Rating.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

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
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end

        local unhelpfulData = review.voters.foundUnhelpful
        local helpfulData = review.voters.foundHelpful

        if unhelpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You have already marked this review as unhelpful." })
            return
        end

        if helpfulData.users[user] then
            helpfulData.users[user] = nil
            helpfulData.count = helpfulData.count - 1
            table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

            local points = -50
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to unhelpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        unhelpfulData.users[user] = {username = username, voted = true, time = currentTime }
        unhelpfulData.count = unhelpfulData.count + 1
        table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

        local points = -20
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 0
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Marked Review as Unhelpful.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as unhelpful successfully." })
    end
)


Handlers.add(
    "MarkHelpfulReview",
    Handlers.utils.hasMatchingTag("Action", "MarkHelpfulReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end


        local helpfulData = review.voters.foundHelpful
       
        local unhelpfulData = review.voters.foundUnhelpful
        
        if helpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as helpful." })
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1
            table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

            local points = -100
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to helpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

        local points = 50
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Review  Rating.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as helpful successfully." })
    end
)




Handlers.add(
    "MarkUpvoteReview",
    Handlers.utils.hasMatchingTag("Action", "MarkUpvoteReview"),
    function(m)
        local appId = m.Tags.AppId
        local reviewId = m.Tags.ReviewId
        local user = m.From
        local currentTime = getCurrentTime(m) -- Ensure you have a function to get the current timestamp
        local username = m.Tags.username

        if not appId or not reviewId then
            ao.send({ Target = m.From, Data = "AppId and ReviewId are required." })
            return
        end

        if not reviewsTable[appId] then
            ao.send({ Target = m.From, Data = "App not found." })
            return
        end

        local review
        for _, r in ipairs(reviewsTable[appId].reviews) do
            if r.reviewId == reviewId then
                review = r
                break
            end
        end

        if not review then
            ao.send({ Target = m.From, Data = "Review not found." })
            return
        end


        local helpfulData = review.voters.upvoted
       
        local unhelpfulData = review.voters.downvoted
        
        if helpfulData.users[user] then
            ao.send({ Target = m.From, Data = "You already marked this review as helpful." })
            return
        end

        if unhelpfulData.users[user] then
            unhelpfulData.users[user] = nil
            unhelpfulData.count = unhelpfulData.count - 1
            table.insert(unhelpfulData.countHistory, { time = currentTime, count = unhelpfulData.count })

            local points = -100
            local userPointsData = getOrInitializeUserPoints(user)
            userPointsData.points = userPointsData.points + points
            local transactionId = generateTransactionId()
            table.insert(transactions, {
                user = user,
                transactionid = transactionId,
                type = "Switched rating to helpful.",
                amount = 0,
                points = userPointsData.points,
                timestamp = currentTime
            })
        end

        helpfulData.users[user] = {username = username, voted = true, time = currentTime }
        helpfulData.count = helpfulData.count + 1
        table.insert(helpfulData.countHistory, { time = currentTime, count = helpfulData.count })

        local points = 50
        local userPointsData = getOrInitializeUserPoints(user)
        userPointsData.points = userPointsData.points + points
        local amount = 5
        ao.send({
            Target = ARS,
            Action = "Transfer",
            Quantity = tostring(amount),
            Recipient = tostring(user)
        })
        local transactionId = generateTransactionId()
        table.insert(transactions, {
            user = user,
            transactionid = transactionId,
            type = "Helpful Review  Rating.",
            amount = amount,
            points = userPointsData.points,
            timestamp = currentTime
        })

        ao.send({ Target = m.From, Data = "Review marked as helpful successfully." })
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

         -- Check if all required m.Tags are present
        local requiredTags = {
        "NewValue", "AppId", "UpdateOption",
        }

        for _, tag in ipairs(requiredTags) do
            if m.Tags[tag] == nil then
                print("Error: " .. tag .. " is nil.")
                ao.send({ Target = m.From, Data = tag .. " is missing or empty." })
                return
            end
        end

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
            OwnerUserName = true,
            AppName = true,
            Description = true,
            Protocol = true,
            WebsiteUrl = true,
            TwitterUrl = true,
            DiscordUrl = true,
            CoverUrl = true ,
            profileUrl = true,
            CompanyName = true,
            AppIconUrl = true,
            BannerUrl1 = true,
            BannerUrl2 = true,
            BannerUrl3 = true,
            BannerUrl4 = true,
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


Handlers.add(
    "DepositConfirmed",
    Handlers.utils.hasMatchingTag("Action", "DepositConfirmed"),
    function(m)
        local userId = m.From
        local appId = m.Tags.AppId
        local tokenId = m.Tags.processId
        local amount = tonumber(m.Tags.Amount)
        
        print("Handler triggered with message:", m)
        print("UserId:", userId, "AppId:", appId, "TokenId:", tokenId, "Amount:", amount)
        
        -- Validate input
        if not appId or not tokenId or not amount then
            ao.send({ Target = m.From, Data = "AppId, processId, or Amount is missing." })
            return
        end

        if not Apps[appId] then
            ao.send({ Target = m.From, Data = "Invalid AppId: " .. tostring(appId) })
            return
        end
        
        local Appname = Apps[appId].AppName or "Unknown"
        local currentTime = getCurrentTime(m)
        local airdropId = generateAirdropId()
        local status = "Pending"

        -- Create a new entry for the deposit
        table.insert(Airdrops[airdropId], {
            userId = userId,
            appId = appId,
            tokenId = tokenId,
            amount = amount,
            timestamp = currentTime,
            appname = Appname,
            airdropId = airdropId,
            status = status
        })
        
        -- Send confirmation back to the sender
        ao.send({ Target = m.From, Data = "Deposit confirmed for AppId: " .. appId .. ", ProcessId: " .. tokenId .. ", Amount: " .. amount })
    end
)



Handlers.add(
    "getAllAirdrops",
    Handlers.utils.hasMatchingTag("Action", "getAllAirdrops"),
    function(m)
        -- Check if the airdrops table exists
        if not Airdrops or next(Airdrops) == nil then
            ao.send({ Target = m.From, Data = "{}" }) -- Send an empty JSON if there are no airdrops
            return
        end
        -- Convert the entire airdrops table to JSON and send it
        ao.send({ Target = m.From, Data = tableToJson(Airdrops) })
    end
)



Handlers.add(
    "getOwnerAirdrops",
    Handlers.utils.hasMatchingTag("Action", "getOwnerAirdrops"),
    function(m)
        local userId = m.From

        -- Check if the airdrops table exists
        if not Airdrops or next(Airdrops) == nil then
            ao.send({ Target = m.From, Data = "{}" }) -- Send an empty JSON if there are no airdrops
            return
        end
        -- Filter airdrops by owner
        local ownerAirdrops = {}
        for id, airdrop in pairs(Airdrops) do
            if airdrop.userId == userId then
                ownerAirdrops[id] = airdrop
            end
        end

        -- Convert the filtered table to JSON and send it
        ao.send({ Target = m.From, Data = tableToJson(ownerAirdrops) })
    end
)

Handlers.add(
    "FetchAirdropData",
    Handlers.utils.hasMatchingTag("Action", "FetchAirdropData"),
    function(m)
        local owner = m.From
        local AirdropId = m.Tags.airdropId

        print("airdropId ".. (AirdropId or "nil") .. " is this")

        -- Validate input
        if not AirdropId then
            ao.send({ Target = m.From, Data = "AirdropId is missing." })
            return
        end

        -- Check if the Airdrop exists
        local airdropFound = nil
        for _, airdrop in ipairs(Airdrops) do
            if airdrop.airdropId == AirdropId then
                airdropFound = airdrop
                break
            end
        end

        if not airdropFound then
            ao.send({ Target = m.From, Data = "No such Airdrop found." })
            return
        end

        -- Validate ownership
        if airdropFound.userId ~= owner then
            ao.send({ Target = m.From, Data = "You are not the owner of this Airdrop." })
            return
        end

        -- Send the Airdrop data back to the user
        ao.send({
            Target = m.From,
            Data = tableToJson(airdropFound)
        })
    end
)

Handlers.add(
    "FinalizeAirdrop",
    Handlers.utils.hasMatchingTag("Action", "FinalizeAirdrop"),
    function(m)
        local airdropId = m.Tags.airdropId
        local airdropsReceivers = m.Tags.airdropsreceivers
        local startTime = m.Tags.startTime
        local endTime = m.Tags.endTime

        print("Finalizing Airdrop with ID: " .. (airdropId or "nil"))

        -- Validate input
        if not airdropId then
            ao.send({ Target = m.From, Data = "AirdropId is missing." })
            return
        end
        if not airdropsReceivers then
            ao.send({ Target = m.From, Data = "AirdropsReceivers is missing." })
            return
        end
        if not startTime then
            ao.send({ Target = m.From, Data = "StartTime is missing." })
            return
        end
        if not endTime then
            ao.send({ Target = m.From, Data = "EndTime is missing." })
            return
        end

        -- Look up the airdrop in the table
        local airdropFound = nil
        for _, airdrop in ipairs(Airdrops) do
            if airdrop.airdropId == airdropId then
                airdropFound = airdrop
                break
            end
        end

        if not airdropFound then
            ao.send({ Target = m.From, Data = "No such Airdrop found with ID: " .. airdropId })
            return
        end

        -- Update the Airdrop with new information
        airdropFound.airdropsReceivers = airdropsReceivers
        airdropFound.startTime = startTime
        airdropFound.endTime = endTime
        airdropFound.status = "Ongoing" -- Update status to Ongoing

        -- Confirm success
        ao.send({
            Target = m.From,
            Data = "Airdrop finalized successfully for ID: " .. airdropId
        })

        -- Log the updated Airdrop (Optional)
        print("Updated Airdrop: " .. tableToJson(airdropFound))
    end
)



















