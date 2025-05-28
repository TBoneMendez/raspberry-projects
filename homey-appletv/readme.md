# Homey Apple TV

Lytter etter "nå spilles"-endringer på Apple TV via `node-appletv`, og sender info til Homey via webhook.

## Oppsett

1. Kopier `.env.example` til `.env`
2. Fyll inn din Homey-webhook
3. Plasser `credentials.json` etter pairing med Apple TV
4. Kjør med `npm start`

## PM2

Du kan kjøre scriptet i bakgrunnen med:

```bash
pm2 start ../pm2.config.js
pm2 save
