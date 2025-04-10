const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // MongoDB 연결 문자열 (환경 변수에서 가져오거나 기본값 사용)
    const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/asset_management', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`MongoDB 연결 완료: ${conn.connection.host}`);
  } catch (err) {
    console.error(`MongoDB 연결 오류: ${err.message}`);
    process.exit(1);
  }
};

module.exports = connectDB; 