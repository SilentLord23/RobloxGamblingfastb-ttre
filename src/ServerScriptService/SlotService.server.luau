local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SlotLogic = require(ReplicatedStorage.Modules.SlotMachineLogic)
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local physicalSpinBtn = Workspace:WaitForChild("PhysicalSpinButton")
local betButtonsFolder = Workspace:WaitForChild("PhysicalBetButtons")

local debounce = false
local DEFAULT_BET = 5
local STARTING_BALANCE = 1000.00
local VALID_BETS = {5, 10, 15, 20, 25, 50, 75, 100, 250, 500}

local PlayerBets = {}
local PlayerBalances = {}

local function isValidBet(amount)
	for _, val in ipairs(VALID_BETS) do
		if val == amount then return true end
	end
	return false
end

local function updateClientUI(player)
	spinRemote:FireClient(player, "UpdateDisplay", PlayerBalances[player.UserId], PlayerBets[player.UserId])
end

Players.PlayerAdded:Connect(function(player)
	PlayerBalances[player.UserId] = STARTING_BALANCE
	PlayerBets[player.UserId] = DEFAULT_BET
	task.wait(1)
	updateClientUI(player)
end)

local function executeSpin(player)
	if debounce then return end
	
	local finalBet = PlayerBets[player.UserId] or DEFAULT_BET
	local currentBalance = PlayerBalances[player.UserId] or 0

	if currentBalance < finalBet then return end

	debounce = true

	PlayerBalances[player.UserId] -= finalBet
	updateClientUI(player)

	physicalSpinBtn.Color = Color3.fromRGB(255, 0, 0)
	physicalSpinBtn.Position -= Vector3.new(0, 0.2, 0)

	local board, winnings = SlotLogic.ProcessSpin(finalBet)
	
	task.wait(3) 

	PlayerBalances[player.UserId] += winnings
	
	physicalSpinBtn.Color = Color3.fromRGB(255, 255, 255)
	physicalSpinBtn.Position += Vector3.new(0, 0.2, 0)
	
	updateClientUI(player)
	debounce = false
end

physicalSpinBtn.Touched:Connect(function(otherPart)
	local player = Players:GetPlayerFromCharacter(otherPart.Parent)
	if player and not debounce then
		executeSpin(player)
	end
end)

for _, button in ipairs(betButtonsFolder:GetChildren()) do
	if button:IsA("BasePart") then
		button.Touched:Connect(function(otherPart)
			if debounce then return end
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if player then
				local amt = tonumber(button.Name)
				if isValidBet(amt) then
					PlayerBets[player.UserId] = amt
					updateClientUI(player)
					
					button.Color = Color3.fromRGB(0, 255, 0)
					task.delay(0.2, function() button.Color = Color3.fromRGB(255, 255, 255) end)
				end
			end
		end)
	end
end

spinRemote.OnServerInvoke = function(player, action)
	if action == "GetInit" then
		return PlayerBalances[player.UserId], PlayerBets[player.UserId]
	end
end