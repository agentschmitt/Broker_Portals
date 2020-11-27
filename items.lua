local addonName, addonTable = ...

-- IDs of items usable for transportation
addonTable.items = {
    -- Dalaran rings
    40585,  -- Signet of the Kirin Tor
    40586,  -- Band of the Kirin Tor
    44934,  -- Loop of the Kirin Tor
    44935,  -- Ring of the Kirin Tor
    45688,  -- Inscribed Band of the Kirin Tor
    45689,  -- Inscribed Loop of the Kirin Tor
    45690,  -- Inscribed Ring of the Kirin Tor
    45691,  -- Inscribed Signet of the Kirin Tor
    48954,  -- Etched Band of the Kirin Tor
    48955,  -- Etched Loop of the Kirin Tor
    48956,  -- Etched Ring of the Kirin Tor
    48957,  -- Etched Signet of the Kirin Tor
    51557,  -- Runed Signet of the Kirin Tor
    51558,  -- Runed Loop of the Kirin Tor
    51559,  -- Runed Ring of the Kirin Tor
    51560,  -- Runed Band of the Kirin Tor
    139599, -- Empowered Ring of the Kirin Tor
    -- Engineering Gadgets
    18984,  -- Dimensional Ripper - Everlook
    18986,  -- Ultrasafe Transporter: Gadgetzan
    30542,  -- Dimensional Ripper - Area 52
    30544,  -- Ultrasafe Transporter: Toshley's Station
    48933,  -- Wormhole Generator: Northrend
    87215,  -- Wormhole Generator: Pandaria
    112059, -- Wormhole Centrifuge
    151652, -- Wormhole Generator: Argus
    168807, -- Wormhole Generator: Kul Tiras
    168808, -- Wormhole Generator: Zandalar
    -- Seasonal items
    21711,  -- Lunar Festival Invitation
    37863,  -- Direbrew's Remote
    -- Miscellaneous
    17690,  -- Frostwolf Insignia Rank 1 (Horde)
    17691,  -- Stormpike Insignia Rank 1 (Alliance)
    17900,  -- Stormpike Insignia Rank 2 (Alliance)
    17901,  -- Stormpike Insignia Rank 3 (Alliance)
    17902,  -- Stormpike Insignia Rank 4 (Alliance)
    17903,  -- Stormpike Insignia Rank 5 (Alliance)
    17904,  -- Stormpike Insignia Rank 6 (Alliance)
    17905,  -- Frostwolf Insignia Rank 2 (Horde)
    17906,  -- Frostwolf Insignia Rank 3 (Horde)
    17907,  -- Frostwolf Insignia Rank 4 (Horde)
    17908,  -- Frostwolf Insignia Rank 5 (Horde)
    17909,  -- Frostwolf Insignia Rank 6 (Horde)
    22631,  -- Atiesh, Greatstaff of the Guardian
    32757,  -- Blessed Medallion of Karabor
    35230,  -- Darnarian's Scroll of Teleportation
    43824,  -- The Schools of Arcane Magic - Mastery
    46874,  -- Argent Crusader's Tabard
    50287,  -- Boots of the Bay
    52251,  -- Jaina's Locket
    54452,  -- Ethereal Portal
    58487,  -- Potion of Deepholm
    61379,  -- Gidwin's Hearthstone
    63206,  -- Wrap of Unity (Alliance)
    63207,  -- Wrap of Unity (Horde)
    63352,  -- Shroud of Cooperation (Alliance)
    63353,  -- Shroud of Cooperation (Horde)
    63378,  -- Hellscream's Reach Tabard
    63379,  -- Baradin's Wardens Tabard
    64457,  -- The Last Relic of Argus
    65274,  -- Cloak of Coordination (Horde)
    65360,  -- Cloak of Coordination (Alliance)
    95050,  -- The Brassiest Knuckle (Horde)
    95051,  -- The Brassiest Knuckle (Alliance)
    95567,  -- Kirin Tor Beacon
    95568,  -- Sunreaver Beacon
    87548,  -- Lorewalker's Lodestone
    93672,  -- Dark Portal
    103678, -- Time-Lost Artifact
    110560, -- Garrison Hearthstone
    118662, -- Bladespire Relic
    118663, -- Relic of Karabor
    118907, -- Pit Fighter's Punching Ring
    128353, -- Admiral's Compass
    128502, -- Hunter's Seeking Crystal
    128503, -- Master Hunter's Seeking Crystal
    136849, -- Nature's Beacon
    139590, -- Scroll of Teleport: Ravenholdt
    140192, -- Dalaran Hearthstone
    140324, -- Mobile Telemancy Beacon
    142469, -- Violet Seal of the Grand Magus
    144391, -- Pugilist's Powerful Punching Ring (Alliance)
    144392, -- Pugilist's Powerful Punching Ring (Horde)
    151016, -- Fractured Necrolyte Skull
    166559, -- Commander's Signet of Battle
    180817, -- Chiffre (Maw)
}

addonTable.scrolls = {
    -- items usable instead of hearthstone, without shared cd
    28585,  -- Ruby Slippers
    37118,  -- Scroll of Recall
    44314,  -- Scroll of Recall II
    44315,  -- Scroll of Recall III  
    -- items usable instead of hearthstone, with shared cd
    64488,  -- The Innkeeper's Daughter
    142298, -- Astonishingly Scarlet Slippers
    142542, -- Tome of Town Portal
    162973, -- Greatfather Winter's Hearthstone
    163045, -- Headless Horseman's Hearthstone
    165669, -- Lunar Elder's Hearthstone
  	165670, -- Peddlefeet's Lovely Hearthstone
    165802, -- Noble Gardener's Hearthstone
    168862, -- G.E.A.R. Tracking Beacon
    168907, -- Holographic Digitalization Hearthstone
    172179, -- Eternal Traveler's Hearthstone
    -- hearthstone
    6948,   -- Hearthstone,  
}

addonTable.whistles = {
  168862, -- G.E.A.R. Tracking Beacon
  141605, -- Flight Master's Whistle
}
