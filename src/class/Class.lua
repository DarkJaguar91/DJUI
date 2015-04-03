local DJUI = LibStub('DJUI')

if DJUI.Class then
	return
end

local function getClassNames(name)
	local _, _end, className = name:find('%s*(%a%w*)%s*%:?')

	if not name:find(':', _end) then
		return className
	end

	local baseName = nil
	_, _end, baseName = name:find('%s*(%a%w*)%s*', _end + 1)

	return className, baseName
end

local function createClass(classTable, ...)
	local classObj = {}

	local metaTable = {
		__index = classTable,
		__class__ = classTable,
	}

	for k, v in pairs(classTable) do
		local name = assert(tostring(k))

		if name:sub(0, 2) == '__' and not name:sub(-1) == '_' and type(v) == 'function' then
			metaTable[name] = v
		end
	end

	local outObj = setmetatable(classObj, metaTable)

	if classTable.__init__ then
		classTable.__init__(classObj, ...)
	end

	return outObj
end

DJUI.classes = {}
DJUI.class = function(name)
	local environment = DJUI.classes

	local className, baseName = getClassNames(name)

	local baseObj = nil
	if baseName then
		baseObj = assert(environment[baseName])
	end

	return function(classTable)
		local metaTable = {
			__call = createClass,
			__base__ = baseObj,
			__tostring = function(self) return className end,
			__index = function(_, key)
				if baseObj and baseObj[key] then
					return baseObj[key]
				end
			end,
		}

		local classObj = setmetatable(classTable, metaTable)

		environment[className] = classObj

		return classObj
	end
end
