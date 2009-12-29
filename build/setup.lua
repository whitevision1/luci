local SYSROOT = os.getenv("LUCI_SYSROOT")

-- override uci access
local uci_core  = require "uci"
local uci_model = require "luci.model.uci"

uci_model.cursor = function(config, save)
	return uci_core.cursor(config or SYSROOT .. "/etc/config", save or SYSROOT .. "/tmp/.uci")
end

uci_model.cursor_state = function()
	return uci_core.cursor(SYSROOT .. "/etc/config", SYSROOT .. "/var/state")
end

uci_model.inst = uci_model.cursor()
uci_model.inst_state = uci_model.cursor_state()

-- override uvl access
local uvl_model = require "luci.uvl"
local uvl_init  = uvl_model.UVL.__init__

uvl_model.UVL.__init__ = function(self, schemedir)
	uvl_init(self, schemedir or SYSROOT .. "/lib/uci/schema")
end

-- allow any password in local sdk
local sys = require "luci.sys"
sys.user.checkpasswd = function() return true end

-- dummy sysinfo on Darwin
require "nixio"

if not nixio.sysinfo then
	function nixio.sysinfo()
		return {
			bufferram = 0,
			freehigh = 0,
			freeram = 0,
			freeswap = 0,
			loads = { 0.0, 0.0, 0.0 },
			mem_unit = 1024,
			procs = 0,
			sharedram = 0,
			totalhigh = 0
		}
	end
end
