const mongoose = require('mongoose');

const equipmentConnectionSchema = new mongoose.Schema({
  no: { type: Number, required: true },
  code: { type: String, required: true, unique: true },
  regDate: { type: Date, required: true, default: Date.now },
  line: { type: String, required: true },
  equipment: { type: String, required: true },
  workType: { type: String, required: true }, // MES 자동투입, SPC, 설비조건데이터, 기타
  dataType: { type: String, required: true }, // PLC, CSV, 기타
  connectionType: { type: String, required: true }, // DataAgent, X-DAS, X-SCADA, 기타
  status: { type: String, required: true }, // 대기, 진행중, 완료, 보류
  detail: { type: String, default: '' },
  startDate: { type: Date },
  completionDate: { type: Date },
  remarks: { type: String, default: '' },
  isDeleted: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
}, { 
  timestamps: true,
  collection: 'connection' // 컬렉션 이름을 connection으로 수정
});

// 인덱스 설정
equipmentConnectionSchema.index({ line: 1 });
equipmentConnectionSchema.index({ equipment: 1 });
equipmentConnectionSchema.index({ workType: 1 });
equipmentConnectionSchema.index({ dataType: 1 });
equipmentConnectionSchema.index({ connectionType: 1 });
equipmentConnectionSchema.index({ status: 1 });
equipmentConnectionSchema.index({ isDeleted: 1 });
equipmentConnectionSchema.index({ regDate: -1 });

// 검색을 위한 복합 인덱스
equipmentConnectionSchema.index({ 
  line: 'text', 
  equipment: 'text',
  workType: 'text',
  dataType: 'text',
  connectionType: 'text',
  detail: 'text',
  remarks: 'text'
});

// 새 문서 저장 전 처리
equipmentConnectionSchema.pre('save', function(next) {
  // 수정일시 자동 업데이트
  this.updatedAt = new Date();
  next();
});

const EquipmentConnectionModel = mongoose.model('EquipmentConnection', equipmentConnectionSchema);

module.exports = EquipmentConnectionModel; 