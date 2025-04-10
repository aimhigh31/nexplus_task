const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const hardwareSchema = new Schema({
  no: {
    type: Number,
    required: true
  },
  regDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  code: {
    type: String,
    required: true,
    unique: true
  },
  assetCode: {
    type: String,
    default: ''
  },
  assetType: {
    type: String,
    default: ''
  },
  assetName: {
    type: String,
    default: '미지정'
  },
  specification: {
    type: String,
    default: ''
  },
  unitPrice: {
    type: Number,
    default: 0
  },
  executionType: {
    type: String,
    required: true,
    enum: ['신규구매', '사용불출', '수리중', '홀딩', '폐기']
  },
  quantity: {
    type: Number,
    required: true,
    default: 1
  },
  lotCode: {
    type: String,
    default: ''
  },
  detail: {
    type: String,
    default: ''
  },
  purchaseDate: {
    type: Date,
    default: null
  },
  serialNumber: {
    type: String,
    default: ''
  },
  warrantyDate: {
    type: Date,
    default: null
  },
  currentUser: {
    type: String,
    default: ''
  },
  remarks: {
    type: String,
    default: ''
  },
  saveStatus: {
    type: Boolean,
    default: true
  },
  modifiedStatus: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  // JSON 변환 시 가상 필드 포함
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// MongoDB에 저장 시는 camelCase 필드명 사용, 클라이언트에 응답할 때는 변환
hardwareSchema.virtual('isSaved').get(function() {
  return this.saveStatus;
});

hardwareSchema.virtual('isModified').get(function() {
  return this.modifiedStatus;
});

// 금액 계산을 위한 가상 필드 추가
hardwareSchema.virtual('totalPrice').get(function() {
  return (this.unitPrice || 0) * (this.quantity || 1);
});

const Hardware = mongoose.model('Hardware', hardwareSchema, 'hardware');

module.exports = Hardware; 