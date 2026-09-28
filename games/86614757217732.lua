return function(context)
    local features = {}

    -- Feature 1: Tap Health
    table.insert(features, {
        name = "Tap Health",
        type = "toggle",
        default = false,
        thread = nil, -- Store the thread ID
        callback = function(isOn)
            if isOn then
                -- If already running, cancel it first to prevent duplicates
                if features[1].thread then
                    task.cancel(features[1].thread)
                end
                
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TapHealth")
                
                features[1].thread = task.spawn(function()
                    while true do
                        -- Check if we should stop
                        if not isOn then break end
                        
                        pcall(function()
                            Event:FireServer()
                        end)
                        task.wait()
                    end
                end)
            else
                -- TURN OFF LOGIC
                if features[1].thread then
                    task.cancel(features[1].thread) -- This kills the loop immediately
                    features[1].thread = nil
                end
            end
        end
    })

    -- Feature 2: Auto Farm
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
                
                local plr = game.Players.LocalPlayer
                
                features[2].thread = task.spawn(function()
                    while true do
                        if not isOn then break end
                        
                        pcall(function()
                            local topRot = nil
                            local bestAmt = 0
                            local brainsFolder = workspace:FindFirstChild("SpawnedBrainrots")
                            
                            if brainsFolder then
                                for i, br in pairs(brainsFolder:GetChildren()) do
                                    if br:GetAttribute("CashPerSec") and br:GetAttribute("CashPerSec") >= bestAmt then
                                        bestAmt = br:GetAttribute("CashPerSec")
                                        topRot = br
                                    end
                                end
                            end

                            if topRot and topRot.Parent == brainsFolder then
                                plr.Character:MoveTo(topRot.PrimaryPart.Position)

                                repeat
                                    if topRot.PickupHitbox and topRot.PickupHitbox.ProximityPrompt then
                                        fireproximityprompt(topRot.PickupHitbox.ProximityPrompt)
                                    end
                                    task.wait()
                                until not topRot or topRot.Parent ~= workspace.SpawnedBrainrots or not isOn

                                firetouchinterest(plr.Character.Head, workspace.Map.BrainrotCollectionPart, true)
                                task.wait()
                                firetouchinterest(plr.Character.Head, workspace.Map.BrainrotCollectionPart, false)
                            else
                                task.wait(1)
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            else
                -- TURN OFF LOGIC
                if features[2].thread then
                    task.cancel(features[2].thread) -- Kills the loop immediately
                    features[2].thread = nil
                end
            end
        end
    })

    return {
        features = features
    }
end
