return {
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
                ["Black Spot Exchange"] = "strategies/easy/win/black_spot_exchange.lua",
                ["Mason Arch"] = "strategies/easy/win/mason_arch.lua",
                ["Gilded Path"] = "strategies/easy/win/gilded_path.lua",
                ["Dead Ahead"] = "strategies/easy/win/dead_ahead.lua",
                ["Lay By"] = "strategies/easy/win/lay_by.lua"
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
                ["Meltdown"] = "strategies/easy/lose/meltdown.lua",
                ["Simplicity"] = "strategies/easy/lose/simplicity.lua",
                ["Stained Temple"] = "strategies/easy/lose/stained_temple.lua",
                ["Midnight Issue"] = "strategies/easy/lose/midnight_issue.lua",
                ["Spring Fever"] = "strategies/easy/lose/spring_fever.lua"
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
            ["Wrecked Battlefield II"] = "strategies/molten/wrecked_battlefield_ii.lua",
            ["Lighthaos"] = "strategies/molten/lighthaos.lua",
            ["Midnight Issue"] = "strategies/molten/midnight_issue.lua",
            ["Nether"] = "strategies/molten/nether.lua"
        }
    },

    Hardcore = {
        Priority = {
            "Wretched Front"
        },

        Maps = {
            ["Wretched Front"] = "strategies/hardcore/wretched_front.lua"
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
            ["Construction Crazy"] = "strategies/fallen/construction_crazy.lua",
            ["The Heights"] = "strategies/fallen/the_heights.lua",
            ["Retro The Heights"] = "strategies/fallen/retro_the_heights.lua",
            ["Forgetten Docks"] = "strategies/fallen/forgetten_docks.lua"
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
            ["Lay By"] = "strategies/frost/lay_by.lua",
            ["Dead Ahead"] = "strategies/frost/dead_ahead.lua",
            ["Retro The Heights"] = "strategies/frost/retro_the_heights.lua",
            ["Construction Crazy"] = "strategies/frost/construction_crazy.lua",
            ["Forgetten Docks"] = "strategies/frost/forgetten_docks.lua",
            ["Winter Abyss"] = "strategies/frost/winter_abyss.lua",
            ["The Heights"] = "strategies/frost/the_heights.lua"
        }
    }
}
