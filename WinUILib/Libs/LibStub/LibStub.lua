--- LibStub — Library Version Negotiation
-- Minimal implementation for WoW addon library versioning.
-- Compatible with the standard LibStub API used by Ace3 and other libraries.
-- If a newer LibStub is already loaded, this file is a no-op.
-------------------------------------------------------------------------------

local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2

local LibStub = _G[LIBSTUB_MAJOR]

if not LibStub or LibStub.minor < LIBSTUB_MINOR then
    LibStub = LibStub or { libs = {}, minors = {} }
    _G[LIBSTUB_MAJOR] = LibStub
    LibStub.minor = LIBSTUB_MINOR

    ---@param major string  Library major version string (e.g. "MyLib-1.0")
    ---@param minor number  Library minor revision number
    ---@return table|nil lib  The library table, or nil if a newer version is loaded
    ---@return number|nil oldMinor  Previous minor version, if upgrading
    function LibStub:NewLibrary(major, minor)
        assert(type(major) == "string",
            "Bad argument #1 to `NewLibrary' (string expected)")
        minor = assert(tonumber(strmatch(tostring(minor), "%d+")),
            "Minor version must be a number or contain a number")

        local oldMinor = self.minors[major]
        if oldMinor and oldMinor >= minor then return nil end

        self.minors[major] = minor
        self.libs[major] = self.libs[major] or {}
        return self.libs[major], oldMinor
    end

    ---@param major string  Library major version string
    ---@param silent? boolean  If true, return nil instead of erroring
    ---@return table|nil lib
    ---@return number|nil minor
    function LibStub:GetLibrary(major, silent)
        if not self.libs[major] and not silent then
            error(("Cannot find a library instance of %q."):format(
                tostring(major)), 2)
        end
        return self.libs[major], self.minors[major]
    end

    ---@return fun(): string, table
    function LibStub:IterateLibraries()
        return pairs(self.libs)
    end

    setmetatable(LibStub, { __call = LibStub.GetLibrary })
end
