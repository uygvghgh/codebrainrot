return function(context)
	local players = game:GetService("Players")
	local player = players.LocalPlayer

	local running = false
	local worker

	local function getCharacter()
		return player.Character or player.CharacterAdded:Wait()
	end

	local function getBrainrots()
		local locations = {
			workspace,
			game:GetService("ReplicatedStorage"),
			game:GetService("Players")
		}

		for _, location in ipairs(locations) do
			local folder = location:FindFirstChild("Brainrots")

			if folder then
				return folder
			end
		end

		return nil
	end

	local function moveTo(position)
		local character = getCharacter()
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid:MoveTo(position)
			return true
		end

		return false
	end

	local function farm()
		if worker then
			return
		end

		worker = task.spawn(function()
			while running do
				local brainrots = getBrainrots()

				if not brainrots then
					context.notify("Brainrots folder not found")
					task.wait(2)
					continue
				end

				local found = false

				for _, br in ipairs(brainrots:GetChildren()) do
					if not running then
						break
					end

					local fieldName = br:GetAttribute("FieldName")
					local traits = br:GetAttribute("Traits")

					if (fieldName == "CelestialField" or fieldName == "OGField")
						and traits ~= "VIP" then

						found = true

						local prompt = br:FindFirstChildWhichIsA("ProximityPrompt", true)

						if not prompt then
							context.notify("found brainrot, but no prompt")
							continue
						end

						context.notify("farming " .. br.Name)

						local position

						if br:IsA("BasePart") then
							position = br.Position
						elseif br:IsA("Model") then
							position = br:GetPivot().Position
						end

						if position then
							moveTo(position)
						end

						task.wait(0.5)

						while running and br.Parent == brainrots do
							local ok = pcall(function()
								fireproximityprompt(prompt)
							end)

							if not ok then
								context.notify("failed to fire prompt")
								break
							end

							task.wait(0.15)
						end

						task.wait(0.2)

						while running do
							local character = getCharacter()

							if not character:FindFirstChild("HeldFieldBrainrot") then
								break
							end

							moveTo(Vector3.new(69, 30, 162))
							task.wait(0.15)
						end
					end
				end

				if not found then
					context.notify("no matching brainrots found")
				end

				task.wait(1)
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
				name = "farming"
			},
			{
				type = "toggle",
				name = "auto farm",
				default = false,
				callback = setEnabled
			}
		}
	}
end








print("")
