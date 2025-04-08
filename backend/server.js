const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const vocRoutes = require('./routes/vocRoutes');
const systemUpdateRoutes = require('./routes/systemUpdateRoutes');
const solutionDevelopmentRoutes = require('./routes/solutionDevelopmentRoutes');
const hardwareRoutes = require('./routes/hardwareRoutes');
const { getSampleVocData, getSampleSystemUpdateData, getSampleHardwareData } = require('./models/sampleData');
const Voc = require('./models/vocModel');
const SystemUpdate = require('./models/systemUpdateModel');
const Hardware = require('./models/hardwareModel');

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
  systemUpdates: [],
  hardware: []
};

// API 라우트
app.use('/api/voc', vocRoutes);
app.use('/api/system-updates', systemUpdateRoutes);
app.use('/api/solution-development', solutionDevelopmentRoutes);
app.use('/api/hardware', hardwareRoutes);
app.use('/api/hardware-assets', hardwareRoutes); // 추가 엔드포인트 (동일한 라우터 사용)

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

// 하드웨어 메모리 API - 조회
app.get('/api/memory/hardware', (req, res) => {
  // 쿼리 파라미터 파싱
  const { search, assetCode, assetName, executionType } = req.query;
  
  // 필터링된 데이터 반환
  let filteredData = [...memoryDB.hardware];
  
  // 검색 필터 적용
  if (search) {
    const searchRegex = new RegExp(search, 'i');
    filteredData = filteredData.filter(item => 
      searchRegex.test(item.code) || 
      searchRegex.test(item.assetCode) || 
      searchRegex.test(item.assetName) || 
      searchRegex.test(item.specification) || 
      searchRegex.test(item.detail) || 
      searchRegex.test(item.remarks)
    );
  }
  
  // 자산 코드 필터 적용
  if (assetCode) {
    const codeRegex = new RegExp(assetCode, 'i');
    filteredData = filteredData.filter(item => codeRegex.test(item.assetCode));
  }
  
  // 자산 이름 필터 적용
  if (assetName) {
    filteredData = filteredData.filter(item => item.assetName === assetName);
  }
  
  // 실행 유형 필터 적용
  if (executionType) {
    filteredData = filteredData.filter(item => item.executionType === executionType);
  }
  
  // 필터링된 결과 반환 (번호 기준 내림차순 정렬)
  res.json(filteredData.sort((a, b) => b.no - a.no));
});

// 하드웨어 메모리 API - 단일 항목 조회
app.get('/api/memory/hardware/code/:code', (req, res) => {
  const code = req.params.code;
  const hardware = memoryDB.hardware.find(h => h.code === code);
  
  if (!hardware) {
    return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
  }
  
  res.json(hardware);
});

// 하드웨어 메모리 API - 추가
app.post('/api/memory/hardware', (req, res) => {
  const newHardware = req.body;
  
  // ID가 없는 경우 ID 생성
  if (!newHardware._id) {
    newHardware._id = `mem_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }
  
  // 번호가 없는 경우 자동 할당
  if (!newHardware.no) {
    const maxNo = memoryDB.hardware.length > 0 
      ? Math.max(...memoryDB.hardware.map(h => h.no)) 
      : 0;
    newHardware.no = maxNo + 1;
  }
  
  // 코드가 없는 경우 자동 생성
  if (!newHardware.code) {
    const regDate = newHardware.regDate ? new Date(newHardware.regDate) : new Date();
    const year = regDate.getFullYear().toString().slice(-2);
    const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
    const day = regDate.getDate().toString().padStart(2, '0');
    const code = `HW${year}${month}${day}-${newHardware.no.toString().padStart(4, '0')}`;
    newHardware.code = code;
  }
  
  // 저장 필드 추가
  newHardware.saveStatus = true;
  newHardware.modifiedStatus = false;
  newHardware.isSaved = true;
  newHardware.isModified = false;
  newHardware.createdAt = new Date();
  newHardware.updatedAt = new Date();
  
  // 중복 코드 확인
  const existingHardware = memoryDB.hardware.find(h => h.code === newHardware.code);
  if (existingHardware) {
    return res.status(400).json({ message: '이미 존재하는 하드웨어 코드입니다.' });
  }
  
  // 데이터 저장
  memoryDB.hardware.push(newHardware);
  
  // 저장된 데이터 반환
  res.status(201).json(newHardware);
});

// 하드웨어 메모리 API - 수정
app.put('/api/memory/hardware/code/:code', (req, res) => {
  const code = req.params.code;
  const updatedData = req.body;
  
  // 항목 검색
  const index = memoryDB.hardware.findIndex(h => h.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
  }
  
  // 중요한 필드는 유지
  updatedData.code = code; // 코드는 변경 불가
  updatedData._id = memoryDB.hardware[index]._id; // ID 유지
  updatedData.no = memoryDB.hardware[index].no; // 번호 유지
  updatedData.saveStatus = true;
  updatedData.modifiedStatus = false;
  updatedData.isSaved = true;
  updatedData.isModified = false;
  updatedData.createdAt = memoryDB.hardware[index].createdAt;
  updatedData.updatedAt = new Date();
  
  // 데이터 업데이트
  memoryDB.hardware[index] = updatedData;
  
  // 업데이트된 데이터 반환
  res.json(updatedData);
});

// 하드웨어 메모리 API - 삭제
app.delete('/api/memory/hardware/code/:code', (req, res) => {
  const code = req.params.code;
  
  // 항목 검색
  const index = memoryDB.hardware.findIndex(h => h.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
  }
  
  // 삭제할 항목 저장
  const deletedItem = memoryDB.hardware[index];
  
  // 데이터 삭제
  memoryDB.hardware.splice(index, 1);
  
  // 삭제 결과 반환
  res.json({ 
    message: '하드웨어 데이터가 성공적으로 삭제되었습니다.',
    deletedHardware: deletedItem 
  });
});

// 루트 라우트
app.get('/', (req, res) => {
  res.json({ message: "NextPlus Task API가 실행 중입니다." });
});

// MongoDB 연결 및 샘플 데이터 초기화
const initializeDatabase = async () => {
  const MAX_RETRIES = 3;
  let retryCount = 0;
  let connected = false;

  while (retryCount < MAX_RETRIES && !connected) {
    try {
      console.log(`MongoDB 연결 시도 중... (시도: ${retryCount + 1}/${MAX_RETRIES})`);
      
      await mongoose.connect(process.env.MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 5000, // 연결 시도 타임아웃 5초
      });
      
      console.log('MongoDB 연결 성공');
      connected = true;
      
      // VOC 샘플 데이터 초기화
      const vocCount = await Voc.countDocuments();
      if (vocCount === 0) {
        const sampleVocData = getSampleVocData();
        await Voc.insertMany(sampleVocData);
        console.log('샘플 VOC 데이터가 추가되었습니다.');
      } else {
        console.log(`VOC 컬렉션에 ${vocCount}개의 데이터가 있습니다.`);
      }
      
      // 시스템 업데이트(솔루션 개발) 샘플 데이터 초기화
      const systemUpdateCount = await SystemUpdate.countDocuments();
      if (systemUpdateCount === 0) {
        const sampleSystemUpdateData = getSampleSystemUpdateData();
        await SystemUpdate.insertMany(sampleSystemUpdateData);
        console.log('샘플 솔루션 개발 데이터가 추가되었습니다.');
      } else {
        console.log(`솔루션 개발 컬렉션에 ${systemUpdateCount}개의 데이터가 있습니다.`);
      }

      // 하드웨어 샘플 데이터 초기화
      const hardwareCount = await Hardware.countDocuments();
      if (hardwareCount === 0) {
        const sampleHardwareData = getSampleHardwareData();
        await Hardware.insertMany(sampleHardwareData);
        console.log('샘플 하드웨어 데이터가 추가되었습니다.');
      } else {
        console.log(`하드웨어 컬렉션에 ${hardwareCount}개의 데이터가 있습니다.`);
      }
      
    } catch (error) {
      retryCount++;
      console.error(`MongoDB 연결 실패 (시도: ${retryCount}/${MAX_RETRIES}):`, error.message);
      
      if (retryCount < MAX_RETRIES) {
        console.log(`${2000 * retryCount}ms 후 재시도합니다...`);
        await new Promise(resolve => setTimeout(resolve, 2000 * retryCount));
      } else {
        console.error('MongoDB 연결 최대 시도 횟수 초과. 메모리 저장소로 전환합니다.');
        console.log('메모리 저장소를 사용하여 서버를 시작합니다.');
        
        // 메모리 저장소에 샘플 데이터 로드
        memoryDB.vocs = getSampleVocData();
        memoryDB.systemUpdates = getSampleSystemUpdateData();
        memoryDB.hardware = getSampleHardwareData();
        console.log(`메모리에 ${memoryDB.vocs.length}개의 VOC 데이터, ${memoryDB.systemUpdates.length}개의 시스템 업데이트 데이터, ${memoryDB.hardware.length}개의 하드웨어 데이터가 로드되었습니다.`);
      }
    }
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