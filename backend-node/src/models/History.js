module.exports = (sequelize, DataTypes) => {
  const History = sequelize.define('History', {
    TradeID: {
      type: DataTypes.INTEGER(11),
      primaryKey: true,
      autoIncrement: true
    },
    SrcUserID: DataTypes.INTEGER(11),
    DestUserID: DataTypes.INTEGER(11),
    RewardID: DataTypes.SMALLINT(5),
    RewardSum: DataTypes.INTEGER(11),
    SrcNickName: DataTypes.STRING(9),
    SrcAccountName: DataTypes.STRING(56),
    DestNickName: DataTypes.STRING(9),
    DestAccountName: DataTypes.STRING(56)
  }, {
    underscored: true,
    freezeTableName: true,
    tableName: 'fishtrade'
  })

  History.associate = function (models) {
  }

  return History
}
