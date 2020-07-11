if not LibStub then return end

local dewdrop = LibStub('LibDewdrop-3.0', true)
local icon = LibStub('LibDBIcon-1.0')

local _

local CreateFrame = CreateFrame
local C_ToyBox = C_ToyBox
local GetBindLocation = GetBindLocation
local GetContainerItemCooldown = GetContainerItemCooldown
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetItemCooldown = GetItemCooldown
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local IsPlayerSpell = IsPlayerSpell
local PlayerHasToy = PlayerHasToy
local SecondsToTime = SecondsToTime
local SendChatMessage = SendChatMessage
local UnitClass = UnitClass
local UnitInRaid = UnitInRaid
local UnitRace = UnitRace
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

local addonName, addonTable = ...
local L = addonTable.L
local items = addonTable.items
local scrolls = addonTable.scrolls
local challengeSpells = addonTable.challengeSpells
local whistle = addonTable.whistle
local portals = addonTable.portals

local obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
    type = 'data source',
    text = L['P'],
    icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local methods = {}
local itemCache = {}
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')

local function pairsByKeys(t)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a)

    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local function tconcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

function findSpell(spellName)
    local i = 1
    while true do
        local s = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not s then
            break
        end

        if s == spellName then
            return i
        end

        i = i + 1
    end
end

-- returns true, if player has item with given ID in inventory or bags
local function hasItem(itemID)
    local item, found, id
    -- scan inventory
    for slotId = 1, 19 do
        item = GetInventoryItemLink('player', slotId)
        if item then
            found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
            if found and tonumber(id) == itemID then
                return true
            end
        end
    end
    -- scan bags
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            item = GetContainerItemLink(bag, slot)
            if item then
                found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
                if found and tonumber(id) == itemID then
                    return true
                end
            end
        end
    end
    -- check Toybox
    if PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID) then
        return true
    end

    return false
end

local function getItemCD(itemID)
    local startTime, duration, cooldown
    startTime, duration = GetItemCooldown(itemID)
    cooldown = duration - (GetTime() - startTime)
    return cooldown
end

local function getSpellCD(spellID)
    local startTime, duration, cooldown
    startTime, duration = GetSpellCooldown(spellID)
    cooldown = duration - (GetTime() - startTime)
    return cooldown    
end

local function getReagentCount(name)
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = GetContainerItemLink(bag, slot)
            if item then
                if item:find(name) then
                    local _, itemCount = GetContainerItemInfo(bag, slot)
                    count = count + itemCount
                end
            end
        end
    end

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

local function GenerateLinks(spells)
    local itemsGenerated = 0

    for _, unTransSpell in ipairs(spells) do
        if IsPlayerSpell(unTransSpell[1]) then
            local spell, _, spellIcon = GetSpellInfo(unTransSpell[1])
            local spellid = findSpell(spell)

            if spellid then
                methods[spell] = {
                    spellid = spellid,
                    text = spell,
                    spellIcon = spellIcon,
                    isPortal = unTransSpell[2] == 'P_RUNE',
                    secure = {
                        type = 'spell',
                        spell = spell
                    }
                }
                itemsGenerated = itemsGenerated + 1
            end
        end
    end

    return itemsGenerated
end

local function LoadItem(itemID)
    --load item async
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        if (hasItem(itemID)) then
            --get item infos
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(item:GetItemLink())
            local secure = {
                type = 'item',
                item = name
            }

            --add info to cache
            itemCache[itemID] = {
                hasItem = true,
                name = name,
                icon = icon,
                secure = secure
            }
        else
            -- add dummy to cache
            itemCache[itemID] = {
                hasItem = false
            }
        end
    end)
end

local function IsCacheLoaded()
    local count = 0
    local totalCount = #items + #scrolls + 1
    for _ in pairs(itemCache) do count = count + 1 end
    return count == totalCount
end

local function LoadItems()
    if (IsCacheLoaded()) then return end

    LoadItem(whistle)

    for i = 1, #scrolls do
        local itemID = scrolls[i]
        LoadItem(itemID)
    end    

    for i = 1, #items do
        local itemID = items[i]
        LoadItem(itemID)
    end
end

local function UpdateClassSpells()
    return GenerateLinks(portals)
end

local function UpdateChallengeSpells()
    return GenerateLinks(challengeSpells)
end

local function UpdateIcon(icon)
    obj.icon = icon
end

local function GetCooldownText(time)
    local seconds = math.floor(time)
    if (seconds < 60) then
        return seconds .. 's'
    end

    local minutes = math.floor(seconds / 60)
    if (minutes < 60) then
        return minutes .. 'm'
    end

    local hours = math.floor(minutes / 60)
    if (hours < 60) then
        return hours .. 'h'
    end

    local days = math.floor(hours / 24)
    return days .. 'd'
end

local function GetTextWithCooldown(text, cooldown)
    local colorCD = "ff0000"    
    
    if (cooldown > 0) then
        local cooldownText = GetCooldownText(cooldown)
        return "|cff"..colorCD..text.." "..cooldownText.."|r"        
    end

    return text
end

local function AddItemToMenu(itemID, alternativeName)
    local cache = itemCache[itemID]

    if (cache ~= nil and cache.hasItem) then
        local name = alternativeName or cache.name
        local icon = cache.icon
        local secure = cache.secure            
        local cooldown = getItemCD(itemID)
        local cdText = GetTextWithCooldown(name, cooldown)
    
        dewdrop:AddLine(
            'textHeight', PortalsDB.fontSize,
            'text', cdText,
            'secure', secure,
            'icon', tostring(icon),
            'func', function() UpdateIcon(icon) end,
            'closeWhenClicked', true)
        
        return true
    else
        return false
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

local function AddSubMenu()
    local chatType = (UnitInRaid("player") and "RAID") or (GetNumGroupMembers() > 0 and "PARTY") or nil
    local announce = PortalsDB.announce
    local addedSpells = 0

    for k, v in pairsByKeys(methods) do
        if v.secure then
            local cooldown = getSpellCD(v.text)
            local cdText = GetTextWithCooldown(v.text, cooldown)
            dewdrop:AddLine(
                'textHeight', PortalsDB.fontSize,
                'text', cdText,
                'secure', v.secure,
                'icon', tostring(v.spellIcon),
                'func', function()
                    UpdateIcon(v.spellIcon)
                    if announce and v.isPortal and chatType then
                        SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. v.text, chatType)
                    end
                end,
                'closeWhenClicked', true)
            addedSpells = addedSpells + 1
        end
    end

    if (addedSpells > 0) then
        dewdrop:AddLine()
    end
end

local function ShowClassSpells()
    methods = {}
    local classSpells = UpdateClassSpells()
    if classSpells > 0 then
      AddSubMenu()
    end    
end

local function ShowChallengeSpells()
    methods = {}
    local challengeSpells = UpdateChallengeSpells()
    if challengeSpells > 0 then
      AddSubMenu()
    end    
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

    LoadItems()

    self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
    UpdateClassSpells()
    UpdateChallengeSpells()
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
