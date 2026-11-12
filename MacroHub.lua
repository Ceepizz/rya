local scripts = {
    [1176784616] = "https://raw.githubusercontent.com/Ceepizz/rya/refs/heads/main/AutoProgress.lua",
    [123456789] = "https://example.com/other-game.lua",
}

local url = scripts[game.GameId]

if url then
    pcall(function()
        local source = game:HttpGet(url)
        local run = assert(loadstring(source))
        run()
    end)
end
