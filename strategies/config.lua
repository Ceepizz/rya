return {
    Towers = {
        Priority = {
            "Engineer",
            "Brawler",
            "Accelerator",
            "Hacker",
            "Necromancer",
            "Pursuit",
            "DJ Booth",
            "Commander",
            "Tesla",
            "Minigunner",
            "Ranger",
            "Gatling Gun",
            "Hunter",
            "Rocketeer",
            "Trapper",
            "Shotgunner",
            "Electroshocker",
            "Pyromancer",
            "Medic",
            "Assassin",
            "Farm",
            "Ace Pilot",
            "Freezer",
            "Military Base",
            "Militant",
            "Paintballer",
            "Scout",
            "Soldier",
            "Boomerang",
            "Sniper",
            "Demoman"
        },

        Info = {
            ["Engineer"] = {
                Type = "Currency",
                Currency = "Gems",
                Price = 4500,
                Level = 50
            },

            ["Brawler"] = {
                Type = "Currency",
                Currency = "Gems",
                Price = 1250,
                Level = 50
            },

            ["Accelerator"] = {
                Type = "Currency",
                Currency = "Gems",
                Price = 2500,
                Level = 50
            },

            ["Hacker"] = {
                Type = "Currency",
                Currency = "Gems",
                Price = 5500,
                Level = 50
            },

            ["Necromancer"] = {
                Type = "Currency",
                Currency = "Gems",
                Price = 2250,
                Level = 50
            },

            ["Turret"] = {
                Type = "Level",
                Level = 50
            },

            ["Mercenary Base"] = {
                Type = "Level",
                Level = 150
            },

            ["Pursuit"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 15000,
                Level = 100
            },

            ["DJ Booth"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 5000
            },

            ["Commander"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 4000
            },

            ["Tesla"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 6000
            },

            ["Mortar"] = {
                Type = "Level",
                Level = 75
            },

            ["Minigunner"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 8000
            },

            ["Ranger"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 12000
            },

            ["Gatling Gun"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 35000,
                Level = 175
            },

            ["Hunter"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 1000
            },

            ["Rocketeer"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 2500
            },

            ["Crook Boss"] = {
                Type = "Level",
                Level = 30
            },

            ["Trapper"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 3000
            },

            ["Shotgunner"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 850
            },

            ["Electroshocker"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 2500
            },

            ["Pyromancer"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 1250
            },

            ["Medic"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 2000
            },

            ["Assassin"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 800
            },

            ["Farm"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 2000
            },

            ["Ace Pilot"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 1500
            },

            ["Freezer"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 650
            },

            ["Military Base"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 4000
            },

            ["Militant"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 800
            },

            ["Paintballer"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 100
            },

            ["Scout"] = {
                Type = "Free"
            },

            ["Soldier"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 350
            },

            ["Boomerang"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 300
            },

            ["Sniper"] = {
                Type = "Free"
            },

            ["Demoman"] = {
                Type = "Currency",
                Currency = "Coins",
                Price = 200
            }
        }
    },

    Easy = {
        Win = {
            Priority = {
                "Black Spot Exchange",
                "Mason Arch",
                "Gilded Path",
                "Dead Ahead",
                "Lay By"
            },

            Maps = {
                ["Black Spot Exchange"] =
                    "strategies/easy/win/black_spot_exchange.lua",

                ["Mason Arch"] =
                    "strategies/easy/win/mason_arch.lua",

                ["Gilded Path"] =
                    "strategies/easy/win/gilded_path.lua",

                ["Dead Ahead"] =
                    "strategies/easy/win/dead_ahead.lua",

                ["Lay By"] =
                    "strategies/easy/win/lay_by.lua"
            }
        },

        Lose = {
            Priority = {
                "Meltdown",
                "Simplicity",
                "Stained Temple",
                "Midnight Issue",
                "Spring Fever"
            },

            Maps = {
                ["Meltdown"] =
                    "strategies/easy/lose/meltdown.lua",

                ["Simplicity"] =
                    "strategies/easy/lose/simplicity.lua",

                ["Stained Temple"] =
                    "strategies/easy/lose/stained_temple.lua",

                ["Midnight Issue"] =
                    "strategies/easy/lose/midnight_issue.lua",

                ["Spring Fever"] =
                    "strategies/easy/lose/spring_fever.lua"
            }
        }
    },

    Molten = {
        Priority = {
            "Wrecked Battlefield II",
            "Lighthaos",
            "Midnight Issue",
            "Nether"
        },

        Maps = {
            ["Wrecked Battlefield II"] =
                "strategies/molten/wrecked_battlefield_ii.lua",

            ["Lighthaos"] =
                "strategies/molten/lighthaos.lua",

            ["Midnight Issue"] =
                "strategies/molten/midnight_issue.lua",

            ["Nether"] =
                "strategies/molten/nether.lua"
        }
    },

    Hardcore = {
        Priority = {
            "Wretched Front"
        },

        Maps = {
            ["Wretched Front"] =
                "strategies/hardcore/wretched_front.lua"
        }
    },

    Fallen = {
        Priority = {
            "Construction Crazy",
            "The Heights",
            "Retro The Heights",
            "Forgetten Docks"
        },

        Maps = {
            ["Construction Crazy"] =
                "strategies/fallen/construction_crazy.lua",

            ["The Heights"] =
                "strategies/fallen/the_heights.lua",

            ["Retro The Heights"] =
                "strategies/fallen/retro_the_heights.lua",

            ["Forgetten Docks"] =
                "strategies/fallen/forgetten_docks.lua"
        }
    },

    Frost = {
        Priority = {
            "Lay By",
            "Dead Ahead",
            "Retro The Heights",
            "Construction Crazy",
            "Forgetten Docks",
            "Winter Abyss",
            "The Heights"
        },

        Maps = {
            ["Lay By"] =
                "strategies/frost/lay_by.lua",

            ["Dead Ahead"] =
                "strategies/frost/dead_ahead.lua",

            ["Retro The Heights"] =
                "strategies/frost/retro_the_heights.lua",

            ["Construction Crazy"] =
                "strategies/frost/construction_crazy.lua",

            ["Forgetten Docks"] =
                "strategies/frost/forgetten_docks.lua",

            ["Winter Abyss"] =
                "strategies/frost/winter_abyss.lua",

            ["The Heights"] =
                "strategies/frost/the_heights.lua"
        }
    }
}
