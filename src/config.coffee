###
Super simple config loader
Give it an environment and it spits out the appropriate cfg
###

require 'js-yaml'

CFG_PATH = process.env.CFG_PATH || '../config.yaml'

console.log "loading config from #{CFG_PATH}"
CFG = null


module.exports = (env) ->
  if(CFG == null)
    init(env)
  return CFG

init = (env) ->
  cfgObject = require(CFG_PATH)
  # .shift()
  if process.env.PRODUCTION?
    env = 'production'
  env = env ? 'testing'
  console.log "Using configuration set: #{env}"
  CFG = cfgObject[env]
  if not CFG?
    throw new Error('Supply a valid environment - \'#{env}\' not in config')
