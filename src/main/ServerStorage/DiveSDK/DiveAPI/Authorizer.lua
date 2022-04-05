local logger = require(script.Parent.Parent.Logger)
local HashLib = require(script.Parent.HashLib)
local authorizer = {}

function authorizer:setSalt(secretKey)
	self.salt = secretKey
end

function authorizer:buildToken(payload)
	--Validate
	if not self.salt then
		logger:w("Error encoding, invalid SecretKey")
		return
	end
	--Encode
	local payloadHmac = HashLib.hmac(
		HashLib.sha1,
		self.salt,
		payload,
		false
	)
	return string.lower(payloadHmac)
end

function authorizer:Verify(input, token)
    if(not self.salt)then return false end
	return authorizer:buildToken(input) == token
end



return authorizer