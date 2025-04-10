const mongoose = require('mongoose');

const SoftwareSchema = new mongoose.Schema({
  no: {
    type: Number,
    required: true
  },
  code: {
    type: String,
    required: true,
    unique: true
  },
  regDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  assetCode: {
    type: String,
    required: true
  },
  assetType: {
    type: String,
    required: true
  },
  assetName: {
    type: String,
    required: true
  },
  specification: {
    type: String,
    default: ''
  },
  setupPrice: {
    type: Number,
    default: 0
  },
  annualMaintenancePrice: {
    type: Number,
    default: 0
  },
  costType: {
    type: String,
    enum: ['연구독', '월구독', '영구'],
    default: '영구'
  },
  vendor: {
    type: String,
    default: ''
  },
  licenseKey: {
    type: String,
    default: ''
  },
  user: {
    type: String,
    default: ''
  },
  quantity: {
    type: Number,
    default: 1
  },
  unitPrice: {
    type: Number,
    default: 0
  },
  totalPrice: {
    type: Number,
    default: 0
  },
  lotCode: {
    type: String,
    default: ''
  },
  detail: {
    type: String,
    default: ''
  },
  startDate: {
    type: Date,
    default: null
  },
  endDate: {
    type: Date,
    default: null
  },
  remarks: {
    type: String,
    default: ''
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// 저장 전 업데이트 날짜 자동 갱신
SoftwareSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// 코드 자동 생성 함수
SoftwareSchema.statics.generateCode = function(date, no) {
  const yearMonth = `${date.getFullYear().toString().substring(2)}${(date.getMonth() + 1).toString().padStart(2, '0')}`;
  const seq = no.toString().padStart(3, '0');
  return `SWM-${yearMonth}-${seq}`;
};

module.exports = mongoose.model('Software', SoftwareSchema); 