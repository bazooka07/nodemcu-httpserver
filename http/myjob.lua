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

	ledAction = gpio.read(ledPin) == gpio.HIGH and 'on' or 'off'
	relayAction = gpio.read(relayPin) == gpio.HIGH and 'off' or 'on'

	rh, t = am2320.read(0)

	dofile("httpserver-header.lc")(connection, 200, 'html')

	connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Myjob</title><link rel="stylesheet" href="style.css" /></head><body><h1>My job</h1>')
	connection:send('<p><a href="/">Accueil</a></p>')
	connection:send('<p><a href="?led=' .. ledAction .. '">Led</a></p>')
	connection:send('<p><a href="?relay=' .. relayAction .. '">Relay</a></p>')
	connection:send(string.format('<p>Temp : %s℃ - Humidité : %s%%</p>', t/10, rh/10))
	connection:send('<p><a href="?watering=on">Watering</a></p>')
	connection:send('</body></html>')

end
