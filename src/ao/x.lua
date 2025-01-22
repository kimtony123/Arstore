

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




local userContent = "Elon Musk"

local prompt = CreatePrompt(
  "Tell a joke on the given topic",
  userContent
);

JOKE_HISTORY = JOKE_HISTORY or {}

Llama.run(
  prompt,                  -- Your prompt
  2,                      -- Number of tokens to generate
  function(generated_text) -- Optional: A function to handle the response
    -- Match up until the first newline character
    local joke = generated_text:match("^(.-)\n")
  
    print("Joke: " .. joke)
    table.insert(JOKE_HISTORY, joke)
  end
)





Handlers.add(
    "getOpenTrades",
    Handlers.utils.hasMatchingTag("Action", "getOpenTrades"),
    function(m)
        local userId = m.Tags.userId
        local AppId = m.Tags.AppId
        local TableType = m.Tags.TableType

        if not AppId then
            ao.send({ Target = m.From, Data = "AppId is required." })
            return
        end
        
        print("UserId" .. userId .. "is this")
        print("appID" .. AppId .. "is this")
        print("TableType".. TableType .. "is this" )

        if not userId then
            ao.send({Target = m.From, Data = "UserId is required."})
            return
        end

        if not TableType then
            ao.send({Target = m.From, Data = "DataType is required."})
            return
        end

        -- Placeholder for the actual data source
        local reviewsTable = {
            -- Example data structure
            ["1"] = {id = 1, AppId = AppId, userId = userId, TableType = TableType},
            ["2"] = {id = 2, AppId = AppId, userId = userId, TableType = TableType}
        }

        ao.send({
            Target = m.From, -- Reply to the sender
            Action = "openTradesResponse",
            Data = json.encode(reviewsTable)
        })
    end
)