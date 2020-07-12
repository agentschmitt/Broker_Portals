if not LibStub then return end

local Dewdrop = LibStub('LibDewdrop-3.0', true)
local LibQTip = LibStub('LibQTip-1.0')
local LibIcon = LibStub('LibDBIcon-1.0')
local LibDataBroker = LibStub:GetLibrary('LibDataBroker-1.1')

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

local secureFrame = addonTable.secureFrame

local LDB = LibDataBroker:NewDataObject(addonName, {
    type = 'data source',
    text = L['P'],
    icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local tooltip
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
        LibIcon:Hide('Broker_Portals')
    else
        LibIcon:Show('Broker_Portals')
    end
end

local function UpdateIcon(icon)
    LDB.icon = icon
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
        local text = getTextWithCooldown(alternativeName or link.name, cooldown)
    
        local lineIndex = tooltip:AddLine(("|T%s:16|t%s"):format(link.icon, ' '..text))
        
        tooltip:SetCellScript(lineIndex, 1, "OnEnter", function(self)
            secureFrame:Activate(self, link.secure)
        end)

        tooltip:SetCellScript(lineIndex, 1, "OnMouseDown", function(self)
            UpdateIcon(link.icon)
        end)

        return true
    else
        return false
    end
end

local function AddSpellToMenu(link)
    local cooldown = getSpellCD(link.name)
    local text = getTextWithCooldown(link.name, cooldown)

    local lineIndex = tooltip:AddLine(("|T%s:16|t%s"):format(link.icon, ' '..text))
    
    tooltip:SetCellScript(lineIndex, 1, "OnEnter", function(self)
        secureFrame:Activate(self, link.secure)
    end)

    tooltip:SetCellScript(lineIndex, 1, "OnMouseDown", function(self)
        UpdateIcon(link.icon)
        AnnouncePortal(link.isPortal, link.name)
    end)
end

local function AddSpellsToMenu(links)
    local seperator = false

    for _, link in pairs(links) do
        AddSpellToMenu(link)
        seperator = true
    end

    if (seperator) then
        tooltip:AddLine(" ")
    end
end

local function ShowWhistle()
    if (AddItemToMenu(whistle)) then
        tooltip:AddLine(" ")
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
        tooltip:AddLine(" ")
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
        tooltip:AddLine(" ")
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

local function ShowOptionsMenu()
    Dewdrop:SetFontSize(UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)

    Dewdrop:AddLine(
        'textHeight', UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT,
        'text', L['SHOW_ITEMS'],
        'checked', PortalsDB.showItems,
        'func', function() PortalsDB.showItems = not PortalsDB.showItems end,
        'closeWhenClicked', true)
    Dewdrop:AddLine(
        'textHeight', UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT,
        'text', L['ATT_MINIMAP'],
        'checked', not PortalsDB.minimap.hide,
        'func', function() ToggleMinimap() end,
        'closeWhenClicked', true)
    Dewdrop:AddLine(
        'textHeight', UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT,
        'text', L['ANNOUNCE'],
        'checked', PortalsDB.announce,
        'func', function() PortalsDB.announce = not PortalsDB.announce end,
        'closeWhenClicked', true)
end

local function ToggleOptionsMenu(self)
    if (self ~= nil and Dewdrop:IsOpen(self)) then
		Dewdrop:Close()
	else
		Dewdrop:Open(self, 'children', ShowOptionsMenu)
	end     
end

local function ShowTooltip(self)
   -- Acquire a tooltip with 1 columns, aligned to left
   tooltip = LibQTip:Acquire(addonName.."tip", 1, "LEFT") 
   self.tooltip = tooltip
   tooltip:EnableMouse(true)
   tooltip:SetAutoHideDelay(.2, self)
 
  -- Use smart anchoring code to anchor the tooltip to our frame
   tooltip:SmartAnchorTo(self)
   tooltip:Clear()

   -- add content
   ShowChallengeSpells()

   if PortalsDB.showItems then
       ShowOtherItems()
       ShowWhistle()
   end

   ShowClassSpells()        

   ShowHearthstone()      

   tooltip:Show()
end

local function HideTooltip(self)
    LibQTip:Release(self.tooltip)
    secureFrame:Deactivate()
end

function frame:PLAYER_LOGIN()
    -- PortalsDB.minimap is there for smooth upgrade of SVs from old version
    if (not PortalsDB) or (PortalsDB.version == nil) then
        PortalsDB = {}
        PortalsDB.minimap = {}
        PortalsDB.minimap.hide = false
        PortalsDB.showItems = true
        PortalsDB.announce = false
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

    if LibIcon then
        LibIcon:Register('Broker_Portals', LDB, PortalsDB.minimap)
    end

    updateItems()

    self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
    updateClassSpells()
    updateChallengeSpells()
end

function LDB.OnClick(self, button)
    if button == "RightButton" then
        HideTooltip(self)
        ToggleOptionsMenu(self)
    end
end

function LDB.OnEnter(self)
    ShowTooltip(self)
end

-- slash command definition
SlashCmdList['BROKER_PORTALS'] = function() ToggleMinimap() end
SLASH_BROKER_PORTALS1 = '/portals'
