return function(context)
    local features = {}

    -- Helper: Get LocalPlayer
    local plr = game.Players.LocalPlayer

    -- Feature 1: Dumbbell Spammer
    table.insert(features, {
        name = "Dumbbell Spammer",
        type = "toggle",
        default = false,
        thread = nil,
        callback = function(isOn)
            if isOn then
                if features[1].thread then
                    task.cancel(features[1].thread)
                end
                
                local Event = game:GetService("ReplicatedStorage").SharedModules.Network.Remotes:FindFirstChild("Activate Dumbbell")
                
                if not Event then
                    warn("Event 'Activate Dumbbell' not found!")
                    return
                end

                features[1].thread = task.spawn(function()
                    while true do
                        if not isOn then break end
                        
                        pcall(function()
                            Event:FireServer(nil)
                        end)
                        task.wait(0.1) -- Spam rate
                    end
                end)
            else
                if features[1].thread then
                    task.cancel(features[1].thread)
                    features[1].thread = nil
                end
            end
        end
    })

    -- Feature 2: Auto Farm (Live -> Friends -> Smart Egg Selection -> Plot Base)
    table.insert(features, {
        name = "Auto Farm",
        type = "toggle",
        default = false,
        thread = nil,
        callback = function(isOn)
            if isOn then
                if features[2].thread then
                    task.cancel(features[2].thread)
                end
                
                features[2].thread = task.spawn(function()
                    while true do
                        if not isOn then break end
                        
                        pcall(function()
                            -- 1. Find the "Live" folder
                            local liveFolder = workspace:FindFirstChild("Live")
                            if not liveFolder then
                                task.wait(1)
                                return
                            end

                            -- 2. Find the "Friends" folder inside Live
                            local friendsFolder = liveFolder:FindFirstChild("Friends")
                            if not friendsFolder then
                                task.wait(1)
                                return
                            end

                            -- 3. Find the model with the HIGHEST "HardScale" attribute in the Friends folder
                            local bestModel = nil
                            local maxHardScale = -1

                            for _, model in pairs(friendsFolder:GetChildren()) do
                                if model:IsA("Model") or model:IsA("Union") or model:IsA("Part") then
                                    local hardScale = model:GetAttribute("HardScale")
                                    if hardScale ~= nil and hardScale > maxHardScale then
                                        maxHardScale = hardScale
                                        bestModel = model
                                    end
                                end
                            end

                            if not bestModel then
                                task.wait(2)
                                return
                            end

                            -- 4. Teleport to the best model
                            if bestModel:FindFirstChild("PrimaryPart") then
                                plr.Character:MoveTo(bestModel.PrimaryPart.Position)
                            else
                                -- Fallback if no primary part, move to the model's position
                                plr.Character:MoveTo(bestModel:GetModelCFrame().p)
                            end
                            task.wait(0.5) -- Wait to arrive

                            -- 5. Press E (Fire ProximityPrompt)
                            local prompt = bestModel:FindFirstChildWhichA("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt)
                            end

                            -- 6. Teleport to the Plot Base
                            -- Find the correct Plot folder by matching the owner string to LocalPlayer name
                            local plotsFolder = workspace:FindFirstChild("Plots")
                            if plotsFolder then
                                local targetPlotFolder = nil
                                
                                for _, plotFolder in pairs(plotsFolder:GetChildren()) do
                                    if plotFolder:IsA("Folder") then
                                        -- Check for "Owner" or "owner"
                                        local ownerString = plotFolder:FindFirstChild("Owner") or plotFolder:FindFirstChild("owner")
                                        
                                        if ownerString and ownerString:IsA("StringValue") then
                                            if ownerString.Value == plr.Name then
                                                targetPlotFolder = plotFolder
                                                break
                                            end
                                        end
                                    end
                                end

                                if targetPlotFolder then
                                    local basePart = targetPlotFolder:FindFirstChild("Base")
                                    if basePart and basePart:IsA("BasePart") then
                                        plr.Character:MoveTo(basePart.Position)
                                        task.wait(1) -- Wait for teleport to finish before next loop
                                    else
                                        warn("Base part not found in plot: " .. targetPlotFolder.Name)
                                        task.wait(2)
                                    end
                                else
                                    warn("Plot folder for owner '" .. plr.Name .. "' not found!")
                                    task.wait(2)
                                end
                            else
                                warn("Plots folder not found in Workspace")
                                task.wait(2)
                            end
                        end)
                        
                        task.wait(0.5) -- Small delay between attempts
                    end
                end)
            else
                if features[2].thread then
                    task.cancel(features[2].thread)
                    features[2].thread = nil
                end
            end
        end
    })

    return {
        features = features
    }
end
