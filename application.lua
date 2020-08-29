-- gestion relais

-- setup
relayPin = 1
gpio.mode(relayPin, gpio.OUTPUT)
DURATION=10000

-- led on the board
ledPin = 4
gpio.mode(ledPin, gpio.OUTPUT)
gpio.write(ledPin, gpio.HIGH)

-- AM 2320
SDA, SCL = 2, 6
i2c.setup(0, SDA, SCL, i2c.SLOW)
model, version, serial = am2320.setup()
print('am2320 : model ' .. model .. ' - version ' .. version .. ' - serial ' .. serial)
if not tmr.create():alarm(2000, tmr.ALARM_SINGLE, function()
	rh, t = am2320.read()
	print(string.format('Temp : %s℃ - Humidité : %s%%', t/10, rh/10))
end) then
	print('Whoopsie')
end


function myjob()
	gpio.write(relayPin, gpio.HIGH)
	print('Relay on')
	if not tmr.create():alarm(DURATION, tmr.ALARM_SINGLE, function()
		gpio.write(relayPin, gpio.LOW)
		print('Relay off')
	end) then
		print('Whoopsie')
	end
end


print('Application running')

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(infos)
	print('Address IP : '..infos.IP)

	sntp.sync(
		{'0.fr.pool.ntp.org', '1.fr.pool.ntp.org'},
		function(sec, ms, server, info)
			print('\nsuccess ntp')
			print('ip server : '..server)
			for k,v in pairs(info) do
					print(k..' : '..v)
			end
			tm = rtctime.epoch2cal(rtctime.get())
			print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))

			if cron then
				print('Setup cron')
				cron.schedule('* * * * *', function(e) print('each 1 minute') end)
				cron.schedule('*/5 * * * *', function(e) print('each 5 minutes') end)
				cron.schedule('0 */2 * * *', function(e) print('each 2 hours') end)
				cron.schedule('0 23 * * *', function(e) print('At 23:00') end)
				cron.schedule('35 21 * * *', myjob)
			end
		end
	)

	startServer = require('httpserver')
	if startServer  then
		print('Starting HTTP server')
		startServer(80)
	end
end
)
