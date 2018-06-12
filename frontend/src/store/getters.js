const getters = {
  sidebar: state => state.app.sidebar,
  token: state => state.user.token,
  userId: state => state.user.userId,
  avatar: state => state.user.avatar,
  goldNum: state => state.user.goldNum,
  name: state => state.user.nickName,
  macaddr: state => state.user.macaddr
}
export default getters
