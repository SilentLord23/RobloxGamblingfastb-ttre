local JumpscareModule = require(script.Parent:WaitForChild("JumpscareModule"))

local TimerModule = {}

function TimerModule.startTimer(time, player)
    print("Timer started!")

    local timer = time

	while timer > 0 do
		timer -= 1
		task.wait(1)
	end

    print("Timer finished!")
	JumpscareModule.startJumpscare(player)
end

return TimerModule