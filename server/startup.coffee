# Setup require
require = __meteor_bootstrap__.require
path = require 'path'
fs = require 'fs'
base = path.resolve '.'
isBundle = fs.existsSync "#{base}/bundle"
modulePath = base + `(isBundle ? '/bundle/static' : '/public')` + '/node_modules'

# Create polytalk client
Polytalk = require "#{modulePath}/polytalk"
client = new Polytalk.Client port: 9090