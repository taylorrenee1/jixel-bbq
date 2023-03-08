Config = {
    Lan = "en",
    Notify = "qb",
    Inv = "qb", -- change to ox if ox inv
    img = "lj-inventory/html/images/", -- set this to what your inventory directory is
    Menu = "jixel",
    JimMenu = false,
    CookingTime = 10000,
    CoreName = "qb-core",
    PrintDebug = false,
    StressRelief = 10,

}

Props = {
    Food = {
        SausageModel = "prop_cs_steak", --<--- need to make
        SteakModel = "prop_cs_steak",
        BurgerModel = "prop_cs_steak", --<--- need to make
        BaconModel = "prop_cs_steak",
        PorkChop = "prop_cs_steak",
        DefaultModel = "prop_cs_steak",
    },
    BBQ = {
        BBQ1 = { itemName = "bbq1", prop ="prop_bbq_1" },
        BBQ2 = { itemName = "bbq2", prop ="prop_bbq_2" },
        BBQ3 = { itemName = "bbq3", prop ="prop_bbq_3" },
        BBQ4 = { itemName = "bbq4", prop ="prop_bbq_4" },
        BBQ5 = { itemName = "bbq5", prop ="prop_bbq_5" },
    }
}

Crafting = {
	Prepare = {
		{ ['hotdog'] = {  ['cookedsausage'] = 1, ['hotdogbun'] = 1  } },
		{ ['hamburger'] = {  ['burgerbun'] = 2, ['burgerpatty'] = 1, ['lettuce'] = 1 } },
        { ['cheeseburger'] = { ['cheese'] = 1, ['burgerbun']= 2, ['burgerpatty'] = 1, ["lettuce"] = 1 } },

	},
    BBQ = {
        { ['cookedsausage'] = {['rawsausage'] = 1}},
        { ['porkchop'] = {['rawpork'] = 1}},
        { ['burgerpatty'] = {['groundbeef'] = 1}},
        { ['steak'] = {['rawbeef'] = 1}},
    }
}

Loc = {}
