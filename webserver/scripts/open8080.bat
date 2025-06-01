@echo off
echo 🛡️ Åpner TCP-port 8080 i Windows Defender Firewall...

netsh advfirewall firewall add rule name="Allow Python Webserver 8080" ^
    dir=in action=allow protocol=TCP localport=8080 enable=yes

echo ✅ Port 8080 er nå åpen for innkommende trafikk.
pause
