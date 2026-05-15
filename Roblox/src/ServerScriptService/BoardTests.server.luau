local ServerScriptService = game:GetService("ServerScriptService")
local slotWinnings = require(ServerScriptService:WaitForChild("SlotWinningsModule"))
local slotmachine = require(ServerScriptService:WaitForChild("SlotMachineModule"))

local function testBoardOfSameSymbols()
	-- setup
    local bet = 1
    local board1 = {}

    for i = 1, 3 do
        board1[i] = {}

        for j = 1, 5 do
            board1[i][j] = 1
        end
    end

    -- act
    local winningAmount = slotWinnings.SlotMachineLogic.CalculateWinnings(board1, bet)

    -- assert
    -- full board should give 22x bet
	assert(winningAmount == bet * 22)
end

local function testGeneratedBoard()
    -- setup
    local board = slotmachine.generateBoard()
    local bet = 1

    print (board)
    -- act
    local winningAmount = slotWinnings.SlotMachineLogic.CalculateWinnings(board, bet)
    -- assert
    -- Needs manual review since the board is random each time
    print(winningAmount)

end

testBoardOfSameSymbols()
testGeneratedBoard()
print("Test passed")