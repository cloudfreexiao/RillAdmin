const {User} = require('../models')
const jwt = require('jsonwebtoken')
const config = require('../config/config')

function jwtSignUser (user) {
  const ONE_HOUR = 60 * 60 * 24
  return jwt.sign(user, config.authentication.jwtSecret, {
    expiresIn: ONE_HOUR
  })
}

module.exports = {
  async login (req, res) {
    try {
      const {username, password} = req.body
      const user = await User.findOne({
        where: {
          AccountName: username
        }
      })

      if (!user) {
        return res.status(200).send({
          code: 1,
          message: 'The login information was incorrect not found'
        })
      }

      const isPasswordValid = await user.comparePassword(password)
      if (!isPasswordValid) {
        return res.status(200).send({
          code: 1,
          message: 'The login information was incorrect pwd'
        })
      }

      const userJson = user.toJSON()
      res.send({
        code: 0,
        message: 'success',
        data: {
          token: jwtSignUser(userJson)
        }
      })
    } catch (err) {
      // console.log('=========error:' + err)
      res.status(500).send({
        code: 1,
        message: 'An error has occured trying to login'
      })
    }
  },
  async logout (req, res) {
  },
  async user (req, res) {
    try {
      const userJson = req.user.toJSON()
      res.send({
        code: 0,
        message: 'success',
        data: {
          user: userJson
        }
      })
    } catch (err) {
      res.status(500).send({
        code: 1,
        message: 'An error has occured trying to login user'
      })
    }
  }
}
