local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SlotLogic = require(ReplicatedStorage.Modules.SlotMachineLogic)
local physicalButton = Workspace:WaitForChild("PhysicalSpinButton")
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local debounce = false
local DEFAULT_BET = 10
local VALID_BETS = {5, 10, 15, 20, 25, 50, 75, 100, 250, 500}

-- Stores the currently selected bet for each player
local PlayerBets = {}

local function isValidBet(amount)
	for _, val in ipairs(VALID_BETS) do
		if val == amount then return true end
	end
	return false
end

local function executeSpin(player, betAmount)
	if debounce then return end
	
	-- Use the provided betAmount, or fallback to the player's last selection, or the default
	local finalBet = betAmount or PlayerBets[player.UserId] or DEFAULT_BET

	if not isValidBet(finalBet) then 
		warn(player.Name .. " attempted an invalid bet: " .. tostring(finalBet))
		return nil 
	end

	debounce = true

	physicalButton.Color = Color3.fromRGB(255, 0, 0)
	physicalButton.Position -= Vector3.new(0, 0.2, 0)

	local board, winnings = SlotLogic.ProcessSpin(finalBet)
	
	task.wait(3) 

	physicalButton.Color = Color3.fromRGB(255, 255, 255)
	physicalButton.Position += Vector3.new(0, 0.2, 0)
	
	debounce = false
	return board, winnings
end

-- Update the player's selected bet when they click a button
spinRemote.OnServerInvoke = function(player, action, value)
	if action == "UpdateBet" then
		if isValidBet(value) then
			PlayerBets[player.UserId] = value
			return true
		end
	elseif action == "Spin" then
		return executeSpin(player, value)
	end
	return nil
end

physicalButton.Touched:Connect(function(otherPart)
	local character = otherPart.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	
	if player and not debounce then
		-- Jumper uses their previously selected bet
		executeSpin(player) 
	end
end)