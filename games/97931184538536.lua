return function(context)
	local players = game:GetService("Players")
	local replicatedStorage = game:GetService("ReplicatedStorage")

	local player = players.LocalPlayer
	local running = false
	local worker

	local function getBrainrots()
		return workspace:FindFirstChild("Brainrots")
			or replicatedStorage:FindFirstChild("Brainrots")
	end

	local function getCharacter()
		return player.Character or player.CharacterAdded:Wait()
	end

	local function moveTo(position)
		local character = getCharacter()
		local root = character:FindFirstChild("HumanoidRootPart")

		if root then
			character:MoveTo(position)
		end
	end

	local function farm()
		if worker then
			return
		end

		worker = task.spawn(function()
			while running do
				local brainrots = getBrainrots()

				if not brainrots then
					task.wait(1)
					continue
				end

				for _, br in ipairs(brainrots:GetChildren()) do
					if not running then
						break
					end

					if br:GetAttribute("FieldName") == "CelestialField"
						or br:GetAttribute("FieldName") == "OGField" then

						if br:GetAttribute("Traits") ~= "VIP" then
							local prompt = br:FindFirstChildOfClass("ProximityPrompt")

							if prompt then
								moveTo(br.Position)
								task.wait(0.1)

								while running and br.Parent == brainrots do
									pcall(function()
										fireproximityprompt(prompt)
									end)

									task.wait(0.1)
								end

								task.wait(0.1)

								while running do
									local character = getCharacter()

									if not character:FindFirstChild("HeldFieldBrainrot") then
										break
									end

									moveTo(Vector3.new(69, 30, 162))
									task.wait(0.1)
								end

								task.wait(0.1)
							end
						end
					end
				end

				task.wait(0.1)
			end

			worker = nil
		end)
	end

	local function setEnabled(enabled)
		running = enabled

		if enabled then
			context.notify("auto farm enabled")
			farm()
		else
			context.notify("auto farm disabled")
		end
	end

	return {
		features = {
			{
				type = "section",
				name = "farming",
			},
			{
				type = "toggle",
				name = "auto farm",
				default = false,
				callback = setEnabled,
			},
		},
	}
end
