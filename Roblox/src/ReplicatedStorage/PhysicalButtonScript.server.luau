local SlotMachine = require(game.ServerScriptService.SlotMachineModule)

script.Parent.ProximityPrompt.Triggered:Connect(function(player)
	SlotMachine.ShowBoard(SlotMachine.GenerateBoard())
	
end)
