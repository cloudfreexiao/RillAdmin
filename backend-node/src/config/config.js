module.exports = {
  port: process.env.PORT || 7777,
  db: {
    database: process.env.DB_NAME || 'fishgame',
    user: process.env.DB_USER || 'fish',
    password: process.env.DB_PASS || '111111',
    pool: {
      max: 5,
      min: 0,
      idle: 10000
    },
    options: {
      dialect: process.env.DIALECT || 'mysql',
      host: process.env.HOST || '192.168.1.14'
    }
  },
  authentication: {
    jwtSecret: process.env.JWT_SECRET || 'secret&&&qihao$@^%&dh672GhFSF#'
  },
  whitelist: ['http://192.168.1.25:10000']
}
