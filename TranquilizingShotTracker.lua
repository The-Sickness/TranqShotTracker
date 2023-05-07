
local defaultFontSize = 40  -- Default font size
local messageDuration = 2  -- Duration in seconds for the message to stay on screen

-- Function to show the message with customizable font size
local function ShowMessage(text, fontSize)
    local messageFrame = CreateFrame("MessageFrame", nil, UIParent)
    messageFrame:SetPoint("CENTER", 0, 200)  -- Move higher on the screen
    messageFrame:SetSize(400, 200)
    messageFrame:SetFontObject(GameFontNormalHuge)  -- Use the default font
    messageFrame:SetInsertMode("TOP")  -- Add spacing between lines
    messageFrame:SetTimeVisible(messageDuration)  -- Show the message for the specified duration

    local fontString = messageFrame:CreateFontString(nil, "OVERLAY")
    fontString:SetPoint("CENTER")
    fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize or defaultFontSize, "OUTLINE")  -- Customize font size
    fontString:SetText(text)
    fontString:SetTextColor(1, 0, 0, 1)  -- Red text color
    fontString:SetJustifyH("CENTER")

    messageFrame.fontString = fontString
    messageFrame:AddMessage("")
    
    -- Timer to clear the message after the specified duration
    C_Timer.After(messageDuration, function()
        messageFrame:Hide()
        messageFrame = nil
    end)
end

local function PlayAlertSound()
    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3)
end

local spellID = 19801  -- Tranquilizing Shot spell ID
local onCooldown = false

local function UpdateCooldown()
    local start, duration, enabled = GetSpellCooldown(spellID)

    if start and duration and enabled == 1 then
        local remainingTime = start + duration - GetTime()
        if remainingTime <= 0 then
            if onCooldown then
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
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" or event == "SPELL_UPDATE_COOLDOWN" then
        UpdateCooldown()
    end
end)
































