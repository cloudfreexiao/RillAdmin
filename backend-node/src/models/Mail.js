module.exports = (sequelize, DataTypes) => {
  const Mail = sequelize.define('Mail', {
    MailID: {
      type: DataTypes.INTEGER(11),
      primaryKey: true,
      autoIncrement: true
    },
    SrcUserID: DataTypes.INTEGER(11),
    Context: DataTypes.STRING(129),
    DestUserID: DataTypes.INTEGER(11),
    SendTime: DataTypes.DATE,
    RewardID: DataTypes.SMALLINT(5),
    RewardSum: DataTypes.INTEGER(10)
  }, {
    timestamps: false,
    underscored: true,
    freezeTableName: true,
    tableName: 'fishmail'
  })

  Mail.associate = function (models) {
  }

  return Mail
}
