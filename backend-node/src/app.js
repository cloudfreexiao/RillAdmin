const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const morgan = require('morgan')
const {sequelize} = require('./models')
const config = require('./config/config')

const whitelist = config.whitelist
const corsPotions = {
  origin: function (origin, callback) {
    if(whitelist.indexOf(origin) !== -1) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials : true, // 'Access-Control - Allow - Credentials'
  optionsSuccessStatus: 200
}

const app = express()
app.use(morgan('combined'))
app.use(bodyParser.json())
app.use(cors(corsPotions))

require('./passport')

require('./routes')(app)

sequelize.sync({force: false})
  .then(() => {
    app.listen(config.port)
    console.log(`Server started on port ${config.port}`)
  })
