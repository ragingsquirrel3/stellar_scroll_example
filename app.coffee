express = require 'express'

ASSET_BUILD_PATH = 'server/client_build/development'
PORT = process.env.PORT ? 3000

app = express()
app.configure ->

  # serve static assets
  app.use('/', express.static("#{__dirname}/#{ASSET_BUILD_PATH}"))

  # logging
  app.use express.logger()
 
module.exports = app
