const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const vocRoutes = require('./routes/vocRoutes');
const { getSampleVocData } = require('./models/sampleData');
const Voc = require('./models/vocModel');

// 환경 변수 설정
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(cors());
app.use(express.json());

// API 라우트
app.use('/api/voc', vocRoutes);

// 루트 라우트
app.get('/', (req, res) => {
  res.json({ message: "VOC System API가 실행 중입니다." });
});

// MongoDB 연결 및 샘플 데이터 초기화
const initializeDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB 연결 성공');
    
    // 샘플 데이터 초기화
    const count = await Voc.countDocuments();
    if (count === 0) {
      const sampleData = getSampleVocData();
      await Voc.insertMany(sampleData);
      console.log('샘플 VOC 데이터가 추가되었습니다.');
    }
  } catch (error) {
    console.error('MongoDB 연결 실패:', error);
    process.exit(1);
  }
};

// 서버 시작
initializeDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
    console.log(`http://localhost:${PORT}`);
  });
});

// 예기치 않은 오류 처리
process.on('unhandledRejection', (error) => {
  console.error('처리되지 않은 Promise 오류:', error);
});

module.exports = app; 