for addon in Convars:GetStr("default_enabled_addons_list"):gmatch("[^,]+") do
	pcall(require, addon)
end
