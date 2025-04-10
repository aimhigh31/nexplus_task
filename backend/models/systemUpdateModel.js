const mongoose = require('mongoose');

const systemUpdateSchema = new mongoose.Schema({
  no: {
    type: Number,
    required: true,
    unique: true
  },
  regDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  updateCode: {
    type: String,
    required: true,
    unique: true
  },
  targetSystem: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  updateType: {
    type: String,
    required: true
  },
  assignee: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    required: true
  },
  completionDate: {
    type: Date,
    default: null
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
  timestamps: true, // createdAt, updatedAt 자동 생성
  collection: 'solution', // MongoDB 컬렉션 이름을 solution으로 수정
  suppressReservedKeysWarning: true // 예약 키워드 경고 억제
});

// API 응답에 isSaved 및 isModified 플래그 추가 (클라이언트 측에서 사용)
systemUpdateSchema.methods.toJSON = function() {
  const obj = this.toObject();
  obj.isSaved = this.saveStatus || true;  // saveStatus 필드를 isSaved로 변환
  obj.isModified = this.modifiedStatus || false; // modifiedStatus 필드를 isModified로 변환
  return obj;
};

// 중복 코드 확인 미들웨어
systemUpdateSchema.pre('save', async function(next) {
  // 새 문서 생성 시에만 중복 체크
  if (this.isNew) {
    try {
      const existingDocument = await this.constructor.findOne({ updateCode: this.updateCode });
      if (existingDocument) {
        const error = new Error(`업데이트 코드 '${this.updateCode}'가 이미 존재합니다.`);
        error.name = 'DuplicateError';
        return next(error);
      }
    } catch (error) {
      return next(error);
    }
  }
  next();
});

const SystemUpdate = mongoose.model('SystemUpdate', systemUpdateSchema);

module.exports = SystemUpdate; 