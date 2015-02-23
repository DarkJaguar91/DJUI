----------------------------------------------------------------------------------
-- Created by: Brandon Talbot ( -_Dark-Jaguar_- )                               --
----------------------------------------------------------------------------------

DJStaminaBar = DJPowerBar("StaminaBar")
:SetBarColor(0.2, 1, 0.2, 1)
:SetTexture("Darkjaguar/resources/images/bartex.dds")
:SetEventManager(DJUIEventManager, "player", POWERTYPE_STAMINA)
:SetSize(300, 15)
:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

DJHealthBar = DJPowerBar("HealthBar")
:SetBarColor(1, 0.1, 0.2, 1)
:SetTexture("Darkjaguar/resources/images/fer14.png")
:SetEventManager(DJUIEventManager, "player", POWERTYPE_HEALTH)
:SetSize(300, 15)
:SetAnchor(BOTTOMLEFT, DJStaminaBar.tlw, TOPLEFT, 0, 0)

DJManaBar = DJPowerBar("ManaBar")
:SetBarColor(0.1, 0.2, 1, 1)
:SetEventManager(DJUIEventManager, "player", POWERTYPE_MAGICKA)
:SetSize(300, 15)
:SetAnchor(TOPLEFT, DJStaminaBar.tlw, BOTTOMLEFT, 0, 0)