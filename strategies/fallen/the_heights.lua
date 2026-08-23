TDS:Loadout("Hacker", "Gatling Gun", "Mercenary Base", "Turret", "Soldier")

TDS:Mode("Fallen")
TDS:GameInfo("The Heights")

TDS:Mercenary(180, 1)
TDS:VoteSkip()

TDS:Place("Soldier", -12.725464820862, 0, 18.447301864624) --1
TDS:Ready()

TDS:Place("Soldier", -12.725464820862, 0, 18.447301864624) --2
TDS:Place("Soldier", -12.725464820862, 0, 18.447301864624) --3
TDS:Place("Soldier", -12.725464820862, 0, 18.447301864624) --4
TDS:Place("Soldier", -12.725464820862, 0, 18.447301864624) --5

for _ = 1, 2 do
    for _, index in ipairs({1, 2, 3, 4, 5}) do
        TDS:Upgrade(index)
    end
end

TDS:Place("Gatling Gun", -14.894138336182, 0, -28.956447601318) --6
TDS:UpgradeTimes(6, 2)

TDS:Place("Hacker", -12.725464820862, 0, 18.447301864624) --7
TDS:Place("Hacker", -12.725464820862, 0, 18.447301864624) --8

TDS:UpgradeTimes(8, 2)
TDS:UpgradeTimes(7, 2)

TDS:Place("Mercenary Base", -14.894138336182, 0, -28.956447601318) --9
TDS:UpgradeTimes(9, 4)
TDS:SetOption(9, "Unit 1", "Riot Guard")
TDS:SetOption(9, "Unit 2", "Riot Guard")
TDS:SetOption(9, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -14.894138336182, 0, -28.956447601318) --10
TDS:UpgradeTimes(10, 4)
TDS:SetOption(10, "Unit 1", "Riot Guard")
TDS:SetOption(10, "Unit 2", "Riot Guard")
TDS:SetOption(10, "Unit 3", "Riot Guard")

TDS:Place("Mercenary Base", -14.894138336182, 0, -28.956447601318) --11
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

TDS:Place("Turret", -3.038432598114, 0, 5.5318174362183) --12
TDS:Place("Turret", -3.038432598114, 0, 5.5318174362183) --13
TDS:Place("Turret", -3.038432598114, 0, 5.5318174362183) --14

for _ = 1, 5 do
    for _, index in ipairs({12, 13, 14}) do
        TDS:Upgrade(index)
    end
end

TDS:LoopAbility(8, "Hologram Tower", {towerPosition = Vector3.new(-4.0475559234619, 1.5999932289124, -15.478811264038), towerToClone = 6})
