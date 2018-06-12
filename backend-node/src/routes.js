const AuthenticationController = require('./controllers/AuthenticationController')
const AuthenticationControllerPolicy = require('./policies/AuthenticationControllerPolicy')
const HistoriesController = require('./controllers/HistoriesController')
const TradeController = require('./controllers/TradeController')

const isAuthenticated = require('./policies/isAuthenticated')

module.exports = (app) => {
  app.post('/api/login',
    AuthenticationController.login)

  app.get('/api/user',
    isAuthenticated,
    AuthenticationController.user)

  app.get('/api/tradehistory',
    isAuthenticated,
    HistoriesController.index)
    
  app.post('/api/trade',
    isAuthenticated,
    TradeController.trade)
}
