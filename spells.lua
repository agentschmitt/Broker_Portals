local addonName, addonTable = ...
local L = addonTable.L

local magePortals = {
    Alliance = {
        { 3561, 'TP_RUNE' },   -- TP:Stormwind
        { 3562, 'TP_RUNE' },   -- TP:Ironforge
        { 3565, 'TP_RUNE' },   -- TP:Darnassus
        { 32271, 'TP_RUNE' },  -- TP:Exodar
        { 49359, 'TP_RUNE' },  -- TP:Theramore
        { 33690, 'TP_RUNE' },  -- TP:Shattrath
        { 53140, 'TP_RUNE' },  -- TP:Dalaran
        { 88342, 'TP_RUNE' },  -- TP:Tol Barad
        { 132621, 'TP_RUNE' }, -- TP:Vale of Eternal Blossoms
        { 120145, 'TP_RUNE' }, -- TP:Ancient Dalaran
        { 176248, 'TP_RUNE' }, -- TP:StormShield
        { 224869, 'TP_RUNE' }, -- TP:Dalaran - Broken Isles
        { 193759, 'TP_RUNE' }, -- TP:Hall of the Guardian
        { 281403, 'TP_RUNE' }, -- TP:Boralus
        { 10059, 'P_RUNE' },   -- P:Stormwind
        { 11416, 'P_RUNE' },   -- P:Ironforge
        { 11419, 'P_RUNE' },   -- P:Darnassus
        { 32266, 'P_RUNE' },   -- P:Exodar
        { 49360, 'P_RUNE' },   -- P:Theramore
        { 33691, 'P_RUNE' },   -- P:Shattrath
        { 53142, 'P_RUNE' },   -- P:Dalaran
        { 88345, 'P_RUNE' },   -- P:Tol Barad
        { 120146, 'P_RUNE' },  -- P:Ancient Dalaran
        { 132620, 'P_RUNE' },  -- P:Vale of Eternal Blossoms
        { 176246, 'P_RUNE' },  -- P:StormShield
        { 224871, 'P_RUNE' },  -- P:Dalaran - Broken Isles
        { 281400, 'P_RUNE' }   -- P:Boralus
    },
    Horde = {
        { 3563, 'TP_RUNE' },   -- TP:Undercity
        { 3566, 'TP_RUNE' },   -- TP:Thunder Bluff
        { 3567, 'TP_RUNE' },   -- TP:Orgrimmar
        { 32272, 'TP_RUNE' },  -- TP:Silvermoon
        { 49358, 'TP_RUNE' },  -- TP:Stonard
        { 35715, 'TP_RUNE' },  -- TP:Shattrath
        { 53140, 'TP_RUNE' },  -- TP:Dalaran
        { 88344, 'TP_RUNE' },  -- TP:Tol Barad
        { 132627, 'TP_RUNE' }, -- TP:Vale of Eternal Blossoms
        { 120145, 'TP_RUNE' }, -- TP:Ancient Dalaran
        { 176242, 'TP_RUNE' }, -- TP:Warspear
        { 224869, 'TP_RUNE' }, -- TP:Dalaran - Broken Isles
        { 193759, 'TP_RUNE' }, -- TP:Hall of the Guardian
        { 281404, 'TP_RUNE' }, -- TP:Dazar'alor
        { 344587, 'TP_RUNE' }, -- TP:Oribos
        { 11418, 'P_RUNE' },   -- P:Undercity
        { 11420, 'P_RUNE' },   -- P:Thunder Bluff
        { 11417, 'P_RUNE' },   -- P:Orgrimmar
        { 32267, 'P_RUNE' },   -- P:Silvermoon
        { 49361, 'P_RUNE' },   -- P:Stonard
        { 35717, 'P_RUNE' },   -- P:Shattrath
        { 53142, 'P_RUNE' },   -- P:Dalaran
        { 88346, 'P_RUNE' },   -- P:Tol Barad
        { 120146, 'P_RUNE' },  -- P:Ancient Dalaran
        { 132626, 'P_RUNE' },  -- P:Vale of Eternal Blossoms
        { 176244, 'P_RUNE' },  -- P:Warspear
        { 224871, 'P_RUNE' },  -- P:Dalaran - Broken Isles
        { 281402, 'P_RUNE' },   -- P:Dazar'alor
        { 344597, 'P_RUNE' } -- P:Oribos
    }
}

-- Gold Challenge portals
local challengeSpells = {
    --MoP Challenge
    { 131204, L['Temple of the Jade Serpent'] }, -- Path of the Jade Serpent
    { 131205, L['Stormstout Brewery'] }, -- Path of the Stout Brew
    { 131206, L['Shado-Pan Monastery'] }, -- Path of the Shado-Pan
    { 131222, L['Mogushan Palace'] }, -- Path of the Mogu King
    { 131225, L['Gate of the Setting Sun'] }, -- Path of the Setting Sun
    { 131231, L['Scarlet Halls'] }, -- Path of the Scarlet Blade
    { 131229, L['Scarlet Monastery'] }, -- Path of the Scarlet Mitre
    { 131232, L['Scholomance'] }, -- Path of the Necromancer
    { 131228, L['Siege of Niuzao Temple'] }, -- Path of the Black Ox
    --WoD Challenge
    { 159895, 'TRUE' }, -- Path of the Bloodmaul
    { 159896, 'TRUE' }, -- Path of the Iron Prow
    { 159897, 'TRUE' }, -- Path of the Vigilant
    { 159898, 'TRUE' }, -- Path of the Skies
    { 159899, 'TRUE' }, -- Path of the Crescent Moon
    { 159900, 'TRUE' }, -- Path of the Dark Rail
    { 159901, 'TRUE' }, -- Path of the Verdant
    { 159902, 'TRUE' }, -- Path of the Burning Mountain
    --SL Season3 M+
    { 354462, L['Necrotic Wake'] }, -- Path of the Courageous
    { 354463, L['Plaguefall'] }, -- Path of the Plagued
    { 354464, L['Mists of Tirna Scithe'] }, -- Path of the Misty Forest
    { 354465, L['Halls of Atonement'] }, -- Path of the Sinful Soul
    { 354466, L['Sprires of Ascension'] }, -- Path of the Ascendant
    { 354467, L['Theater of Pain'] }, -- Path of the Undefeated
    { 354468, L['De Other Side'] }, -- Path of the Scheming Loa
    { 354469, L['Sanguine Depths'] }, -- Path of the Stone Warden
    { 367416, L['Tazavesh'] }, -- Path of the Streetwise Merchant
    --SL Season4 M+
    { 15695, L['Grimrail Depot'] }, --Path of the Dark Rail    
    { 159896, L['Irondocks'] }, -- Path of the Iron Prow
    { 373262, L['Karazhan'] }, --Path of the Fallen Guardian
    { 373274, L['Mechagon'] }, --Path of the Scrappy Prince    
}

local UnitClass = UnitClass
local UnitRace = UnitRace

local _, class = UnitClass('player')
local _, race = UnitRace('player')
local faction, _ = UnitFactionGroup('player')
local portals = {}

-- class portals
if class == 'MAGE' then
    portals = magePortals[faction]
elseif class == 'DEATHKNIGHT' then
    portals = {
        { 50977, 'TRUE' } -- Death Gate
    }
elseif class == 'DRUID' then
    portals = {
        { 18960,  'TRUE' }, -- TP:Moonglade
        { 147420, 'TRUE' }, -- TP:One with Nature
        { 193753, 'TRUE' }  -- TP:Dreamwalk
    }
elseif class == 'SHAMAN' then
    portals = {
        { 556, 'TRUE' } -- Astral Recall
    }
elseif class == 'MONK' then
    portals = {
        { 126892, 'TRUE' }, -- Zen Pilgrimage
        { 126895, 'TRUE' }  -- Zen Pilgrimage: Return
    }
end

-- race portals
if race == 'DarkIronDwarf' then
    table.insert(portals, { 265225, 'TRUE' }) -- Mole Machine
elseif race == 'Vulpera' then
    table.insert(portals, { 312372, 'TRUE' }) -- Return to Camp
    table.insert(portals, { 312370, 'TRUE' }) -- Make Camp
end

addonTable.portals = portals
addonTable.challengeSpells = challengeSpells