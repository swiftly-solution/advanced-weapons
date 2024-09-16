AddEventHandler("OnPluginStart", function (event)
    config:Create("advanced-weapons", {
        weapons = {}
    })

    local weapons = config:Fetch("advanced-weapons.weapons")

    for weapon_name, weapon_data in next,weapons,nil do
        if weapon_data.model and string.len(weapon_data.model or "") > 0 then
            precacher:PrecacheModel(weapon_data.model)
        end
    end
end)

AddEventHandler("OnEntityCreated", function (event, entityptr)
    local designername = CEntityInstance(entityptr).Entity.DesignerName

    if designername:find("weapon") then
        NextTick(function()
            local weapon_name = ItemDefIdx[CBasePlayerWeapon(entityptr).Parent.AttributeManager.Item.ItemDefinitionIndex]

            if config:Exists(string.format("advanced-weapons.weapons.%s.model", weapon_name)) then
                local model = config:Fetch(string.format("advanced-weapons.weapons.%s.model", weapon_name))
                CBaseModelEntity(entityptr):SetModel(model)
            end
        end)
    end
end)

AddEventHandler("OnEntitySpawned", function (event, entityptr)
    local designername = CEntityInstance(entityptr).Entity.DesignerName

    if designername:find("weapon") then
        NextTick(function()
            local weapon_name = ItemDefIdx[CBasePlayerWeapon(entityptr).Parent.AttributeManager.Item.ItemDefinitionIndex]
            local weapon_data = config:Fetch(string.format("advanced-weapons.weapons.%s", weapon_name))
            if not weapon_data then return end

            local weaponvdata = CCSWeaponBaseVData(CBaseEntity(entityptr):GetVData():ToPtr())

            if weapon_data.clip ~= nil and weapon_data.clip > 0 then
                weaponvdata.Parent.MaxClip1 = weapon_data.clip
                weaponvdata.Parent.MaxClip2 = weapon_data.clip
            end

            if weapon_data.ammo ~= nil and weapon_data.ammo > 0 then
                weaponvdata.PrimaryReserveAmmoMax = weapon_data.ammo
                weaponvdata.SecondaryReserveAmmoMax = weapon_data.ammo
            end
        end)
    end
end)

AddEventHandler("OnWeaponFire", function (event)
    local player = GetPlayer(event:GetInt("userid"))
    if not player then return end
    if not player:IsValid() then return end

    local activeweapon = player:CBasePlayerPawn().WeaponServices.ActiveWeapon
    if not activeweapon:IsValid() then return end

    local current_weapon = ItemDefIdx[activeweapon.Parent.AttributeManager.Item.ItemDefinitionIndex]
    if not current_weapon then return end

    local weapon_data = config:Fetch(string.format("advanced-weapons.weapons.%s", current_weapon))
    if not weapon_data then return end

    if weapon_data.unlimitedclip then
        activeweapon.Clip1 = activeweapon.Clip1 + 1
    end

    if weapon_data.unlimitedammo then
        local reserveAmmo = activeweapon.ReserveAmmo
        reserveAmmo[2] = reserveAmmo[2] + 1
        activeweapon.ReserveAmmo = reserveAmmo
    end
end)