local Format = require(script.Parent.Format)

return {
	["Total Money"] = {
		DataStore = ("Total Money_v-RELEASE"),
		smallestFirst = false;
	};
	["Total Gems"] = {
		DataStore = ("Total Gems_v-RELEASE"),
		smallestFirst = false;
	};
	["Hearts"] = {
		DataStore = ("Hearts_v-RELEASE"),
		smallestFirst = false;
	};
	["Skate Race Record"] = {
		DataStore = ("Skate Race Record_v-RELEASE"),
		smallestFirst = true;
		Format = function(Value)
            return Value/100
        end
	};
	["Soccer"] = { -- Goals
		DataStore = ("Soccer_v-RELEASE"),
		smallestFirst = false;
	};
	["Falling Tiles"] = {
		DataStore = ("Falling Tiles_v-RELEASE"),
		smallestFirst = false;
	};
	["Candy Rush"] = {
		DataStore = ("Candy Rush_v-RELEASE"),
		smallestFirst = false;
	};
	["Ice Cream Extravaganza"] = {
		DataStore = ("Ice Cream Extravaganza_v-RELEASE"),
		smallestFirst = false;
	};
	["Sled Race"] = {
		DataStore = ("Sled Race_v-RELEASE1"),
		smallestFirst = true;
		Format = function(Value)
			if Value < 100 then
				Value *= 100
			end

			Value /= 100
			return string.format("%.2f", Value)
		end
	};

	["Rebirths"] = {
		DataStore = ("Rebirths_v-RELEASE"),
		smallestFirst = false;
	};

	["Total Mined"] = {
		DataStore = ("Total Mined_v-RELEASE"),
		smallestFirst = false;
	};

	["Total Chopped"] = {
		DataStore = ("Total Chopped-RELEASE"),
		smallestFirst = false;
	};

	["Total Fished"] = {
		DataStore = ("Total Fished_v-RELEASE"),
		smallestFirst = false;
	};

	["Candy Collected"] = {
		DataStore = ("Candy Collected_v-RELEASE"),
		smallestFirst = false;
	};

	["Soccer Wins"] = {
		DataStore = ("Soccer Wins_v-RELEASE"),
		smallestFirst = false;
	};

	["Sled Race Wins"] = {
		DataStore = ("Sled Race Wins_v-RELEASE"),
		smallestFirst = false;
	};

	["Skate Race Wins"] = {
		DataStore = ("Skate Race Wins_v-RELEASE"),
		smallestFirst = false;
	};

}