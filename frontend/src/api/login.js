import request from '@/utils/request'

export function login(username, password) {
  return request({
    url: '/api/login',
    method: 'post',
    data: {
      username,
      password
    }
  })
}

export function getInfo(token) {
  return request({
    url: '/api/user',
    method: 'get'
  })
}

export function logout() {
  return request({
    url: '/api/logout',
    method: 'post'
  })
}

export function tradehistory() {
  return request({
    url: '/api/tradehistory',
    method: 'get'
  })
}

export function trade() {
  return request({
    url: '/api/trade',
    method: 'post'
  })
}
