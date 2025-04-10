const express = require('express');
const router = express.Router();
const EquipmentConnectionModel = require('../models/equipmentConnectionModel');

// 모든 설비연동 데이터 조회 (검색 및 필터링 지원)
router.get('/', async (req, res) => {
  try {
    const { search, line, equipment, workType, dataType, connectionType, status, startDate, endDate } = req.query;
    console.log(`설비연동 조회 요청 - 검색어: ${search}, 라인: ${line}, 설비: ${equipment}, 상태: ${status}`);
    console.log('컬렉션 정보: nexplus_task/connection');
    
    // 조회 조건 구성
    const query = { isDeleted: false };
    
    // 검색어 처리
    if (search && search.length > 0) {
      query.$or = [
        { line: { $regex: search, $options: 'i' } },
        { equipment: { $regex: search, $options: 'i' } },
        { workType: { $regex: search, $options: 'i' } },
        { dataType: { $regex: search, $options: 'i' } },
        { connectionType: { $regex: search, $options: 'i' } },
        { detail: { $regex: search, $options: 'i' } },
        { remarks: { $regex: search, $options: 'i' } },
      ];
    }
    
    // 라인 필터
    if (line) {
      query.line = line;
    }
    
    // 설비 필터
    if (equipment) {
      query.equipment = equipment;
    }
    
    // 작업유형 필터
    if (workType) {
      query.workType = workType;
    }
    
    // 데이터유형 필터
    if (dataType) {
      query.dataType = dataType;
    }
    
    // 연동유형 필터
    if (connectionType) {
      query.connectionType = connectionType;
    }
    
    // 상태 필터
    if (status) {
      query.status = status;
    }
    
    // 날짜 범위 필터
    if (startDate || endDate) {
      query.regDate = {};
      
      if (startDate) {
        query.regDate.$gte = new Date(startDate);
      }
      
      if (endDate) {
        query.regDate.$lte = new Date(endDate);
      }
    }
    
    console.log('설비연동 데이터 조회 쿼리:', JSON.stringify(query));
    
    // 데이터 조회 및 정렬
    const connectionData = await EquipmentConnectionModel.find(query)
      .sort({ regDate: -1, no: -1 })
      .lean();
    
    console.log(`설비연동 데이터 조회 결과: ${connectionData.length}개 항목 (nexplus_task/connection)`);
    res.status(200).json(connectionData);
    
  } catch (error) {
    console.error('설비연동 조회 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 설비연동 데이터 추가
router.post('/', async (req, res) => {
  try {
    const connectionData = req.body;
    console.log('설비연동 데이터 추가 요청:', JSON.stringify(connectionData));
    console.log('데이터베이스/컬렉션: nexplus_task/connection');
    
    // no 필드가 없는 경우 자동 생성
    if (!connectionData.no) {
      const lastItem = await EquipmentConnectionModel.findOne().sort({ no: -1 }).lean();
      connectionData.no = lastItem ? lastItem.no + 1 : 1;
      console.log(`자동 생성된 번호: ${connectionData.no}`);
    }
    
    // code 필드가 없는 경우 자동 생성
    if (!connectionData.code) {
      const date = connectionData.regDate ? new Date(connectionData.regDate) : new Date();
      const year = date.getFullYear().toString().substring(2);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const seq = connectionData.no.toString().padStart(3, '0');
      connectionData.code = `EQC-${year}${month}-${seq}`;
      console.log(`자동 생성된 코드: ${connectionData.code}`);
    }
    
    // 날짜 필드 처리
    if (connectionData.regDate && typeof connectionData.regDate === 'string') {
      connectionData.regDate = new Date(connectionData.regDate);
    }
    
    if (connectionData.startDate && typeof connectionData.startDate === 'string') {
      connectionData.startDate = new Date(connectionData.startDate);
    }
    
    if (connectionData.completionDate && typeof connectionData.completionDate === 'string') {
      connectionData.completionDate = new Date(connectionData.completionDate);
    }
    
    // 중복 체크
    const existingConnection = await EquipmentConnectionModel.findOne({ code: connectionData.code });
    if (existingConnection) {
      console.log(`중복 코드 발견: ${connectionData.code}`);
      return res.status(409).json({ message: '이미 존재하는 코드입니다.' });
    }
    
    // 데이터 저장
    const newConnection = new EquipmentConnectionModel(connectionData);
    await newConnection.save();
    
    console.log(`설비연동 데이터 추가 성공: ${newConnection.code} (nexplus_task/connection 컬렉션에 저장됨)`);
    res.status(201).json(newConnection);
    
  } catch (error) {
    console.error('설비연동 추가 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 설비연동 데이터 수정 (코드로 조회)
router.put('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    const updateData = req.body;
    console.log(`설비연동 데이터 수정 요청 - 코드: ${code}`);
    console.log('데이터베이스/컬렉션: nexplus_task/connection');
    
    // _id 필드 제거 (MongoDB가 자동 관리)
    delete updateData._id;
    
    // 날짜 필드 처리
    if (updateData.regDate && typeof updateData.regDate === 'string') {
      updateData.regDate = new Date(updateData.regDate);
    }
    
    if (updateData.startDate && typeof updateData.startDate === 'string') {
      updateData.startDate = new Date(updateData.startDate);
    }
    
    if (updateData.completionDate && typeof updateData.completionDate === 'string') {
      updateData.completionDate = new Date(updateData.completionDate);
    }
    
    // 데이터 업데이트
    const updatedConnection = await EquipmentConnectionModel.findOneAndUpdate(
      { code, isDeleted: false },
      updateData,
      { new: true }
    );
    
    if (!updatedConnection) {
      console.log(`설비연동 데이터를 찾을 수 없음: ${code} (nexplus_task/connection)`);
      return res.status(404).json({ message: '설비연동 데이터를 찾을 수 없습니다.' });
    }
    
    console.log(`설비연동 데이터 수정 성공: ${code} (nexplus_task/connection)`);
    res.status(200).json(updatedConnection);
    
  } catch (error) {
    console.error('설비연동 수정 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 설비연동 데이터 삭제 (코드로 조회) - 소프트 삭제
router.delete('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    console.log(`설비연동 데이터 삭제 요청 - 코드: ${code}`);
    console.log('데이터베이스/컬렉션: nexplus_task/connection');
    
    // 소프트 삭제 (isDeleted 필드 업데이트)
    const result = await EquipmentConnectionModel.findOneAndUpdate(
      { code, isDeleted: false },
      { isDeleted: true },
      { new: true }
    );
    
    if (!result) {
      console.log(`삭제할 설비연동 데이터를 찾을 수 없음: ${code} (nexplus_task/connection)`);
      return res.status(404).json({ message: '설비연동 데이터를 찾을 수 없습니다.' });
    }
    
    console.log(`설비연동 데이터 삭제 성공: ${code} (nexplus_task/connection)`);
    res.status(200).json({ message: '설비연동 데이터가 삭제되었습니다.' });
    
  } catch (error) {
    console.error('설비연동 삭제 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

module.exports = router; 