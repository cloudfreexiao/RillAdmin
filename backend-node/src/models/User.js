// const Promise = require('bluebird')
// const bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))

// function hashPassword (user, options) {
//   const SALT_FACTOR = 8

//   if (!user.changed('password')) {
//     return
//   }

//   return bcrypt
//     .genSaltAsync(SALT_FACTOR)
//     .then(salt => bcrypt.hashAsync(user.password, salt, null))
//     .then(hash => {
//       user.setDataValue('password', hash)
//     })
// }

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    UserID: {
      type: DataTypes.INTEGER(11),
      primaryKey: true,
      autoIncrement: true
    },
    AccountName: {
      type: DataTypes.STRING(56),
      unique: true
    },
    PasswordCrc1: DataTypes.INTEGER(11),
    PasswordCrc2: DataTypes.INTEGER(11),
    PasswordCrc3: DataTypes.INTEGER(11),
    NickName: DataTypes.STRING(9),
    GlobalNum: DataTypes.INTEGER(11),
    BankGoldNum: DataTypes.INTEGER(11),
    BankPassword: DataTypes.INTEGER(11),
    MacAddress: DataTypes.STRING(57)
  }, {
    // hooks: {
    //   beforeCreate: hashPassword,
    //   beforeUpdate: hashPassword,
    //   beforeSave: hashPassword
    // },
    timestamps: false,
    underscored: true,
    freezeTableName: true,
    tableName: 'accountinfo'
  })

  User.prototype.comparePassword = function (password) {
    return this.PasswordCrc1.toString() === password // bcrypt.compareAsync(password, this.PasswordCrc1)
  }

  User.associate = function (models) {
  }

  return User
}
