--// UPGRADE MODULE
local Upgrade = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local Remotes         = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeRemote   = Remotes:WaitForChild("RequestProgressionUpgrade")
local PowerRollRemote = Remotes:WaitForChild("RequestPowerRoll")

-- FIX LỖI 3: mỗi conn dùng biến riêng, không gán nhầm
local hakiConn  = nil
local fruitConn = nil
local raceConn  = nil   -- ← tách riêng, không dùng chung fruitConn

--// BUILD UI
function Upgrade.BuildUI(tab, Fluent, Options)
    tab:AddParagraph({
        Title   = "Auto Upgrade",
        Content = "Tự động upgrade Haki và roll Fruit / Race."
    })

    -- Auto Haki
    tab:AddToggle("AutoHaki", {
        Title       = "Auto Haki Upgrade",
        Description = "Tự động spam RequestProgressionUpgrade Haki",
        Default     = false,
        Callback    = function(val)
            if val then
                hakiConn = RunService.Heartbeat:Connect(function()
                    UpgradeRemote:InvokeServer("Haki")
                    task.wait(0.1)
                end)
            else
                if hakiConn then hakiConn:Disconnect() hakiConn = nil end
            end
        end
    })

    -- Auto Fruit Roll
    tab:AddToggle("AutoFruitRoll", {
        Title       = "Auto Fruit Roll",
        Description = "Tự động spam RequestPowerRoll Fruit",
        Default     = false,
        Callback    = function(val)
            if val then
                fruitConn = RunService.Heartbeat:Connect(function()  -- ← fruitConn
                    PowerRollRemote:InvokeServer("Fruit")
                    task.wait(0.1)
                end)
            else
                if fruitConn then fruitConn:Disconnect() fruitConn = nil end
            end
        end
    })

    -- Auto Race Roll (FIX: dùng raceConn, không phải fruitConn)
    tab:AddToggle("AutoRaceRoll", {
        Title       = "Auto Race Roll",
        Description = "Tự động spam RequestPowerRoll Race",
        Default     = false,
        Callback    = function(val)
            if val then
                raceConn = RunService.Heartbeat:Connect(function()   -- ← raceConn
                    PowerRollRemote:InvokeServer("Race")
                    task.wait(0.1)
                end)
            else
                if raceConn then raceConn:Disconnect() raceConn = nil end  -- ← raceConn
            end
        end
    })
end

return Upgrade