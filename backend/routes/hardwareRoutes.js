const express = require('express');
const router = express.Router();
const Hardware = require('../models/hardwareModel');

// 하드웨어 자산 목록 조회 API
router.get('/', async (req, res) => {
  try {
    // 쿼리 파라미터 추출
    const { 
      search, 
      assetCode, 
      assetType,
      assetName, 
      executionType, 
      startDate, 
      endDate,
      serialNumber,
      currentUser
    } = req.query;
    
    // 검색 조건 구성
    const query = {};
    
    // 통합 검색어 처리
    if (search) {
      query.$or = [
        { code: { $regex: search, $options: 'i' } },
        { assetCode: { $regex: search, $options: 'i' } },
        { assetType: { $regex: search, $options: 'i' } },
        { assetName: { $regex: search, $options: 'i' } },
        { specification: { $regex: search, $options: 'i' } },
        { lotCode: { $regex: search, $options: 'i' } },
        { detail: { $regex: search, $options: 'i' } },
        { serialNumber: { $regex: search, $options: 'i' } },
        { currentUser: { $regex: search, $options: 'i' } },
        { remarks: { $regex: search, $options: 'i' } }
      ];
    }
    
    // 자산 코드 필터
    if (assetCode) {
      query.assetCode = { $regex: assetCode, $options: 'i' };
    }
    
    // 자산 분류 필터
    if (assetType) {
      query.assetType = assetType;
    }
    
    // 자산 이름 필터
    if (assetName) {
      query.assetName = assetName;
    }
    
    // 실행 유형 필터
    if (executionType) {
      query.executionType = executionType;
    }
    
    // 시리얼 넘버 필터
    if (serialNumber) {
      query.serialNumber = { $regex: serialNumber, $options: 'i' };
    }
    
    // 현재 사용자 필터
    if (currentUser) {
      query.currentUser = { $regex: currentUser, $options: 'i' };
    }
    
    // 날짜 범위 필터 (등록일)
    if (startDate || endDate) {
      query.regDate = {};
      
      if (startDate) {
        query.regDate.$gte = new Date(startDate);
      }
      
      if (endDate) {
        const endDateObj = new Date(endDate);
        endDateObj.setHours(23, 59, 59, 999); // 해당 일자의 마지막 시간으로 설정
        query.regDate.$lte = endDateObj;
      }
    }

    // 데이터 조회 (등록 번호 기준 내림차순 정렬)
    const hardwareData = await Hardware.find(query).sort({ no: -1 });
    
    console.log(`하드웨어 데이터 조회 완료: ${hardwareData.length}개 항목`);
    
    // 응답 반환
    res.json(hardwareData);
  } catch (error) {
    console.error('하드웨어 데이터 조회 중 오류:', error);
    res.status(500).json({ message: '하드웨어 데이터를 불러오는 중 오류가 발생했습니다.', error: error.message });
  }
});

// 단일 하드웨어 자산 조회 API (코드 기준)
router.get('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    
    console.log(`단일 하드웨어 조회 요청: ${code}`);
    
    // 코드로 데이터 조회
    const hardware = await Hardware.findOne({ code });
    
    if (!hardware) {
      console.log(`하드웨어 코드 ${code} 조회 실패: 데이터 없음`);
      return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
    }
    
    console.log(`하드웨어 코드 ${code} 조회 성공`);
    
    // 응답 반환
    res.json(hardware);
  } catch (error) {
    console.error('하드웨어 상세 조회 중 오류:', error);
    res.status(500).json({ message: '하드웨어 상세 정보를 불러오는 중 오류가 발생했습니다.', error: error.message });
  }
});

// 하드웨어 자산 추가 API
router.post('/', async (req, res) => {
  try {
    console.log('[Backend] 하드웨어 추가 요청 수신:', new Date().toISOString());
    console.log('[Backend] 요청 본문:', JSON.stringify(req.body, null, 2));

    const hardwareData = req.body;

    // 필수 필드 중 executionType만 확인
    // (assetCode와 assetName은 스키마에서 기본값 설정)
    if (hardwareData.executionType == null) {
      console.error('[Backend] 필수 필드 누락:', { executionType: hardwareData.executionType });
      return res.status(400).json({ message: '실행유형(executionType)은 필수 입력 항목입니다.' });
    }
    
    // 빈 문자열은 기본값으로 대체 (추가 안전 조치)
    if (hardwareData.assetCode === '') {
      console.log('[Backend] assetCode가 빈 문자열이므로 기본값으로 대체합니다.');
      // 기본값은 이미 스키마에 설정되어 있으므로 필드를 삭제하면 기본값이 적용됨
      delete hardwareData.assetCode;
    }
    
    if (hardwareData.assetName === '') {
      console.log('[Backend] assetName이 빈 문자열이므로 기본값으로 대체합니다.');
      delete hardwareData.assetName;
    }
    
    // 클라이언트에서 넘어온 가상 필드 처리
    if (hardwareData.isSaved !== undefined) {
      hardwareData.saveStatus = hardwareData.isSaved;
    }
    if (hardwareData.isModified !== undefined) {
      hardwareData.modifiedStatus = hardwareData.isModified;
    }
    
    // 번호 자동 생성 (기존 데이터가 없는 경우 1부터 시작)
    if (!hardwareData.no) {
      try {
        const maxNoHardware = await Hardware.findOne({}, {}, { sort: { 'no': -1 } }).select('no');
        hardwareData.no = maxNoHardware ? maxNoHardware.no + 1 : 1;
        console.log(`[Backend] 하드웨어 번호 자동 생성: ${hardwareData.no}`);
      } catch (err) {
        console.error('[Backend] 번호 자동 생성 중 오류:', err);
        hardwareData.no = Math.floor(Math.random() * 1000) + 1; // 오류 시 임의의 번호 할당
        console.log(`[Backend] 대체 번호 생성: ${hardwareData.no}`);
      }
    }
    
    // 코드 자동 생성 (없는 경우)
    if (!hardwareData.code) {
      try {
        const regDate = hardwareData.regDate ? new Date(hardwareData.regDate) : new Date();
        const year = regDate.getFullYear().toString().slice(-2);
        const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
        const day = regDate.getDate().toString().padStart(2, '0');
        const code = `HW${year}${month}${day}-${hardwareData.no.toString().padStart(4, '0')}`;
        hardwareData.code = code;
        console.log(`[Backend] 하드웨어 코드 자동 생성: ${code}`);
      } catch (err) {
        console.error('[Backend] 코드 자동 생성 중 오류:', err);
        const now = new Date();
        const timestamp = Math.floor(now.getTime() / 1000);
        hardwareData.code = `HW-${timestamp}-${hardwareData.no}`;
        console.log(`[Backend] 대체 코드 생성: ${hardwareData.code}`);
      }
    }
    
    // 필드 기본값 설정
    hardwareData.createdAt = new Date();
    hardwareData.updatedAt = new Date();
    hardwareData.saveStatus = true;
    hardwareData.modifiedStatus = false;

    // 날짜 필드 처리 (문자열 -> Date 객체)
    if (hardwareData.regDate && typeof hardwareData.regDate === 'string') {
      try {
        hardwareData.regDate = new Date(hardwareData.regDate);
      } catch (err) {
        console.error('[Backend] 날짜 변환 오류:', err);
        hardwareData.regDate = new Date(); // 오류 시 현재 날짜 사용
      }
    }
    
    console.log('[Backend] MongoDB 저장 시도 데이터:', JSON.stringify(hardwareData, null, 2));

    // 모델 인스턴스 생성 및 저장
    const newHardware = new Hardware(hardwareData);
    const savedHardware = await newHardware.save();
    
    console.log(`[Backend] 하드웨어 데이터 저장 성공 - ID: ${savedHardware._id}, 코드: ${savedHardware.code}`);
    
    // 저장된 데이터 반환
    res.status(201).json(savedHardware);
  } catch (error) {
    console.error('[Backend] 하드웨어 데이터 저장 중 오류:', error);
    
    // 중복 코드 오류 처리
    if (error.code === 11000 && error.keyPattern && error.keyPattern.code) {
      const duplicateCode = error.keyValue?.code || '';
      return res.status(400).json({ message: `이미 존재하는 하드웨어 코드입니다: ${duplicateCode}`, error: error.message });
    }
    
    // 유효성 검사 오류 처리
    if (error.name === 'ValidationError') {
      const validationErrors = {};
      for (const field in error.errors) {
        validationErrors[field] = error.errors[field].message;
      }
      console.error('[Backend] 유효성 검사 오류 세부 정보:', validationErrors);
      return res.status(400).json({ 
        message: '데이터 유효성 검사 실패', 
        validationErrors: validationErrors
      });
    }
    
    res.status(500).json({ message: '하드웨어 데이터를 저장하는 중 오류가 발생했습니다.', error: error.message });
  }
});

// 하드웨어 자산 수정 API (코드 기준)
router.put('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    const updateData = req.body;
    
    console.log(`하드웨어 수정 요청: ${code}`);
    console.log('수정 데이터:', updateData);
    
    // 클라이언트에서 넘어온 가상 필드 처리
    if (updateData.isSaved !== undefined) {
      updateData.saveStatus = updateData.isSaved;
    }
    if (updateData.isModified !== undefined) {
      updateData.modifiedStatus = updateData.isModified;
    }
    
    // 중요 필드 보호
    delete updateData._id; // _id는 변경 불가
    updateData.code = code; // 코드는 URL에서 지정한 값으로 유지
    updateData.updatedAt = new Date(); // 수정 시간 업데이트
    updateData.saveStatus = true;
    updateData.modifiedStatus = false;
    
    // 날짜 필드가 문자열로 전달된 경우 Date 객체로 변환
    if (typeof updateData.regDate === 'string') {
      updateData.regDate = new Date(updateData.regDate);
    }
    
    // 데이터 업데이트
    const updatedHardware = await Hardware.findOneAndUpdate(
      { code },
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!updatedHardware) {
      console.log(`하드웨어 수정 실패: 코드 ${code} 데이터 없음`);
      return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
    }
    
    console.log(`하드웨어 데이터 수정 성공: ${code}`);
    
    // 수정된 데이터 반환
    res.json(updatedHardware);
  } catch (error) {
    console.error('하드웨어 데이터 수정 중 오류:', error);
    res.status(500).json({ message: '하드웨어 데이터를 수정하는 중 오류가 발생했습니다.', error: error.message });
  }
});

// 하드웨어 자산 삭제 API (코드 기준)
router.delete('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    
    console.log(`하드웨어 삭제 요청: ${code}`);
    
    // 데이터 삭제
    const deletedHardware = await Hardware.findOneAndDelete({ code });
    
    if (!deletedHardware) {
      console.log(`하드웨어 삭제 실패: 코드 ${code} 데이터 없음`);
      return res.status(404).json({ message: '해당 코드의 하드웨어를 찾을 수 없습니다.' });
    }
    
    console.log(`하드웨어 데이터 삭제 성공: ${code}`);
    
    // 삭제 성공 응답
    res.json({ 
      message: '하드웨어 데이터가 성공적으로 삭제되었습니다.',
      deletedHardware
    });
  } catch (error) {
    console.error('하드웨어 데이터 삭제 중 오류:', error);
    res.status(500).json({ message: '하드웨어 데이터를 삭제하는 중 오류가 발생했습니다.', error: error.message });
  }
});

module.exports = router; 