TDS:Loadout("Hacker", "Gatling Gun", "Mercenary Base", "Turret", "Soldier")

TDS:Mode("Fallen")
TDS:GameInfo("Retro The Heights")

TDS:Mercenary(180, 1)
TDS:VoteSkip()

TDS:Place("Soldier", -10.077674865723, 0, 19.113710403442) --1
TDS:Ready()

TDS:Place("Soldier", -10.077674865723, 0, 19.113710403442) --2
TDS:Place("Soldier", -10.077674865723, 0, 19.113710403442) --3
TDS:Place("Soldier", -10.077674865723, 0, 19.113710403442) --4
TDS:Place("Soldier", -10.077674865723, 0, 19.113710403442) --5

for _ = 1, 2 do
    for _, index in ipairs({1, 2, 3, 4, 5}) do
        TDS:Upgrade(index)
    end
end

TDS:Place("Gatling Gun", -11.985363006592, 0, -29.333477020264) --6
TDS:UpgradeTimes(6, 2)

TDS:Place("Hacker", -10.077674865723, 0, 19.113710403442) --7
TDS:Place("Hacker", -10.077674865723, 0, 19.113710403442) --8

TDS:UpgradeTimes(8, 2)
TDS:UpgradeTimes(7, 2)

TDS:Place("Mercenary Base", -11.985363006592, 0, -29.333477020264) --9
TDS:UpgradeTimes(9, 4)
TDS:SetOption(9, "Unit 1", "Riot Guard")
TDS:SetOption(9, "Unit 2", "Riot Guard")
TDS:SetOption(9, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -11.985363006592, 0, -29.333477020264) --10
TDS:UpgradeTimes(10, 4)
TDS:SetOption(10, "Unit 1", "Riot Guard")
TDS:SetOption(10, "Unit 2", "Riot Guard")
TDS:SetOption(10, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -11.985363006592, 0, -29.333477020264) --11
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

TDS:Place("Turret", 0.22364568710327, 0, 5.7304515838623) --12
TDS:Place("Turret", 0.22364568710327, 0, 5.7304515838623) --13
TDS:Place("Turret", 0.22364568710327, 0, 5.7304515838623) --14

for _ = 1, 5 do
    for _, index in ipairs({12, 13, 14}) do
        TDS:Upgrade(index)
    end
end

TDS:LoopAbility(8, "Hologram Tower", {towerPosition = Vector3.new(-0.095447540283203, 1.5625, -15.946265220642), towerToClone = 6})

