local TerminalClientModule = {}

local playerService = game:GetService("Players")
local terminalUI = playerService.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TerminalGUI")
local mainContainer = terminalUI:WaitForChild("MainContainer")
local winScreen = terminalUI:WaitForChild("WinFrame")
local scoresFolder = game.Workspace:WaitForChild("TerminalValues")
local hostilesScores = scoresFolder:WaitForChild("HostilesScore")
local maxScores = scoresFolder:WaitForChild("MaxScore")
local phaseValue = scoresFolder:WaitForChild("Phase")

local HOSTILES_WIN_CODE = 999 
local DEFENDERS_WIN_CODE = 888

local terminals = {
    phase1 = {
        value = 1,
        owner = game.Workspace:WaitForChild("Phase1TerminalZone"):WaitForChild("Owner"),
    },
    phase2 = {
        value = 2,
        owner = game.Workspace:WaitForChild("Phase2TerminalZone"):WaitForChild("Owner"),
    }
}

local function generateWinCode()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local codelength = 12 

    local code = ""
    for i = 1, codelength do
        local index = math.random(1, #charset)
        code = code .. charset:sub(index, index)
    end

    return code 
end 

phaseValue.Changed:Connect(function()
    if phaseValue.Value == terminals.phase1.value then
        mainContainer.Phase.Text = "Phase 1"
    elseif phaseValue.Value == terminals.phase2.value then
        mainContainer.Phase.Text = "Phase 2"
    elseif phaseValue.Value == DEFENDERS_WIN_CODE then
        local winCode = generateWinCode()
        winScreen.Visible = true
        mainContainer.Visible = false
        winScreen.RandomCodeLabel.Text = winCode
        winScreen.TeamNameLabel.Text = "DEFENDERS WIN"
        task.wait(10)
        winScreen.Visible = false
        mainContainer.Phase.Text = "Raid Inactive"
        mainContainer.Visible = true
    elseif phaseValue.Value == HOSTILES_WIN_CODE then
        local winCode = generateWinCode()
        winScreen.Visible = true
        mainContainer.Visible = false
        winScreen.RandomCodeLabel.Text = winCode
        winScreen.TeamNameLabel.Text = "HOSTILES WIN"
        task.wait(10)
        winScreen.Visible = false
        mainContainer.Phase.Text = "Raid Inactive"
        mainContainer.Visible = true
    else
        mainContainer.Phase.Text = "Raid Inactive"
    end
end)

hostilesScores.Changed:Connect(function()
    mainContainer.ProgressBarContainer.ProgressBarFill.Size = UDim2.new(hostilesScores.Value / maxScores.Value, 0, 1, 0)
end)

for _, terminal in pairs(terminals) do
    terminal.owner.Changed:Connect(function()
        if terminal.owner.Value == "Defenders" then 
            mainContainer.OwnerLabel.Text = "Owned by: Defenders"
        elseif terminal.owner.Value == "Hostiles" then
            mainContainer.OwnerLabel.Text = "Owned by: Hostiles"
        else 
            mainContainer.OwnerLabel.Text = "Owned by: Neutral"
        end 
    end)
end

return TerminalClientModule
