
TDS:Loadout("Trapper", "Hacker", "Gatling Gun", "Mercenary Base", "DJ Booth")

TDS:Mode("Frost")

TDS:GameInfo("Construction Crazy", {
    "HiddenEnemies",
    "Glass",
    "ExplodingEnemies",
    "Limitation",
    "Committed",
    "Quarantine",
    "Fog"
})

TDS:Mercenary(140, 1)
TDS:VoteSkip(11, 39)

TDS:Place("Trapper", -1.1427366733551025, 4.750006198883057, 3.680018901824951) --1
TDS:Ready()

TDS:Place("Trapper", 5.823723793029785, 3.4050028324127197, -12.659399032592773) --2
TDS:Place("Trapper", 5.823723793029785, 3.4050028324127197, -12.659399032592773) --3
TDS:Place("Trapper", -1.1427366733551025, 4.750006198883057, 3.680018901824951) --4
TDS:Place("Trapper", -1.1427366733551025, 4.750006198883057, 3.680018901824951) --5

TDS:UpgradeTimes(5, 2)
TDS:SetOption(5, "Trap", "Landmine")
TDS:SetTarget(5, "Last")
TDS:SetTarget(5, "Strongest")

TDS:Upgrade(4)
TDS:Upgrade(1)

TDS:Place("Trapper", -1.1427366733551025, 4.750006198883057, 3.680018901824951) --6

TDS:Upgrade(1)
TDS:SetOption(1, "Trap", "Landmine")

TDS:Upgrade(4)
TDS:SetOption(4, "Trap", "Landmine")

TDS:Place("Gatling Gun", -39.97031021118164, 3.2550060749053955, -1.2429859638214111) --7
TDS:UpgradeTimes(7, 2)

TDS:UpgradeTimes(6, 2)
TDS:SetOption(6, "Trap", "Landmine")

TDS:UpgradeTimes(2, 2)
TDS:SetOption(2, "Trap", "Landmine")

TDS:UpgradeTimes(3, 2)
TDS:SetOption(3, "Trap", "Landmine")

TDS:Place("Trapper", 5.823723793029785, 3.4050028324127197, -12.659399032592773) --8
TDS:UpgradeTimes(8, 2)
TDS:SetOption(8, "Trap", "Landmine")

TDS:Place("Hacker", 5.823723793029785, 3.4050028324127197, -12.659399032592773) --9
TDS:Place("Hacker", 5.823723793029785, 3.4050028324127197, -12.659399032592773) --10

TDS:UpgradeTimes(9, 2)
TDS:UpgradeTimes(10, 2)

TDS:Place("DJ Booth", -39.97031021118164, 3.2550060749053955, -1.2429859638214111) --11
TDS:UpgradeTimes(11, 3)
TDS:SetOption(11, "Track", "Green")

TDS:Place("Mercenary Base", -39.97031021118164, 3.2550060749053955, -1.2429859638214111) --12
TDS:UpgradeTimes(12, 4)

for slot = 1, 3 do
    TDS:SetOption(12, "Unit " .. slot, "Riot Guard")
end

TDS:Place("Mercenary Base", -39.97031021118164, 3.2550060749053955, -1.2429859638214111) --13
TDS:UpgradeTimes(13, 4)

for _, slot in ipairs({2, 3, 1}) do
    TDS:SetOption(13, "Unit " .. slot, "Riot Guard")
end

TDS:Place("Mercenary Base", -39.97031021118164, 3.2550060749053955, -1.2429859638214111) --14
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

TDS:LoopAbility(9, "Hologram Tower", {towerPosition = TDS:StackPosition(-40.625732421875, 3.2550060749053955, 9.564187049865723, 0), towerToClone = 7})
