local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local addonName = "TranquilizingShotTracker"
local TranquilizingShotTracker = AceAddon:NewAddon(addonName, "AceEvent-3.0")

-- Define your sound file paths
TranquilizingShotTracker.soundOptions = {
    ["Sound1"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Sheldon.mp3",
    ["Sound2"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Arrow Swoosh.mp3",
    ["Sound3"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\AxeCrit.mp3",
    ["Sound4"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Buzzer.mp3",
    ["Sound5"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Gun Cocking.mp3",
	["Sound6"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Laser.mp3",
	["Sound7"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Parry.mp3",
	["Sound8"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\ReadyCheck.mp3",
	["Sound9"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\SealofMight.mp3",
	["Sound10"] = "Interface\\AddOns\\TranquilizingShotTracker\\Sounds\\Target Acquired.mp3",
    -- and so on...
}

-- Sound option names for display in dropdown
local soundOptionNames = {
    ["Sound1"] = "Sheldon",
    ["Sound2"] = "Arrow Swoosh",
    ["Sound3"] = "Axe Crit",
    ["Sound4"] = "Buzzer",
    ["Sound5"] = "Gun Cocking",
	["Sound6"] = "Laser",
	["Sound7"] = "Pary",
	["Sound8"] = "Ready Check",
	["Sound9"] = "Seal of Might",
	["Sound10"] = "Target Acquired",
    -- and so on...
}

local spellID = 19801  -- Tranquilizing Shot spell ID
local onCooldown = false
local inCombat = false

-- Function to show the message with customizable font size and color
local function ShowMessage(text)
    local messageDuration = 2  -- Duration in seconds for the message to stay on screen

    local messageFrame = CreateFrame("MessageFrame", nil, UIParent)
    messageFrame:SetPoint("CENTER", 0, 200)  -- Move higher on the screen
    messageFrame:SetSize(400, 200)
    messageFrame:SetInsertMode("TOP")  -- Add spacing between lines

    local fontString = messageFrame:CreateFontString(nil, "OVERLAY")
    fontString:SetPoint("CENTER")
    fontString:SetFont(LSM:Fetch("font", TranquilizingShotTracker.db.profile.fontType), TranquilizingShotTracker.db.profile.fontSize, "OUTLINE")  -- Customize font size

    local color = TranquilizingShotTracker.db.profile.fontColor
    if color then
        fontString:SetTextColor(color[1], color[2], color[3], color[4])  -- use selected color
    else
        fontString:SetTextColor(1, 0, 0, 1)  -- default to red if no color selected
    end

    fontString:SetText(text)
    fontString:SetJustifyH("CENTER")

    messageFrame.fontString = fontString
    messageFrame:AddMessage("") -- Add an empty message to start the animation

    -- Timer to clear the message after the specified duration
    C_Timer.After(messageDuration, function()
        messageFrame:Hide()
        messageFrame = nil
    end)
end

-- Function to play the alert sound based on the selected option
local function PlayAlertSound()
    local selectedSound = TranquilizingShotTracker.db.profile.alertSound
    local soundFilePath = TranquilizingShotTracker.soundOptions[selectedSound]
    if soundFilePath then
        PlaySoundFile(soundFilePath, "Master")
    end
end

local function UpdateCooldown()
    -- Check if the player is a Hunter
    if select(2, UnitClass("player")) ~= "HUNTER" then
        return
    end
    
    local start, duration, enabled = GetSpellCooldown(spellID)
    
    if start and duration and enabled == 1 then
        local remainingTime = start + duration - GetTime()
        if remainingTime <= 0 then
            if onCooldown and inCombat then
                onCooldown = false
                ShowMessage("Tranquilizing Shot\nis available!")
                PlayAlertSound()
            end
        else
            onCooldown = true
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" or event == "SPELL_UPDATE_COOLDOWN" then
        UpdateCooldown()
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    end
end)

local options = {
    name = addonName,
    type = "group",
    args = {
        fontSize = {
            type = "range",
            name = "Font Size",
            desc = "Set the font size for the message",
            min = 10,
            max = 100,
            step = 1,
            order = 1,
            set = function(info, val)
                TranquilizingShotTracker.db.profile.fontSize = val
            end,
            get = function(info)
                return TranquilizingShotTracker.db.profile.fontSize
            end,
        },
        fontType = {
            type = "select",
            dialogControl = 'LSM30_Font',
            name = "Font Type",
            desc = "Select the font type for the message",
            order = 2,
            values = function()
                return LSM:HashTable("font")
            end,
            set = function(info, val)
                TranquilizingShotTracker.db.profile.fontType = val
            end,
            get = function(info)
                return TranquilizingShotTracker.db.profile.fontType
            end,
        },
        fontColor = {
            type = "color",
            name = "Font Color",
            desc = "Select the font color for the message",
            order = 3,
            hasAlpha = true,
            set = function(info, r, g, b, a)
                TranquilizingShotTracker.db.profile.fontColor = { r, g, b, a }
            end,
            get = function(info)
                local color = TranquilizingShotTracker.db.profile.fontColor
                if color then
                    return unpack(color)
                else
                    return 1, 0, 0, 1 -- Default to red color
                end
            end,
        },
        soundSelect = {
            type = "select",
            name = "Alert Sound",
            desc = "Select the sound for the alert",
            order = 4,
            values = soundOptionNames,
            set = function(info, val)
                TranquilizingShotTracker.db.profile.alertSound = val
                PlayAlertSound() -- Play the selected sound immediately
            end,
            get = function(info)
                return TranquilizingShotTracker.db.profile.alertSound
            end,
        },
    },
}

function TranquilizingShotTracker:OnInitialize()
    self.db = AceDB:New("TranquilizingShotTrackerDB", { profile = { fontSize = 40, fontType = "Friz Quadrata TT", fontColor = { 1, 0, 0, 1 }, alertSound = "Sound1" } })
    AceConfig:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, addonName)
end




































