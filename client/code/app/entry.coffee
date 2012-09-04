# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

# Astor REST API configuration
ss.astor_api = {
  host: '127.0.0.1'
  port: 8889
}

ss.server.on 'disconnect', ->
  console.log('Astor: Oops, connection down...')

ss.server.on 'reconnect', ->
  console.log('Astor: Yay, connection recovered!')

ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery ->
    
    # Load app
    ss.live_metrics      = require('/live_metrics')
    ss.archived_metrics  = require('/archived_metrics')
    ss.alerts           = require('/alerts')
    ss.astor             = require('/astor')
