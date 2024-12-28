local storage = require("storageAPI")

local import_chests = {"minecraft:chest_4"}

storage.setImportChests(import_chests)
storage.indexChests()
storage.importFromChests()