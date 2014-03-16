express = require 'express'
publicController = require './server/controllers/public_controller'

ASSET_BUILD_PATH = 'server/client_build/development'
PORT = process.env.PORT ? 3000

app = express()
app.configure ->
  # jade templates from templates dir
  app.use express.compress()
  app.set 'views', "#{__dirname}/server/templates"
  app.set 'view engine', 'jade'
  
  # serve static assets
  app.use('/', express.static("#{__dirname}/#{ASSET_BUILD_PATH}"))
  
  
  # # needed for body parsing and session usage
  # app.use express.cookieParser()
  # app.use express.bodyParser()
  # app.use express.session secret: SESSION_SECRET
  # app.use passport.initialize()
  # app.use passport.session()
  # assign login rules after assigning static route
  # app.use ensureAuthenticated

   
  # logging
  app.use express.logger()
#   
# public routes
app.get '/', publicController.index
app.get '/about', publicController.about
# 
# 
# # auth routes
# app.get '/signup', authController.newRegistration
# app.post '/signup', authController.createRegistration
# app.get '/login', authController.newSession
# app.post '/login', authController.createSession
# app.get '/logout', authController.destroySession
# 
# # account routes
# app.get '/account', accountController.index
# 
# # admin
# app.get '/admin', ensureAdmin, adminController.index
# app.get '/admin/account/:id', ensureAdmin, adminController.showAccount
# app.get '/admin/account/:id/edit_password', ensureAdmin, adminController.editPassword
# app.post '/admin/account/:id/update_password', ensureAdmin, adminController.updatePassword
# app.post '/admin/account/:id/toggle_admin', ensureAdmin, adminController.toggleAdmin
# app.post '/admin/account/:id/delete_account', ensureAdmin, adminController.deleteAccount

 
module.exports = app
