local SlotServiceModule = {}

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SlotLogic = require(ReplicatedStorage.Modules.SlotMachineLogic)
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local physicalSpinBtn = Workspace:WaitForChild("PhysicalSpinButton")
local betButtonsFolder = Workspace:WaitForChild("PhysicalBetButtons")

local debounce = false

local DEFAULT_BET = 10
local STARTING_BALANCE = 1000
local VALID_BETS = {5, 10, 15, 20, 25, 50, 75, 100, 250, 500}

local PlayerBets = {}
local PlayerBalances = {}

function SlotServiceModule.IsValidBet(amount)
	for _, val in ipairs(VALID_BETS) do
		if val == amount then
			return true
		end
	end
	return false
end

function SlotServiceModule.UpdateClientUI(player)
	spinRemote:FireClient(
		player,
		"UpdateDisplay",
		PlayerBalances[player.UserId],
		PlayerBets[player.UserId]
	)
end

function SlotServiceModule.Init()
	Players.PlayerAdded:Connect(function(player)
		PlayerBalances[player.UserId] = STARTING_BALANCE
		PlayerBets[player.UserId] = DEFAULT_BET

		task.wait(1)
		SlotServiceModule.UpdateClientUI(player)
	end)
end

function SlotServiceModule.ExecuteSpin(player)
	if debounce then return end

	local userId = player.UserId
	local bet = PlayerBets[userId] or DEFAULT_BET
	local balance = PlayerBalances[userId] or 0

	if balance < bet then return end

	debounce = true

	PlayerBalances[userId] -= bet
	SlotServiceModule.UpdateClientUI(player)

	physicalSpinBtn.Color = Color3.fromRGB(255, 0, 0)
	physicalSpinBtn.Position -= Vector3.new(0, 0.2, 0)

	local board, winnings = SlotLogic.ProcessSpin(bet)

	task.wait(3)

	PlayerBalances[userId] += winnings

	physicalSpinBtn.Color = Color3.fromRGB(255, 255, 255)
	physicalSpinBtn.Position += Vector3.new(0, 0.2, 0)

	SlotServiceModule.UpdateClientUI(player)

	debounce = false
end

function SlotServiceModule.BindInputs()
	physicalSpinBtn.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			SlotServiceModule.ExecuteSpin(player)
		end
	end)

	for _, button in ipairs(betButtonsFolder:GetChildren()) do
		if button:IsA("BasePart") then
			button.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then return end

				if debounce then return end

				local amount = tonumber(button.Name)
				if not SlotServiceModule.IsValidBet(amount) then return end

				PlayerBets[player.UserId] = amount
				SlotServiceModule.UpdateClientUI(player)

				button.Color = Color3.fromRGB(0, 255, 0)
				task.delay(0.2, function()
					button.Color = Color3.fromRGB(255, 255, 255)
				end)
			end)
		end
	end
end

function SlotServiceModule.BindRemotes()
	spinRemote.OnServerInvoke = function(player, action)
		if action == "GetInit" then
			return PlayerBalances[player.UserId], PlayerBets[player.UserId]
		end
	end
end

return SlotServiceModule