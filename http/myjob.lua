return function (connection, req, args)
	if args['led'] then
		gpio.write(ledPin, args['led'] == 'on' and gpio.LOW or gpio.HIGH)
	end

	if args['relay'] then
		gpio.write(relayPin, args['relay'] == 'on' and gpio.HIGH or gpio.LOW)
	else
		if args['watering'] then
			myjob()
		end
	end

	local ledAction = gpio.read(ledPin) == gpio.HIGH and 'on' or 'off'
	local relayAction = gpio.read(relayPin) == gpio.HIGH and 'off' or 'on'

	local rh, t = am2320.read(0)
	local tm1 = rtctime.get()

	local oneDay = 86400
	local tm2 = tm1 + oneDay
	rtcmem.write32(21, tm2) -- until 31
	tm2 = rtcmem.read32(21)

	dofile("httpserver-header.lc")(connection, 200, 'html')

	connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Myjob</title><link rel="stylesheet" href="style.css" /></head><body><h1>My job</h1>')
	connection:send('<p><a href="/">Accueil</a></p>')
	connection:send('<p><a class="button" href="?led=' .. ledAction .. '">Led</a></p>')
	connection:send('<p><a class="button" href="?relay=' .. relayAction .. '">Relay</a></p>')
	connection:send(string.format('<p>Temp : %s℃ - Humidité : %s%%</p>', t/10, rh/10))
	connection:send('<p><a class="button" href="?watering=on">Watering</a></p>')
	local tm = rtctime.epoch2cal(tm1)
	connection:send('<p>' .. string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]) .. '</p>')
	tm = rtctime.epoch2cal(tm2)
	connection:send('<p>' .. string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]) .. '</p>')
	connection:send('<form><input type="time" value="" /></form>')
	connection:send('</body></html>')

end
