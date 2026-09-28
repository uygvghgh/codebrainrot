return function(ctx)
	local speed = 16

	return {
		features = {
			{ type = "section", name = "player" },
			{
				type = "toggle",
				name = "auto collect",
				default = false,
				callback = function(on)
					ctx.notify(on and "auto collect on" or "auto collect off")
				end,
			},
			{
				type = "slider",
				name = "walk speed",
				min = 16,
				max = 120,
				default = 16,
				callback = function(value)
					speed = value
				end,
			},
			{ type = "section", name = "misc" },
			{
				type = "button",
				name = "teleport to base",
				callback = function()
					ctx.notify("teleported at speed " .. speed)
				end,
			},
		},
	}
end
