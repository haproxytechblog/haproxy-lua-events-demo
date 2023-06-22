-- Make an http post request to a webhook endpoint to notify about a backend
-- going down at a given time. For the sake of the example, contextual data
-- is formatted in JSON, webhook handlers often rely on a combination of
-- headers and plain POST or JSON formatted POST payloads to extract arguments
-- from the request.
local function backend_is_down(backend, when)
	local httpclient = core.httpclient()
	local api_base_url = os.getenv("DEMO_WEBHOOK_URL")

	local request_body = string.format("{\
	                                     \"type\":\"%s\",\
	                                     \"name\":\"%s\",\
	                                     \"when\":\"%d\"\
	                                    }",
	                                   "backend_down",
	                                   backend,
	                                   when)

	local response = httpclient:post{url = api_base_url, body=request_body}
	if (response.status ~= 200) then
		core.Alert("Error when making request to http endpoint")
	end
end

-- this function will be called by event framework each time a server
-- from the chosen backend will be transitioning from UP to DOWN
local function server_down(event, data, mgmt, when)
	local server = data.reference -- get a reference to the server

	if server == nil then
		-- the server has been removed, we cannot fetch
		-- (should not happen in our testcase)
		return
	end
	if server:get_proxy():get_srv_act() == 0 then
		-- no more active servers within the backend, trigger an alert
		backend_is_down(server:get_proxy():get_name(), when)
	end
end

core.register_init(function()
	-- register server_down function for DOWN event for every server
	-- within "test" backend
	for srv_name, srv in pairs(core.backends["test"].servers) do
		srv:event_sub({"SERVER_DOWN"}, server_down)
	end
end)