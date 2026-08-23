TDS:Loadout("Hacker", "Gatling Gun", "Mercenary Base", "Turret", "Soldier")

TDS:Mode("Fallen")
TDS:GameInfo("Construction Crazy")

TDS:Mercenary(170, 1)
TDS:VoteSkip()

TDS:Place("Soldier", 2.3942394256591797, 0, -25.7822208404541) --1
TDS:Ready()

TDS:Place("Soldier", 2.3942394256591797, 0, -25.7822208404541) --2
TDS:Place("Soldier", 2.3942394256591797, 0, -25.7822208404541) --3
TDS:Place("Soldier", 2.3942394256591797, 0, -25.7822208404541) --4
TDS:Place("Soldier", 2.3942394256591797, 0, -25.7822208404541) --5

for _ = 1, 2 do
    for _, index in ipairs({1, 2, 3, 4, 5}) do
        TDS:Upgrade(index)
    end
end

TDS:Place("Gatling Gun", -44.702110290527344, 0, -0.4374852180480957) --6
TDS:UpgradeTimes(6, 2)

TDS:Place("Hacker", 2.3942394256591797, 0, -25.7822208404541) --7
TDS:Place("Hacker", 2.3942394256591797, 0, -25.7822208404541) --8

TDS:UpgradeTimes(8, 2)
TDS:UpgradeTimes(7, 2)

TDS:Place("Mercenary Base", -44.702110290527344, 0, -0.4374852180480957) --9
TDS:UpgradeTimes(9, 4)
TDS:SetOption(9, "Unit 1", "Riot Guard")
TDS:SetOption(9, "Unit 2", "Riot Guard")
TDS:SetOption(9, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -44.702110290527344, 0, -0.4374852180480957) --10
TDS:UpgradeTimes(10, 4)
TDS:SetOption(10, "Unit 1", "Riot Guard")
TDS:SetOption(10, "Unit 2", "Riot Guard")
TDS:SetOption(10, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -44.702110290527344, 0, -0.4374852180480957) --11
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

TDS:Place("Turret", 0.45348191261291504, 0, 0.8144723176956177) --12
TDS:Place("Turret", 0.45348191261291504, 0, 0.8144723176956177) --13
TDS:Place("Turret", 0.45348191261291504, 0, 0.8144723176956177) --14

for _ = 1, 5 do
    for _, index in ipairs({12, 13, 14}) do
        TDS:Upgrade(index)
    end
end

TDS:LoopAbility(8, "Hologram Tower", {towerPosition = Vector3.new(-33.40981674194336, 0.2550067901611328, -0.07360172271728516), towerToClone = 6})

