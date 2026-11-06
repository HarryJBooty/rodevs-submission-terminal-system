local TerminalModule = {}

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")

local scoresFolder = game.Workspace:WaitForChild("TerminalValues")
local scoringActive = false 
local onGoingRaid = false 
local zoneListener = nil 
local maxPhases = 2 

local startRaidEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("StartRaid")
local forceEndEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("EndRaid")
local currentPhase = scoresFolder:WaitForChild("Phase")

local groupID = 16389801
local minRank = 100

local terminals = {
    phase1 = {
        phaseID = 1, 
        zone = workspace:WaitForChild("Phase1TerminalZone"),
        visualizer = workspace:WaitForChild("Phase1TerminalVisual"),
        defendersCount = 0,
        hostilesCount = 0,
        goalPoints = 10,
        owner = workspace:WaitForChild("Phase1TerminalZone"):WaitForChild("Owner"),
        playersInZone = {}
    },
    phase2 = {
        phaseID = 2, 
        zone = workspace:WaitForChild("Phase2TerminalZone"),
        visualizer = workspace:WaitForChild("Phase2TerminalVisual"),
        defendersCount = 0,
        hostilesCount = 0,
        goalPoints = 10,
        owner = workspace:WaitForChild("Phase2TerminalZone"):WaitForChild("Owner"),
        playersInZone = {}
    },
} 

local function raidCleanup(result) 
    scoringActive = false
    onGoingRaid = false
    if result == "Dwin" then 
        currentPhase.Value = 888
    elseif result == "Hwin" then
        currentPhase.Value = 999
    else 
        currentPhase.Value = 0
    end
    scoresFolder.HostilesScore.Value = 0
    scoresFolder.MaxScore.Value = 0

    if zoneListener then
        zoneListener:Disconnect()
        zoneListener = nil
    end

    for _, terminal in pairs(terminals) do
        terminal.visualizer.Transparency = 0.5
        terminal.visualizer.Color = Color3.new(1, 1, 1)
        terminal.owner.Value = "Neutral"
        terminal.defendersCount = 0
        terminal.hostilesCount = 0
        terminal.playersInZone = {}
    end
end

local function scoreRoutine() 
    if scoringActive then 
        return
    end 

    scoringActive = true
    task.spawn(function()
        while scoringActive do
            if scoresFolder.HostilesScore.Value >= scoresFolder.MaxScore.Value and currentPhase.Value <= maxPhases then 
                    for _, terminal in pairs(terminals) do 
                        if terminal.phaseID == currentPhase.Value then 
                            terminal.visualizer.Transparency = 1 
                            terminal.owner.Value = "Neutral"           
                        end 
                    end 
                    currentPhase.Value += 1
                    print("Phase advanced to ", currentPhase.Value)
            end
            task.wait(1)  
            
            for _, terminal in pairs(terminals) do
                if terminal.owner.Value == "Defenders" and scoresFolder.HostilesScore.Value > 0 then
                    scoresFolder.HostilesScore.Value -= 1
                elseif terminal.owner.Value == "Hostiles" then
                    scoresFolder.HostilesScore.Value += 1
                end
            end
        end
    end)
end

local function checkOwner(terminal) -- see who has the most people in term 
    if terminal.defendersCount > terminal.hostilesCount then 
        terminal.owner.Value = "Defenders"
        terminal.visualizer.Color = Color3.new(0, 0, 1)
        print("defenders have term")
    elseif terminal.hostilesCount > terminal.defendersCount then 
        terminal.owner.Value = "Hostiles"
        terminal.visualizer.Color = Color3.new(1, 0, 0)
        print("hostiles have term")
    else
        terminal.owner.Value = "Neutral"
        terminal.visualizer.Color = Color3.new(1, 1, 1)
        print("no one has term")
    end
end

local function isPlayerInZone(character, zone) -- this function checks if the player is in the current term 
    if not character then 
        return false
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local localPos = zone.CFrame:PointToObjectSpace(humanoidRootPart.Position)
        local half = zone.Size * 0.5
        
        local inside =
            math.abs(localPos.X) <= half.X and
            math.abs(localPos.Y) <= half.Y and
            math.abs(localPos.Z) <= half.Z

        if inside then
            return true
        end
    end
    
    return false
end
    

local function startGame()

    zoneListener = runService.Heartbeat:Connect(function() -- player in zone listener
        for _, terminal in pairs(terminals) do
            if terminal.phaseID == currentPhase.Value then
                for _, player in pairs(playerService:GetPlayers()) do
                    local character = player.Character
                    local wasInZone = terminal.playersInZone[player] ~= nil
                    local isInZone = isPlayerInZone(character, terminal.zone)

                    if isInZone and not wasInZone then
                        terminal.playersInZone[player] = true
                        if player.Team then
                            if player.Team.Name == "Defenders" then
                                terminal.defendersCount = terminal.defendersCount + 1
                            elseif player.Team.Name == "Hostiles" then
                                terminal.hostilesCount = terminal.hostilesCount + 1
                            end
                        end

                        checkOwner(terminal)

                    elseif not isInZone and wasInZone then
                        terminal.playersInZone[player] = nil
                        if player.Team then
                            if player.Team.Name == "Defenders" then
                                terminal.defendersCount = terminal.defendersCount - 1
                            elseif player.Team.Name == "Hostiles" then
                                terminal.hostilesCount = terminal.hostilesCount - 1
                            end
                        end

                        checkOwner(terminal)
                    end

                end
            end
        end
    end)
end

currentPhase.Changed:Connect(function()

    for _, terminal in pairs(terminals) do 
        if terminal.phaseID == currentPhase.Value then 
            terminal.visualizer.Transparency = 0 
        elseif terminal.phaseID == 0 then 
            terminal.zone.Transparency = 0.5
            terminal.Color = BrickColor.new("Medium stone grey")
        else
            terminal.visualizer.Transparency = 1
        end
    end

    if currentPhase.Value == 0 then
        print("The game is not yet active")
        return 
    elseif currentPhase.Value == 1 then
        scoresFolder.MaxScore.Value = terminals.phase1.goalPoints
        scoresFolder.HostilesScore.Value = 0
        startGame()
        scoreRoutine()
    elseif currentPhase.Value == 2 then
        scoresFolder.MaxScore.Value = terminals.phase2.goalPoints
        scoresFolder.HostilesScore.Value = 0 
    elseif currentPhase.Value == maxPhases + 1 then
        raidCleanup("Hwin")
        print("Hostiles win the raid!")
    else
        print("All phases complete")
        scoringActive = false
        return 
    end
end)


startRaidEvent.OnServerEvent:Connect(function(player) 
    if onGoingRaid then 
        return
    end 

    local playerRank = player:GetRankInGroup(groupID)
    if playerRank < minRank then
        print("Player does not have the rank to start the raid.")
        return
    end 

    raidCleanup("NoResult")
    onGoingRaid = true
    currentPhase.Value = 1
end)

forceEndEvent.OnServerEvent:Connect(function(player)

    local playerRank = player:GetRankInGroup(groupID)
    if playerRank < minRank then
        print("Player does not have the rank to end the raid.")
        return
    end 

    if not onGoingRaid then
        return
    end

    raidCleanup("Dwin")
end) 

return TerminalModule
