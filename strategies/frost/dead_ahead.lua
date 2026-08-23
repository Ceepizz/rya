TDS:Loadout("Trapper", "Hacker", "Gatling Gun", "Mercenary Base", "DJ Booth")

TDS:Mode("Frost")

TDS:GameInfo("Dead Ahead", {
    "HiddenEnemies",
    "Glass",
    "ExplodingEnemies",
    "Limitation",
    "Committed",
    "Quarantine",
    "Fog"
})

TDS:Mercenary(80, 1)
TDS:VoteSkip(11, 39)

TDS:Place("Trapper", 3.37874698638916, 3.999997615814209, 11.550716400146484) --1
TDS:Ready()

TDS:Place("Trapper", 2.4502341747283936, 3.9999938011169434, -13.815633773803711) --2
TDS:Place("Trapper", 2.4502341747283936, 3.9999938011169434, -13.815633773803711) --3
TDS:Place("Trapper", 3.37874698638916, 3.999997615814209, 11.550716400146484) --4
TDS:Place("Trapper", 3.37874698638916, 3.999997615814209, 11.550716400146484) --5

TDS:UpgradeTimes(5, 2)
TDS:SetOption(5, "Trap", "Landmine")
TDS:SetTarget(5, "Last")
TDS:SetTarget(5, "Strongest")

TDS:Upgrade(4)
TDS:Upgrade(1)

TDS:Place("Trapper", 3.37874698638916, 3.999997615814209, 11.550716400146484) --6

TDS:Upgrade(1)
TDS:SetOption(1, "Trap", "Landmine")

TDS:Upgrade(4)
TDS:SetOption(4, "Trap", "Landmine")

TDS:Place("Gatling Gun", -2.3217856884002686, 3.999992609024048, 38.978782653808594) --7
TDS:UpgradeTimes(7, 2)

TDS:UpgradeTimes(6, 2)
TDS:SetOption(6, "Trap", "Landmine")

TDS:UpgradeTimes(2, 2)
TDS:SetOption(2, "Trap", "Landmine")

TDS:UpgradeTimes(3, 2)
TDS:SetOption(3, "Trap", "Landmine")

TDS:Place("Trapper", 2.4502341747283936, 3.9999938011169434, -13.815633773803711) --8
TDS:UpgradeTimes(8, 2)
TDS:SetOption(8, "Trap", "Landmine")

TDS:Place("Hacker", 2.4502341747283936, 3.9999938011169434, -13.815633773803711) --9
TDS:Place("Hacker", 2.4502341747283936, 3.9999938011169434, -13.815633773803711) --10

TDS:UpgradeTimes(9, 2)
TDS:UpgradeTimes(10, 2)

TDS:Place("DJ Booth", -2.3217856884002686, 3.999992609024048, 38.978782653808594) --11
TDS:UpgradeTimes(11, 3)
TDS:SetOption(11, "Track", "Green")

TDS:Place("Mercenary Base", -2.3217856884002686, 3.999992609024048, 38.978782653808594) --12
TDS:UpgradeTimes(12, 4)

for slot = 1, 3 do
    TDS:SetOption(12, "Unit " .. slot, "Riot Guard")
end

TDS:Place("Mercenary Base", -2.3217856884002686, 3.999992609024048, 38.978782653808594) --13
TDS:UpgradeTimes(13, 4)

for _, slot in ipairs({2, 3, 1}) do
    TDS:SetOption(13, "Unit " .. slot, "Riot Guard")
end

TDS:Place("Mercenary Base", -2.3217856884002686, 3.999992609024048, 38.978782653808594) --14
TDS:UpgradeTimes(14, 4)

for slot = 1, 3 do
    TDS:SetOption(14, "Unit " .. slot, "Riot Guard")
end

for _, index in ipairs({12, 13, 14}) do
    TDS:Upgrade(index)
end

TDS:UpgradeTimes(11, 2)
TDS:UpgradeTimes(7, 2)

for _, index in ipairs({12, 13, 14}) do
    TDS:Upgrade(index)
end

TDS:WaitForWave(33)

TDS:UpgradeTimes(7, 2)

TDS:UpgradeTimes(9, 2)
TDS:Upgrade(9, 2)

TDS:UpgradeTimes(10, 2)
TDS:Upgrade(10, 2)

for _, index in ipairs({6, 5}) do
    TDS:UpgradeTimes(index, 2)
    TDS:SetOption(index, "Trap", "Bear Traps")
end

for _, index in ipairs({1, 4, 2, 3, 8}) do
    TDS:UpgradeTimes(index, 2)
end

TDS:SetOption(11, "Track", "Red")

TDS:LoopAbility(9, "Hologram Tower", {towerPosition = TDS:StackPosition(-12.547797203063965, 3.999992609024048, 40.41588592529297, 0), towerToClone = 7})

