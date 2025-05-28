module.exports = {
  apps: [
    {
      name: 'appletv',
      script: 'start.js',
      cwd: './homey-appletv',
      watch: false,
      env: {
        NODE_ENV: 'production'
      }
    },
    {
      name: "minecraft-bedrock",
      script: "./minecraft-bedrock/start.sh",
      interpreter: "/bin/bash",
      cwd: "./minecraft-bedrock",
      watch: false
    }
  ]
};
