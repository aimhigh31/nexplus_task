const mongoose = require('mongoose');

const attachmentSchema = new mongoose.Schema({
  fileName: {
    type: String,
    required: [true, '파일 이름은 필수입니다.']
  },
  originalFilename: {
    type: String,
    required: [true, '원본 파일 이름은 필수입니다.']
  },
  mimeType: {
    type: String,
    required: [true, 'MIME 타입은 필수입니다.']
  },
  size: {
    type: Number,
    required: [true, '파일 크기는 필수입니다.']
  },
  path: { // 서버 내 저장 경로
    type: String,
    required: [true, '파일 경로는 필수입니다.']
  },
  uploadDate: {
    type: Date,
    default: Date.now
  },
  relatedEntityId: {
    type: mongoose.Schema.Types.ObjectId, // 또는 String, 관련 엔티티의 ID 타입에 맞게
    required: true,
    index: true // 검색 성능을 위해 인덱스 추가
  },
  relatedEntityType: {
    type: String, // 예: 'system_update', 'hardware', 'voc' 등
    required: true,
    index: true // 검색 성능을 위해 인덱스 추가
  }
}, { timestamps: true }); // createdAt, updatedAt 자동 생성

// 복합 인덱스 (필요 시 추가)
// attachmentSchema.index({ relatedEntityId: 1, relatedEntityType: 1 });

const Attachment = mongoose.model('Attachment', attachmentSchema);

module.exports = Attachment; 