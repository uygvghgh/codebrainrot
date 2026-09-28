return function(context)
    local features = {}

    table.insert(features, {
        name = "Tap Health",
        type = "toggle",
        default = false,
        callback = function(isOn)
            if isOn then
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TapHealth")
                
                spawn(function()
                    while isOn do
                        pcall(function()
                            Event:FireServer()
                        end)
                        task.wait()
                    end
                end)
            end
        end
    })

    table.insert(features, {
        name = "Auto Farm",
        type = "toggle",
        default = false,
        callback = function(isOn)
            if isOn then
                spawn(function()
                    local plr = game.Players.LocalPlayer
                    while isOn do
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
            end
        end
    })

    return {
        features = features
    }
end
