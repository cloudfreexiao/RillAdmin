import request from '@/utils/request'

export function getInfo(searchObj = {}, page = 1, pageSize = 10) {
  return request({
    url: '/api/account',
    method: 'get',
    params: {
      page,
      pageSize,
      name: searchObj.name,
      email: searchObj.email
    }
  })
}

export function Model(userId = 0, name = '', accountName = '', avatar = '', password = '', password_confirmation = '') {
  this.userId = userId
  this.name = name
  this.accountName = accountName
  this.avatar = avatar
  this.password = password
  this.password_confirmation = password_confirmation
}

export function SearchModel(account = ' ') {
  this.name = name
  this.account = account
}
