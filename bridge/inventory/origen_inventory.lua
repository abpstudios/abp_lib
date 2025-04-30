return {

    Shared = {
        getItemImageURI = function(i, item)
            return 'https://cfx-nui-origen_inventory/html/images/' .. item .. '.png'
        end,

        getItems = function(i)
            return i:Items()
        end
    },

    Client = {
        get = function(i)
            return i:GetInventory()
        end,

        hasItem = function(i, itemName)
            return i:HasItem(itemName)
        end
    },

    Server = {
        getItem = function(i, name)
            return i:Items(name)
        end,

        hasItem = function(i, playerId, item, amount)
            return i:HasItem(playerId, item, amount)
        end,

        addItem = function(i, playerId, item, amount)
            return i:AddItem(playerId, item, amount)
        end,

        removeItem = function(i, playerId, item, amount)
            return i:RemoveItem(playerId, item, amount)
        end,

        canCarryItem = function(i, playerId, item, amount)
            return i:CanCarryItem(playerId, item, amount)
        end,

        get = function(i, playerId)
            return i:GetInventory(playerId).inventory
        end,

        getItemCount = function(i, playerId, item)
            return i:GetItemTotalAmount(playerId, item)
        end
    },

}