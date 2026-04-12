local SlotMachineLogic = {}

-- Defining the winning lines 
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
