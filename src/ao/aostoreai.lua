local json = require("json")
local math = require("math")




-- Load the Llama Herder library
Llama = require("@sam/Llama-Herder")


function CreatePrompt(systemPrompt, userContent)
    return [[<|system|>
]] .. systemPrompt .. [[<|end|>
<|user|>
]] .. userContent .. [[<|end|>
<|assistant|>
]]
end

currentData = currentData or {}

-- Credentials token
AOS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"


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

-- Function to fetch data from another process
function fetchAppData(AppId, userId, TableType)
    -- Send a request to the target process to get the AppData
    ao.send({
        Target = AOS, -- Target process name
        Tags = {
            {name = "Action", value = "FetchAppComments"},
            {name = "AppId", value = AppId},
            {name = "userId", value = userId},
            {name = "TableType", value = TableType}
            
        }
    })
end





Handlers.add(
    "FetchAppComments",
    Handlers.utils.hasMatchingTag("Action", "FetchAppComments"),
    function(m)
        local userId = m.From -- Get the sender's ID
        local AppId = m.Tags.AppId
        local TableType = m.Tags.TableType

        if not AppId then
            ao.send({Target = m.From, Data = "AppId is missing."})
            return
        end

        if not TableType then
            ao.send({Target = m.From, Data = "TableType is missing."})
            return
        end
        fetchAppData(AppId, userId, TableType)
    end
)

Handlers.add(
    "openTradesResponse",
    Handlers.utils.hasMatchingTag("Action", "openTradesResponse"),
    function(m)
        local xData = json.decode(m.Data)

        if not xData then
            print("No data received in response.")
            return
        end
        
        table.insert(currentData, xData)

        local userId = xData.ownerId
    
        ao.send({ Target = userId, Data = "Thanks" })

        print("Updated currentData:", json.encode(currentData))

    end
)

Handlers.add(
    "UseAI",
    Handlers.utils.hasMatchingTag("Action", "UseAI"),
    function(m)
        local userId = m.From -- Get the sender's ID

        
        currentData = currentData or {}

        -- Use the existing currentData table
        if not currentData or not currentData.comments or not currentData.ownerId then
            ao.send({ Target = userId, Data = "Invalid or missing data in currentData." })
            return
        end

        -- Validate ownerId matches userId
        if currentData.ownerId ~= userId then
            ao.send({ Target = userId, Data = "Unauthorized access." })
            return
        end

        local comments = currentData.comments
        FinalAnalysis = FinalAnalysis or {}

        -- Function to classify comments as positive or negative
        local function classifyComment(comment, callback)
            local prompt = CreatePrompt("Classify the sentiment of this comment as 1 for positive and 2 for negative: ", comment)
            Llama.run(prompt, 10, function(generated_text)
                local sentiment = tonumber(generated_text) or 0 -- Expect 1 or 2
                callback(sentiment)
            end)
        end

        -- Process each comment
        for _, comment in ipairs(comments) do
            classifyComment(comment, function(sentiment)
                if sentiment == 1 or sentiment == 2 then
                    table.insert(FinalAnalysis, { comment = comment, sentiment = sentiment })
                else
                    print("Invalid sentiment response for comment:", comment)
                end
            end)
        end

        -- Clear comments and ownerId after processing
        currentData.comments = nil
        currentData.ownerId = nil

        -- Send processed data back to the user
        ao.send({ Target = userId, Data = tableToJson(FinalAnalysis) })
        print("Final analysis:", tableToJson(FinalAnalysis))
    end
)


-- Handler to clear currentData
Handlers.add(
    "clearCurrentData",
    Handlers.utils.hasMatchingTag("Action", "clearCurrentData"),
    function(m)
        -- Check if currentData exists
        if currentData then
            -- Clear all entries in the table
            for k in pairs(currentData) do
                currentData[k] = nil
            end
            print("currentData has been cleared.")
            ao.send({ Target = m.From, Data = "currentData has been cleared successfully." })
        else
            print("currentData is not initialized.")
            ao.send({ Target = m.From, Data = "currentData is not initialized." })
        end
    end
)