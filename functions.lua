local addonName, addonTable = ...

local C_ToyBox = C_ToyBox
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemInfo = GetContainerItemInfo
local GetItemInfo = GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetItemCooldown = GetItemCooldown
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellInfo = GetSpellInfo
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local IsPlayerSpell = IsPlayerSpell
local PlayerHasToy = PlayerHasToy

-- ==== GENERIC FUNCTIONS ====

local function getCooldownText(time)
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

local function getTextWithCooldown(text, cooldown)
    local colorCD = "ff0000"    
    
    if (cooldown > 0) then
        local cooldownText = getCooldownText(cooldown)
        return "|cff"..colorCD..text.." "..cooldownText.."|r"        
    end

    return text
end

-- ==== ITEM FUNCTIONS ====

local function getItemCD(itemID)
    local startTime, duration, cooldown
    startTime, duration = GetItemCooldown(itemID)
    cooldown = duration - (GetTime() - startTime)
    return cooldown
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

-- load item async & adds link
local function loadItem(itemID, links)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        if (hasItem(itemID)) then
            local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(item:GetItemLink())

            -- create item link
            links[itemID] = {
                hasItem = true,
                name = name,
                icon = icon,
                secure = {
                    type = 'item',
                    item = name
                }
            }
        else
            -- create item link dummy
            links[itemID] = {
                hasItem = false
            }
        end
    end)
end

-- loads all items async to itemLinks
local function updateItems()
    for i = 1, #addonTable.whistles do
        local itemID = addonTable.whistles[i]
        loadItem(itemID, addonTable.itemLinks)
    end

    for i = 1, #addonTable.scrolls do
        local itemID = addonTable.scrolls[i]
        loadItem(itemID, addonTable.itemLinks)
    end    

    for i = 1, #addonTable.items do
        local itemID = addonTable.items[i]
        loadItem(itemID, addonTable.itemLinks)
    end
end

-- ==== SPELL FUNCTIONS ====

local function getSpellCD(spellID)
    local startTime, duration, cooldown
    startTime, duration = GetSpellCooldown(spellID)
    cooldown = duration - (GetTime() - startTime)
    return cooldown    
end

-- returns true, if player has spell in his book
local function hasSpell(spellName)
    local i = 1
    while true do
        local s = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not s then
            break
        end

        if s == spellName then
            return true
        end

        i = i + 1
    end

    return false
end

local function loadSpell(spellID, spellFlag, links)
    if IsPlayerSpell(spellID) then
        local name, _, icon = GetSpellInfo(spellID)

        if hasSpell(name) then
            links[name] = {
                name = name,
                icon = icon,
                isPortal = spellFlag == 'P_RUNE',
                secure = {
                    type = 'spell',
                    spell = name
                }
            }
        end
    end    
end

local function loadSpells(spells)
    local links = {}

    for _, spellPair in ipairs(spells) do
        loadSpell(spellPair[1], spellPair[2], links)
    end

    return links
end

local function updateClassSpells()
    return loadSpells(addonTable.portals)
end

local function updateChallengeSpells()
    return loadSpells(addonTable.challengeSpells)
end

-- ==== EXPORT ====
addonTable.itemLinks = {}
addonTable.updateItems = updateItems
addonTable.updateClassSpells = updateClassSpells
addonTable.updateChallengeSpells = updateChallengeSpells
addonTable.getItemCD = getItemCD
addonTable.getSpellCD = getSpellCD
addonTable.getTextWithCooldown = getTextWithCooldown