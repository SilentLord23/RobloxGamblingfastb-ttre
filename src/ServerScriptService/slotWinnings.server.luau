local ServerScriptService = game:GetService("ServerScriptService")
local SlotMachineLogic = {}

-- Winning Line Definitions (Column, Row)
SlotMachineLogic.PayLines = {
    {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}}, -- 1: Top row
    {{1,2}, {2,2}, {3,2}, {4,2}, {5,2}}, -- 2: Middle row
    {{1,3}, {2,3}, {3,3}, {4,3}, {5,3}}, -- 3: Bottom row
    {{1,1}, {2,2}, {3,3}, {4,2}, {5,1}}, -- 4: V-Shape
    {{3,1}, {2,2}, {1,3}, {4,2}, {5,1}}, -- 5: Inverted V-Shape
    {{1,2}, {2,1}, {3,1}, {4,1}, {5,2}}, -- 6: Arch
    {{1,2}, {2,3}, {3,3}, {4,3}, {5,2}}, -- 7: Inverted Arch
    {{1,1}, {2,1}, {3,2}, {4,3}, {5,3}}, -- 8: Diagonal Top-Left to Bottom-Right
    {{1,3}, {2,3}, {3,2}, {4,1}, {5,1}}, -- 9: Diagonal Bottom-Left to Top-Right
    {{1,2}, {2,3}, {3,2}, {4,1}, {5,2}}, -- 10: Zig-Zag down,up
    {{1,2}, {2,1}, {3,2}, {4,3}, {5,2}}  -- 11: Zig-Zag up,down
}

-- Multiplier Paytable
local PAYTABLE = {
    [1] = {[3] = 0.1, [4] = 0.5, [5] = 2.0},
    [2] = {[3] = 0.1, [4] = 0.5, [5] = 2.0},
    [3] = {[3] = 0.1, [4] = 0.5, [5] = 2.0},
    [4] = {[3] = 0.1, [4] = 0.8, [5] = 3.0},
    [5] = {[3] = 0.1, [4] = 0.8, [5] = 3.0},
    [6] = {[3] = 0.6, [4] = 2.0, [5] = 15.0},
    [7] = {[3] = 0.6, [4] = 2.0, [5] = 15.0},
    [8] = {[3] = 0.8, [4] = 8.0, [5] = 40.0},
    [9] = {[3] = 2.0, [4] = 20.0, [5] = 100.0}
}

-- The Math Engine: Checks the board against paylines
function SlotMachineLogic.CalculateWinnings(board, currentBet)
    local totalWinnings = 0
    
    for _, line in ipairs(SlotMachineLogic.PayLines) do
        local firstSymbol = nil
        local matchCount = 0
        
        for i, coord in ipairs(line) do
            local col, row = coord[1], coord[2]
            local symbolAtCoord = board[row][col]
            
            if i == 1 then
                firstSymbol = symbolAtCoord
                matchCount = 1
            elseif symbolAtCoord == firstSymbol then
                matchCount += 1
            else
                break -- Stop checking this line if the sequence is broken
            end
        end
        
        -- Only award winnings for 3 or more symbols in a row
        if matchCount >= 3 then
            local symbolData = PAYTABLE[firstSymbol]
            if symbolData and symbolData[matchCount] then
                totalWinnings += (currentBet * symbolData[matchCount])
            end
        end
    end
    
    return totalWinnings
end

-- This handles the imports and runs the spin
function SlotMachineLogic.ProcessSpin(betAmount)
    -- Import the Generator and the Data
    local slotMachine = require(ServerScriptService:WaitForChild("slotMachine"))
    local symbVal = require(ServerScriptService:WaitForChild("symbVal")) 
    
    -- Generate the board using the symbol list from symbVal
    local board = slotMachine.GenerateBoard(symbVal.symbols)
    
    -- Calculate result
    local winnings = SlotMachineLogic.CalculateWinnings(board, betAmount)
    
    return board, winnings
end

return SlotMachineLogic