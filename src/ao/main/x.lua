

Handlers.add(
  "AddProjectZ",
  Handlers.utils.hasMatchingTag("Action", "AddProjectZ"),
  function(m)
      local currentTime = getCurrentTime(m)
      local AppId = generateAppId()
      local user = m.From
      local appName = "aostore testX"
      local description = "This is a test App"

      -- Reset DataCount for this transaction
        DataCount = 0
      
           -- Call the add functions
      AddReviewTable(AppId, user, nil)
      AddHelpfulTable(AppId, user)   

      -- Set the finalize callback to be called when DataCount reaches 2
      globalFinalizeProjectCallback = function()
        finalizeProject(user, AppId, appName, description, currentTime)
          
        end
  end
)

Handlers.add(
    "AddHelpfulRating",
    Handlers.utils.hasMatchingTag("Action", "AddHelpfulRating"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      AddHelpfulTable(AppId, user, nil)
    end
)

Handlers.add(
    "AddUnHelpfulRating",
    Handlers.utils.hasMatchingTag("Action", "AddUnHelpfulRating"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      --AddUnHelpfulTable(AppId, user, nil)
    end
)

Handlers.add(
    "AddAidropTable",
    Handlers.utils.hasMatchingTag("Action", "AddAidropTable"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      local AppName = "aostore"
      AddAirdropTable(AppId, user,AppName,  nil)
    end
)

Handlers.add(
    "AddFlagTableX",
    Handlers.utils.hasMatchingTag("Action", "AddFlagTableX"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      AddFlagTable(AppId, user, nil)
    end
)


Handlers.add(
    "AddBugReportX",
    Handlers.utils.hasMatchingTag("Action", "AddBugReportX"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      local username = m.Tags.username
      local profileUrl = m.Tags.profileUrl
      AddBugReportTable(AppId, user,profileUrl,username,nil)
    end
)

Handlers.add(
    "AddDevTable",
    Handlers.utils.hasMatchingTag("Action", "AddDevTable"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      local username = m.Tags.username
      local profileUrl = m.Tags.profileUrl
      AddDevForumTable(AppId, user,profileUrl,username,nil)
    end
)

Handlers.add(
    "AddFeatureRequestTable",
    Handlers.utils.hasMatchingTag("Action", "AddFeatureRequestTable"),
    function(m)
      local AppId = generateAppId()
      local user = m.From
      local username = m.Tags.username
      local profileUrl = m.Tags.profileUrl
      AddFeatureRequestTable(AppId, user,profileUrl,username,nil)
    end
)
