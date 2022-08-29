local ServerScriptService = game:GetService("ServerScriptService")
local Sentry = require(ServerScriptService.ErrorTracking.Sentry)

Sentry.init({
	dsn = "https://469239f61bee4433842d78a8592e582a@o987012.ingest.sentry.io/6700516"
})