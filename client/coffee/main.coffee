VENDOR = "vendor"
requirejs.config
  paths:
    'jquery': "#{VENDOR}/jquery.min"
    'backbone': "#{VENDOR}/backbone.min"
    'underscore': "#{VENDOR}/underscore.min"
    'jade': "#{VENDOR}/jade.min"
    'stellar': "#{VENDOR}/stellar.min"
  shim:
    'jquery': exports: '$'
    'stellar':
      deps: ['jquery']
      exports: 'stellar'
    'backbone':
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    'underscore': exports: '_'
    'jade': exports: 'jade'

requirejs ['jquery', 'stellar'], ($) ->
  $(window).stellar verticalScrolling: true
