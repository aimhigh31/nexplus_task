const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const vocRoutes = require('./routes/vocRoutes');
const systemUpdateRoutes = require('./routes/systemUpdateRoutes');
const solutionDevelopmentRoutes = require('./routes/solutionDevelopmentRoutes');
const { getSampleVocData, getSampleSystemUpdateData } = require('./models/sampleData');
const Voc = require('./models/vocModel');
const SystemUpdate = require('./models/systemUpdateModel');

// 환경 변수 설정
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(cors());
app.use(express.json());

// 메모리 저장소 (MongoDB 연결 실패 시 사용)
const memoryDB = {
  vocs: [],
  systemUpdates: []
};

// API 라우트
app.use('/api/voc', vocRoutes);
app.use('/api/system-updates', systemUpdateRoutes);
app.use('/api/solution-development', solutionDevelopmentRoutes);

// 메모리 백업 API 라우트 (MongoDB 연결 실패 시 사용)
// 솔루션 개발 데이터 조회
app.get('/api/memory/system-updates', (req, res) => {
  // 쿼리 파라미터 파싱
  const { search, targetSystem, updateType, status } = req.query;
  
  // 필터링된 데이터 반환
  let filteredData = [...memoryDB.systemUpdates];
  
  // 검색 필터 적용
  if (search) {
    const searchRegex = new RegExp(search, 'i');
    filteredData = filteredData.filter(item => 
      searchRegex.test(item.updateCode) || 
      searchRegex.test(item.description) || 
      searchRegex.test(item.assignee) || 
      searchRegex.test(item.remarks)
    );
  }
  
  // 솔루션 분류 필터 적용
  if (targetSystem) {
    filteredData = filteredData.filter(item => item.targetSystem === targetSystem);
  }
  
  // 업데이트 유형 필터 적용
  if (updateType) {
    filteredData = filteredData.filter(item => item.updateType === updateType);
  }
  
  // 상태 필터 적용
  if (status) {
    filteredData = filteredData.filter(item => item.status === status);
  }
  
  // 필터링된 결과 반환 (번호 기준 내림차순 정렬)
  res.json(filteredData.sort((a, b) => b.no - a.no));
});

// 솔루션 개발 데이터 추가
app.post('/api/memory/system-updates', (req, res) => {
  const newUpdate = req.body;
  
  // ID가 없는 경우 ID 생성
  if (!newUpdate._id) {
    newUpdate._id = `mem_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }
  
  // 번호가 없는 경우 자동 할당
  if (!newUpdate.no) {
    const maxNo = memoryDB.systemUpdates.length > 0 
      ? Math.max(...memoryDB.systemUpdates.map(u => u.no)) 
      : 0;
    newUpdate.no = maxNo + 1;
  }
  
  // 코드가 없는 경우 자동 생성
  if (!newUpdate.updateCode) {
    const now = new Date();
    const year = now.getFullYear().toString().substring(2);
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const seq = newUpdate.no.toString().padStart(3, '0');
    newUpdate.updateCode = `UPD${year}${month}${seq}`;
  }
  
  // 저장 필드 추가
  newUpdate.saveStatus = true;
  newUpdate.modifiedStatus = false;
  newUpdate.isSaved = true;
  newUpdate.isModified = false;
  newUpdate.createdAt = new Date();
  newUpdate.updatedAt = new Date();
  
  // 데이터 저장
  memoryDB.systemUpdates.push(newUpdate);
  
  // 저장된 데이터 반환
  res.status(201).json(newUpdate);
});

// 솔루션 개발 데이터 수정
app.put('/api/memory/system-updates/code/:code', (req, res) => {
  const code = req.params.code;
  const updatedData = req.body;
  
  // 항목 검색
  const index = memoryDB.systemUpdates.findIndex(u => u.updateCode === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 시스템 업데이트를 찾을 수 없습니다.' });
  }
  
  // 중요한 필드는 유지
  updatedData.updateCode = code; // 코드는 변경 불가
  updatedData._id = memoryDB.systemUpdates[index]._id; // ID 유지
  updatedData.no = memoryDB.systemUpdates[index].no; // 번호 유지
  updatedData.saveStatus = true;
  updatedData.modifiedStatus = false;
  updatedData.isSaved = true;
  updatedData.isModified = false;
  updatedData.createdAt = memoryDB.systemUpdates[index].createdAt;
  updatedData.updatedAt = new Date();
  
  // 데이터 업데이트
  memoryDB.systemUpdates[index] = updatedData;
  
  // 업데이트된 데이터 반환
  res.json(updatedData);
});

// 솔루션 개발 데이터 삭제
app.delete('/api/memory/system-updates/code/:code', (req, res) => {
  const code = req.params.code;
  
  // 항목 검색
  const index = memoryDB.systemUpdates.findIndex(u => u.updateCode === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 시스템 업데이트를 찾을 수 없습니다.' });
  }
  
  // 삭제할 항목 저장
  const deletedItem = memoryDB.systemUpdates[index];
  
  // 데이터 삭제
  memoryDB.systemUpdates.splice(index, 1);
  
  // 삭제 결과 반환
  res.json({ message: '솔루션 개발 데이터가 성공적으로 삭제되었습니다.', deletedUpdate: deletedItem });
});

// 루트 라우트
app.get('/', (req, res) => {
  res.json({ message: "NextPlus Task API가 실행 중입니다." });
});

// MongoDB 연결 및 샘플 데이터 초기화
const initializeDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB 연결 성공');
    
    // VOC 샘플 데이터 초기화
    const vocCount = await Voc.countDocuments();
    if (vocCount === 0) {
      const sampleVocData = getSampleVocData();
      await Voc.insertMany(sampleVocData);
      console.log('샘플 VOC 데이터가 추가되었습니다.');
    }
    
    // 시스템 업데이트(솔루션 개발) 샘플 데이터 초기화
    const systemUpdateCount = await SystemUpdate.countDocuments();
    if (systemUpdateCount === 0) {
      const sampleSystemUpdateData = getSampleSystemUpdateData();
      await SystemUpdate.insertMany(sampleSystemUpdateData);
      console.log('샘플 솔루션 개발 데이터가 추가되었습니다.');
    }
  } catch (error) {
    console.error('MongoDB 연결 실패:', error);
    console.log('메모리 저장소를 사용하여 서버를 시작합니다.');
    
    // 메모리 저장소에 샘플 데이터 로드
    memoryDB.vocs = getSampleVocData();
    memoryDB.systemUpdates = getSampleSystemUpdateData();
    console.log(`메모리에 ${memoryDB.vocs.length}개의 VOC 데이터와 ${memoryDB.systemUpdates.length}개의 시스템 업데이트 데이터가 로드되었습니다.`);
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