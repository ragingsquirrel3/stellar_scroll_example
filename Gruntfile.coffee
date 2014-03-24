fs = require 'fs'
jade = require 'jade'
util = require 'util'

module.exports = (grunt) ->
  
  # register external tasks
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-env'
  
  BUILD_PATH = 'server/client_build'
  APP_PATH = 'client'
  TEMPLATES_PATH = "#{APP_PATH}/coffee/templates"
  DEV_BUILD_PATH = "#{BUILD_PATH}/development"
  JS_DEV_BUILD_PATH = "#{DEV_BUILD_PATH}/js"
  PRODUCTION_BUILD_PATH = "#{BUILD_PATH}/production"
  SERVER_PATH = "server"
  VENDOR = "vendor"
  REQUIRE_PATH = 
    'jquery': "#{VENDOR}/jquery.min" # "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min"
    'backbone': "#{VENDOR}/backbone.min"
    'underscore': "#{VENDOR}/underscore.min"
    'stellar' : "#{VENDOR}/stellar.min"
    'd3': "#{VENDOR}/d3.min"
    'jade': "#{VENDOR}/jade.min"
  REQUIRE_SHIM =
    'jquery': exports: '$'
    'backbone':
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    'underscore': exports: '_'
    'jade': exports: 'jade'
    'd3': exports: 'd3'
  
  grunt.initConfig

    clean:
      development: [DEV_BUILD_PATH]
      production: [PRODUCTION_BUILD_PATH]
      js_pre_production: ["#{PRODUCTION_BUILD_PATH}/js"]

    coffee:
      development:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: "#{APP_PATH}/coffee"
          dest: "#{DEV_BUILD_PATH}/js"
          src: ["*.coffee", "**/*.coffee"]
          ext: ".js"
        ]
      pre_production:
        options:
          sourceMap:false
        files: [  
          expand: true
          cwd: "#{APP_PATH}/coffee"
          dest: "#{DEV_BUILD_PATH}/js"
          src: ["*.coffee", "**/*.coffee"]
          ext: ".js"
        ]

    env:
      production:
        ENV: 'production'

    requirejs:
      production:
        options:
          baseUrl: JS_DEV_BUILD_PATH
          name: 'main'
          paths: REQUIRE_PATH
          shim: REQUIRE_SHIM
          out: "#{PRODUCTION_BUILD_PATH}/js/main.js"
          include: "#{VENDOR}/require"

    copy:
      development:
        files: [
          { expand: true, cwd: "#{APP_PATH}/public", src:['**'], dest: DEV_BUILD_PATH }
        ]
      production:
        files: [
          { expand: true, cwd: "#{APP_PATH}/public", src:['**'], dest: PRODUCTION_BUILD_PATH }
        ]  
      # production:
      #   files: [
      #     { expand: true, cwd: DEV_BUILD_PATH, src:['**'], dest: PRODUCTION_BUILD_PATH },
      #   ]

    jade:
      development:
        options:
          pretty: false

        files: [
          {
            src: "#{APP_PATH}/index.jade"
            dest: "#{DEV_BUILD_PATH}/index.html"
          }
        ]
      production:
        options:
          pretty: false

        files: [
          {
            src: "#{APP_PATH}/index.jade"
            dest: "#{PRODUCTION_BUILD_PATH}/index.html"
          }
        ]  
  
    # run tests with mocha test, mocha test:unit, or mocha test:controllers
    mochaTest:
      controllers:
        options:
          reporter: 'spec'
        src: ['test/controllers/*']
        
    # express server
    express:
      test:
        options:
          server: './app'
          port: 5000
      development:
        options:
          server: './app'
          port: 3000
      production:
        options:
          server: './app'
          port: 3000    
    
    sass:
      development:
        files:
          "server/client_build/development/stylesheets/main.css": "client/scss/main.scss"
      production:
        files:
          "server/client_build/production/stylesheets/main.css": "client/scss/main.scss"    
    
    watch:
      coffee:
        files: "#{APP_PATH}/coffee/**/*.coffee"
        tasks: 'coffee:development'
      jade:
        files: "#{APP_PATH}/index.jade"
        tasks: 'jade:development'
      jadeClient:
        files: "#{TEMPLATES_PATH}/**/*.jade"
        tasks: 'clientTemplates'
      sass:
        files: ["#{APP_PATH}/scss/**/*.scss"]
        tasks: 'sass:development' 
        
  grunt.registerTask 'test', [
    'development'
    'express:test'
    'mochaTest:controllers'
  ]
    
  grunt.registerTask 'development', [
    'clean:development'
    'copy:development'
    'sass:development'
    'coffee:development'
    'jade:development'
  ]  

  grunt.registerTask 'pre_production',[
    'clean:development'
    'copy:development'
    'sass:development'
    'coffee:development'
    'jade:development'
  ]

  grunt.registerTask 'production', [
    'env:production'
    'clean:production'
    'pre_production'
    'copy:production'
    'clean:js_pre_production'
    'sass:production'
    'jade:production'
    'requirejs:production'
  ]   
        
  grunt.registerTask 'default', [
    # 'env:development'
    'development'
    'express:development'
    'watch'
  ]
