const { Client } = require('node-appletv-x');
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question("🔧 Apple TV IP-adresse: ", function (ip) {
  const client = new Client();

  console.log(`\n🔌 Kobler til Apple TV på ${ip}...`);
  console.log('⏳ Venter på PIN-inntasting fra Apple TV...');

  client.pair(ip)
    .then(credentials => {
      console.log('\n✅ Pairing fullført!');
      const data = {
        host: ip,
        credentials: credentials
      };

      fs.writeFileSync('credentials.json', JSON.stringify(data, null, 2));
      console.log('💾 Lagret i credentials.json');
      console.log('🚀 Du kan nå kjøre start.js for å hente metadata.');
      rl.close();
    })
    .catch(err => {
      console.error('\n❌ Feil under pairing:', err.message);
      rl.close();
    });
});
