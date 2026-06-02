local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/lelo0002/hai../refs/heads/main/roxylinoria.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/lelo0002/hai../refs/heads/main/theme.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local Window = Library:CreateWindow({
    Title = "$$ duels fucker $$",
    Center = true,
    AutoShow = true,
    MenuFadeTime = 0.1,
    Resizable = true,
    ShowCustomCursor = false,
    NotifySide = "Bottom",
    Size = UDim2.new(0, 750, 0, 480)
})
local Tabs = {
    Combat = Window:AddTab("combat"),
    Visuals = Window:AddTab("visuals"),
    Misc = Window:AddTab("misc"),
    ["UI Settings"] = Window:AddTab("configs")
}

local S = setmetatable({}, {__index = function(t, k) local s = game:GetService(k); t[k] = s; return s end})
local P, RS, WS, UIS = S.Players, S.RunService, workspace, S.UserInputService
local LP = P.LocalPlayer or P:GetPropertyChangedSignal("LocalPlayer"):Wait() or P.LocalPlayer
local C = WS.CurrentCamera

local L = {
    Master = false,
    BE = false,
    BC = Color3.fromRGB(255, 255, 255),
    BFE = false,
    BFC = Color3.fromRGB(255, 255, 255),
    BFTrans = 0.5,
    NE = false,
    NTC = Color3.fromRGB(255, 255, 255),
    DE = false,
    DTC = Color3.fromRGB(255, 255, 255),
    DistMode = "Studs",
    HE = false,
    HHC = Color3.fromRGB(0, 255, 0),
    HMC = Color3.fromRGB(255, 255, 0),
    HLC = Color3.fromRGB(255, 0, 0),
    HGrad = false,
    HGradAnim = false,
    HGradAnimSpeed = 1,
    HGradAnimStyle = "Orbit",
    HTE = false,
    HTC = Color3.fromRGB(255, 255, 255),
    HBarThickness = 2,
    HBarOffset = 5,
    WE = false,
    WTC = Color3.fromRGB(255, 255, 255),
    Skel = false,
    SkelColor = Color3.fromRGB(255, 255, 255),
    SkelTrans = 0.0,
    Chams = false,
    ChamsColor = Color3.fromRGB(84, 132, 171),
    ChamsTrans = 0.5,
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsOutlineTrans = 0.0,
    NameStyle = "Username",
    CustomName = ".gg/",
    TeamCheck = true,
    VisCheck = false,
    FadeIn = 0.5,
    FadeOut = 0.5,
    DMax = 650,
    FS = 13,
    Font = 2,
    FCase = "Normal",
    TextGradient = false,
    TextGradType = "String",
    TextGradColor1 = Color3.fromRGB(211, 227, 255),
    TextGradColor2 = Color3.fromRGB(255, 255, 255),
    TextGradRot = false,
    TextGradSpeed = 1,
    BoxType = "Full",
    BoxGrad = false,
    BoxGrad1 = Color3.fromRGB(211, 227, 255),
    BoxGrad2 = Color3.fromRGB(255, 255, 255),
    BoxGradRot = false,
    BoxGradSpeed = 1,
    BoxGradAnimStyle = "Orbit",
    VMChamsEnabled   = false,
    VMChamsFill      = Color3.fromRGB(255, 255, 255),
    VMChamsFillTrans = 0.5,
    VMChamsOutline   = Color3.fromRGB(255, 255, 255),
    VMChamsOutTrans  = 0.0,
    VMMatEnabled     = false,
    VMMatColor       = Color3.fromRGB(255, 255, 255),
    VMMatTrans       = 0.0,
    VMMaterial       = Enum.Material.Neon,
    VMHideEnabled    = false,
    VMHideLeft       = true,
    VMHideRight      = true,
}

local G = {}
local cache = {}
G.FM = { ['UI'] = 0, ['System'] = 1, ['Plex'] = 2, ['Monospace'] = 3 }

local GlobalRaycastParams = RaycastParams.new()
GlobalRaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local NOOB_NAME_BLACKLIST = {
    ["Noob"]         = true,
    ["Walking Noob"] = true,
}

local BoneConnections = {
    { "Head",     "Torso"            },
    { "Torso",    "HumanoidRootPart" },
    { "Torso",    "Left Arm"         },
    { "Torso",    "Right Arm"        },
    { "Torso",    "Left Leg"         },
    { "Torso",    "Right Leg"        },
}

G.GRAD_SEG_MAX        = 32
G.GRAD_CHAR_W         = 0.52
G.TEXT_GRAD_MAX_CHARS = 18
G.TEXT_GRAD_MAX_SLOTS = 90
G.BOX_PERIM_SEGS      = 40
G.gradPoolTrimTick    = 0
G.textGradPhase       = 0
G.boxGradPhase        = 0

local function setupDraw(class, props)
    local obj = Drawing.new(class)
    for k, v in next, props do obj[k] = v end
    return obj
end

local function hideGradPool(pool)
    if not pool then return end
    for i = 1, #pool do
        local seg = pool[i]
        if seg then seg.Visible = false end
    end
end

local function trimGradPool(pool, keep)
    if not pool then return end
    keep = keep or 0
    for i = #pool, keep + 1, -1 do
        local seg = pool[i]
        if seg then
            pcall(function() seg:Remove() end)
            pool[i] = nil
        end
    end
end

local function hideBoxDraw(esp)
    if esp.boxOutline then esp.boxOutline.Visible = false end
    if esp.box then esp.box.Visible = false end
    if esp.boxFill then esp.boxFill.Visible = false end
    if esp.boxCornerFill then
        for i = 1, 8 do
            local ln = esp.boxCornerFill[i]
            if ln then ln.Visible = false end
        end
    end
    if esp.boxCornerOut then
        for i = 1, 8 do
            local ln = esp.boxCornerOut[i]
            if ln then ln.Visible = false end
        end
    end
    if esp.boxPerim then
        for i = 1, #esp.boxPerim do
            local ln = esp.boxPerim[i]
            if ln then ln.Visible = false end
        end
    end
end

local function hideESP(esp)
    hideBoxDraw(esp)
    if esp.nameText then esp.nameText.Visible = false end
    if esp.distanceText then esp.distanceText.Visible = false end
    if esp.weaponText then esp.weaponText.Visible = false end
    if esp.healthOutlineBg then esp.healthOutlineBg.Visible = false end
    if esp.healthOutline then esp.healthOutline.Visible = false end
    if esp.healthText then esp.healthText.Visible = false end
    if esp.healthLines then
        for i = 1, #esp.healthLines do
            local line = esp.healthLines[i]
            if line then line.Visible = false end
        end
    end
    if esp.skeletonLines then
        for i = 1, #esp.skeletonLines do
            local line = esp.skeletonLines[i]
            if line then
                if line.outline then line.outline.Visible = false end
                if line.fill then line.fill.Visible = false end
            end
        end
    end
    if esp.chamHighlight then
        esp.chamHighlight.Enabled = false
    end
    hideGradPool(esp.gradName)
    hideGradPool(esp.gradWeapon)
    hideGradPool(esp.gradDist)
    hideGradPool(esp.gradHealth)
end

local function createESP(model)
    local esp = {
        boxOutline = setupDraw("Square", { Thickness = 3, Color = Color3.fromRGB(0, 0, 0), Filled = false, Visible = false, ZIndex = 3 }),
        box = setupDraw("Square", { Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false, Visible = false, ZIndex = 3 }),
        boxFill = setupDraw("Square", { Filled = true, Visible = false, ZIndex = 1 }),
        nameText = setupDraw("Text", { Size = 13, Center = true, Outline = true, Visible = false, ZIndex = 6 }),
        distanceText = setupDraw("Text", { Size = 13, Center = true, Outline = true, Visible = false, ZIndex = 6 }),
        weaponText = setupDraw("Text", { Size = 13, Center = true, Outline = true, Visible = false, ZIndex = 6 }),
        healthOutlineBg = setupDraw("Square", { Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Filled = true, Visible = false, ZIndex = 4 }),
        healthOutline = setupDraw("Square", { Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Filled = false, Visible = false, ZIndex = 4 }),
        healthText = setupDraw("Text", { Size = 13, Outline = true, Font = L.Font, Visible = false, ZIndex = 6 }),
        healthLines = {},
        skeletonLines = {},
        boxCornerFill = {},
        boxCornerOut = {},
        boxPerim = {},
        hum = model:FindFirstChildOfClass("Humanoid"),
        hrp = model:FindFirstChild("HumanoidRootPart"),
        opacity = 0,
        state = "fadein",
        highlightLerp = 0
    }
    for i = 1, 6 do
        esp.skeletonLines[i] = {
            outline = setupDraw("Line", { Thickness = 2, Color = Color3.fromRGB(0, 0, 0), Visible = false, ZIndex = 2 }),
            fill = setupDraw("Line", { Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false, ZIndex = 2 })
        }
    end
    for i = 1, 60 do
        esp.healthLines[i] = setupDraw("Square", { Filled = true, Thickness = 1, Visible = false, ZIndex = 5 })
    end
    for i = 1, 8 do
        esp.boxCornerOut[i] = setupDraw("Line", { Thickness = 3, Color = Color3.fromRGB(0, 0, 0), Visible = false, ZIndex = 3 })
        esp.boxCornerFill[i] = setupDraw("Line", { Thickness = 1, Visible = false, ZIndex = 3 })
    end
    
    cache[model] = esp
    return esp
end

local function removeESP(model)
    local esp = cache[model]
    if esp then
        if esp.boxOutline then pcall(function() esp.boxOutline:Remove() end) end
        if esp.box then pcall(function() esp.box:Remove() end) end
        if esp.boxFill then pcall(function() esp.boxFill:Remove() end) end
        if esp.nameText then pcall(function() esp.nameText:Remove() end) end
        if esp.distanceText then pcall(function() esp.distanceText:Remove() end) end
        if esp.weaponText then pcall(function() esp.weaponText:Remove() end) end
        if esp.healthOutlineBg then pcall(function() esp.healthOutlineBg:Remove() end) end
        if esp.healthOutline then pcall(function() esp.healthOutline:Remove() end) end
        if esp.healthText then pcall(function() esp.healthText:Remove() end) end
        if esp.healthLines then
            for i = 1, #esp.healthLines do
                local line = esp.healthLines[i]
                if line then pcall(function() line:Remove() end) end
            end
            table.clear(esp.healthLines)
        end
        for _, key in ipairs({ "gradName", "gradWeapon", "gradDist", "gradHealth" }) do
            local pool = esp[key]
            if pool then
                for i = 1, #pool do
                    if pool[i] then pcall(function() pool[i]:Remove() end) end
                end
            end
        end
        if esp.skeletonLines then
            for _, line in ipairs(esp.skeletonLines) do
                if line.outline then pcall(function() line.outline:Remove() end) end
                if line.fill then pcall(function() line.fill:Remove() end) end
            end
            table.clear(esp.skeletonLines)
        end
        for _, key in ipairs({ "boxCornerFill", "boxCornerOut", "boxPerim" }) do
            local arr = esp[key]
            if arr then
                for i = 1, #arr do
                    if arr[i] then pcall(function() arr[i]:Remove() end) end
                end
            end
        end
        if esp.chamHighlight then
            pcall(function() esp.chamHighlight:Destroy() end)
            esp.chamHighlight = nil
        end
        cache[model] = nil
    end
end

local function perimeterPoint(t, x, y, w, h)
    local perim = 2 * (w + h)
    local d = t * perim
    if d <= w then return x + d, y end
    d = d - w
    if d <= h then return x + w, y + d end
    d = d - h
    if d <= w then return x + w - d, y + h end
    d = d - w
    return x, y + h - d
end

local function boxGradTAt(px, py, bx, by, bw, bh, rotOff, animStyle)
    local cx, cy = bx + bw * 0.5, by + bh * 0.5
    if rotOff and rotOff ~= 0 then
        local ang = math.atan2(py - cy, px - cx) / (2 * math.pi)
        local base = (ang + 0.25 + rotOff) % 1
        if animStyle then
            if animStyle == "Helix" then
                base = (base + math.sin(rotOff * 12) * 0.15) % 1
            elseif animStyle == "Stream" then
                base = math.sin(base * math.pi + rotOff * 4) * 0.5 + 0.5
            elseif animStyle == "Flux" then
                base = (base + math.sin(base * 3 + rotOff * 8) * 0.1) % 1
            elseif animStyle == "Nova" then
                local dist = math.sqrt((px - cx)^2 + (py - cy)^2) / math.max(bw, bh)
                base = (base + dist * 0.3 + rotOff) % 1
            elseif animStyle == "Drift" then
                base = (base + rotOff * 0.4) % 1
            end
        end
        return math.clamp(base, 0, 1)
    end
    return math.clamp((px - bx) / math.max(bw, 1), 0, 1)
end

local function drawCornerBracket(esp, x, y, w, h, cl, opacity, solidColor, useGrad, c1, c2, rotOff, bx, by, bw, bh, animStyle)
    local fills, outs = esp.boxCornerFill, esp.boxCornerOut
    if not fills or not outs then return end
    local segs = {
        {x, y, x + cl, y},
        {x, y, x, y + cl},
        {x + w - cl, y, x + w, y},
        {x + w, y, x + w, y + cl},
        {x + w - cl, y + h, x + w, y + h},
        {x + w, y + h - cl, x + w, y + h},
        {x, y + h, x + cl, y + h},
        {x, y + h - cl, x, y + h},
    }
    for i = 1, 8 do
        local s = segs[i]
        local fx, fy, tx, ty = s[1], s[2], s[3], s[4]
        local mx, my = (fx + tx) * 0.5, (fy + ty) * 0.5
        local col = useGrad and c1:Lerp(c2, boxGradTAt(mx, my, bx, by, bw, bh, rotOff, animStyle)) or solidColor
        local from, to = Vector2.new(fx, fy), Vector2.new(tx, ty)
        local outLn, fillLn = outs[i], fills[i]
        if outLn then
            outLn.From, outLn.To = from, to
            outLn.Thickness = 2
            outLn.Color = Color3.fromRGB(0, 0, 0)
            outLn.Transparency = opacity
            outLn.Visible = true
        end
        if fillLn then
            fillLn.From, fillLn.To = from, to
            fillLn.Color = col
            fillLn.Thickness = 1
            fillLn.Transparency = opacity
            fillLn.Visible = true
        end
    end
end

local function drawPerimeterGrad(esp, x, y, w, h, opacity, c1, c2, rotOff, bx, by, bw, bh, animStyle)
    local lines = esp.boxPerim
    if not lines then return end
    local n = G.BOX_PERIM_SEGS
    for i = 1, n do
        local t0 = (i - 1) / n
        local t1 = i / n
        local p0x, p0y = perimeterPoint(t0, x, y, w, h)
        local p1x, p1y = perimeterPoint(t1, x, y, w, h)
        local tMid = (t0 + t1) * 0.5
        local mx, my = perimeterPoint(tMid, x, y, w, h)
        local col = c1:Lerp(c2, boxGradTAt(mx, my, bx, by, bw, bh, rotOff, animStyle))
        local ln = lines[i]
        if not ln then
            ln = Drawing.new("Line")
            ln.Thickness = 1
            ln.ZIndex = 3
            lines[i] = ln
        end
        ln.From = Vector2.new(p0x, p0y)
        ln.To = Vector2.new(p1x, p1y)
        ln.Color = col
        ln.Transparency = opacity
        ln.Visible = true
    end
    for i = n + 1, #lines do
        if lines[i] then lines[i].Visible = false end
    end
end

local function drawPlayerBox(esp, box, opacity, solidColor, gradPhase)
    hideBoxDraw(esp)
    local x, y, w, h = box.x, box.y, box.w, box.h
    local corners = L.BoxType == "Corners"
    local useGrad = L.BoxGrad
    local rotOff = L.BoxGradRot and gradPhase or 0
    local c1, c2 = L.BoxGrad1, L.BoxGrad2
    local animStyle = L.BoxGradRot and L.BoxGradAnimStyle or nil

    if not useGrad and not corners then
        esp.boxOutline.Size = Vector2.new(w, h)
        esp.boxOutline.Position = Vector2.new(x, y)
        esp.boxOutline.Transparency = opacity
        esp.boxOutline.Visible = true
        esp.box.Size = Vector2.new(w, h)
        esp.box.Position = Vector2.new(x, y)
        esp.box.Color = solidColor
        esp.box.Transparency = opacity
        esp.box.Visible = true
        return
    end

    if esp.box then esp.box.Visible = false end

    if corners then
        if esp.boxPerim then
            for i = 1, #esp.boxPerim do
                local ln = esp.boxPerim[i]
                if ln then ln.Visible = false end
            end
        end
        if esp.boxOutline then esp.boxOutline.Visible = false end
        drawCornerBracket(esp, x, y, w, h, math.max(3, math.floor(math.min(w, h) * 0.22)), opacity, solidColor, useGrad, c1, c2, rotOff, x, y, w, h, animStyle)
    elseif useGrad then
        if esp.boxCornerFill then
            for i = 1, 8 do
                if esp.boxCornerFill[i] then esp.boxCornerFill[i].Visible = false end
                if esp.boxCornerOut[i] then esp.boxCornerOut[i].Visible = false end
            end
        end
        local inset = 1
        esp.boxOutline.Size = Vector2.new(w, h)
        esp.boxOutline.Position = Vector2.new(x, y)
        esp.boxOutline.Transparency = opacity
        esp.boxOutline.Visible = true
        drawPerimeterGrad(esp, x + inset, y + inset, w - inset * 2, h - inset * 2, opacity, c1, c2, rotOff, x, y, w, h, animStyle)
    else
        if esp.boxPerim then
            for i = 1, #esp.boxPerim do
                local ln = esp.boxPerim[i]
                if ln then ln.Visible = false end
            end
        end
        esp.boxOutline.Size = Vector2.new(w, h)
        esp.boxOutline.Position = Vector2.new(x, y)
        esp.boxOutline.Transparency = opacity
        esp.boxOutline.Visible = true
        esp.box.Size = Vector2.new(w, h)
        esp.box.Position = Vector2.new(x, y)
        esp.box.Color = solidColor
        esp.box.Transparency = opacity
        esp.box.Visible = true
    end
end

local function drawEspLabel(mainDraw, pool, text, x, y, size, font, opacity, fallbackColor, centered, gradPhase)
    if not L.TextGradient then
        hideGradPool(pool)
        trimGradPool(pool, 0)
        mainDraw.Text = text
        mainDraw.Size = size
        mainDraw.Font = font
        mainDraw.Color = fallbackColor
        mainDraw.Transparency = opacity
        mainDraw.Position = Vector2.new(x, y)
        mainDraw.Center = centered ~= false
        mainDraw.Visible = true
        return pool
    end
    mainDraw.Visible = false
    local len = #text
    if len < 1 then
        hideGradPool(pool)
        return pool
    end
    pool = pool or {}
    local c1, c2 = L.TextGradColor1, L.TextGradColor2
    local rotOff = L.TextGradRot and gradPhase or 0
    local used = 0
    if L.TextGradType == "Character" then
        local useLen = math.min(len, G.TEXT_GRAD_MAX_CHARS)
        local charW = size * G.GRAD_CHAR_W
        local totalW = charW * useLen
        local x0 = centered ~= false and (x - totalW * 0.5) or x
        for ci = 1, useLen do
            local ch = text:sub(ci, ci)
            if ch ~= "" and ch ~= " " then
                used += 1
                if used > G.TEXT_GRAD_MAX_SLOTS then break end
                local seg = pool[used]
                if not seg then
                    seg = Drawing.new("Text")
                    seg.Outline = true
                    seg.Center = false
                    seg.ZIndex = 6
                    pool[used] = seg
                end
                local t = (ci - 0.5) / useLen
                t = (t + rotOff) % 1
                seg.Text = ch
                seg.Size = size
                seg.Font = font
                seg.Color = c1:Lerp(c2, t)
                seg.Transparency = opacity
                seg.Position = Vector2.new(x0 + (ci - 1) * charW, y)
                seg.Visible = true
            end
        end
    else
        local segs = math.min(len, G.GRAD_SEG_MAX)
        if segs < 2 then segs = math.min(len, 2) end
        local totalW = size * G.GRAD_CHAR_W * len
        local x0 = centered ~= false and (x - totalW * 0.5) or x
        local step = totalW / segs
        for i = 1, segs do
            used += 1
            local seg = pool[used]
            if not seg then
                seg = Drawing.new("Text")
                seg.Outline = true
                seg.Center = false
                seg.ZIndex = 6
                pool[used] = seg
            end
            local i0 = math.floor((i - 1) * len / segs) + 1
            local i1 = math.min(len, math.ceil(i * len / segs))
            local chunk = text:sub(i0, i1)
            if chunk ~= "" then
                local charMid = (i0 + i1) * 0.5
                local t = ((charMid - 0.5) / len + rotOff) % 1
                seg.Text = chunk
                seg.Size = size
                seg.Font = font
                seg.Color = c1:Lerp(c2, t)
                seg.Transparency = opacity
                seg.Position = Vector2.new(x0 + (i - 1) * step, y)
                seg.Visible = true
            else
                seg.Visible = false
            end
        end
    end
    for i = used + 1, #pool do
        local seg = pool[i]
        if seg then seg.Visible = false end
    end
    return pool
end

local function getBoundingBox(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local hrpPos = hrp.Position
    local topWorld = hrpPos + Vector3.new(0, 3, 0)
    local bottomWorld = hrpPos - Vector3.new(0, 3.5, 0)
    local topPos = C:WorldToViewportPoint(topWorld)
    local bottomPos = C:WorldToViewportPoint(bottomWorld)
    if topPos.Z <= 0 or bottomPos.Z <= 0 then return nil end
    local height = math.abs(topPos.Y - bottomPos.Y)
    local width = height * 0.55
    local x = topPos.X - (width / 2)
    local y = topPos.Y
    return {
        x = math.floor(x),
        y = math.floor(y),
        w = math.floor(width),
        h = math.floor(height)
    }
end

local function blend3Colors(cLow, cMid, cHigh, t)
    t = math.clamp(t, 0, 1)
    if t <= 0.5 then return cLow:Lerp(cMid, t * 2) end
    return cMid:Lerp(cHigh, (t - 0.5) * 2)
end

local function getHeldWeapon(model)
    if not model then return "None" end
    local name = model.Name
    local vm = WS:FindFirstChild("ViewModels")
    if vm then
        for _, child in ipairs(vm:GetChildren()) do
            local cName = child.Name
            local prefix = name .. " - "
            if cName:sub(1, #prefix) == prefix then
                local remaining = cName:sub(#prefix + 1)
                local parts = string.split(remaining, " - ")
                if parts[1] then return parts[1] end
            end
        end
    end
    return "None"
end

local function isAlly(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local billboard = hrp:FindFirstChild("__AllyHeadBillboard")
    if billboard then return true end
    return false
end

G.cachedActiveTargets = {}
G.playerScanTick      = 0
G.masterWasOn         = true

local drawHealthBar 

local function drawModelESP(esp, model, camPos, currentFont, currentFontSize, now, dt)
    local humanoid = esp.hum
    local hrp = esp.hrp
    if not humanoid or humanoid.Parent ~= model then
        humanoid = model:FindFirstChildOfClass("Humanoid")
        esp.hum = humanoid
    end
    if not hrp or hrp.Parent ~= model then
        hrp = model:FindFirstChild("HumanoidRootPart")
        esp.hrp = hrp
    end

    if not humanoid or not hrp then
        hideESP(esp)
        return
    end

    local distance = (camPos - hrp.Position).Magnitude
    local box = getBoundingBox(model)
    local skip = NOOB_NAME_BLACKLIST[model.Name] or distance > L.DMax

    if not skip and L.TeamCheck then
        if esp.teamSkipTick and (now - esp.teamSkipTick) < 0.25 then
            skip = esp.teamSkipCached == true
        else
            local ally = hrp:FindFirstChild("__AllyHeadBillboard") ~= nil
            esp.teamSkipCached = ally
            esp.teamSkipTick = now
            skip = ally
        end
    end

    if not skip and not box then skip = true end

    if not skip and L.VisCheck then
        local targetPart = model:FindFirstChild("Head") or hrp
        if targetPart then
            GlobalRaycastParams.FilterDescendantsInstances = {LP.Character, model}
            if WS:Raycast(camPos, targetPart.Position - camPos, GlobalRaycastParams) then skip = true end
        end
    end

    if skip then
        hideESP(esp)
        return
    end

    
    if L.BE then
        drawPlayerBox(esp, box, esp.opacity, L.BC, G.boxGradPhase)
        if L.BFE then
            esp.boxFill.Size = Vector2.new(box.w, box.h)
            esp.boxFill.Position = Vector2.new(box.x, box.y)
            esp.boxFill.Color = L.BFC
            esp.boxFill.Transparency = (1 - L.BFTrans) * esp.opacity
            esp.boxFill.Visible = true
        else
            esp.boxFill.Visible = false
        end
    else
        hideBoxDraw(esp)
    end

    
    if L.NE then
        local rawName = model.Name
        if L.NameStyle == "DisplayName" then
            if esp.cachedPlayer == nil then
                esp.cachedPlayer = P:GetPlayerFromCharacter(model) or false
            end
            if esp.cachedPlayer then rawName = esp.cachedPlayer.DisplayName end
        elseif L.NameStyle == "Custom" then
            rawName = L.CustomName or ".gg/"
        end
        if L.FCase == "Uppercase" then rawName = rawName:upper()
        elseif L.FCase == "Lowercase" then rawName = rawName:lower() end
        esp.gradName = drawEspLabel(esp.nameText, esp.gradName, rawName, box.x + box.w * 0.5, box.y - currentFontSize - 2, currentFontSize, currentFont, esp.opacity, L.NTC, true, G.textGradPhase)
    else
        esp.nameText.Visible = false
        hideGradPool(esp.gradName)
    end

    
    local bottomOffset = 2
    if L.WE then
        local weaponName = getHeldWeapon(model)
        if L.FCase == "Uppercase" then weaponName = weaponName:upper()
        elseif L.FCase == "Lowercase" then weaponName = weaponName:lower() end
        esp.gradWeapon = drawEspLabel(esp.weaponText, esp.gradWeapon, weaponName, box.x + box.w * 0.5, box.y + box.h + bottomOffset, currentFontSize, currentFont, esp.opacity, L.WTC, true, G.textGradPhase)
        bottomOffset = bottomOffset + currentFontSize + 2
    else
        esp.weaponText.Visible = false
        hideGradPool(esp.gradWeapon)
    end

    if L.DE then
        local displayedDist = math.floor(L.DistMode == "Meters" and distance * 0.28 or distance)
        local distStr = displayedDist .. (L.DistMode == "Meters" and "m" or " studs")
        if L.FCase == "Uppercase" then distStr = distStr:upper()
        elseif L.FCase == "Lowercase" then distStr = distStr:lower() end
        esp.gradDist = drawEspLabel(esp.distanceText, esp.gradDist, distStr, box.x + box.w * 0.5, box.y + box.h + bottomOffset, currentFontSize, currentFont, esp.opacity, L.DTC, true, G.textGradPhase)
    else
        esp.distanceText.Visible = false
        hideGradPool(esp.gradDist)
    end

    
    if L.HE then
        drawHealthBar(esp, humanoid, box, currentFont, currentFontSize, now, dt)
    else
        esp.healthOutlineBg.Visible = false
        esp.healthOutline.Visible = false
        for i = 1, #esp.healthLines do
            local sq = esp.healthLines[i]
            if sq then sq.Visible = false end
        end
        esp.healthText.Visible = false
    end

    
    if L.Skel then
        local skelCache = esp.skelParts
        if not skelCache then skelCache = {}; esp.skelParts = skelCache end
        local skelFillAlpha = esp.opacity * (1 - L.SkelTrans)
        for i, bone in next, BoneConnections do
            local pA = skelCache[bone[1]]
            if not pA or not pA.Parent then pA = model:FindFirstChild(bone[1]); skelCache[bone[1]] = pA end
            local pB = skelCache[bone[2]]
            if not pB or not pB.Parent then pB = model:FindFirstChild(bone[2]); skelCache[bone[2]] = pB end
            local draw = esp.skeletonLines[i]
            if pA and pB and draw then
                local sA, onA = C:WorldToViewportPoint(pA.Position)
                local sB, onB = C:WorldToViewportPoint(pB.Position)
                if onA and onB then
                    local from, to = Vector2.new(sA.X, sA.Y), Vector2.new(sB.X, sB.Y)
                    draw.outline.From, draw.outline.To = from, to
                    draw.outline.Transparency = esp.opacity
                    draw.outline.Visible = true
                    draw.fill.From, draw.fill.To = from, to
                    draw.fill.Color = L.SkelColor
                    draw.fill.Transparency = skelFillAlpha
                    draw.fill.Visible = true
                else
                    draw.outline.Visible, draw.fill.Visible = false, false
                end
            elseif draw then
                draw.outline.Visible, draw.fill.Visible = false, false
            end
        end
    else
        for _, draw in next, esp.skeletonLines do
            draw.outline.Visible, draw.fill.Visible = false, false
        end
    end

    
    if L.Chams then
        local highlight = esp.chamHighlight
        if not highlight or highlight.Parent == nil then
            highlight = Instance.new("Highlight")
            highlight.Name = "RoxyCham"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            pcall(function() highlight.Parent = model end)
            esp.chamHighlight = highlight
        end
        highlight.FillColor = L.ChamsColor
        highlight.FillTransparency = 1 - (1 - L.ChamsTrans) * esp.opacity
        highlight.OutlineColor = L.ChamsOutlineColor
        highlight.OutlineTransparency = 1 - (1 - L.ChamsOutlineTrans) * esp.opacity
        highlight.Enabled = true
    else
        if esp.chamHighlight then esp.chamHighlight.Enabled = false end
    end
end

drawHealthBar = function(esp, humanoid, box, currentFont, currentFontSize, now, dt)
    local maxHealth = humanoid.MaxHealth
    local health = math.clamp(humanoid.Health, 0, maxHealth)
    local healthPercentage = health / maxHealth
    if not esp.healthLerp then esp.healthLerp = healthPercentage end
    esp.healthLerp = esp.healthLerp + (healthPercentage - esp.healthLerp) * math.min(1, dt * 10)
    local barX = math.floor(box.x) - (L.HBarOffset or 5)
    local barY = math.floor(box.y)
    local barW = L.HBarThickness or 2
    local barH = math.floor(box.h)
    esp.healthOutlineBg.Visible = false
    local filledH = math.max(1, math.floor(barH * esp.healthLerp))
    local filledY = barY + (barH - filledH)
    esp.healthOutline.Filled = false
    esp.healthOutline.Thickness = 1
    esp.healthOutline.Size = Vector2.new(barW + 2, filledH + 2)
    esp.healthOutline.Position = Vector2.new(barX - 1, filledY - 1)
    esp.healthOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.healthOutline.Transparency = esp.opacity
    esp.healthOutline.Visible = true

    if not L.HGrad then
        local sq = esp.healthLines[1]
        if sq then
            sq.Size = Vector2.new(barW, filledH)
            sq.Position = Vector2.new(barX, filledY)
            sq.Transparency = esp.opacity
            sq.Color = blend3Colors(L.HLC, L.HMC or Color3.fromRGB(255, 255, 0), L.HHC, esp.healthLerp)
            sq.Visible = true
        end
        for i = 2, #esp.healthLines do
            local sq = esp.healthLines[i]
            if sq then sq.Visible = false end
        end
    else
        local maxSegs = math.min(60, filledH)
        local animTime = L.HGradAnim and (now * (L.HGradAnimSpeed or 1)) or 0
        for i = 1, maxSegs do
            local sq = esp.healthLines[i]
            if sq then
                local segTop = math.floor(filledY + (i - 1) / maxSegs * filledH)
                local segBot = math.floor(filledY + i / maxSegs * filledH)
                local segH = math.max(1, segBot - segTop)
                sq.Size = Vector2.new(barW, segH)
                sq.Position = Vector2.new(barX, segTop)
                sq.Transparency = esp.opacity
                local t = 1 - ((i - 0.5) / maxSegs)
                if L.HGradAnim then
                    local style = L.HGradAnimStyle
                    if style == "Orbit" then t = (t - animTime * 0.2) % 1
                    elseif style == "Helix" then t = math.clamp(t + math.sin(animTime * 1.5) * 0.15, 0, 1)
                    elseif style == "Stream" then t = math.sin(t * math.pi + animTime * 0.5) * 0.5 + 0.5
                    elseif style == "Flux" then t = math.clamp(t + math.sin(t * 3 + animTime) * 0.1, 0, 1)
                    elseif style == "Nova" then t = math.clamp(t + math.cos(animTime * 0.8) * 0.2, 0, 1)
                    elseif style == "Drift" then t = (t + animTime * 0.05) % 1 end
                end
                sq.Color = blend3Colors(L.HLC, L.HMC or Color3.fromRGB(255, 255, 0), L.HHC, t)
                sq.Visible = true
            end
        end
        for i = maxSegs + 1, #esp.healthLines do
            local sq = esp.healthLines[i]
            if sq then sq.Visible = false end
        end
    end

    if L.HTE and healthPercentage < 0.99 then
        local hpText = tostring(math.floor(healthPercentage * 100))
        esp.gradHealth = drawEspLabel(esp.healthText, esp.gradHealth, hpText, barX - 15, filledY - 2, currentFontSize - 2, currentFont, esp.opacity, L.HTC, false, G.textGradPhase)
    else
        esp.healthText.Visible = false
        hideGradPool(esp.gradHealth)
    end
end

local function onRender(dt)
local now = os.clock()
dt = math.clamp(tonumber(dt) or 0, 0, 0.05)

if L.TextGradRot then
    G.textGradPhase = (G.textGradPhase + dt * (L.TextGradSpeed or 1) * 0.12) % 1
else
    G.textGradPhase = 0
end

if L.BoxGradRot then
    G.boxGradPhase = (G.boxGradPhase + dt * (L.BoxGradSpeed or 1) * 0.12) % 1
else
    G.boxGradPhase = 0
end

if not L.Master then
    if G.masterWasOn then
        G.masterWasOn = false
        for _, esp in next, cache do
            hideESP(esp)
        end
    end
    return
end

G.masterWasOn = true

if now - G.playerScanTick > 0.15 then
    G.playerScanTick = now

    local active = {}
    local charactersFolder = WS:FindFirstChild("Characters")

    if charactersFolder then
        local lpChar = LP.Character

        for _, model in ipairs(charactersFolder:GetChildren()) do
            if model:IsA("Model") and model ~= lpChar and not NOOB_NAME_BLACKLIST[model.Name] then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")

                if humanoid and hrp and humanoid.Health > 0 then
                    active[model] = true
                end
            end
        end
    end

    G.cachedActiveTargets = active
end

    local activeTargets = G.cachedActiveTargets
    local targets = {}

    for model, esp in pairs(cache) do
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart")
        local isAlive = activeTargets[model] and humanoid and hrp and humanoid.Health > 0

        if isAlive then
            if esp.state == "fadeout" or esp.state == "dead" then
                esp.state = "fadein"
            end
            if esp.state == "fadein" then
                esp.opacity = math.min(1, esp.opacity + (dt / L.FadeIn))
                if esp.opacity >= 1 then esp.state = "active" end
            else
                esp.opacity = 1
            end
            targets[model] = true
        else
            if esp.state ~= "dead" then
                esp.state = "fadeout"
                esp.opacity = math.max(0, esp.opacity - (dt / L.FadeOut))
                if esp.opacity <= 0 then
                    esp.state = "dead"
                else
                    if hrp then targets[model] = true end
                end
            end
        end
    end

    for model in pairs(activeTargets) do
        if not cache[model] then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.Health > 0 then
                local esp = createESP(model)
                esp.opacity = 0
                esp.state = "fadein"
                targets[model] = true
            end
        end
    end

    for model, esp in pairs(cache) do
        if esp.state == "dead" or not model:IsDescendantOf(WS) then
            removeESP(model)
        end
    end

    local camPos = C.CFrame.Position
    local currentFont = tonumber(L.Font) or 2
    local currentFontSize = L.FS
    local needDraw = L.BE or L.BFE or L.NE or L.DE or L.WE or L.HE or L.Skel or L.Chams

    if needDraw then
        for model in next, targets do
            local esp = cache[model]
            if esp then
                drawModelESP(esp, model, camPos, currentFont, currentFontSize, now, dt)
            end
        end
    else
        for _, esp in next, cache do
            hideESP(esp)
        end
    end

    G.gradPoolTrimTick += dt
    if G.gradPoolTrimTick >= 45 then
        G.gradPoolTrimTick = 0
        for _, esp in pairs(cache) do
            trimGradPool(esp.gradName, G.TEXT_GRAD_MAX_SLOTS)
            trimGradPool(esp.gradWeapon, G.TEXT_GRAD_MAX_SLOTS)
            trimGradPool(esp.gradDist, G.TEXT_GRAD_MAX_SLOTS)
            trimGradPool(esp.gradHealth, G.TEXT_GRAD_MAX_SLOTS)
        end
    end
end

local renderConnection = RS.RenderStepped:Connect(onRender)
G.cache, G.renderConnection, G.removeESP = cache, renderConnection, removeESP

local RedirTabbox = Tabs.Combat:AddLeftTabbox()
local A           = RedirTabbox:AddTab("bullet redirection")
local KR_Tab      = RedirTabbox:AddTab("knife redirection")
local B           = Tabs.Combat:AddRightGroupbox('rage')

local REDIR_BONES = { "HumanoidRootPart", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local KNIFE_KEYWORDS = { "knife", "blade", "dagger", "cleaver", "machete", "sword", "axe", "throw" }
local GUN_KEYWORDS   = { "revolver", "pistol", "gun", "rifle", "shotgun", "smg" }

local function LP_getWeaponName()
    local name = LP.Name
    local vm   = WS:FindFirstChild("ViewModels")
    if not vm then return "None" end
    local prefix = name .. " - "
    for _, child in ipairs(vm:GetChildren()) do
        local cName = child.Name
        if cName:sub(1, #prefix) == prefix then
            local remaining = cName:sub(#prefix + 1)
            local parts = string.split(remaining, " - ")
            if parts[1] then return parts[1] end
        end
    end
    return "None"
end
local function LP_isHoldingKnife()
    local char = LP.Character
    if not char then
        return false
    end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()

            for _, kw in ipairs(KNIFE_KEYWORDS) do
                if n:find(kw, 1, true) then
                    return true
                end
            end

            for _, kw in ipairs(GUN_KEYWORDS) do
                if n:find(kw, 1, true) then
                    return false
                end
            end
        end
    end

    local weapon = LP_getWeaponName():lower()

    if weapon ~= "none" then
        for _, kw in ipairs(KNIFE_KEYWORDS) do
            if weapon:find(kw, 1, true) then
                return true
            end
        end

        for _, kw in ipairs(GUN_KEYWORDS) do
            if weapon:find(kw, 1, true) then
                return false
            end
        end
    end

    return false
end

local BR = {
    Enabled     = false,
    WallCheck   = true,
    ClosestPart = false,
    SilentBone  = "HumanoidRootPart",
    HitChance   = 100,
    MaxDist     = 350,
    FOVVisible  = false,
    FOVColor    = Color3.fromRGB(255, 255, 255),
    FOVSize     = 120,
    FOVPosition = "Mouse",
    Snapline    = false,
    SnapColor   = Color3.fromRGB(255, 255, 255),
    SnapFrom    = "Mouse",
    Manipulate  = false,
}

local KR = {
    Enabled     = false,
    WallCheck   = true,
    ClosestPart = false,
    SilentBone  = "HumanoidRootPart",
    HitChance   = 100,
    MaxDist     = 350,
    FOVVisible  = false,
    FOVColor    = Color3.fromRGB(255, 255, 255),
    FOVSize     = 120,
    FOVPosition = "Mouse",
    Snapline    = false,
    SnapColor   = Color3.fromRGB(255, 255, 255),
    SnapFrom    = "Mouse",
    Manipulate  = false,
}

local BR_RayParams = RaycastParams.new()
BR_RayParams.FilterType = Enum.RaycastFilterType.Exclude

local KR_RayParams = RaycastParams.new()
KR_RayParams.FilterType = Enum.RaycastFilterType.Exclude

local SharedFovOutline = Drawing.new("Circle")
SharedFovOutline.Thickness = 3
SharedFovOutline.Color     = Color3.fromRGB(0, 0, 0)
SharedFovOutline.Filled    = false
SharedFovOutline.Visible   = false
SharedFovOutline.ZIndex    = 9

local SharedFovCircle = Drawing.new("Circle")
SharedFovCircle.Thickness = 1
SharedFovCircle.Filled    = false
SharedFovCircle.Visible   = false
SharedFovCircle.ZIndex    = 10

local SharedSnapOutline = Drawing.new("Line")
SharedSnapOutline.Thickness = 3
SharedSnapOutline.Color     = Color3.fromRGB(0, 0, 0)
SharedSnapOutline.Visible   = false
SharedSnapOutline.ZIndex    = 9

local SharedSnapLine = Drawing.new("Line")
SharedSnapLine.Thickness = 1
SharedSnapLine.Visible   = false
SharedSnapLine.ZIndex    = 10

local _lerpRadius = 120
local _lerpColor  = Color3.fromRGB(255, 255, 255)

local function REDIR_getFovOrigin(cfg, cam)
    local pos = tostring(cfg.FOVPosition or "Mouse")

    if pos == "Mouse" then
        local mp = UIS:GetMouseLocation()
        return Vector2.new(mp.X, mp.Y)
    end

    return Vector2.new(
        cam.ViewportSize.X * 0.5,
        cam.ViewportSize.Y * 0.5
    )
end

local function REDIR_getSnapFrom(cfg, cam)
    local mp = UIS:GetMouseLocation()
    local sf = cfg.SnapFrom
    if sf == "Mouse"  then return Vector2.new(mp.X, mp.Y) end
    if sf == "Bottom" then return Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y) end
    if sf == "Top"    then return Vector2.new(cam.ViewportSize.X * 0.5, 0) end
    return Vector2.new(mp.X, mp.Y)
end

local function REDIR_closestPart(cfg, model, cam, screenPt)
    local best, bestDist = nil, math.huge
    for _, boneName in ipairs(REDIR_BONES) do
        local part = model:FindFirstChild(boneName)
        if part then
            local sPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(sPos.X, sPos.Y) - screenPt).Magnitude
                if d < bestDist then
                    bestDist = d
                    best     = part
                end
            end
        end
    end
    return best
end

local BR_scanTick, BR_cachedTarget = 0, nil
local KR_scanTick, KR_cachedTarget = 0, nil

local function REDIR_getTarget(cfg, scanTick, cachedTarget, getFovOrigin)
    local now = os.clock()
    if now - scanTick < 0.05 and cachedTarget then
        local hum = cachedTarget:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return cachedTarget, scanTick end
        cachedTarget = nil
    end
    scanTick = now

    local cam     = WS.CurrentCamera
    local origin  = getFovOrigin(cfg, cam)
    local lpChar  = LP.Character
    local camPos  = cam.CFrame.Position
    local bestDist, bestModel = math.huge, nil

    local chars = WS:FindFirstChild("Characters")
    if chars then
        for _, model in ipairs(chars:GetChildren()) do
            if model:IsA("Model") and model ~= lpChar and not NOOB_NAME_BLACKLIST[model.Name] then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local wDist = (camPos - hrp.Position).Magnitude
                    if wDist <= cfg.MaxDist then
                        local sPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local sDist = (Vector2.new(sPos.X, sPos.Y) - origin).Magnitude
                            if sDist <= cfg.FOVSize and sDist < bestDist then
                                bestDist  = sDist
                                bestModel = model
                            end
                        end
                    end
                end
            end
        end
    end

    return bestModel, scanTick
end
local function BR_getTarget()
    local t, tick = REDIR_getTarget(BR, BR_scanTick, BR_cachedTarget, REDIR_getFovOrigin)
    BR_scanTick, BR_cachedTarget = tick, t
    return t
end

local function KR_getTarget()
    local t, tick = REDIR_getTarget(KR, KR_scanTick, KR_cachedTarget, REDIR_getFovOrigin)
    KR_scanTick, KR_cachedTarget = tick, t
    return t
end

local function BR_resolveBone(target, cam, screenOrigin)
    if BR.ClosestPart then return REDIR_closestPart(BR, target, cam, screenOrigin) end
    return target:FindFirstChild(BR.SilentBone) or target:FindFirstChild("HumanoidRootPart")
end

local function KR_resolveBone(target, cam, screenOrigin)
    if KR.ClosestPart then return REDIR_closestPart(KR, target, cam, screenOrigin) end
    return target:FindFirstChild(KR.SilentBone) or target:FindFirstChild("HumanoidRootPart")
end

local function BR_hasLOS(targetModel, targetPart)
    BR_RayParams.FilterDescendantsInstances = { LP.Character, targetModel }
    local camPos = WS.CurrentCamera.CFrame.Position
    return WS.Raycast(WS, camPos, targetPart.Position - camPos, BR_RayParams) == nil
end

local function KR_hasLOS(targetModel, targetPart)
    local char = LP.Character
    if not char then return false end
    local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart")
    if not hand then return false end
    KR_RayParams.FilterDescendantsInstances = { char, targetModel }
    return WS.Raycast(WS, hand.Position, targetPart.Position - hand.Position, KR_RayParams) == nil
end

local BR_Connection
local function BR_connect()
    if BR_Connection then return end
    BR_Connection = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not BR.Enabled then return end
        if BR.Manipulate then return end
        if BR.HitChance < 100 and math.random(1, 100) > BR.HitChance then return end
        local target = BR_getTarget()
        if not target then return end
        local cam          = WS.CurrentCamera
        local screenOrigin = REDIR_getFovOrigin(BR, cam)
        local bone         = BR_resolveBone(target, cam, screenOrigin)
        if not bone then return end
        if BR.WallCheck and not BR_hasLOS(target, bone) then return end
        cam.CFrame = CFrame.new(cam.CFrame.Position, bone.Position)
    end)
end

local function BR_disconnect()
    if BR_Connection then BR_Connection:Disconnect(); BR_Connection = nil end
    BR_cachedTarget = nil
end

local KR_Connection

local currentKnifeTarget = nil
local currentKnifeChanceSucceeded = false
local currentKnifeLockTick = 0

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    local self = args[1]

    if self == workspace and KR.Enabled and currentKnifeTarget then
        
        if (os.clock() - currentKnifeLockTick) < 2.0 and currentKnifeChanceSucceeded then
            if method == "Raycast" then
                local origin = args[2]
                if typeof(origin) == "Vector3" then
                    local dir = (currentKnifeTarget.Position - origin)
                    if dir.Magnitude > 0 then
                        args[3] = dir.Unit * 1000
                        return oldNamecall(unpack(args))
                    end
                end
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" or method == "findPartOnRay" then
                local a_ray = args[2]
                if typeof(a_ray) == "Ray" then
                    local origin = a_ray.Origin
                    local dir = (currentKnifeTarget.Position - origin).Unit * 1000
                    args[2] = Ray.new(origin, dir)
                    return oldNamecall(unpack(args))
                end
            end
        end
    elseif method == "FireServer" and self and typeof(self) == "Instance" and self.Name == "ShootReplicate" then
        local packet = args[2]
        if BR.Enabled and BR.Manipulate and typeof(packet) == "table" then
            local chance = BR.HitChance or 100
            if math.random(1, 100) <= chance then
                local cam          = WS.CurrentCamera
                local screenOrigin = REDIR_getFovOrigin(BR, cam)
                local target       = BR_getTarget()
                if target then
                    local bone = BR_resolveBone(target, cam, screenOrigin)
                    if bone then
                        local newPacket = {}
                        for k, v in pairs(packet) do
                            newPacket[k] = v
                        end
                        newPacket.hitPos = bone.Position
                        newPacket.to = bone.Position
                        newPacket.hitInstance = bone
                        newPacket.isCharacterHit = true
                        
                        args[2] = newPacket
                        return oldNamecall(unpack(args))
                    end
                end
            end
        end
    end
    return oldNamecall(...)
end))

local KR_Connection
local function KR_connect()
    if KR_Connection then return end
    KR_Connection = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not KR.Enabled then return end
        
        currentKnifeChanceSucceeded = (math.random(1, 100) <= (KR.HitChance or 100))
        currentKnifeLockTick = os.clock()
        
        local cam = WS.CurrentCamera
        local screenOrigin = REDIR_getFovOrigin(KR, cam)
        local target = KR_getTarget()
        
        if target then
            local bone = KR_resolveBone(target, cam, screenOrigin)
            if bone and (not KR.WallCheck or KR_hasLOS(target, bone)) then
                currentKnifeTarget = bone
            else
                currentKnifeTarget = nil
            end
        else
            currentKnifeTarget = nil
        end
        
        if not KR.Manipulate and currentKnifeChanceSucceeded and currentKnifeTarget then
            cam.CFrame = CFrame.new(cam.CFrame.Position, currentKnifeTarget.Position)
        end
    end)
end

local function KR_disconnect()
    if KR_Connection then KR_Connection:Disconnect(); KR_Connection = nil end
    currentKnifeTarget = nil
end

local REDIR_RenderConn
local REDIR_fovPriority = nil  

local function REDIR_updateFovPriority(side, enabled)
    if enabled then
        if REDIR_fovPriority == nil then
            REDIR_fovPriority = side
        end
    else
        
        if REDIR_fovPriority == side then
            REDIR_fovPriority = nil
            
            if side == "BR" and KR.FOVVisible then
                REDIR_fovPriority = "KR"
            elseif side == "KR" and BR.FOVVisible then
                REDIR_fovPriority = "BR"
            end
        end
    end
end

local function REDIR_startVisuals()
    if G.redirVisuals then
        G.redirVisuals:Disconnect()
    end

    G.redirVisuals = RS.RenderStepped:Connect(function(dt)
        local cam = C

        
        
        
        
        local knifeActive = KR.Enabled and LP_isHoldingKnife()
        local bulletActive = BR.Enabled and not knifeActive

        local activeCfg
        local getTarget
        local resolveBone

        if knifeActive then
            activeCfg   = KR
            getTarget   = KR_getTarget
            resolveBone = KR_resolveBone
        elseif bulletActive then
            activeCfg   = BR
            getTarget   = BR_getTarget
            resolveBone = BR_resolveBone
        else
            SharedFovOutline.Visible  = false
            SharedFovCircle.Visible   = false
            SharedSnapOutline.Visible = false
            SharedSnapLine.Visible    = false
            return
        end

        if not activeCfg.FOVVisible then
            SharedFovOutline.Visible  = false
            SharedFovCircle.Visible   = false
            SharedSnapOutline.Visible = false
            SharedSnapLine.Visible    = false
            return
        end

        local wantFov  = true  
        local wantSnap = activeCfg.Snapline

        local targetRadius = activeCfg.FOVSize
        local targetColor  = activeCfg.FOVColor
        local snapColor    = activeCfg.SnapColor

        local lerpSpeed = math.min(1, dt * 14)
        _lerpRadius = _lerpRadius + (targetRadius - _lerpRadius) * lerpSpeed
        _lerpColor  = _lerpColor:Lerp(targetColor, lerpSpeed)

        local fovOrigin = REDIR_getFovOrigin(activeCfg, cam)

        SharedFovOutline.Position = fovOrigin
        SharedFovCircle.Position  = fovOrigin
        SharedFovOutline.Radius   = _lerpRadius
        SharedFovCircle.Radius    = _lerpRadius
        SharedFovCircle.Color     = _lerpColor

        SharedFovOutline.Visible = true
        SharedFovCircle.Visible  = true

        if wantSnap then
            local target = getTarget()
            if target then
                local bone = resolveBone(target, cam, fovOrigin)
                if bone then
                    local pos, visible = cam:WorldToViewportPoint(bone.Position)
                    if visible then
                        local snapFrom = REDIR_getSnapFrom(activeCfg, cam)
                        local toPos    = Vector2.new(pos.X, pos.Y)

                        SharedSnapOutline.From    = snapFrom
                        SharedSnapOutline.To      = toPos
                        SharedSnapOutline.Visible = true

                        SharedSnapLine.From    = snapFrom
                        SharedSnapLine.To      = toPos
                        SharedSnapLine.Color   = snapColor
                        SharedSnapLine.Visible = true
                        return
                    end
                end
            end
        end

        SharedSnapOutline.Visible = false
        SharedSnapLine.Visible    = false
    end)
end

REDIR_startVisuals()

local BR_MasterToggle = A:AddToggle("BREnabled", {
    Text     = "bullet redirection",
    Default  = false,
    Callback = function(v)
        BR.Enabled = v
        if v then BR_connect() else BR_disconnect() end
    end
})

local D_BR = A:AddDependencyBox()
D_BR:SetupDependencies({{BR_MasterToggle, true}})

D_BR:AddToggle("BRWallCheck", {
    Text     = "wall check",
    Default  = true,
    Callback = function(v) BR.WallCheck = v end
})

local BR_ClosestToggle = D_BR:AddToggle("BRClosestPart", {
    Text     = "closest part",
    Default  = false,
    Callback = function(v)
        BR.ClosestPart  = v
        BR_cachedTarget = nil
    end
})

D_BR:AddToggle("BRManipulate", {
    Text     = "manipulate",
    Default  = false,
    Callback = function(v)
        BR.Manipulate = v
    end
})

do
local D_BR_Bone = D_BR:AddDependencyBox()
D_BR_Bone:SetupDependencies({{BR_ClosestToggle, false}})

D_BR_Bone:AddDropdown("BRSilentBone", {
    Values   = REDIR_BONES,
    Default  = 1,
    Multi    = false,
    Text     = "silent bone",
    Callback = function(v)
        BR.SilentBone   = v
        BR_cachedTarget = nil
    end
})
end

D_BR:AddSlider("BRHitChance", {
    Text     = "hit chance %",
    Default  = 100,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) BR.HitChance = v end
})

D_BR:AddSlider("BRMaxDist", {
    Text     = "max distance",
    Default  = 350,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) BR.MaxDist = v end
})

D_BR:AddDivider()

local BR_FovToggle = D_BR:AddToggle("BRFovVisible", {
    Text     = "fov visible",
    Default  = false,
    Callback = function(v)
        BR.FOVVisible = v
        REDIR_updateFovPriority("BR", v)
    end
})
BR_FovToggle:AddColorPicker("BRFovColor", {
    Default      = BR.FOVColor,
    Title        = "fov circle color",
    Transparency = 0,
    Callback     = function(c) BR.FOVColor = c end
})

do
local D_BR_FovOpts = D_BR:AddDependencyBox()
D_BR_FovOpts:SetupDependencies({{BR_FovToggle, true}})

D_BR_FovOpts:AddDropdown("BRFovPosition", {
    Values   = { "Mouse", "Center" },
    Default  = 1,
    Multi    = false,
    Text     = "fov position",
    Callback = function(v)
        BR.FOVPosition  = v
        BR_cachedTarget = nil
    end
})
end

local BR_SnapToggle = D_BR:AddToggle("BRSnapline", {
    Text     = "snapline",
    Default  = false,
    Callback = function(v) BR.Snapline = v end
})
BR_SnapToggle:AddColorPicker("BRSnapColor", {
    Default      = BR.SnapColor,
    Title        = "snapline color",
    Transparency = 0,
    Callback     = function(c) BR.SnapColor = c end
})

do
local D_BR_SnapOpts = D_BR:AddDependencyBox()
D_BR_SnapOpts:SetupDependencies({{BR_SnapToggle, true}})

D_BR_SnapOpts:AddDropdown("BRSnapFrom", {
    Values   = { "Mouse", "Bottom", "Top" },
    Default  = 1,
    Multi    = false,
    Text     = "snap from",
    Callback = function(v) BR.SnapFrom = v end
})
end

D_BR:AddSlider("BRFovSize", {
    Text     = "fov size",
    Default  = 120,
    Min      = 10,
    Max      = 500,
    Rounding = 0,
    Compact  = true,

    Callback = function(v)
        BR.FOVSize = v
    end
})

local KR_MasterToggle = KR_Tab:AddToggle("KREnabled", {
    Text     = "knife redirection",
    Default  = false,
    Callback = function(v)
        KR.Enabled = v
        if v then KR_connect() else KR_disconnect() end
    end
})

local D_KR = KR_Tab:AddDependencyBox()
D_KR:SetupDependencies({{KR_MasterToggle, true}})

D_KR:AddToggle("KRWallCheck", {
    Text     = "wall check",
    Default  = true,
    Callback = function(v) KR.WallCheck = v end
})

local KR_ClosestToggle = D_KR:AddToggle("KRClosestPart", {
    Text     = "closest part",
    Default  = false,
    Callback = function(v)
        KR.ClosestPart  = v
        KR_cachedTarget = nil
    end
})

do
local D_KR_Bone = D_KR:AddDependencyBox()
D_KR_Bone:SetupDependencies({{KR_ClosestToggle, false}})

D_KR_Bone:AddDropdown("KRSilentBone", {
    Values   = REDIR_BONES,
    Default  = 1,
    Multi    = false,
    Text     = "silent bone",
    Callback = function(v)
        KR.SilentBone   = v
        KR_cachedTarget = nil
    end
})
end

D_KR:AddSlider("KRHitChance", {
    Text     = "hit chance %",
    Default  = 100,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) KR.HitChance = v end
})

D_KR:AddSlider("KRMaxDist", {
    Text     = "max distance",
    Default  = 350,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) KR.MaxDist = v end
})

D_KR:AddDivider()

local KR_FovToggle = D_KR:AddToggle("KRFovVisible", {
    Text     = "fov visible",
    Default  = false,
    Callback = function(v)
        KR.FOVVisible = v
        REDIR_updateFovPriority("KR", v)
    end
})
KR_FovToggle:AddColorPicker("KRFovColor", {
    Default      = KR.FOVColor,
    Title        = "fov circle color",
    Transparency = 0,
    Callback     = function(c) KR.FOVColor = c end
})

do
local D_KR_FovOpts = D_KR:AddDependencyBox()
D_KR_FovOpts:SetupDependencies({{KR_FovToggle, true}})

D_KR_FovOpts:AddDropdown("KRFovPosition", {
    Values   = { "Mouse", "Center" },
    Default  = 1,
    Multi    = false,
    Text     = "fov position",
    Callback = function(v)
        KR.FOVPosition  = v
        KR_cachedTarget = nil
    end
})
end

local KR_SnapToggle = D_KR:AddToggle("KRSnapline", {
    Text     = "snapline",
    Default  = false,
    Callback = function(v) KR.Snapline = v end
})
KR_SnapToggle:AddColorPicker("KRSnapColor", {
    Default      = KR.SnapColor,
    Title        = "snapline color",
    Transparency = 0,
    Callback     = function(c) KR.SnapColor = c end
})

do
local D_KR_SnapOpts = D_KR:AddDependencyBox()
D_KR_SnapOpts:SetupDependencies({{KR_SnapToggle, true}})

D_KR_SnapOpts:AddDropdown("KRSnapFrom", {
    Values   = { "Mouse", "Bottom", "Top" },
    Default  = 1,
    Multi    = false,
    Text     = "snap from",
    Callback = function(v) KR.SnapFrom = v end
})
end

D_KR:AddSlider("KRFovSize", {
    Text     = "fov size",
    Default  = 120,
    Min      = 10,
    Max      = 500,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) KR.FOVSize = v end
})

local AS_BONES = { "HumanoidRootPart", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local AS = {
    Enabled   = false,
    WallCheck = true,
    TeamCheck = true,
    Delay     = false,
    DelayAmt  = 0.1,
    ChanceOn  = false,
    Chance    = 100,
    Bones     = {
        HumanoidRootPart = true,
        Head = true,
        Torso = true,
        ["Left Arm"] = true,
        ["Right Arm"] = true,
        ["Left Leg"] = true,
        ["Right Leg"] = true
    }
}

local AS_conn
local AS_lastShot  = 0
local AS_teamCache = {}
local AS_teamTick  = {}

local AS_RayParams = RaycastParams.new()
AS_RayParams.FilterType = Enum.RaycastFilterType.Exclude

local sqrt, clamp, random, clock = math.sqrt, math.clamp, math.random, os.clock
local GetMouse = LP.GetMouse

local function AS_isAlly(model)
    local now = clock()
    local tick = AS_teamTick[model]

    if tick and now - tick < 0.25 then
        return AS_teamCache[model]
    end

    local hrp = model:FindFirstChild("HumanoidRootPart")
    local ally = hrp and hrp:FindFirstChild("__AllyHeadBillboard") ~= nil or false

    AS_teamCache[model] = ally
    AS_teamTick[model] = now

    return ally
end

local function AS_hasLOS(camPos, targetModel, targetPart)
    AS_RayParams.FilterDescendantsInstances = { LP.Character, targetModel }
    return not WS:Raycast(camPos, targetPart.Position - camPos, AS_RayParams)
end

local function AS_click()
    local mouse = GetMouse(LP)

    if pcall(function()
        local svc = game:GetService("VirtualInputManager")
        svc:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
        svc:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
    end) then
        return
    end

    pcall(function()
        mouse.Button1Down:Fire()
        mouse.Button1Up:Fire()
    end)
end

local function AS_getHoveredTarget()
    local cam = WS.CurrentCamera
    local mouse = GetMouse(LP)

    local guiInset = game:GetService("GuiService"):GetGuiInset()

    local mouseX = mouse.X
    local mouseY = mouse.Y + guiInset.Y

    local lpChar = LP.Character

    local chars = WS:FindFirstChild("Characters")
    if not chars then
        return nil, nil
    end

    local bestModel, bestPart, bestDist = nil, nil, math.huge

    for _, model in ipairs(chars:GetChildren()) do
        if not model:IsA("Model") or model == lpChar or (NOOB_NAME_BLACKLIST and NOOB_NAME_BLACKLIST[model.Name]) then
            continue
        end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            continue
        end

        if AS.TeamCheck and AS_isAlly(model) then
            continue
        end

        for _, boneName in ipairs(AS_BONES) do
            if not AS.Bones[boneName] then
                continue
            end

            local part = model:FindFirstChild(boneName)
            if not part then
                continue
            end

            local screenPos, visible = cam:WorldToViewportPoint(part.Position)
            if not visible then
                continue
            end

            local dx = screenPos.X - mouseX
            local dy = screenPos.Y - mouseY
            local dist2d = sqrt(dx * dx + dy * dy)

            if dist2d <= 6 and dist2d < bestDist then
                bestDist = dist2d
                bestModel = model
                bestPart = part
            end
        end
    end

    return bestModel, bestPart
end
local function AS_start()
    if AS_conn then
        return
    end

    AS_conn = RS.Heartbeat:Connect(function()
        if not AS.Enabled then
            return
        end

        local now = clock()
        local delay = AS.Delay and ((Options.ASDelaySlider and Options.ASDelaySlider.Value) or AS.DelayAmt) or 0

        if now - AS_lastShot < delay then
            return
        end

        if AS.ChanceOn then
            local pct = (Options.ASChanceSlider and Options.ASChanceSlider.Value) or AS.Chance
            if random(1, 100) > pct then
                return
            end
        end

        local target, part = AS_getHoveredTarget()
        if not target or not part then
            return
        end

        if AS.WallCheck and not AS_hasLOS(WS.CurrentCamera.CFrame.Position, target, part) then
            return
        end

        AS_lastShot = now
        AS_click()
    end)
end

local function AS_stop()
    if AS_conn then
        AS_conn:Disconnect()
        AS_conn = nil
    end
end

local C_AS = Tabs.Combat:AddLeftGroupbox('auto shoot')

local AS_MasterToggle = C_AS:AddToggle("ASEnabled", {
    Text     = "auto shoot",
    Default  = false,
    Callback = function(v)
        AS.Enabled = v
        if v then AS_start() else AS_stop() end
    end
})
AS_MasterToggle:AddKeyPicker("ASKeybind", {
    Default  = "none",
    Text     = "auto shoot keybind",
    Callback = function(v)
        if v then Toggles.ASEnabled:SetValue(not Toggles.ASEnabled.Value) end
    end
})

local D_AS = C_AS:AddDependencyBox()
D_AS:SetupDependencies({{AS_MasterToggle, true}})

D_AS:AddToggle("ASWallCheck", {
    Text     = "wall check",
    Default  = true,
    Callback = function(v) AS.WallCheck = v end
})

D_AS:AddToggle("ASTeamCheck", {
    Text     = "team check",
    Default  = true,
    Callback = function(v) AS.TeamCheck = v end
})

local AS_DelayToggle = D_AS:AddToggle("ASDelay", {
    Text     = "delay",
    Default  = false,
    Callback = function(v) AS.Delay = v end
})

local D_ASDelay = D_AS:AddDependencyBox()
D_ASDelay:SetupDependencies({{AS_DelayToggle, true}})
D_ASDelay:AddSlider("ASDelaySlider", {
    Text     = "delay amount",
    Default  = 0.1,
    Min      = 0.05,
    Max      = 2,
    Rounding = 2,
    Compact  = true,
    Callback = function(v) AS.DelayAmt = v end
})

local AS_ChanceToggle = D_AS:AddToggle("ASChanceOn", {
    Text     = "shoot chance",
    Default  = false,
    Callback = function(v) AS.ChanceOn = v end
})

local D_ASChance = D_AS:AddDependencyBox()
D_ASChance:SetupDependencies({{AS_ChanceToggle, true}})
D_ASChance:AddSlider("ASChanceSlider", {
    Text     = "chance %",
    Default  = 100,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Compact  = true,
    Callback = function(v) AS.Chance = v end
})

D_AS:AddDropdown("ASBoneDropdown", {
    Values   = AS_BONES,
    Default  = AS_BONES,
    Multi    = true,
    Text     = "bone whitelist",
    Callback = function(v)
        AS.Bones = {}
        for bone, selected in next, v do
            if selected then AS.Bones[bone] = true end
        end
    end
})

B:AddToggle('KillAllToggle', {
    Text = 'kill all',
    Default = false,
    Blatant = true,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local Players = game:GetService("Players")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local LocalPlayer = Players.LocalPlayer
                local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ReportHit")
                while Toggles.KillAllToggle.Value do
                    local Character = LocalPlayer.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    local CharactersFolder = workspace:FindFirstChild("Characters")
                    if Root and CharactersFolder then
                        for _, targetModel in ipairs(CharactersFolder:GetChildren()) do
                            if targetModel ~= Character then
                                local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
                                local targetHead = targetModel:FindFirstChild("Head")
                                if targetRoot and targetHead then
                                    local distance = (Root.Position - targetRoot.Position).Magnitude
                                    if distance <= 350 then
                                        local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
                                        if targetPlayer then
                                            local origin = Root.Position
                                            local hitPos = targetHead.Position
                                            local velocity = (hitPos - origin).Unit * 200
                                            local args = {
                                                [1] = {
                                                    ["hitPos"] = hitPos,
                                                    ["ownerUserId"] = LocalPlayer.UserId,
                                                    ["origin"] = origin,
                                                    ["vel"] = velocity,
                                                    ["headshot"] = true,
                                                    ["targetUserId"] = targetPlayer.UserId,
                                                    ["targetModel"] = targetModel,
                                                    ["to"] = hitPos,
                                                    ["throwId"] = 1,
                                                    ["kind"] = "throw",
                                                    ["at"] = tick(),
                                                    ["hitPart"] = targetHead
                                                }
                                            }
                                            Remote:FireServer(unpack(args))
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

local MOV = Tabs.Combat:AddRightGroupbox('movement')

local _flyActive = false
local _flyConn
local _flyBodyVel, _flyBodyGyro

local function stopFly()
    _flyActive = false
    if _flyConn then _flyConn:Disconnect(); _flyConn = nil end
    if _flyBodyVel then pcall(function() _flyBodyVel:Destroy() end); _flyBodyVel = nil end
    if _flyBodyGyro then pcall(function() _flyBodyGyro:Destroy() end); _flyBodyGyro = nil end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startFly()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    _flyBodyVel = Instance.new("BodyVelocity")
    _flyBodyVel.Velocity = Vector3.zero
    _flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    _flyBodyVel.Parent = hrp
    _flyBodyGyro = Instance.new("BodyGyro")
    _flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    _flyBodyGyro.P = 1e4
    _flyBodyGyro.CFrame = hrp.CFrame
    _flyBodyGyro.Parent = hrp
    _flyActive = true
    _flyConn = RS.RenderStepped:Connect(function()
        if not _flyActive then return end
        local c = WS.CurrentCamera
        local spd = Options.FlySpeedSlider and Options.FlySpeedSlider.Value or 50
        local vel = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, 1, 0) end
        if vel.Magnitude > 0 then vel = vel.Unit * spd end
        if _flyBodyVel and _flyBodyVel.Parent then _flyBodyVel.Velocity = vel end
        if _flyBodyGyro and _flyBodyGyro.Parent then _flyBodyGyro.CFrame = c.CFrame end
    end)
end

local FlyToggle = MOV:AddToggle("FlyToggle", {
    Text = "fly",
    Default = false,
    Callback = function(v)
        if v then startFly() else stopFly() end
    end
})
FlyToggle:AddKeyPicker("FlyKeybind", {
    Default = "none",
    Text = "fly keybind",
    Callback = function(v)
        if v then
            local cur = Toggles.FlyToggle.Value
            Toggles.FlyToggle:SetValue(not cur)
        end
    end
})

do
local D_FlySpeed = MOV:AddDependencyBox()
D_FlySpeed:SetupDependencies({{FlyToggle, true}})
D_FlySpeed:AddSlider("FlySpeedSlider", {
    Text = "speed amount",
    Default = 50,
    Min = 5,
    Max = 300,
    Rounding = 0,
    Compact = true,
    Callback = function(v) end
})
end

local _walkspeedActive = false
local _wsConn

local function stopWalkspeed()
    _walkspeedActive = false
    if _wsConn then _wsConn:Disconnect(); _wsConn = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

local function startWalkspeed()
    _walkspeedActive = true
    _wsConn = RS.RenderStepped:Connect(function()
        if not _walkspeedActive then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local spd = Options.WalkSpeedSlider and Options.WalkSpeedSlider.Value or 50
        if hum then hum.WalkSpeed = spd end
    end)
end

local SpeedToggle = MOV:AddToggle("SpeedToggle", {
    Text = "speed",
    Default = false,
    Callback = function(v)
        if v then startWalkspeed() else stopWalkspeed() end
    end
})
SpeedToggle:AddKeyPicker("SpeedKeybind", {
    Default = "none",
    Text = "speed keybind",
    Callback = function(v)
        if v then
            local cur = Toggles.SpeedToggle.Value
            Toggles.SpeedToggle:SetValue(not cur)
        end
    end
})

do
local D_WalkSpeed = MOV:AddDependencyBox()
D_WalkSpeed:SetupDependencies({{SpeedToggle, true}})
D_WalkSpeed:AddSlider("WalkSpeedSlider", {
    Text = "speed amount",
    Default = 50,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        if _walkspeedActive then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})
end

MOV:AddToggle("NoclipToggle", {
    Text = "noclip",
    Default = false,
    Callback = function(v)
        if v then
            RS.Stepped:Connect(function()
                if not Toggles.NoclipToggle.Value then return end
                local char = LP.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

MOV:AddToggle("InfJumpToggle", {
    Text = "inf jump",
    Default = false,
    Callback = function(v) end
})

UIS.JumpRequest:Connect(function()
    if Toggles.InfJumpToggle and Toggles.InfJumpToggle.Value then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local _spinConn

local SpinToggle = MOV:AddToggle("SpinToggle", {
    Text = "spin",
    Default = false,
    Callback = function(v)
        if v then
            _spinConn = RS.RenderStepped:Connect(function(dt)
                if not Toggles.SpinToggle.Value then return end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local spd = Options.SpinSpeedSlider and Options.SpinSpeedSlider.Value or 10
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spd), 0)
                end
            end)
        else
            if _spinConn then _spinConn:Disconnect(); _spinConn = nil end
        end
    end
})

do
local D_SpinSpeed = MOV:AddDependencyBox()
D_SpinSpeed:SetupDependencies({{SpinToggle, true}})
D_SpinSpeed:AddSlider("SpinSpeedSlider", {
    Text = "speed",
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = true,
    Callback = function(v) end
})
end

local PlayerESPTabbox = Tabs.Visuals:AddLeftTabbox()
local PlayerESPGroup = PlayerESPTabbox:AddTab("player esp")

local ME = PlayerESPGroup:AddToggle('MasterESP', {
    Text = 'enable esp',
    Default = false,
    Callback = function(v)
        L.Master = v
    end
})

local D_Box = PlayerESPGroup:AddDependencyBox()
D_Box:SetupDependencies({{ME, true}})

local BV = D_Box:AddToggle("BoxESP", {
    Text = "box",
    Default = false,
    Callback = function(v)
        L.BE = v
    end
})
BV:AddColorPicker("BoxESPColor", {
    Default = L.BC,
    Title = "box color",
    Transparency = 0,
    Callback = function(c)
        L.BC = c
    end
})

local D_BoxOpts = D_Box:AddDependencyBox()
D_BoxOpts:SetupDependencies({{BV, true}})

D_BoxOpts:AddDropdown("BoxTypeDropdown", {
    Values = {"Full", "Corners"},
    Default = 1,
    Multi = false,
    Text = "type",
    Callback = function(v)
        L.BoxType = v
    end
})

local BGV = D_BoxOpts:AddToggle("BoxGradient", {
    Text = "box gradient",
    Default = false,
    Tooltip = "50% color 1 on the left, 50% color 2 on the right, blended in the middle.",
    Callback = function(v)
        L.BoxGrad = v
    end
})
BGV:AddColorPicker("BoxGradColor1", {
    Default = L.BoxGrad1,
    Title = "box gradient color 1",
    Callback = function(v)
        L.BoxGrad1 = v
    end
})
BGV:AddColorPicker("BoxGradColor2", {
    Default = L.BoxGrad2,
    Title = "box gradient color 2",
    Callback = function(v)
        L.BoxGrad2 = v
    end
})

local BGRV = D_BoxOpts:AddToggle("BoxGradRotation", {
    Text = "gradient rotation",
    Default = false,
    Callback = function(v)
        L.BoxGradRot = v
    end
})

do
local D_BoxGradSpeed = D_BoxOpts:AddDependencyBox()
D_BoxGradSpeed:SetupDependencies({{BGRV, true}})

D_BoxGradSpeed:AddSlider("BoxGradRotSpeed", {
    Text = "rotation speed",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        L.BoxGradSpeed = v
    end
})
end

local D_BoxSub = PlayerESPGroup:AddDependencyBox()
D_BoxSub:SetupDependencies({{ME, true}, {BV, true}})

D_BoxSub:AddToggle("BoxFillToggle", {
    Text = "box fill",
    Default = false,
    Callback = function(v)
        L.BFE = v
    end
}):AddColorPicker("BoxFillColorPicker", {
    Default = L.BFC,
    Title = "box fill color",
    Transparency = 0.5,
    Callback = function(c)
        L.BFC = c
        if Options.BoxFillColorPicker then
            L.BFTrans = Options.BoxFillColorPicker.Transparency or 0.5
        end
    end
})

local D_Name = PlayerESPGroup:AddDependencyBox()
D_Name:SetupDependencies({{ME, true}})

local NV = D_Name:AddToggle('ShowPlayerTags', {
    Text = 'name',
    Default = false,
    Callback = function(v)
        L.NE = v
    end
})
NV:AddColorPicker('NameTagColor', {
    Default = L.NTC,
    Title = 'name text color',
    Transparency = 0,
    Callback = function(c)
        L.NTC = c
    end
})

local NameStyleDropdown
do
local D_NameSub = PlayerESPGroup:AddDependencyBox()
D_NameSub:SetupDependencies({{ME, true}, {NV, true}})

NameStyleDropdown = D_NameSub:AddDropdown('NameStyleDropdown', {
    Values = {'Username', 'DisplayName', 'Custom'},
    Default = 1,
    Multi = false,
    Text = 'name type',
    Callback = function(v)
        L.NameStyle = v
    end
})
end

local D_CustomName = PlayerESPGroup:AddDependencyBox()
D_CustomName:SetupDependencies({{ME, true}, {NV, true}, {NameStyleDropdown, 'Custom'}})

D_CustomName:AddInput('CustomNameInput', {
    Text = 'custom name',
    Default = '.gg/',
    Placeholder = '.gg/...',
    Numeric = false,
    Finished = false,
    Callback = function(v)
        L.CustomName = v
    end
})

local D_Health = PlayerESPGroup:AddDependencyBox()
D_Health:SetupDependencies({{ME, true}})

local HV = D_Health:AddToggle("HealthESP", {
    Text = "health",
    Default = false,
    Callback = function(v)
        L.HE = v
    end
})
HV:AddColorPicker("HealthESPHigh", {
    Default = L.HHC,
    Title = "high health color",
    Callback = function(c)
        L.HHC = c
    end
}):AddColorPicker("HealthESPMid", {
    Default = L.HMC,
    Title = "mid health color",
    Callback = function(c)
        L.HMC = c
    end
}):AddColorPicker("HealthESPLow", {
    Default = L.HLC,
    Title = "low health color",
    Callback = function(c)
        L.HLC = c
    end
})

local D_HealthSub = PlayerESPGroup:AddDependencyBox()
D_HealthSub:SetupDependencies({{ME, true}, {HV, true}})

local HGradToggle = D_HealthSub:AddToggle("HealthGradientToggle", {
    Text = "health gradient",
    Default = false,
    Callback = function(v)
        L.HGrad = v
    end
})

local HGradAnimToggle
do
local D_HGradSub = PlayerESPGroup:AddDependencyBox()
D_HGradSub:SetupDependencies({{ME, true}, {HV, true}, {HGradToggle, true}})

HGradAnimToggle = D_HGradSub:AddToggle("HGradAnim", {
    Text = "gradient animation",
    Default = false,
    Callback = function(v) L.HGradAnim = v end
})
end

do
local D_HGradAnimSub = PlayerESPGroup:AddDependencyBox()
D_HGradAnimSub:SetupDependencies({{ME, true}, {HV, true}, {HGradToggle, true}, {HGradAnimToggle, true}})

D_HGradAnimSub:AddSlider("HGradAnimSpeed", {
    Text = "animation speed",
    Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = true,
    Callback = function(v) L.HGradAnimSpeed = v end
})

D_HGradAnimSub:AddDropdown("HGradAnimStyle", {
    Values = { 'Orbit', 'Helix', 'Stream', 'Flux', 'Nova', 'Drift' },
    Default = 1, Multi = false, Text = 'animation style',
    Callback = function(v) L.HGradAnimStyle = v end
})
end

do
local D_HealthTextSub = PlayerESPGroup:AddDependencyBox()
D_HealthTextSub:SetupDependencies({{ME, true}, {HV, true}})

D_HealthTextSub:AddToggle("HealthTextToggle", {
    Text = "health text",
    Default = false,
    Callback = function(v)
        L.HTE = v
    end
}):AddColorPicker("HealthTextColor", {
    Default = L.HTC,
    Title = "health text color",
    Callback = function(c)
        L.HTC = c
    end
})
end

do
local D_HealthBarOptions = PlayerESPGroup:AddDependencyBox()
D_HealthBarOptions:SetupDependencies({{ME, true}, {HV, true}})

D_HealthBarOptions:AddSlider("HBarThickness", {
    Text = "healthbar thickness",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        L.HBarThickness = v
    end
})

D_HealthBarOptions:AddSlider("HBarOffset", {
    Text = "healthbar offset",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        L.HBarOffset = v
    end
})
end

local D_Chams = PlayerESPGroup:AddDependencyBox()
D_Chams:SetupDependencies({{ME, true}})

local CV = D_Chams:AddToggle("ChamsESP", {
    Text = "chams",
    Default = false,
    Callback = function(v)
        L.Chams = v
    end
})
CV:AddColorPicker("ChamsColor", {
    Default = L.ChamsColor,
    Title = "fill color",
    Transparency = 0.5,
    Callback = function(c)
        L.ChamsColor = c
        if Options.ChamsColor then
            L.ChamsTrans = Options.ChamsColor.Transparency or 0.5
        end
    end
})
CV:AddColorPicker("ChamsOutlineColor", {
    Default = L.ChamsOutlineColor,
    Title = "outline color",
    Transparency = 0.0,
    Callback = function(c)
        L.ChamsOutlineColor = c
        if Options.ChamsOutlineColor then
            L.ChamsOutlineTrans = Options.ChamsOutlineColor.Transparency or 0.0
        end
    end
})

local D_Dist = PlayerESPGroup:AddDependencyBox()
D_Dist:SetupDependencies({{ME, true}})

local CE2 = D_Dist:AddToggle('DistanceESP', {
    Text = 'distance',
    Default = false,
    Callback = function(v)
        L.DE = v
    end
})
CE2:AddColorPicker("DistanceESPCP", {
    Default = L.DTC,
    Title = "distance color",
    Callback = function(v)
        L.DTC = v
    end
})

do
local D_DistSub = PlayerESPGroup:AddDependencyBox()
D_DistSub:SetupDependencies({{ME, true}, {CE2, true}})

D_DistSub:AddDropdown('DistanceMode', {
    Values = {'Studs', 'Meters'},
    Default = 1,
    Multi = false,
    Text = 'measuring mode',
    Callback = function(v)
        L.DistMode = v
    end
})
end

local D_Weapon = PlayerESPGroup:AddDependencyBox()
D_Weapon:SetupDependencies({{ME, true}})

local WE2 = D_Weapon:AddToggle('WeaponESP', {
    Text = 'weapon',
    Default = false,
    Callback = function(v)
        L.WE = v
    end
})
WE2:AddColorPicker("WeaponESPCP", {
    Default = L.WTC,
    Title = "weapon color",
    Callback = function(v)
        L.WTC = v
    end
})

local D_Skel = PlayerESPGroup:AddDependencyBox()
D_Skel:SetupDependencies({{ME, true}})

local SV = D_Skel:AddToggle("SkeletonESP", {
    Text = "skeleton",
    Default = false,
    Callback = function(v)
        L.Skel = v
    end
})
SV:AddColorPicker("SkeletonColor", {
    Default = L.SkelColor,
    Title = "skeleton color",
    Transparency = 0.0,
    Callback = function(c)
        L.SkelColor = c
        if Options.SkeletonColor then
            L.SkelTrans = Options.SkeletonColor.Transparency or 0.0
        end
    end
})

local D_Misc = PlayerESPGroup:AddDependencyBox()
D_Misc:SetupDependencies({{ME, true}})

D_Misc:AddDivider()

local TGV = D_Misc:AddToggle("TextGradient", {
    Text = "text gradient",
    Default = false,
    Callback = function(v)
        L.TextGradient = v
    end
})
TGV:AddColorPicker("TextGradColor1", {
    Default = L.TextGradColor1,
    Title = "gradient color 1",
    Callback = function(v)
        L.TextGradColor1 = v
    end
})
TGV:AddColorPicker("TextGradColor2", {
    Default = L.TextGradColor2,
    Title = "gradient color 2",
    Callback = function(v)
        L.TextGradColor2 = v
    end
})

do
local D_TextGradType = D_Misc:AddDependencyBox()
D_TextGradType:SetupDependencies({{TGV, true}})
D_TextGradType:AddDropdown("TextGradType", {
    Values = { "String", "Character" },
    Default = 1,
    Multi = false,
    Text = "gradient type",
    Callback = function(v)
        L.TextGradType = v
    end,
})
end

local D_TextGradRot = D_Misc:AddDependencyBox()
D_TextGradRot:SetupDependencies({{TGV, true}})

local TGRV = D_TextGradRot:AddToggle("TextGradRotation", {
    Text = "gradient rotation",
    Default = false,
    Callback = function(v)
        L.TextGradRot = v
    end
})

do
local D_TextGradSpeed = D_TextGradRot:AddDependencyBox()
D_TextGradSpeed:SetupDependencies({{TGRV, true}})

D_TextGradSpeed:AddSlider("TextGradRotSpeed", {
    Text = "rotation speed",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        L.TextGradSpeed = v
    end
})
end

D_Misc:AddDropdown('FontTypeDropdown', {
    Values = {'UI', 'System', 'Plex', 'Monospace'},
    Default = 3,
    Multi = false,
    Text = 'font type',
    Callback = function(v)
        L.Font = G.FM[v] or 2
    end
})
D_Misc:AddDropdown('FontCaseDropdown', {
    Values = {'Normal', 'Lowercase', 'Uppercase'},
    Default = 1,
    Multi = false,
    Text = 'font case',
    Callback = function(v)
        L.FCase = v
    end
})
D_Misc:AddSlider("FontSize", {
    Text = "font size",
    Default = 13,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        L.FS = math.floor(v)
    end
})
D_Misc:AddSlider("MaxDistance", {
    Text = "max distance",
    Default = 650,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        L.DMax = v
    end
})

local ExtraTab = PlayerESPTabbox:AddTab("extra")

ExtraTab:AddToggle("VisCheck", {
    Text = "visible only",
    Default = false,
    Callback = function(v) L.VisCheck = v end
})

ExtraTab:AddToggle("TeamCheck", {
    Text = "team check",
    Default = true,
    Callback = function(v)
        L.TeamCheck = v
    end
})

ExtraTab:AddSlider("FadeIn", {
    Text = "fade in",
    Default = 0.5,
    Min = 0.05,
    Max = 3,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        L.FadeIn = v
    end
})

ExtraTab:AddSlider("FadeOut", {
    Text = "fade out",
    Default = 0.5,
    Min = 0.05,
    Max = 3,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        L.FadeOut = v
    end
})

local function getLocalChar()
    local chars = WS:FindFirstChild("Characters")
    if not chars then return nil end
    return chars:FindFirstChild(LP.Name)
end

local function vmShouldRun()
    local char = getLocalChar()
    if not char then return false end
    return char:FindFirstChild("OVERHEAD") == nil
end

local vmChamsHighlight = nil

local function vmDestroyChamsAll()
    if not vmChamsHighlight then return end
    for _, h in ipairs(vmChamsHighlight) do
        pcall(function() h:Destroy() end)
    end
    vmChamsHighlight = nil
end

local function vmApplyChams()
    vmDestroyChamsAll()
    if not L.VMChamsEnabled or not vmShouldRun() then return end

    local char = getLocalChar()
    if not char then return end

    local arms = { char:FindFirstChild("Left Arm"), char:FindFirstChild("Right Arm") }
    for _, arm in ipairs(arms) do
        if arm and arm:IsA("BasePart") then
            local h = Instance.new("Highlight")
            h.Adornee             = arm
            h.FillColor           = L.VMChamsFill
            h.FillTransparency    = L.VMChamsFillTrans
            h.OutlineColor        = L.VMChamsOutline
            h.OutlineTransparency = L.VMChamsOutTrans
            h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent              = arm
            if not vmChamsHighlight then vmChamsHighlight = {} end
            table.insert(vmChamsHighlight, h)
        end
    end
end

local vmOrigMaterials = {}

local function vmApplyMaterial()
    for part, orig in pairs(vmOrigMaterials) do
        pcall(function()
            part.Material     = orig.mat
            part.Color        = orig.color
            part.Transparency = orig.trans
        end)
    end
    table.clear(vmOrigMaterials)

    if not L.VMMatEnabled or not vmShouldRun() then return end

    local char = getLocalChar()
    if not char then return end

    local arms = { char:FindFirstChild("Left Arm"), char:FindFirstChild("Right Arm") }
    for _, arm in ipairs(arms) do
        if arm and arm:IsA("BasePart") then
            vmOrigMaterials[arm] = { mat = arm.Material, color = arm.Color, trans = arm.Transparency }
            arm.Material     = L.VMMaterial
            arm.Color        = L.VMMatColor
            arm.Transparency = L.VMMatTrans
        end
    end
end

local vmHiddenParts = {}

local function vmApplyHide()
    for part, origTrans in pairs(vmHiddenParts) do
        pcall(function() part.Transparency = origTrans end)
    end
    table.clear(vmHiddenParts)

    if not L.VMHideEnabled or not vmShouldRun() then return end

    local char = getLocalChar()
    if not char then return end

    if L.VMHideLeft then
        local arm = char:FindFirstChild("Left Arm")
        if arm and arm:IsA("BasePart") then
            vmHiddenParts[arm] = arm.Transparency
            arm.Transparency = 1
        end
    end

    if L.VMHideRight then
        local arm = char:FindFirstChild("Right Arm")
        if arm and arm:IsA("BasePart") then
            vmHiddenParts[arm] = arm.Transparency
            arm.Transparency = 1
        end
    end
end

local function vmRefresh()
    vmDestroyChamsAll()
    vmApplyChams()
    vmApplyMaterial()
    vmApplyHide()
end

local vmLastState = nil
RS.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    local state = vmShouldRun()
    if state ~= vmLastState then
        vmLastState = state
        vmRefresh()
    end
end)

local VMGroup = Tabs.Visuals:AddRightGroupbox("viewmodel")

local VMChamsToggle = VMGroup:AddToggle("VMChamsEnabled", {
    Text     = "arm chams",
    Default  = false,
    Callback = function(v)
        L.VMChamsEnabled = v
        vmRefresh()
    end
})
VMChamsToggle:AddColorPicker("VMChamsFillColor", {
    Default      = L.VMChamsFill,
    Title        = "fill color",
    Transparency = L.VMChamsFillTrans,
    Callback     = function(c)
        L.VMChamsFill      = c
        L.VMChamsFillTrans = Options.VMChamsFillColor
            and Options.VMChamsFillColor.Transparency
            or  L.VMChamsFillTrans
        vmRefresh()
    end
})
VMChamsToggle:AddColorPicker("VMChamsOutlineColor", {
    Default      = L.VMChamsOutline,
    Title        = "outline color",
    Transparency = L.VMChamsOutTrans,
    Callback     = function(c)
        L.VMChamsOutline  = c
        L.VMChamsOutTrans = Options.VMChamsOutlineColor
            and Options.VMChamsOutlineColor.Transparency
            or  L.VMChamsOutTrans
        vmRefresh()
    end
})

do
local D_VMChams = VMGroup:AddDependencyBox()
D_VMChams:SetupDependencies({{VMChamsToggle, true}})
D_VMChams:AddSlider("VMChamsTrans", {
    Text     = "transparency",
    Default  = 0.5,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
    Compact  = true,
    Callback = function(v)
        L.VMChamsFillTrans = v
        vmRefresh()
    end
})
end

local VMMatToggle = VMGroup:AddToggle("VMMatEnabled", {
    Text     = "arm material",
    Default  = false,
    Callback = function(v)
        L.VMMatEnabled = v
        vmRefresh()
    end
})
VMMatToggle:AddColorPicker("VMMatColor", {
    Default  = L.VMMatColor,
    Title    = "material color",
    Callback = function(c)
        L.VMMatColor = c
        vmRefresh()
    end
})

do
local D_VMMat = VMGroup:AddDependencyBox()
D_VMMat:SetupDependencies({{VMMatToggle, true}})
D_VMMat:AddDropdown("VMMatDropdown", {
    Values  = { "ForceField", "Glass", "Neon", "SmoothPlastic", "Metal", "Wood", "Granite", "Marble", "Brick", "Cobblestone", "Ice", "Sand", "Fabric", "DiamondPlate", "Foil" },
    Default = 3,
    Multi   = false,
    Text    = "material",
    Callback = function(v)
        local mat = Enum.Material[v]
        if mat then
            L.VMMaterial = mat
            vmRefresh()
        end
    end
})
D_VMMat:AddSlider("VMMatTrans", {
    Text     = "transparency",
    Default  = 0.0,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
    Compact  = true,
    Callback = function(v)
        L.VMMatTrans = v
        vmRefresh()
    end
})
end

local VMHideToggle = VMGroup:AddToggle("VMHideEnabled", {
    Text     = "hide arms",
    Default  = false,
    Callback = function(v)
        L.VMHideEnabled = v
        vmRefresh()
    end
})

do
local D_VMHide = VMGroup:AddDependencyBox()
D_VMHide:SetupDependencies({{VMHideToggle, true}})
D_VMHide:AddDropdown("VMHideArmsDropdown", {
    Values   = { "Left", "Right" },
    Default  = { "Left", "Right" },
    Multi    = true,
    Text     = "which arms",
    Callback = function(v)
        L.VMHideLeft  = v["Left"]  == true
        L.VMHideRight = v["Right"] == true
        vmRefresh()
    end
})
end

Library:OnUnload(function()
    vmDestroyChamsAll()
    for part, orig in pairs(vmOrigMaterials) do
        pcall(function()
            part.Material     = orig.mat
            part.Color        = orig.color
            part.Transparency = orig.trans
        end)
    end
    table.clear(vmOrigMaterials)
    for part, origTrans in pairs(vmHiddenParts) do
        pcall(function() part.Transparency = origTrans end)
    end
    table.clear(vmHiddenParts)
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("menu")
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "open keybind menu",
    Callback = function(v)
        Library.KeybindFrame.Visible = v
    end
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "custom cursor",
    Default = false,
    Callback = function(v)
        Library.ShowCustomCursor = v
    end
})
MenuGroup:AddToggle("HideLogo", {
    Text = "hide logo",
    Default = false,
    Callback = function(v)
        Library.HideImages = v
        if Library.BackgroundImage then
            Library.BackgroundImage.Visible = not v
        end
    end
})

local BlurTgl = MenuGroup:AddToggle("UIBlur", {
    Text = "blur",
    Default = false,
    Callback = function(v)
        Library.UIBlur = v
        if Library.UpdateBlur then
            Library:UpdateBlur()
        end
    end
})

do
local BlurDep = MenuGroup:AddDependencyBox()
BlurDep:SetupDependencies({{BlurTgl, true}})
BlurDep:AddSlider("UIBlurIntensity", {
    Text = "blur intensity",
    Default = 15,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Callback = function(v)
        Library.UIBlurIntensity = v
        if Library.UpdateBlur then
            Library:UpdateBlur()
        end
    end
})
end

MenuGroup:AddDropdown("NotificationPosition", {
    Values = {"Left", "Right", "Bottom"},
    Default = "Bottom",
    Multi = false,
    Text = "notification position",
    Callback = function(v)
        Library.NotifySide = v
        Library:Notify("notification test", 3)
    end
})

MenuGroup:AddDropdown("LibraryFont", {
    Values = {
        "Legacy", "Arial", "ArialBold", "SourceSans", "SourceSansBold", "SourceSansSemibold",
        "SourceSansLight", "SourceSansItalic", "Bodoni", "Garamond", "Cartoon", "Code",
        "Highway", "SciFi", "Arcade", "Fantasy", "Antique", "Gotham", "GothamBold",
        "GothamSemibold", "GothamMedium", "GothamBlack", "AmaticSC", "Bangers", "Creepster",
        "DenkOne", "Fondamento", "FredokaOne", "GrenzeGotisch", "IndieFlower", "JosefinSans",
        "Jura", "Kalam", "LuckiestGuy", "Merriweather", "Michroma", "Nunito", "Oswald",
        "PatrickHand", "PermanentMarker", "PressStart2P", "Roboto", "RobotoCondensed",
        "RobotoMono", "Sarpanch", "SpecialElite", "TitilliumWeb", "Ubuntu"
    },
    Default = "FredokaOne",
    Multi = false,
    Text = "library font",
    Callback = function(v)
        local ok, font = pcall(function() return Enum.Font[v] end)
        if ok and font then
            Library:SetFont(font)
        end
    end
})

MenuGroup:AddSlider("UIGlowAmount", {
    Text = "ui glow intensity",
    Default = 1,
    Min = 0,
    Max = 4,
    Rounding = 2,
    Callback = function(v)
        if Library.SetGlowAmount then
            Library:SetGlowAmount(v)
        end
    end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "menu keybind"
})
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

local SG = Tabs['UI Settings']:AddRightGroupbox("server")
SG:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)
SG:AddButton("Server Hop", function()
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local data = game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
        if data and data.data then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing >= 12 and s.playing < s.maxPlayers then
                    return s.id
                end
            end
        end
    end)
    if success and result then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, result, LP)
    else
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end
end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder('RoxyRivals')
SaveManager:SetFolder('RoxyRivals/TheWildWest')
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    Library.Unloaded = true
    if renderConnection then renderConnection:Disconnect() end
    for model in next, cache do
        removeESP(model)
    end
    table.clear(cache)

    BR_disconnect()
    KR_disconnect()
    if REDIR_RenderConn then REDIR_RenderConn:Disconnect() end
    if G.redirVisuals then G.redirVisuals:Disconnect(); G.redirVisuals = nil end
    if oldNamecall then hookmetamethod(game, "__namecall", oldNamecall) end
    pcall(stopFly)
    pcall(stopWalkspeed)
    pcall(AS_stop)
    
    pcall(function() SharedFovOutline:Remove() end)
    pcall(function() SharedFovCircle:Remove() end)
    pcall(function() SharedSnapOutline:Remove() end)
    pcall(function() SharedSnapLine:Remove() end)
end)
