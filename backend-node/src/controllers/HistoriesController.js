const {
  History
} = require('../models')
const _ = require('lodash')

module.exports = {
  async index (req, res) {
    try {
      const UserID = req.user.UserID
      const histories = await History.findAll({
        where: {
          SrcUserID: UserID
        },
        limit: 20,
        order: [
          ['created_at', 'DESC']
        ]
      })
      res.send(_.uniqBy(histories, history => history.TradeID))
    } catch (err) {
      console.log('$$$$$$$$$$$$$$$ history error:' + err)
      res.status(200).send({
        code: 1,
        message: 'an error has occured trying to fetch the history'
      })
    }
  }
}
