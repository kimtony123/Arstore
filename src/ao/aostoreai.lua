local json = require("json")
local math = require("math")

currentData = currentData or {}

-- Credentials token
AOS = "e-lOufTQJ49ZUX1vPxO-QxjtYXiqM8RQgKovrnJKJ18"


-- Function to fetch data from another process
function fetchAppData(AppId, userId, TableType)
    -- Send a request to the target process to get the AppData
    ao.send({
        Target = AOS, -- Target process name
        Tags = {
            {name = "Action", value = "getOpenTrades"},
            {name = "AppId", value = AppId},
            {name = "userId", value = userId},
            {name = "TableType", value = TableType}
            
        }
    })
end



Handlers.add(
    "getTableData",
    Handlers.utils.hasMatchingTag("Action", "getTableData"),
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

        -- Save the fetched data into currentData
        for _, trade in pairs(xData) do
            table.insert(currentData, trade)
        end
        print("Updated currentData:", json.encode(currentData))
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