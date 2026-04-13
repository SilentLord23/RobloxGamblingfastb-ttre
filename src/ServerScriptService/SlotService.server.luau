local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SlotLogic = require(ReplicatedStorage.Modules.SlotMachineLogic)
local physicalButton = Workspace:WaitForChild("PhysicalSpinButton")
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

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

-- Initialize player data when they join
Players.PlayerAdded:Connect(function(player)
	PlayerBalances[player.UserId] = STARTING_BALANCE
	PlayerBets[player.UserId] = DEFAULT_BET
end)

-- Cleanup when they leave
Players.PlayerRemoving:Connect(function(player)
	PlayerBalances[player.UserId] = nil
	PlayerBets[player.UserId] = nil
end)

local function executeSpin(player, betAmount)
	if debounce then return end
	
	local finalBet = betAmount or PlayerBets[player.UserId] or DEFAULT_BET
	local currentBalance = PlayerBalances[player.UserId] or 0

	-- 1. Security Check: Valid bet amount
	if not isValidBet(finalBet) then return nil end

	-- 2. Security Check: Can they afford it?
	if currentBalance < finalBet then
		print(player.Name .. " is too broke to spin!")
		return nil, "Insufficient Funds"
	end

	debounce = true

	-- 3. Subtract the bet immediately
	PlayerBalances[player.UserId] -= finalBet

	physicalButton.Color = Color3.fromRGB(255, 0, 0)
	physicalButton.Position -= Vector3.new(0, 0.2, 0)

	local board, winnings = SlotLogic.ProcessSpin(finalBet)
	
	-- 4. Add winnings back to balance
	PlayerBalances[player.UserId] += winnings
	
	task.wait(3) 

	physicalButton.Color = Color3.fromRGB(255, 255, 255)
	physicalButton.Position += Vector3.new(0, 0.2, 0)
	
	print(player.Name .. " | New Balance: " .. PlayerBalances[player.UserId])
	
	debounce = false
	return board, winnings, PlayerBalances[player.UserId]
end

spinRemote.OnServerInvoke = function(player, action, value)
	if action == "UpdateBet" then
		if isValidBet(value) then
			PlayerBets[player.UserId] = value
			return true
		end
	elseif action == "Spin" then
		return executeSpin(player, value)
	elseif action == "GetBalance" then
		return PlayerBalances[player.UserId] or STARTING_BALANCE
	end
	return nil
end

physicalButton.Touched:Connect(function(otherPart)
	local player = Players:GetPlayerFromCharacter(otherPart.Parent)
	if player and not debounce then
		executeSpin(player) 
	end
end)