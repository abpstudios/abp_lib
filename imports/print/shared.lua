---@enum PrintLevel
local printLevel = {
    error = 1,
    warn = 2,
    info = 3,
    verbose = 4,
    debug = 5,
}

local oldPrint = print

local levelPrefixes = {
    '^1[ERROR]',
    '^3[WARN]',
    '^7[INFO]',
    '^4[VERBOSE]',
    '^2[DEBUG]',
}

local resourcePrintLevel = printLevel[abplib.debugLevel]
local template = ('^5[%s] %%s \n%%s^7'):format(abpcache.resource)

---Prints to console conditionally based on what Distrito:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level PrintLevel
---@param ... any
local function libPrint(level, ...)
    if level > resourcePrintLevel then return end

    local args = { ... }
    local str = ""

    for i = 1, #args do
        local arg = args[i]
        if arg == nil then
            str = str .. ' ' .. "nil"
        end

        if type(arg) == "boolean" then
            str = str .. ' ' .. (tostring(arg))
        elseif type(arg) == "function" then
            str = str .. ' ' .. ('This is a function, can´t be displayed.')
        elseif type(arg) == "table" then
            str = str .. ' ' .. (abplib.table.dump(arg))
        else
            str = str .. ' ' .. tostring(arg)
        end
    end

    if str:len() == 0 then
        str = "nil"
    end

    oldPrint(template:format(levelPrefixes[level], str))
end

abplib.print = {}
abplib.print = setmetatable({}, {
    __call = function(_, ...)
        libPrint(printLevel.debug, ...)
    end
})

abplib.print.error = function(...) libPrint(printLevel.error, ...) end
abplib.print.warn = function(...) libPrint(printLevel.warn, ...) end
abplib.print.info = function(...) libPrint(printLevel.info, ...) end
abplib.print.verbose = function(...) libPrint(printLevel.verbose, ...) end
abplib.print.debug = function(...) libPrint(printLevel.debug, ...) end

---Sets the print level for the resource.
---@param level PrintLevel | string
---@return function
abplib.print.setDebugLevel = function(level)
    resourcePrintLevel = printLevel[level]
end

--print = abplib.print.debug(...)

-- Example usage:
-- abplib.print.debug("This is a debug message.")
return abplib.print