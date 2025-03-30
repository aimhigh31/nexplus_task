const mongoose = require('mongoose');

const vocSchema = new mongoose.Schema({
  no: {
    type: Number,
    required: true,
    unique: true
  },
  code: {
    type: String,
    unique: true,
    sparse: true  // null 값이 있어도 유니크 인덱스 생성 가능
  },
  regDate: {
    type: Date,
    default: Date.now
  },
  vocCategory: {
    type: String,
    required: true
  },
  requestDept: {
    type: String,
    default: ''
  },
  requester: {
    type: String,
    default: ''
  },
  systemPath: {
    type: String,
    default: ''
  },
  request: {
    type: String,
    default: ''
  },
  requestType: {
    type: String,
    required: true
  },
  action: {
    type: String,
    default: ''
  },
  actionTeam: {
    type: String,
    default: ''
  },
  actionPerson: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    required: true,
    default: '접수'
  },
  dueDate: {
    type: Date,
    required: true
  }
}, {
  timestamps: true
});

// 자동 증가 no 필드 처리를 위한 메서드
vocSchema.statics.getNextSequence = async function() {
  const max = await this.findOne({}, {}, { sort: { 'no': -1 } });
  if (max) {
    return max.no + 1;
  }
  return 1; // 첫 번째 문서인 경우
};

module.exports = mongoose.model('Voc', vocSchema); 