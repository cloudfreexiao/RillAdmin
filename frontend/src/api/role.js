import request from '@/utils/request'

export function getInfo() {
  return request({
    url: '/api/role',
    method: 'get'
  })
}

export function getRoles() {
  return request({
    url: '/api/getRoles',
    method: 'get'
  })
}

export function getInfoById(id) {
  return request({
    url: '/api/role/' + id,
    method: 'get'
  })
}

export function updateInfo(id, data) {
  return request({
    url: '/api/role/' + id,
    method: 'PATCH',
    data
  })
}

export function deleteInfoById(id) {
  return request({
    url: '/api/role/' + id,
    method: 'delete'
  })
}

export function addInfo(data) {
  return request({
    url: '/api/role',
    method: 'post',
    data
  })
}

export function Model(name = '', explain = '', remark = '', permission = []) {
  this.name = name
  this.explain = explain
  this.remark = remark
  this.permission = permission
}
