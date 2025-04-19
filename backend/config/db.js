const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // MongoDB 연결 문자열 (환경 변수에서 가져오거나 기본값 사용)
    const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/asset_management', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    // 데이터베이스 이름 확인
    const dbName = conn.connection.db.databaseName;
    console.log(`MongoDB 연결 완료: ${conn.connection.host}, 데이터베이스: ${dbName}`);
    
    // 데이터베이스가 asset_management가 아니면 경고 출력
    if (dbName !== 'asset_management') {
      console.warn(`경고: 현재 연결된 데이터베이스(${dbName})가 'asset_management'가 아닙니다.`);
      
      // asset_management 데이터베이스로 전환 시도
      try {
        await conn.connection.useDb('asset_management');
        console.log('asset_management 데이터베이스로 전환했습니다.');
      } catch (switchErr) {
        console.error('데이터베이스 전환 실패:', switchErr.message);
      }
    }
  } catch (err) {
    console.error(`MongoDB 연결 오류: ${err.message}`);
    process.exit(1);
  }
};

module.exports = connectDB; 