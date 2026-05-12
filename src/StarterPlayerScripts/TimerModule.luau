local TimerModule = {}

function TimerModule.startTimer(time)
    print("Timer started!")

    timer = time

	while timer > 0 do
		timer -= 1
		task.wait(1)
	end

    print("Timer finished!")
	JumpscareModule.startJumpscare()
end

return TimerModule