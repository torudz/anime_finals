--// GACHA MODULE
local Gacha = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local GachaRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ChampionRollRequest")

local Config = {
    AutoGacha = false,
    World     = "World 1",
}

local function doGacha()
    GachaRemote:InvokeServer(Config.World, 3, {
        autoDelete = true,
        pity = {
            lTotal    = 1000,
            legendary = 60,
            mTotal    = 10000,
            mythic    = 60
        }
    })
end

-- Gacha loop (dùng task.wait(0.5) tránh spam quá nhanh)
RunService.Heartbeat:Connect(function()
    if not Config.AutoGacha then return end
    doGacha()
    task.wait(0.5)
end)

--// BUILD UI
function Gacha.BuildUI(tab, Fluent, Options)
    tab:AddParagraph({
        Title   = "Auto Gacha",
        Content = "Tự động roll gacha liên tục."
    })

    tab:AddDropdown("GachaWorld", {
        Title    = "Chọn World",
        Values   = { "World 1", "World 2", "World 3", "World 4", "World 5" },
        Default  = Config.World,
        Callback = function(val)
            Config.World = val
        end
    })

    tab:AddToggle("AutoGachaToggle", {
        Title    = "Auto Gacha",
        Default  = false,
        Callback = function(val)
            Config.AutoGacha = val
            Fluent:Notify({
                Title    = val and "Auto Gacha BẬT" or "Auto Gacha TẮT",
                Content  = val and ("Rolling " .. Config.World) or "Đã dừng.",
                Duration = 2
            })
        end
    })
end

return Gacha