--[[
    desc: Java style object-oriented helper functions for Lua
    author: Elvin Zeng
    date: 2017-6-1
--]]


local P = {} --  package
if _REQUIREDNAME == nil then
    joo4lua = P
else
    _G[_REQUIREDNAME] = P
end
--  setmetatable(P, {__index = _G})
--  setfenv(1, P)


local SUPER_CLASS_FIELD_NAME = "__joo4lua_superClass"
local INTERFACES_FIELD_NAME = "__joo4lua_baseInterfaces"
local CLASS_OBJECT_FLAG_FIELD_NAME = "__joo4lua_isClass"


--  find member from super classes
local function findMember(member, superClasses)
    for _, parentClass in ipairs(superClasses) do
        local v = parentClass[member]
        if v then return v end
    end
end

--  create a interface with specified super interfaces.
--  if number of parameters is zero, it will extends from {}.
function P.createInterface(...)
    local derivedInterface = {}
    derivedInterface[INTERFACES_FIELD_NAME] = {...}

    function derivedInterface:declareMedhod(methodName, methodDesc)
        if not methodName then
            error("First parameter 'methodName' can not be nil.")
        end
        if not methodDesc then
            error("Second parameter 'methodDesc' can not be nil.")
        end
        rawset(self, methodName, function()
            error("Method '" .. methodName .. "' is not implemented. \n" .. methodDesc)
        end)
    end

    setmetatable(derivedInterface, {
        __index = function(table, key)
            return findMember(key, arg)
        end,
        __newindex = function (t, k, v)
            error("Can not add member to a interface.", 2)
        end
    })

    return derivedInterface
end

--  create class from specified super classes
local function createClass(...)
    local derivedClass = {}

    setmetatable(derivedClass, {
        __index = function(table, key)
            return findMember(key, arg)
        end
    })

    derivedClass[CLASS_OBJECT_FLAG_FIELD_NAME] = true
    function derivedClass:new(o)
        if self[CLASS_OBJECT_FLAG_FIELD_NAME] then
            o = o or {}
            setmetatable(o, derivedClass)
            derivedClass.__index = derivedClass
            self[CLASS_OBJECT_FLAG_FIELD_NAME] = false
            return o
        else
            error("Only Class object can Instantiate, this object is an Instance.")
        end
    end

    return derivedClass
end

--  create a class with specified super class.
--  just single inheritance.
--  if number of parameters is zero, derived class will extends from {}.
function P.createClass(...)
    local superClass = {};
    if #arg > 1 then
        error("Java style object-oriented programming just support single inheritance.")
    elseif 1 == #arg then
        superClass = arg[1]
    end
    local derivedClass = createClass(superClass)
    derivedClass[SUPER_CLASS_FIELD_NAME] = superClass

    function derivedClass:implements(...)
        if #arg < 1 then
            error("Parameters can not be nil.")
        end
        local extendedClass = createClass(self, arg)
        derivedClass[INTERFACES_FIELD_NAME] = {...}
        return extendedClass
    end

    return derivedClass
end


return P