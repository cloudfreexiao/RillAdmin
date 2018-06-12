import { login, logout, getInfo } from '@/api/login'
import { getToken, setToken, removeToken } from '@/utils/auth'

const user = {
  state: {
    token: getToken(),
    userId: 0,
    avatar: 1,
    accountName: '',
    nickName: '',
    goldNum: '',
    macaddr: ''
  },

  mutations: {
    SET_TOKEN: (state, token) => {
      state.token = token
    },
    SET_USERID: (state, userId) => {
      state.userId = userId
    },
    SET_ACCOUNTNAME: (state, accountName) => {
      state.accountName = accountName
    },
    SET_NICKNAME: (state, name) => {
      state.name = name
    },
    SET_GOLDNUM: (state, goldNum) => {
      state.goldNum = goldNum
    },
    SET_MACADDR: (state, macaddr) => {
      state.macaddr = macaddr
    }
  },

  actions: {
    // 登录
    Login({ commit }, userInfo) {
      const username = userInfo.username.trim()
      return new Promise((resolve, reject) => {
        login(username, userInfo.password).then(response => {
          const data = response.data
          setToken(data.token)
          commit('SET_TOKEN', data.token)
          resolve()
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 获取用户信息
    GetInfo({ commit, state }) {
      return new Promise((resolve, reject) => {
        getInfo(state.token).then(response => {
          const data = response.data
          commit('SET_USERID', data.UserID)
          commit('SET_ACCOUNTNAME', data.AccountName)
          commit('SET_NICKNAME', data.NickName)
          commit('SET_GOLDNUM', data.GlobalNum)
          commit('SET_MACADDR', data.MacAddress)
          resolve(response)
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 登出
    LogOut({ commit, state }) {
      return new Promise((resolve, reject) => {
        logout(state.token).then(() => {
          commit('SET_TOKEN', '')
          commit('SET_USERID', 0)
          removeToken()
          resolve()
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 前端 登出
    FedLogOut({ commit }) {
      return new Promise(resolve => {
        commit('SET_TOKEN', '')
        commit('SET_USERID', 0)
        removeToken()
        resolve()
      })
    }
  }
}

export default user
