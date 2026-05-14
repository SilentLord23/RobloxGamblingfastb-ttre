local TweenService = game:GetService("TweenService")

local FadeModule = {}

function FadeModule.fadeIn(frame, duration)
	local tween = TweenService:Create(frame, TweenInfo.new(duration), { BackgroundTransparency = 0 })

	tween:Play()

    return tween
end

function FadeModule.fadeOut(frame, duration)

	local tween = TweenService:Create(
		frame,
		TweenInfo.new(duration),
		{
			BackgroundTransparency = 1
		}
	)
	tween:Play()
	return tween

end

return FadeModule