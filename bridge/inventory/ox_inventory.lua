return {

    Shared = {
        getItemImageURI = function(i, item)
            return 'https://cfx-nui-ox_inventory/web/images/' .. item .. '.png'
        end
    },

    Client = {
        get = function(i)
            return i:GetInventory()
        end,

        hasItem = function(i, itemName)
            return i:GetItemCount(itemName) > 0
        end
    },

    Server = {
        getItem = function(i, name)
            return i:Items(name)
        end,

        hasItem = function(i, playerId, item, amount)
            local itemCount = i:GetItem(playerId, item, false, true)
            if amount and itemCount >= amount then
                return true
            end

            if not amount and itemCount > 0 then
                return false
            end

            return false
        end,

        addItem = function(i, playerId, item, amount, metadata)
            return i:AddItem(playerId, item, amount, metadata)
        end,

        removeItem = function(i, playerId, item, amount)
            return i:RemoveItem(playerId, item, amount)
        end,

        canCarryItem = function(i, playerId, item, amount)
            return i:CanCarryItem(playerId, item, amount)
        end,

        get = function(i, playerId)
            return i:GetInventory(playerId, false)
        end,

        getItemCount = function(i, playerId, item)
            return i:GetItem(playerId, item, false, true)
        end
    },

}