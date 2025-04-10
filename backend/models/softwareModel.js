const mongoose = require('mongoose');

const softwareSchema = new mongoose.Schema({
  no: { type: Number, required: true },
  code: { type: String, required: true, unique: true },
  regDate: { type: Date, required: true, default: Date.now },
  assetCode: { type: String, default: '' },
  assetType: { type: String, required: true },
  assetName: { type: String, required: true },
  specification: { type: String, default: '' },
  setupPrice: { type: Number, default: 0 },
  annualMaintenancePrice: { type: Number, default: 0 },
  costType: { type: String, required: true }, // 연구독, 월구독, 영구
  vendor: { type: String, default: '' },
  licenseKey: { type: String, default: '' },
  user: { type: String, default: '' },
  quantity: { type: Number, default: 1 },
  unitPrice: { type: Number, default: 0 },
  totalPrice: { type: Number, default: 0 },
  lotCode: { type: String, default: '' },
  detail: { type: String, default: '' },
  startDate: { type: Date },
  endDate: { type: Date },
  remarks: { type: String, default: '' },
  isDeleted: { type: Boolean, default: false },
}, { 
  timestamps: true,
  collection: 'software' // 명시적으로 컬렉션 이름 지정
});

// 인덱스 설정
softwareSchema.index({ assetType: 1 });
softwareSchema.index({ costType: 1 });
softwareSchema.index({ isDeleted: 1 });
softwareSchema.index({ regDate: -1 });

// 검색을 위한 복합 인덱스
softwareSchema.index({ 
  assetType: 'text', 
  assetName: 'text', 
  assetCode: 'text',
  specification: 'text',
  vendor: 'text',
  licenseKey: 'text',
  user: 'text',
  detail: 'text',
  remarks: 'text'
});

const SoftwareModel = mongoose.model('Software', softwareSchema);

module.exports = SoftwareModel; 