const {
  sequelize,
  User,
  History,
  Mail
} = require('../models')

module.exports = {
  async trade (req, res) {
    // 要把在线玩家踢下线
    const {recvuserId, gold} = req.body
    if (gold == null || gold <= 0 || recvuserId == null || recvuserId <= 0) {
      return res.status(200).send({
        code: 1,
        message: 'The trade information was incorrect'
      })
    }

    const sendHasGold = req.user.GlobalNum
    if (sendHasGold < gold) {
      return res.status(200).send({
        code: 1,
        message: 'The trade information was incorrect you have not much gold'
      })
    }

    const recvuser = await User.findOne({
      where: {
        UserID: recvuserId
      }
    })

    if (!recvuser) {
      return res.status(200).send({
        code: 1,
        message: 'The want send user information was incorrect not found'
      })
    }

    req.user.GlobalNum = req.user.GlobalNum - gold
    const RewardID = 11 // 奖励物品ID 11

    // Sequelize.transaction(function (t) {
    //   User.updateAttributes({ GlobalNum: req.user.GlobalNum })
    //     .then(function (result) {
    //       Mail.create({
    //         SrcUserID: req.user.UserID,
    //         DestUserID: recvuser.UserID,
    //         Context: '玩家赠送',
    //         SendTime: Sequelize.NOW,
    //         RewardID: RewardID,
    //         RewardSum: gold
    //       })
    //     })
    //     .then(function (result) {
    //       History.create({
    //         SrcUserID: req.user.UserID,
    //         DestUserID: recvuser.UserID,
    //         RewardID: RewardID,
    //         RewardSum: gold,
    //         SrcNickName: req.user.NickName,
    //         SrcAccountName: req.user.AccountName,
    //         DestNickName: recvuser.NickName,
    //         DestAccountName: recvuser.AccountName
    //       })
    //         .then(function (result) {
    //           t.commit()
    //           return res.status(200).send({
    //             code: 0,
    //             message: 'trade ok'
    //           })
    //         })
    //         .catch(function (err) {
    //           console.log('&&&&&&&&&&&&&&&&trade error:' + err)
    //           t.rollback()
    //           return res.status(200).send({
    //             code: 0,
    //             message: 'trade failed'
    //           })
    //         })
    //     })
    // })
    let t = await sequelize.transaction()
    try {
      await Mail.create({
        SrcUserID: req.user.UserID,
        DestUserID: recvuser.UserID,
        Context: '玩家赠送',
        SendTime: new Date(),
        RewardID: RewardID,
        RewardSum: gold
      }, {transaction: t})
      await History.create({
        SrcUserID: req.user.UserID,
        DestUserID: recvuser.UserID,
        RewardID: RewardID,
        RewardSum: gold,
        SrcNickName: req.user.NickName,
        SrcAccountName: req.user.AccountName,
        DestNickName: recvuser.NickName,
        DestAccountName: recvuser.AccountName
      }, {transaction: t})
      await User.update({ GlobalNum: req.user.GlobalNum }, { where: { UserID: req.user.UserID } }, { transaction: t })
      await t.commit()
      return res.status(200).send({
        code: 0,
        message: 'trade ok'
      })
    } catch (err) {
      console.log('&&&&&&&&&&&&&&&&trade error:' + err)
      await t.rollback()
      return res.status(200).send({
        code: 0,
        message: 'trade failed'
      })
    }
  }
}
