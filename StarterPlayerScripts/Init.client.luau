local ClientFolder = script.Parent:WaitForChild("Client")

for _, module in ipairs(ClientFolder:GetChildren()) do
	if module:IsA("ModuleScript") then
		local loadedModule = require(module)
		if loadedModule and typeof(loadedModule) == "table" and loadedModule.Init then
			loadedModule.Init()
		end
	end
end
