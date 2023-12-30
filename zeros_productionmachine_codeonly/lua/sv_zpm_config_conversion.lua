zpm = zpm or {}
zpm.Item = zpm.Item or {}
zpm.Item.IngredientClass = {}

/*

	Here we can specify some other entity classes which are accepted as ingredients

*/

zpm.Item.Conversion = {}
local function AddConversion(class,func)
	zpm.Item.IngredientClass[class] = true
	zpm.Item.Conversion[class] = zpm.Item.Conversion[class] or {}
	table.insert(zpm.Item.Conversion[class],func)
end

/*
AddConversion("entity_class",function(ent)
	if SomeOptionalCheck then return end
	return ZPM_ITEM_ID , Amount
end)
*/

AddConversion("sent_ball",function(ent)
	return ZPM_INGREDIENT_APPLE , 10
end)
