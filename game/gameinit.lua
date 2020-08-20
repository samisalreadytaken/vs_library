for addon in Convars:GetStr("default_enabled_addons_list"):gmatch("[^,]+") do
	if not pcall(require,addon) then
		pcall(require,addon..".init")
	end
end
