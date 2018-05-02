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

// export function getCurrentPage(current_page) {
//   return request({
//     url: '/api/account',
//     method: 'get',
//     params: {
//       page: current_page
//     }
//   })
// }

// export function getInfoById(id) {
//   return request({
//     url: '/api/account/' + id,
//     method: 'get'
//   })
// }

// export function resetAdminByPsw(id, password) {
//   return request({
//     url: '/api/account/' + id + '/reset',
//     method: 'post',
//     data: {
//       password
//     }
//   })
// }

// export function uploadAdminByImg(data) {
//   return request({
//     url: '/api/account/uploadAvatar',
//     method: 'post',
//     data,
//     headers: {
//       'Content-Type': 'multipart/form-data'
//     }
//   })
// }

// export function updateInfo(id, data) {
//   return request({
//     url: '/api/account/' + id,
//     method: 'put',
//     params: {
//       name: data.name,
//       role: data.role,
//       avatar: data.avatar
//     },
//     headers: {
//       'Content-Type': 'application/x-www-form-urlencoded'
//     }
//   })
// }

// export function deleteInfoById(id) {
//   return request({
//     url: '/api/account/' + id,
//     method: 'delete'
//   })
// }

// export function addInfo(data) {
//   console.log(data)
//   return request({
//     url: '/api/account',
//     method: 'post',
//     data
//   })
// }

// export function uploadFile(data) {
//   return request({
//     url: '/api/account/upload',
//     method: 'post',
//     data,
//     headers: {
//       'Content-Type': 'multipart/form-data'
//     }
//   })
// }

// export function exportCurrentPage(pageSize = 10, page = 1, searchObj = {}) {
//   return request({
//     url: '/api/account/export',
//     method: 'post',
//     data: {
//       page,
//       pageSize,
//       name: searchObj.name,
//       email: searchObj.email
//     }
//   })
// }

// export function exportAll(searchObj = {}) {
//   return request({
//     url: '/api/account/exportAll',
//     method: 'post',
//     data: {
//       name: searchObj.name,
//       email: searchObj.email
//     }
//   })
// }

// export function deleteAll(params) {
//   return request({
//     url: '/api/account/deleteAll',
//     method: 'post',
//     data: {
//       ids: params
//     }
//   })
// }

export function Model(name = '', email = '', role = [], avatar = '', password = '', password_confirmation = '') {
  this.name = name
  this.email = email
  this.role = role
  this.avatar = avatar
  this.password = password
  this.password_confirmation = password_confirmation
}

export function SearchModel(account = ' ') {
  this.name = name
  this.account = account
}
