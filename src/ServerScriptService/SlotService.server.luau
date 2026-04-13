local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Import your modules
local SlotLogic = require(ReplicatedStorage.Modules.SlotMachineLogic)
local physicalButton = Workspace:WaitForChild("PhysicalSpinButton")

-- Create a RemoteFunction in ReplicatedStorage named "SpinRequest"
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local debounce = false

-- The master function that actually runs a spin
local function executeSpin(player, betAmount)
    if debounce then return end
    debounce = true

    -- 1. Physical Button Animation (Server-side so everyone sees it)
    physicalButton.Color = Color3.fromRGB(255, 0, 0)
    physicalButton.Position -= Vector3.new(0, 0.2, 0)

    -- 2. Generate and Calculate (Using your logic chain)
    local board, winnings = SlotLogic.ProcessSpin(betAmount)
    
    -- 3. Wait for "Spinning" time (simulates the reels)
    task.wait(3) 

    -- 4. Reset Button
    physicalButton.Color = Color3.fromRGB(255, 255, 255)
    physicalButton.Position += Vector3.new(0, 0.2, 0)
    
    debounce = false
    return board, winnings
end

-- Trigger from Physical Button
physicalButton.Touched:Connect(function(otherPart)
    local character = otherPart.Parent
    local player = game.Players:GetPlayerFromCharacter(character)
    if player and not debounce then
        executeSpin(player, 10) -- Default bet for jumping
    end
end)

-- Trigger from UI Button (RemoteFunction)
spinRemote.OnServerInvoke = executeSpin