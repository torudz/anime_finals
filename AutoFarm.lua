--// AUTO FARM MODULE
local AutoFarm = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local camera      = workspace.CurrentCamera
local HitRemote   = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttackEvent")

local Config = {
    AutoFarm      = false,
    SelectedMob   = "",
    SelectedWorld = "World 1",
}

local lastHit   = 0
local WorldList = { "World 1", "World 2", "World 3", "World 4", "World 5" }

-- ─────────────────────────────────────────
-- LẤY DANH SÁCH MOB THEO WORLD + SẮP XẾP HP TĂNG DẦN
-- ─────────────────────────────────────────
local function getMobNames()
    local mobData = {}  -- { name, hp } để sort
    local seen    = {}
    local enemies = workspace:FindFirstChild("Enemies")

    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then

                -- Lọc theo IslandName
                local islandVal = mob:FindFirstChild("IslandName")
                local mobWorld  = islandVal and islandVal.Value or nil

                if mobWorld == Config.SelectedWorld and not seen[mob.Name] then
                    seen[mob.Name] = true

                    -- Đọc ScaledMaxHP từ Properties
                    local hpVal = mob:FindFirstChild("ScaledMaxHP")
                    local hp    = hpVal and hpVal.Value or hum.MaxHealth or 0

                    table.insert(mobData, { name = mob.Name, hp = hp })
                end
            end
        end
    end

    -- Sắp xếp theo HP tăng dần
    table.sort(mobData, function(a, b)
        return a.hp < b.hp
    end)

    -- Format tên hiển thị: "Nemo (350K HP)"
    local names = {}
    local nameMap = {}  -- map display → tên thật để dùng khi farm

    for _, data in ipairs(mobData) do
        local hpDisplay
        if data.hp >= 1000000 then
            hpDisplay = string.format("%.1fM", data.hp / 1000000)
        elseif data.hp >= 1000 then
            hpDisplay = string.format("%.0fK", data.hp / 1000)
        else
            hpDisplay = tostring(data.hp)
        end

        local display = data.name .. " (" .. hpDisplay .. " HP)"
        table.insert(names, display)
        nameMap[display] = data.name
    end

    if #names == 0 then
        table.insert(names, "(Chưa có mob)")
        nameMap["(Chưa có mob)"] = ""
    end

    return names, nameMap
end

-- ─────────────────────────────────────────
-- TÌM MOB GẦN NHẤT
-- ─────────────────────────────────────────
local function findNearestMob()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, nearestDist = nil, math.huge
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name == Config.SelectedMob then
            local root = mob:FindFirstChild("HumanoidRootPart")
                      or mob:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest     = root
                end
            end
        end
    end
    return nearest
end

-- ─────────────────────────────────────────
-- ĐÁNH MOB
-- ─────────────────────────────────────────
local function attackMob(mobPart)
    if not mobPart or not mobPart.Parent then return end
    if tick() - lastHit then return end
    lastHit = tick()

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(mobPart.Position + Vector3.new(0, 0, 2.5))
    task.wait(0.05)

    local screenPos, onScreen = camera:WorldToScreenPoint(mobPart.Position)
    if onScreen then
        VirtualUser:ClickButton1(Vector2.new(screenPos.X, screenPos.Y), camera.CFrame)
    end

    HitRemote:FireServer()
end

-- ─────────────────────────────────────────
-- FARM LOOP
-- ─────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not Config.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local mob = findNearestMob()
    if mob then attackMob(mob) end
end)

-- ─────────────────────────────────────────
-- BUILD UI
-- ─────────────────────────────────────────
function AutoFarm.BuildUI(tab, Fluent, Options)

    -- nameMap dùng chung trong scope BuildUI
    local currentNameMap = {}

    local function refreshMobDropdown()
        local names, nameMap = getMobNames()
        currentNameMap = nameMap

        if Options.MobSelect then
            Options.MobSelect:SetValues(names)
            local first = names[1] or ""
            Options.MobSelect:SetValue(first)
            Config.SelectedMob = nameMap[first] or ""
        end
        return #names
    end

    tab:AddParagraph({
        Title   = "Auto Farm",
        Content = "Chọn World → Chọn Mob → Bật farm."
    })

    -- Dropdown World
    tab:AddDropdown("WorldSelect", {
        Title    = "Chọn World",
        Values   = WorldList,
        Default  = Config.SelectedWorld,
        Callback = function(val)
            Config.SelectedWorld = val
            Config.AutoFarm      = false  -- tắt farm khi đổi world

            -- Clear tạm
            if Options.MobSelect then
                Options.MobSelect:SetValues({ "(Đang load...)" })
            end

            -- Đợi map load xong rồi refresh
            task.delay(3, function()
                local count = refreshMobDropdown()
                Fluent:Notify({
                    Title   = "✅ " .. val,
                    Content = count .. " mob · sắp xếp theo HP tăng dần",
                    Duration = 3
                })
            end)
        end
    })

    -- Dropdown Mob (hiển thị tên + HP, sắp xếp tăng dần)
    local initNames, initMap = getMobNames()
    currentNameMap = initMap

    tab:AddDropdown("MobSelect", {
        Title    = "Chọn Mob",
        Values   = initNames,
        Default  = initNames[1] or "",
        Callback = function(val)
            -- Dùng nameMap để lấy tên thật của mob
            Config.SelectedMob = currentNameMap[val] or val
        end
    })

    -- Toggle Auto Farm
    tab:AddToggle("AutoFarmToggle", {
        Title    = "Auto Farm",
        Default  = false,
        Callback = function(val)
            Config.AutoFarm = val
            Fluent:Notify({
                Title    = val and "⚔️ Auto Farm BẬT" or "🛑 Auto Farm TẮT",
                Content  = val and (Config.SelectedMob .. " @ " .. Config.SelectedWorld) or "Đã dừng.",
                Duration = 2
            })
        end
    })



end

return AutoFarm