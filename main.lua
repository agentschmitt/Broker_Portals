if not LibStub then return end

local dewdrop = LibStub('LibDewdrop-3.0', true)
local icon = LibStub('LibDBIcon-1.0')

local _

local CreateFrame = CreateFrame

local GetBindLocation = GetBindLocation
local GetNumGroupMembers = GetNumGroupMembers
local SendChatMessage = SendChatMessage
local UnitInRaid = UnitInRaid

local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

local addonName, addonTable = ...
local L = addonTable.L
local items = addonTable.items
local scrolls = addonTable.scrolls
local challengeSpells = addonTable.challengeSpells
local whistle = addonTable.whistle
local portals = addonTable.portals
local itemLinks = addonTable.itemLinks

local updateItems = addonTable.updateItems
local updateClassSpells = addonTable.updateClassSpells
local updateChallengeSpells = addonTable.updateChallengeSpells
local getItemCD = addonTable.getItemCD
local getSpellCD = addonTable.getSpellCD
local getTextWithCooldown = addonTable.getTextWithCooldown

local obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
    type = 'data source',
    text = L['P'],
    icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')

local function tableCount(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function ToggleMinimap()
    local hide = not PortalsDB.minimap.hide
    PortalsDB.minimap.hide = hide
    if hide then
        icon:Hide('Broker_Portals')
    else
        icon:Show('Broker_Portals')
    end
end

local function UpdateIcon(icon)
    obj.icon = icon
end

local function AnnouncePortal(isPortal, text)
    local chatType = (UnitInRaid("player") and "RAID") or (GetNumGroupMembers() > 0 and "PARTY") or nil
    if PortalsDB.announce and isPortal and chatType then
        SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. text, chatType)
    end
end

local function AddItemToMenu(itemID, alternativeName)
    local link = itemLinks[itemID]

    if (link ~= nil and link.hasItem) then
        local cooldown = getItemCD(itemID)
        local cdText = getTextWithCooldown(alternativeName or name, cooldown)
    
        dewdrop:AddLine(
            'textHeight', PortalsDB.fontSize,
            'text', cdText,
            'secure', link.secure,
            'icon', tostring(link.icon),
            'func', function() UpdateIcon(icon) end,
            'closeWhenClicked', true)
        
        return true
    else
        return false
    end
end

local function AddSpellToMenu(link)
    local cooldown = getSpellCD(link.name)
    local cdText = getTextWithCooldown(link.name, cooldown)

    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', cdText,
        'secure', link.secure,
        'icon', tostring(link.icon),
        'func', function()
            UpdateIcon(link.icon)
            AnnouncePortal(link.isPortal, link.name)
        end,
        'closeWhenClicked', true)
end

local function AddSpellsToMenu(links)
    local seperator = false

    for _, link in pairs(links) do
        AddSpellToMenu(link)
        seperator = true
    end

    if (seperator) then
        dewdrop:AddLine()
    end
end

local function ShowWhistle()
    if (AddItemToMenu(whistle)) then
        dewdrop:AddLine()
    end
end

local function ShowHearthstone()
    local bindLoc = GetBindLocation()
    local text = L['INN'] .. ' ' .. bindLoc
    local seperator = false

    for i = 1, #scrolls do
        local itemID = scrolls[i]
        if (AddItemToMenu(itemID, text)) then
            seperator = true
        end
    end

    if seperator then
        dewdrop:AddLine()
    end
end

local function ShowOtherItems()
    local seperator = false

    for i = 1, #items do
        local itemID = items[i]
        if (AddItemToMenu(itemID)) then
            seperator = true
        end
    end

    if seperator then
        dewdrop:AddLine()
    end
end

local function ShowClassSpells()
    local links = updateClassSpells()
    AddSpellsToMenu(links)
end

local function ShowChallengeSpells()
    local links = updateChallengeSpells()
    AddSpellsToMenu(links)
end

local function ShowOptions()
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['OPTIONS'],
        'hasArrow', true,
        'value', 'options')    
end

local function ShowOptionsMenu()
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['SHOW_ITEMS'],
        'checked', PortalsDB.showItems,
        'func', function() PortalsDB.showItems = not PortalsDB.showItems end,
        'closeWhenClicked', true)
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['SHOW_ITEM_COOLDOWNS'],
        'checked', PortalsDB.showItemCooldowns,
        'func', function() PortalsDB.showItemCooldowns = not PortalsDB.showItemCooldowns end,
        'closeWhenClicked', true)
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['ATT_MINIMAP'],
        'checked', not PortalsDB.minimap.hide,
        'func', function() ToggleMinimap() end,
        'closeWhenClicked', true)
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['ANNOUNCE'],
        'checked', PortalsDB.announce,
        'func', function() PortalsDB.announce = not PortalsDB.announce end,
        'closeWhenClicked', true)
    dewdrop:AddLine(
        'textHeight', PortalsDB.fontSize,
        'text', L['DROPDOWN_FONT_SIZE'],
        'hasArrow', true,
        'hasEditBox', true,
        'editBoxText', PortalsDB.fontSize,
        'editBoxFunc', function(value)
            if value ~= '' and tonumber(value) ~= nil then
                PortalsDB.fontSize = tonumber(value)
            else
                PortalsDB.fontSize = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
            end
        end)
end

local function UpdateMenu(level, value)
    dewdrop:SetFontSize(PortalsDB.fontSize)

    if level == 1 then
        ShowChallengeSpells()

        if PortalsDB.showItems then
            ShowOtherItems()
            ShowWhistle()
        end

        ShowClassSpells()        

        ShowHearthstone()        

        ShowOptions()

    elseif level == 2 and value == 'options' then
        ShowOptionsMenu()
    end    
end

function frame:PLAYER_LOGIN()
    -- PortalsDB.minimap is there for smooth upgrade of SVs from old version
    if (not PortalsDB) or (PortalsDB.version == nil) then
        PortalsDB = {}
        PortalsDB.minimap = {}
        PortalsDB.minimap.hide = false
        PortalsDB.showItems = true
        PortalsDB.showItemCooldowns = true
        PortalsDB.announce = false
        PortalsDB.fontSize = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
        PortalsDB.version = 5
    end

    -- upgrade from versions
    if PortalsDB.version == 4 then
        PortalsDB.fontSize = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
        PortalsDB.version = 5
    elseif PortalsDB.version == 3 then
        PortalsDB.announce = false
        PortalsDB.version = 4
    elseif PortalsDB.version == 2 then
        PortalsDB.showItemCooldowns = true
        PortalsDB.announce = false
        PortalsDB.version = 4
    elseif PortalsDB.version < 2 then
        PortalsDB.showItems = true
        PortalsDB.showItemCooldowns = true
        PortalsDB.announce = false
        PortalsDB.version = 4
    end

    if icon then
        icon:Register('Broker_Portals', obj, PortalsDB.minimap)
    end

    updateItems()

    self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
    updateClassSpells()
    updateChallengeSpells()
end

function obj.OnClick(self, button)
	if (self ~= nil and dewdrop:IsOpen(self)) then
		dewdrop:Close()
	else
		dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
	end
end

function obj.OnLeave()
end

function obj.OnEnter(self)
    dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
end

-- slash command definition
SlashCmdList['BROKER_PORTALS'] = function() ToggleMinimap() end
SLASH_BROKER_PORTALS1 = '/portals'
