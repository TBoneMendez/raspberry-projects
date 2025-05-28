require('dotenv').config();
const { Client } = require('node-appletv-x');
const credentials = require('./credentials.json');

const client = new Client();

client
  .pair(credentials.host, credentials.credentials)
  .then(device => {
    console.log(`✅ Koblet til Apple TV (${device.info.name})`);

    device.on('nowPlayingUpdated', info => {
      console.log('🎬 Nå spilles:', JSON.stringify(info, null, 2));
    });

    return device.openConnection();
  })
  .catch(err => {
    console.error('❌ Feil ved tilkobling:', err.message);
  });
