local rock_installation_result = ""

---@class Plugin
local function is_luarocks_installed()
    local check_cmd

    if Comtrya.contexts.os == "windows" then
        check_cmd = "where luarocks > nul 2>&1"
    else
        check_cmd = "command -v luarocks > /dev/null 2>&1"
    end

    return os.execute(check_cmd)
end

local function install_luarocks()
    -- TODO: Still need to implement running package manager stuff in rust.
    -- But should look something like this:

    Comtrya.package.install("luarocks")
end

return {
    name = "luarocks",
    summary = function()
        return rock_installation_result
    end,
    actions = {
        install = {
            plan = function()
                if ~is_luarocks_installed() then
                    install_luarocks()
                end
            end,
            exec = function(rock_input)
                local rock_list
                if type(rock_input) == "string" then
                    rock_list = {rock_input}
                elseif type(rock_input) == "table" then
                    rock_list = rock_input
                else
                    rock_installation_result = "Rock installation failed: Invalid input type."
                    return false
                end

                if #rock_list == 0 then
                    rock_installation_result = "Rock installation complete: No rocks specified."
                    return true
                end

                local success_count = 0
                
                for i, rock_name in ipairs(rock_list) do
                    print(string.format("Installing rock: %s (%d/%d)", rock_name, i, #rock_list))

                    if os.execute("luarocks install " .. rock_name) then
                        success_count = success_count + 1
                    end
                end

                rock_installation_result = string.format("Luarocks rock installation complete: %d/%d installed.", success_count, #rock_list)

                return success_count == #rock_list
            end,
        },
        remove = {
            exec = function(rock_input, force)
                local rock_list
                if type(rock_input) == "string" then
                    rock_list = {rock_input}
                elseif type(rock_input) == "table" then
                    rock_list = rock_input
                else
                    rock_removal_result = "Rock removal failed: Invalid input type."
                    return false
                end

                if #rock_list == 0 then
                    rock_removal_result = "Rock removal complete: No rocks specified."
                    return true
                end

                local success_count = 0
                
                for i, rock_name in ipairs(rock_list) do
                    print(string.format("\n--- Attempting to remove rock: %s (%d/%d) ---", rock_name, i, #rock_list))

                    -- Construct the command to uninstall the rock
                    local command = "luarocks remove "
                    if force then
                        command = command .. "--force "
                    end
                    
                    if os.execute(command .. rock_name) then
                        success_count = success_count + 1
                    end
                end

                rock_removal_result = string.format("Rock removal complete: %d/%d removed.", success_count, #rock_list)

                return success_count == #rock_list
            end,
        },
    },
}
