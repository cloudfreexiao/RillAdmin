<template>
  <div id="account">
    </div>
</template>

<script>

// import {
//   getInfo,
//   Model
// } from '@/api/account'

export default {
  data() {

  }
}
</script>

<style lang="scss">
@import './../../styles/app-main.scss';
.avatar {
  width: 178px;
  height: 178px;
  display: block;
}
#account .el-form--label-top .el-form-item__label {
  width: 100%;
  text-align:center;
}
#account .el-form-item__content{
  text-align: center;
}
#account .el-col-10>.el-form-item>.el-form-item__content>.el-input{
  width: 80%;
}
#account .first-row .el-col {
border:1px solid $border-color;
border-left: 0px;
}
#account .first-row .first-column {
border-left:1px solid $border-color;
}
#account .normal-row .el-col {
border:1px solid $border-color;
border-left: 0px;
border-top: 0px;
}
#account .normal-row .first-column {
border-left:1px solid $border-color;
}
#account .last-row .el-col {
border:1px solid $border-color;
border-top: 0px;
border-left: 0px;
}
#account .last-row .first-column {
border-left:1px solid $border-color;
}
#account .last-row .first-column .el-upload-dragger{
  width: auto;
  height: auto;
}
</style>
