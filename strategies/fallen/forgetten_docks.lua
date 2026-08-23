TDS:Loadout("Hacker", "Gatling Gun", "Mercenary Base", "Turret", "Soldier")

TDS:Mode("Fallen")
TDS:GameInfo("Forgetten Docks")

TDS:Mercenary(150, 1)
TDS:VoteSkip()

TDS:Place("Soldier", -29.360931396484, 0, -14.618578910828) --1
TDS:Ready()

TDS:Place("Soldier", -29.360931396484, 0, -14.618578910828) --2
TDS:Place("Soldier", -29.360931396484, 0, -14.618578910828) --3
TDS:Place("Soldier", -29.360931396484, 0, -14.618578910828) --4
TDS:Place("Soldier", -29.360931396484, 0, -14.618578910828) --5

for _ = 1, 2 do
    for _, index in ipairs({1, 2, 3, 4, 5}) do
        TDS:Upgrade(index)
    end
end

TDS:Place("Gatling Gun", 21.987722396851, 0, -1.8362607955933) --6
TDS:UpgradeTimes(6, 2)

TDS:Place("Hacker", -29.360931396484, 0, -14.618578910828) --7
TDS:Place("Hacker", -29.360931396484, 0, -14.618578910828) --8

TDS:UpgradeTimes(8, 2)
TDS:UpgradeTimes(7, 2)

TDS:Place("Mercenary Base", 21.987722396851, 0, -1.8362607955933) --9
TDS:UpgradeTimes(9, 4)
TDS:SetOption(9, "Unit 1", "Riot Guard")
TDS:SetOption(9, "Unit 2", "Riot Guard")
TDS:SetOption(9, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", 21.987722396851, 0, -1.8362607955933) --10
TDS:UpgradeTimes(10, 4)
TDS:SetOption(10, "Unit 1", "Riot Guard")
TDS:SetOption(10, "Unit 2", "Riot Guard")
TDS:SetOption(10, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", 21.987722396851, 0, -1.8362607955933) --11
TDS:UpgradeTimes(11, 4)
TDS:SetOption(11, "Unit 1", "Riot Guard")
TDS:SetOption(11, "Unit 2", "Riot Guard")
TDS:SetOption(11, "Unit 3", "Riot Guard")

TDS:Upgrade(9)
TDS:Upgrade(10)
TDS:Upgrade(11)

TDS:UpgradeTimes(6, 2)

TDS:UpgradeTimes(8, 2)
TDS:Upgrade(8, 2)

TDS:UpgradeTimes(7, 2)
TDS:Upgrade(7, 2)

TDS:Upgrade(9)
TDS:Upgrade(10)
TDS:Upgrade(11)

TDS:UpgradeTimes(6, 2)

TDS:Place("Turret", -21.877502441406, 0, -9.7464361190796) --12
TDS:Place("Turret", -21.877502441406, 0, -9.7464361190796) --13
TDS:Place("Turret", -21.877502441406, 0, -9.7464361190796) --14

for _ = 1, 5 do
    for _, index in ipairs({12, 13, 14}) do
        TDS:Upgrade(index)
    end
end

TDS:LoopAbility(8, "Hologram Tower", {towerPosition = Vector3.new(23.523794174194, 1.0249900817871, 3.7587015628815), towerToClone = 6})

