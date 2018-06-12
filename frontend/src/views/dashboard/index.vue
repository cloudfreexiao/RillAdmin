<template>
  <div class="dashboard-container">
    <div class="dashboard-text">{{message}}</div>
  </div>
</template>

<script>

export default {
  name: 'dashboard',
  computed: {
    message() {
      return '欢迎使用本系统'
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss" scoped>
.dashboard {
  &-container {
    margin: 30px;
  }
  &-text {
    font-size: 30px;
    line-height: 46px;
  }
}
</style>
