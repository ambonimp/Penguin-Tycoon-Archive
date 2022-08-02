local AllQuests = {
	["Easy"] = {
		["Catch"] = {
			{"Rare","Fish",1,"Catch a rare fish"},
			{"Epic","Fish",1,"Catch an epic fish"},
			{"Junk","Sea Weed",5,"Catch 5 seaweed"},
			{"Junk","Old Boots",5,"Catch 5 old boots"},
			{"Junk","Bottle",5,"Catch 5 bottles"},
		},
		["Win"] = {
			{"Minigame","Soccer",1,"Win a game of soccer"},
		},
		["Collect"] = {
			{"Minigame","Candy Rush",50,"Collect 50 candy in candy rush"},
			{"Minigame","Ice Cream Extravaganza",50,"Collect 50 ice cream in ice cream extravanza"},
			{"Minigame","Soccer",3,"Score 3 goals in soccer"},
			{"Woodcutting","Tree",20,"Chop 20 trees", "Axe#1"}
		},
		
	},
	["Medium"] = {
		["Catch"] = {
			{"Legendary","Fish",1,"Catch a legendary fish"},
			{"Junk","Sea Weed",10,"Catch 10 seaweed"},
			{"Junk","Old Boots",10,"Catch 10 old boots"},
			{"Junk","Bottle",10,"Catch 10 bottles"},
		},
		["Win"] = {
			{"Minigame","Falling Tiles",1,"Win a game of falling tiles"},
			{"Minigame","Skate Race",1,"Win a game of skate race"},
		},
		["Collect"] = {
			{"Minigame","Candy Rush",100,"Collect 100 candy in candy rush"},
			{"Minigame","Ice Cream Extravaganza",100,"Collect 100 ice cream in ice cream extravanza"},
			{"Minigame","Soccer",5,"Score 5 goals in soccer"},
			{"Woodcutting","Tree",60,"Chop 60 trees", "Axe#1"}
		},
		
	},

	["Hard"] = {
		["Catch"] = {
			{"Mythic","Fish",1,"Catch a mythic fish"},
		},
		["Win"] = {
			{"Minigame","Falling Tiles",3,"Win 3 games of falling tiles"},
			{"Minigame","Candy Rush",3,"Win 3 games of candy rush"},
			{"Minigame","Ice Cream Extravaganza",3,"Win 3 games of candy rush"},
			{"Minigame","All",6,"Win one of every minigame"}
		},
		["Collect"] = {
			{"Minigame","Candy Rush",250,"Collect 250 candy in candy rush"},
			{"Minigame","Ice Cream Extravaganza",200,"Collect 200 ice cream in ice cream extravanza"},
			{"Minigame","Soccer",15,"Score 15 goals in soccer"},
			{"Woodcutting","Tree",120,"Chop 120 trees", "Axe#1"}
		},
		
	},
	
	["Types"] = {
		"Catch","Win","Collect"
	}

}




return AllQuests