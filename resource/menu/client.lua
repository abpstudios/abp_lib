local Menu                  = {}
Menu.RegisteredTypes        = {}
Menu.Opened                 = {}

Menu.RegisterType = function(type, open, close)
	Menu.RegisteredTypes[type] = {
		open  = open,
		close = close
	}
end

exports('menu_registerType', Menu.RegisterType)

Menu.Open = function(type, name, data, submit, cancel, change, close)
	local menu = {}
	local nope = function() end
	local nopeCancel = function() menu.close() end
	local namespace = GetInvokingResource()

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel or nopeCancel
	menu.change    = change or nope
	menu.closeFunc = close or nope

	menu.close = function()

		if Menu.RegisteredTypes[type] then
			Menu.RegisteredTypes[type].close(namespace, name)
		end

		for i = 1, #Menu.Opened, 1 do
			if Menu.Opened[i] then
				if Menu.Opened[i].type == type and Menu.Opened[i].namespace == namespace and Menu.Opened[i].name == name then
					Menu.Opened[i] = nil
				end
			end
		end

		if menu.closeFunc then menu.closeFunc() end
	end

	menu.update = function(query, newData)

		for i = 1, #menu.data.elements, 1 do
			local match = true

			for k, v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k, v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

		menu.refresh()
	end

	menu.onSubmit = function(submit)
		menu.submit = submit
	end

	menu.onChange = function(change)
		menu.change = change
	end

	menu.onClose = function(close)
		menu.closeFunc = close
	end

	menu.refresh = function()
		Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val, refresh)
		menu.data.elements[i][key] = val
		if refresh then
			menu.refresh()
		end
	end

	menu.setElementByValue = function(searchValue, key, val, refresh)
		for i = 1, #menu.data.elements, 1 do
			if menu.data.elements[i].value == searchValue then
				menu.data.elements[i][key] = val
				if refresh then
					menu.refresh()
				end
			end
		end
	end

	menu.setElements = function(newElements)
		menu.data.elements = newElements
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i = 1, #menu.data.elements, 1 do
			for k, v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	menu.getItemByKey = function(key, value)
		for i = 1, #menu.data.elements, 1 do
			if menu.data.elements[i][key] == value then
				return menu.data.elements[i]
			end
		end
		return nil
	end

	menu.getItemByValue = function(value)
		for i = 1, #menu.data.elements, 1 do
			if menu.data.elements[i].value == value then
				return menu.data.elements[i]
			end
		end
		return nil
	end

	table.insert(Menu.Opened, menu)
	Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end
exports('menu_open', Menu.Open)

Menu.Close = function(type, namespace, name)
	for i = 1, #Menu.Opened, 1 do
		if Menu.Opened[i] then
			if Menu.Opened[i].type == type and Menu.Opened[i].namespace == namespace and
				Menu.Opened[i].name == name then
				Menu.Opened[i].close()
				Menu.Opened[i] = nil
			end
		end
	end
end

Menu.CloseAll = function()
	for i = 1, #Menu.Opened, 1 do
		if Menu.Opened[i] then
			Menu.Opened[i].close()
			Menu.Opened[i] = nil
		end
	end
end
exports('menu_closeAll', Menu.CloseAll)

Menu.GetOpened = function(type, namespace, name)
	for i = 1, #Menu.Opened, 1 do
		if Menu.Opened[i] then
			if Menu.Opened[i].type == type and Menu.Opened[i].namespace == namespace and
				Menu.Opened[i].name == name then
				return Menu.Opened[i]
			end
		end
	end
end
exports('menu_getOpened', Menu.GetOpened)

Menu.GetOpenedMenus = function()
	return Menu.Opened
end
exports('menu_getOpenedMenus', Menu.GetOpenedMenus)

Menu.IsOpen = function(type, namespace, name)
	return Menu.GetOpened(type, namespace, name) ~= nil
end

AddEventHandler('onResourceStop', function(resource)
	for i = 1, #Menu.Opened, 1 do
		if Menu.Opened[i] then
			if Menu.Opened[i].namespace == resource then
				Menu.Opened[i].close()
				Menu.Opened[i] = nil
			end
		end
	end
end)