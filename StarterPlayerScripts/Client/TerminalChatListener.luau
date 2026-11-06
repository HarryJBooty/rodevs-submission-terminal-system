local TerminalChatModule = {}

local TextChatService = game:GetService("TextChatService")
local playerService = game:GetService("Players")

local raidEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("StartRaid")
local forceEndEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("EndRaid")

TextChatService.MessageReceived:Connect(function(message)
    local text = message.Text:lower()
    local source = message.TextSource

    if not source then 
        return
    end 

    local player = playerService:GetPlayerByUserId(source.UserId)

    if not player then 
        print("hb debug: no player")
        return 
    end 

    if text == "!startraid" then
        raidEvent:FireServer()
    end
end) 

TextChatService.MessageReceived:Connect(function(message)
    local text = message.Text:lower()
    local source = message.TextSource

    if not source then 
        return
    end 

    local player = playerService:GetPlayerByUserId(source.UserId)

    if not player then 
        print("hb debug: no player")
        return 
    end 

    if text == "!endraid" then
        forceEndEvent:FireServer()
    end
end) 

return TerminalChatModule
