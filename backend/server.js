const express = require('express');
const mongoose = require('mongoose');
const connectDB = require('./config/db');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');
const vocRoutes = require('./routes/vocRoutes');
const systemUpdateRoutes = require('./routes/systemUpdateRoutes');
const solutionDevelopmentRoutes = require('./routes/solutionDevelopmentRoutes');
const hardwareRoutes = require('./routes/hardwareRoutes');
const softwareRoutes = require('./routes/softwareRoutes');
const equipmentConnectionRoutes = require('./routes/equipmentConnectionRoutes');
const attachmentRoutes = require('./routes/attachmentRoutes');
const { getSampleVocData, getSampleSystemUpdateData, getSampleHardwareData, getSampleSoftwareData, getSampleEquipmentConnectionData } = require('./models/sampleData');
const Voc = require('./models/vocModel');
const SystemUpdate = require('./models/systemUpdateModel');
const Hardware = require('./models/hardwareModel');
const Software = require('./models/softwareModel');
const EquipmentConnection = require('./models/equipmentConnectionModel');
const Attachment = require('./models/attachmentModel');

// 환경 변수 로드
dotenv.config();

// 포트 설정
const PORT = process.env.PORT || 3000;

// Express 앱 초기화
const app = express();

// MongoDB 연결
connectDB();

// 미들웨어
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 메모리 저장소 (MongoDB 연결 실패 시 사용)
const memoryDB = {
  vocs: [],
  systemUpdates: [],
  hardware: [],
  software: [],
  equipmentConnections: [],
  // attachments: []
};

// API 라우트
app.use('/api/voc', vocRoutes);
app.use('/api/system-updates', systemUpdateRoutes);
app.use('/api/solution-development', solutionDevelopmentRoutes);
app.use('/api/hardware', hardwareRoutes);
app.use('/api/hardware-assets', hardwareRoutes);
app.use('/api/software', softwareRoutes);
app.use('/api/equipment-connections', equipmentConnectionRoutes);
app.use('/api/attachments', attachmentRoutes);

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

// 소프트웨어 메모리 API - 조회
app.get('/api/memory/software', (req, res) => {
  // 쿼리 파라미터 파싱
  const { search, assetType, assetName, costType } = req.query;
  
  // 필터링된 데이터 반환
  let filteredData = [...memoryDB.software];
  
  // 검색 필터 적용
  if (search) {
    const searchRegex = new RegExp(search, 'i');
    filteredData = filteredData.filter(item => 
      searchRegex.test(item.code) || 
      searchRegex.test(item.assetType) || 
      searchRegex.test(item.assetName) || 
      searchRegex.test(item.specification) || 
      searchRegex.test(item.vendor) || 
      searchRegex.test(item.licenseKey) || 
      searchRegex.test(item.user) || 
      searchRegex.test(item.remarks)
    );
  }
  
  // 자산 분류 필터 적용
  if (assetType) {
    const typeRegex = new RegExp(assetType, 'i');
    filteredData = filteredData.filter(item => typeRegex.test(item.assetType));
  }
  
  // 자산 이름 필터 적용
  if (assetName) {
    filteredData = filteredData.filter(item => item.assetName === assetName);
  }
  
  // 비용 형태 필터 적용
  if (costType) {
    filteredData = filteredData.filter(item => item.costType === costType);
  }
  
  // 필터링된 결과 반환 (번호 기준 내림차순 정렬)
  res.json(filteredData.sort((a, b) => b.no - a.no));
});

// 소프트웨어 메모리 API - 단일 항목 조회
app.get('/api/memory/software/code/:code', (req, res) => {
  const code = req.params.code;
  const software = memoryDB.software.find(s => s.code === code);
  
  if (!software) {
    return res.status(404).json({ message: '해당 코드의 소프트웨어를 찾을 수 없습니다.' });
  }
  
  res.json(software);
});

// 소프트웨어 메모리 API - 추가
app.post('/api/memory/software', (req, res) => {
  const newSoftware = req.body;
  
  // ID가 없는 경우 ID 생성
  if (!newSoftware._id) {
    newSoftware._id = `mem_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }
  
  // 번호가 없는 경우 자동 할당
  if (!newSoftware.no) {
    const maxNo = memoryDB.software.length > 0 
      ? Math.max(...memoryDB.software.map(s => s.no)) 
      : 0;
    newSoftware.no = maxNo + 1;
  }
  
  // 코드가 없는 경우 자동 생성
  if (!newSoftware.code) {
    const regDate = newSoftware.regDate ? new Date(newSoftware.regDate) : new Date();
    const year = regDate.getFullYear().toString().slice(-2);
    const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
    const seq = newSoftware.no.toString().padStart(3, '0');
    newSoftware.code = `SWM-${year}${month}-${seq}`;
  }
  
  // 저장 필드 추가
  newSoftware.saveStatus = true;
  newSoftware.modifiedStatus = false;
  newSoftware.isSaved = true;
  newSoftware.isModified = false;
  newSoftware.createdAt = new Date();
  newSoftware.updatedAt = new Date();
  
  // 중복 코드 확인
  const existingSoftware = memoryDB.software.find(s => s.code === newSoftware.code);
  if (existingSoftware) {
    return res.status(400).json({ message: '이미 존재하는 소프트웨어 코드입니다.' });
  }
  
  // 데이터 저장
  memoryDB.software.push(newSoftware);
  
  // 저장된 데이터 반환
  res.status(201).json(newSoftware);
});

// 소프트웨어 메모리 API - 수정
app.put('/api/memory/software/code/:code', (req, res) => {
  const code = req.params.code;
  const updatedData = req.body;
  
  // 항목 검색
  const index = memoryDB.software.findIndex(s => s.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 소프트웨어를 찾을 수 없습니다.' });
  }
  
  // 중요한 필드는 유지
  updatedData.code = code; // 코드는 변경 불가
  updatedData._id = memoryDB.software[index]._id; // ID 유지
  updatedData.no = memoryDB.software[index].no; // 번호 유지
  updatedData.saveStatus = true;
  updatedData.modifiedStatus = false;
  updatedData.isSaved = true;
  updatedData.isModified = false;
  updatedData.createdAt = memoryDB.software[index].createdAt;
  updatedData.updatedAt = new Date();
  
  // 데이터 업데이트
  memoryDB.software[index] = updatedData;
  
  // 업데이트된 데이터 반환
  res.json(updatedData);
});

// 소프트웨어 메모리 API - 삭제
app.delete('/api/memory/software/code/:code', (req, res) => {
  const code = req.params.code;
  
  // 항목 검색
  const index = memoryDB.software.findIndex(s => s.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 소프트웨어를 찾을 수 없습니다.' });
  }
  
  // 삭제할 항목 저장
  const deletedItem = memoryDB.software[index];
  
  // 데이터 삭제
  memoryDB.software.splice(index, 1);
  
  // 삭제 결과 반환
  res.json({ 
    message: '소프트웨어 데이터가 성공적으로 삭제되었습니다.',
    deletedSoftware: deletedItem 
  });
});

// 설비 연동관리 메모리 API - 조회
app.get('/api/memory/equipment-connections', (req, res) => {
  // 쿼리 파라미터 파싱
  const { search, line, equipment, workType, dataType, connectionType, status } = req.query;
  
  // 필터링된 데이터 반환
  let filteredData = [...memoryDB.equipmentConnections];
  
  // 검색 필터 적용
  if (search) {
    const searchRegex = new RegExp(search, 'i');
    filteredData = filteredData.filter(item => 
      searchRegex.test(item.code) || 
      searchRegex.test(item.line) || 
      searchRegex.test(item.equipment) || 
      searchRegex.test(item.workType) || 
      searchRegex.test(item.dataType) || 
      searchRegex.test(item.connectionType) || 
      searchRegex.test(item.detail) || 
      searchRegex.test(item.remarks)
    );
  }
  
  // 라인 필터 적용
  if (line) {
    filteredData = filteredData.filter(item => item.line === line);
  }
  
  // 설비 필터 적용
  if (equipment) {
    filteredData = filteredData.filter(item => item.equipment === equipment);
  }
  
  // 작업유형 필터 적용
  if (workType) {
    filteredData = filteredData.filter(item => item.workType === workType);
  }
  
  // 데이터유형 필터 적용
  if (dataType) {
    filteredData = filteredData.filter(item => item.dataType === dataType);
  }
  
  // 연동유형 필터 적용
  if (connectionType) {
    filteredData = filteredData.filter(item => item.connectionType === connectionType);
  }
  
  // 상태 필터 적용
  if (status) {
    filteredData = filteredData.filter(item => item.status === status);
  }
  
  // 필터링된 결과 반환 (번호 기준 내림차순 정렬)
  res.json(filteredData.sort((a, b) => b.no - a.no));
});

// 설비 연동관리 메모리 API - 단일 항목 조회
app.get('/api/memory/equipment-connections/code/:code', (req, res) => {
  const code = req.params.code;
  const connection = memoryDB.equipmentConnections.find(c => c.code === code);
  
  if (!connection) {
    return res.status(404).json({ message: '해당 코드의 설비 연동 데이터를 찾을 수 없습니다.' });
  }
  
  res.json(connection);
});

// 설비 연동관리 메모리 API - 추가
app.post('/api/memory/equipment-connections', (req, res) => {
  const newConnection = req.body;
  
  // ID가 없는 경우 ID 생성
  if (!newConnection._id) {
    newConnection._id = `mem_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }
  
  // 번호가 없는 경우 자동 할당
  if (!newConnection.no) {
    const maxNo = memoryDB.equipmentConnections.length > 0 
      ? Math.max(...memoryDB.equipmentConnections.map(c => c.no)) 
      : 0;
    newConnection.no = maxNo + 1;
  }
  
  // 코드가 없는 경우 자동 생성
  if (!newConnection.code) {
    const regDate = newConnection.regDate ? new Date(newConnection.regDate) : new Date();
    const year = regDate.getFullYear().toString().slice(-2);
    const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
    const seq = newConnection.no.toString().padStart(3, '0');
    newConnection.code = `EQC-${year}${month}-${seq}`;
  }
  
  // 데이터 저장
  memoryDB.equipmentConnections.push(newConnection);
  
  // 저장된 데이터 반환
  res.status(201).json(newConnection);
});

// 설비 연동관리 메모리 API - 수정
app.put('/api/memory/equipment-connections/code/:code', (req, res) => {
  const code = req.params.code;
  const updatedData = req.body;
  
  // 항목 검색
  const index = memoryDB.equipmentConnections.findIndex(c => c.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 설비 연동 데이터를 찾을 수 없습니다.' });
  }
  
  // 중요한 필드는 유지
  updatedData.code = code; // 코드는 변경 불가
  
  // 데이터 업데이트
  memoryDB.equipmentConnections[index] = {
    ...memoryDB.equipmentConnections[index],
    ...updatedData
  };
  
  // 업데이트된 데이터 반환
  res.json(memoryDB.equipmentConnections[index]);
});

// 설비 연동관리 메모리 API - 삭제
app.delete('/api/memory/equipment-connections/code/:code', (req, res) => {
  const code = req.params.code;
  
  // 항목 검색
  const index = memoryDB.equipmentConnections.findIndex(c => c.code === code);
  
  if (index === -1) {
    return res.status(404).json({ message: '해당 코드의 설비 연동 데이터를 찾을 수 없습니다.' });
  }
  
  // 삭제할 항목 저장
  const deletedItem = memoryDB.equipmentConnections[index];
  
  // 데이터 삭제
  memoryDB.equipmentConnections.splice(index, 1);
  
  // 삭제 결과 반환
  res.json({ 
    message: '설비 연동 데이터가 성공적으로 삭제되었습니다.',
    deletedItem 
  });
});

// MongoDB 직접 접근 API 추가
// MongoDB 라우트 - 컬렉션에서 문서 찾기
app.post('/api/mongodb/:collection/find', async (req, res) => {
  try {
    const collectionName = req.params.collection;
    const { filter = {} } = req.body;
    
    console.log(`MongoDB 컬렉션 ${collectionName} 조회 요청`, { filter });

    // 컬렉션 접근
    const collection = mongoose.connection.db.collection(collectionName);
    if (!collection) {
      return res.status(404).json({ error: `컬렉션 ${collectionName}을 찾을 수 없습니다.` });
    }
    
    // 데이터 조회
    const result = await collection.find(filter).toArray();
    console.log(`MongoDB ${collectionName} 검색 결과: ${result.length}개 문서`);
    
    res.json(result);
  } catch (error) {
    console.error('MongoDB 조회 오류:', error);
    res.status(500).json({ error: error.message });
  }
});

// MongoDB 라우트 - 문서 추가
app.post('/api/mongodb/:collection/insertOne', async (req, res) => {
  try {
    const collectionName = req.params.collection;
    const { document = {} } = req.body;
    
    console.log(`MongoDB 컬렉션 ${collectionName}에 문서 추가 요청`);

    // 컬렉션 접근
    const collection = mongoose.connection.db.collection(collectionName);
    if (!collection) {
      return res.status(404).json({ error: `컬렉션 ${collectionName}을 찾을 수 없습니다.` });
    }
    
    // 문서 추가
    const result = await collection.insertOne(document);
    console.log(`MongoDB ${collectionName}에 문서 추가 성공: ID=${result.insertedId}`);
    
    res.status(201).json({ 
      _id: result.insertedId,
      acknowledged: result.acknowledged,
      insertedId: result.insertedId 
    });
  } catch (error) {
    console.error('MongoDB 문서 추가 오류:', error);
    res.status(500).json({ error: error.message });
  }
});

// MongoDB 라우트 - 문서 수정
app.post('/api/mongodb/:collection/updateOne', async (req, res) => {
  try {
    const collectionName = req.params.collection;
    const { filter = {}, update = {} } = req.body;
    
    console.log(`MongoDB 컬렉션 ${collectionName} 문서 수정 요청`, { filter });

    // 컬렉션 접근
    const collection = mongoose.connection.db.collection(collectionName);
    if (!collection) {
      return res.status(404).json({ error: `컬렉션 ${collectionName}을 찾을 수 없습니다.` });
    }
    
    // 문서 수정
    const result = await collection.updateOne(filter, update);
    console.log(`MongoDB ${collectionName} 문서 수정 결과:`, {
      matchedCount: result.matchedCount,
      modifiedCount: result.modifiedCount
    });
    
    res.json({
      acknowledged: result.acknowledged,
      matchedCount: result.matchedCount,
      modifiedCount: result.modifiedCount,
    });
  } catch (error) {
    console.error('MongoDB 문서 수정 오류:', error);
    res.status(500).json({ error: error.message });
  }
});

// MongoDB 라우트 - 문서 삭제
app.post('/api/mongodb/:collection/deleteOne', async (req, res) => {
  try {
    const collectionName = req.params.collection;
    const { filter = {} } = req.body;
    
    console.log(`MongoDB 컬렉션 ${collectionName} 문서 삭제 요청`, { filter });

    // 컬렉션 접근
    const collection = mongoose.connection.db.collection(collectionName);
    if (!collection) {
      return res.status(404).json({ error: `컬렉션 ${collectionName}을 찾을 수 없습니다.` });
    }
    
    // 문서 삭제
    const result = await collection.deleteOne(filter);
    console.log(`MongoDB ${collectionName} 문서 삭제 결과:`, {
      deletedCount: result.deletedCount
    });
    
    res.json({
      acknowledged: result.acknowledged,
      deletedCount: result.deletedCount
    });
  } catch (error) {
    console.error('MongoDB 문서 삭제 오류:', error);
    res.status(500).json({ error: error.message });
  }
});

// 루트 라우트
app.get('/', (req, res) => {
  res.json({ message: "NextPlus Task API가 실행 중입니다." });
});

// 서버 시작 시 MongoDB 초기화 및 샘플 데이터 추가
const initMongoDB = async () => {
  let retryCount = 0;
  const maxRetries = 5;

  while (retryCount < maxRetries) {
    try {
      console.log(`MongoDB 연결 중... (시도 ${retryCount + 1}/${maxRetries})`);
      
      // 데이터베이스 이름을 확인하고 nexplus_task로 설정
      const dbName = mongoose.connection.db.databaseName;
      console.log(`현재 연결된 데이터베이스: ${dbName}`);
      
      if (dbName !== 'nexplus_task') {
        console.log('경고: 연결된 데이터베이스가 nexplus_task가 아닙니다.');
      }
      
      // 샘플 VOC 데이터 초기화 - voc 컬렉션 사용
      try {
        const vocCount = await Voc.countDocuments();
        if (vocCount === 0) {
          const sampleVocData = getSampleVocData();
          await Voc.insertMany(sampleVocData);
          console.log('샘플 VOC 데이터가 voc 컬렉션에 추가되었습니다.');
        } else {
          console.log(`voc 컬렉션에 ${vocCount}개의 데이터가 있습니다.`);
        }
      } catch (vocError) {
        console.error('VOC 데이터 초기화 오류:', vocError.message);
      }
      
      // 샘플 시스템 업데이트 데이터 초기화 - solution 컬렉션 사용
      try {
        const systemUpdateCount = await SystemUpdate.countDocuments();
        if (systemUpdateCount === 0) {
          const sampleSystemUpdateData = getSampleSystemUpdateData();
          await SystemUpdate.insertMany(sampleSystemUpdateData);
          console.log('샘플 시스템 업데이트 데이터가 solution 컬렉션에 추가되었습니다.');
        } else {
          console.log(`solution 컬렉션에 ${systemUpdateCount}개의 데이터가 있습니다.`);
        }
      } catch (solutionError) {
        console.error('솔루션 데이터 초기화 오류:', solutionError.message);
      }
      
      // 하드웨어 샘플 데이터 초기화 - hardware 컬렉션 사용
      try {
        const hardwareCount = await Hardware.countDocuments();
        if (hardwareCount === 0) {
          const sampleHardwareData = getSampleHardwareData();
          await Hardware.insertMany(sampleHardwareData);
          console.log('샘플 하드웨어 데이터가 hardware 컬렉션에 추가되었습니다.');
        } else {
          console.log(`hardware 컬렉션에 ${hardwareCount}개의 데이터가 있습니다.`);
        }
      } catch (hwError) {
        console.error('하드웨어 데이터 초기화 오류:', hwError.message);
      }
      
      // 소프트웨어 샘플 데이터 초기화 - software 컬렉션 사용
      try {
        const softwareCount = await Software.countDocuments();
        if (softwareCount === 0) {
          const sampleSoftwareData = getSampleSoftwareData();
          await Software.insertMany(sampleSoftwareData);
          console.log('샘플 소프트웨어 데이터가 software 컬렉션에 추가되었습니다.');
        } else {
          console.log(`software 컬렉션에 ${softwareCount}개의 데이터가 있습니다.`);
        }
      } catch (swError) {
        console.error('소프트웨어 데이터 초기화 오류:', swError.message);
      }
      
      // 설비 연동관리 샘플 데이터 초기화 - connection 컬렉션 사용
      try {
        console.log('설비 연동관리 데이터 초기화 시작...');
        
        // 데이터베이스 연결 확인
        const dbName = mongoose.connection.db.databaseName;
        console.log(`현재 연결된 데이터베이스: ${dbName}`);
        
        // 필요시 asset_management 데이터베이스로 전환
        let db = mongoose.connection.db;
        if (dbName !== 'asset_management') {
          console.log('asset_management 데이터베이스로 전환 시도...');
          db = mongoose.connection.useDb('asset_management');
          console.log('asset_management 데이터베이스로 전환 완료');
        }
        
        // 설비 연동관리 컬렉션이 존재하는지 확인
        const collections = await db.listCollections({ name: 'connection' }).toArray();
        if (collections.length === 0) {
          console.log('connection 컬렉션이 없습니다. 컬렉션을 생성합니다.');
          await db.createCollection('connection');
          console.log('connection 컬렉션이 성공적으로 생성되었습니다.');
          
          // 필요한 인덱스 생성
          const connectionCollection = db.collection('connection');
          await connectionCollection.createIndex({ 'code': 1 }, { unique: true });
          await connectionCollection.createIndex({ 'line': 1 });
          await connectionCollection.createIndex({ 'equipment': 1 });
          await connectionCollection.createIndex({ 'status': 1 });
          console.log('connection 컬렉션 인덱스 생성 완료.');
        } else {
          console.log('connection 컬렉션이 이미 존재합니다.');
        }
        
        // 직접 컬렉션 접근
        const connectionCollection = db.collection('connection');
        
        // 데이터 초기화
        const equipmentConnectionCount = await connectionCollection.countDocuments();
        console.log(`현재 connection 컬렉션의 데이터 수: ${equipmentConnectionCount}`);
        
        if (equipmentConnectionCount === 0) {
          const sampleEquipmentConnectionData = getSampleEquipmentConnectionData();
          console.log(`설비 연동관리 샘플 데이터 ${sampleEquipmentConnectionData.length}개를 추가합니다.`);
          
          // 데이터 삽입 전 로깅
          sampleEquipmentConnectionData.forEach((item, index) => {
            console.log(`데이터 ${index + 1}: 코드=${item.code}, 라인=${item.line}, 설비=${item.equipment}, 상태=${item.status}`);
          });
          
          // 직접 MongoDB 컬렉션에 삽입
          const result = await connectionCollection.insertMany(sampleEquipmentConnectionData);
          console.log(`설비 연동관리 ${result.insertedCount}개 데이터가 connection 컬렉션에 성공적으로 추가되었습니다.`);
        } else {
          console.log(`connection 컬렉션에 이미 ${equipmentConnectionCount}개의 데이터가 있습니다.`);
        }
        
        // 연결 및 데이터 확인 로깅
        const verifyCount = await connectionCollection.countDocuments();
        console.log(`설비 연동관리 데이터 검증: connection 컬렉션에 ${verifyCount}개의 데이터가 있습니다.`);
        
      } catch (connectionError) {
        console.error('설비 연동관리 초기화 오류:', connectionError.message);
        console.log('설비 연동관리 초기화를 다시 시도합니다...');
        
        try {
          // asset_management 데이터베이스 연결
          const assetManagementDB = mongoose.connection.useDb('asset_management');
          
          // 컬렉션 삭제 후 재생성 시도
          try {
            const hasCollection = await assetManagementDB.listCollections({ name: 'connection' }).toArray();
            if (hasCollection.length > 0) {
              await assetManagementDB.dropCollection('connection');
              console.log('기존 connection 컬렉션을 삭제했습니다.');
            }
          } catch (dropError) {
            console.log('connection 컬렉션 삭제 실패 (존재하지 않을 수 있음):', dropError.message);
          }
          
          // 컬렉션 생성
          await assetManagementDB.createCollection('connection');
          console.log('connection 컬렉션을 새로 생성했습니다.');
          
          // 인덱스 생성
          const connectionCollection = assetManagementDB.collection('connection');
          await connectionCollection.createIndex({ 'code': 1 }, { unique: true });
          await connectionCollection.createIndex({ 'line': 1 });
          await connectionCollection.createIndex({ 'equipment': 1 });
          await connectionCollection.createIndex({ 'status': 1 });
          console.log('connection 컬렉션 인덱스 생성 완료.');
          
          // 샘플 데이터 생성
          const sampleEquipmentConnectionData = getSampleEquipmentConnectionData();
          
          // 직접 MongoDB 컬렉션에 삽입
          const result = await connectionCollection.insertMany(sampleEquipmentConnectionData);
          console.log(`설비 연동관리 ${result.insertedCount}개 데이터 초기화 성공!`);
          
        } catch (createError) {
          console.error('설비 연동관리 컬렉션 생성 오류:', createError.message);
          console.error('설비 연동관리 데이터는 메모리에만 저장될 것입니다.');
        }
      }
      
      // attachments 컬렉션 존재 확인 및 생성
      try {
        const collections = await mongoose.connection.db.listCollections({ name: 'attachments' }).toArray();
        if (collections.length === 0) {
          console.log('attachments 컬렉션이 없습니다. 컬렉션을 생성합니다.');
          // 컬렉션 생성 시 스키마 옵션(예: 인덱스) 적용 가능
          await mongoose.connection.db.createCollection('attachments');
          console.log('attachments 컬렉션 생성 완료.');
          // 인덱스 생성 (예: relatedEntityId와 relatedEntityType 복합 인덱스)
          await Attachment.createIndexes();
          console.log('attachments 컬렉션 인덱스 생성 완료.');
        } else {
          console.log('attachments 컬렉션이 이미 존재합니다.');
        }
      } catch (attachError) {
        console.error('Attachments 컬렉션 확인/생성/인덱싱 오류:', attachError.message);
        // 심각한 오류일 경우 서버 시작 중단 고려
        // process.exit(1);
      }
      
      console.log('MongoDB 초기화 완료!');
      break; // 초기화 성공 - 루프 종료
      
    } catch (error) {
      retryCount++;
      console.log(`MongoDB 초기화 오류: ${error.message}`);
      
      if (retryCount >= maxRetries) {
        console.log('최대 재시도 횟수 초과. 메모리 저장소로 전환합니다.');
        
        // 메모리 저장소 초기화 (첨부파일 제외)
        if (memoryDB.vocs.length === 0) {
          memoryDB.vocs = getSampleVocData();
          console.log('메모리에 샘플 VOC 데이터가 추가되었습니다.');
        }
        
        if (memoryDB.systemUpdates.length === 0) {
          memoryDB.systemUpdates = getSampleSystemUpdateData();
          console.log('메모리에 샘플 시스템 업데이트 데이터가 추가되었습니다.');
        }
        
        if (memoryDB.hardware.length === 0) {
          memoryDB.hardware = getSampleHardwareData();
          console.log('메모리에 샘플 하드웨어 데이터가 추가되었습니다.');
        }
        
        if (memoryDB.software.length === 0) {
          memoryDB.software = getSampleSoftwareData();
          console.log('메모리에 샘플 소프트웨어 데이터가 추가되었습니다.');
        }
        
        if (memoryDB.equipmentConnections.length === 0) {
          memoryDB.equipmentConnections = getSampleEquipmentConnectionData();
          console.log('메모리에 샘플 설비 연동관리 데이터가 추가되었습니다.');
        }
        
        break;
      }
      
      // 잠시 대기 후 재시도
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
};

// 서버 시작
initMongoDB().then(() => {
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