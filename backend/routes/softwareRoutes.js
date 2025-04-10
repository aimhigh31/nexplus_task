const express = require('express');
const router = express.Router();
const SoftwareModel = require('../models/softwareModel');

// 모든 소프트웨어 데이터 조회 (검색 및 필터링 지원)
router.get('/', async (req, res) => {
  try {
    const { search, assetType, assetCode, assetName, costType, startDate, endDate } = req.query;
    
    // 조회 조건 구성
    const query = { isDeleted: false };
    
    // 검색어 처리
    if (search && search.length > 0) {
      query.$or = [
        { assetType: { $regex: search, $options: 'i' } },
        { assetName: { $regex: search, $options: 'i' } },
        { specification: { $regex: search, $options: 'i' } },
        { assetCode: { $regex: search, $options: 'i' } },
        { vendor: { $regex: search, $options: 'i' } },
        { licenseKey: { $regex: search, $options: 'i' } },
        { user: { $regex: search, $options: 'i' } },
        { detail: { $regex: search, $options: 'i' } },
        { remarks: { $regex: search, $options: 'i' } },
      ];
    }
    
    // 자산분류 필터
    if (assetType) {
      query.assetType = assetType;
    }
    
    // 자산코드 필터
    if (assetCode) {
      query.assetCode = assetCode;
    }
    
    // 자산명 필터
    if (assetName) {
      query.assetName = assetName;
    }
    
    // 비용형태 필터
    if (costType) {
      query.costType = costType;
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
    
    // 데이터 조회 및 정렬
    const softwareData = await SoftwareModel.find(query)
      .sort({ regDate: -1, no: -1 })
      .lean();
    
    res.status(200).json(softwareData);
    
  } catch (error) {
    console.error('소프트웨어 조회 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 소프트웨어 데이터 추가
router.post('/', async (req, res) => {
  try {
    const softwareData = req.body;
    
    // no 필드가 없는 경우 자동 생성
    if (!softwareData.no) {
      const lastItem = await SoftwareModel.findOne().sort({ no: -1 }).lean();
      softwareData.no = lastItem ? lastItem.no + 1 : 1;
    }
    
    // code 필드가 없는 경우 자동 생성
    if (!softwareData.code) {
      const date = softwareData.regDate ? new Date(softwareData.regDate) : new Date();
      const year = date.getFullYear().toString().substring(2);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const seq = softwareData.no.toString().padStart(3, '0');
      softwareData.code = `SWM-${year}${month}-${seq}`;
    }
    
    // 중복 체크
    const existingSoftware = await SoftwareModel.findOne({ code: softwareData.code });
    if (existingSoftware) {
      return res.status(409).json({ message: '이미 존재하는 코드입니다.' });
    }
    
    // 데이터 저장
    const newSoftware = new SoftwareModel(softwareData);
    await newSoftware.save();
    
    res.status(201).json(newSoftware);
    
  } catch (error) {
    console.error('소프트웨어 추가 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 소프트웨어 데이터 수정 (코드로 조회)
router.put('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    const updateData = req.body;
    
    // _id 필드 제거 (MongoDB가 자동 관리)
    delete updateData._id;
    
    // 데이터 업데이트
    const updatedSoftware = await SoftwareModel.findOneAndUpdate(
      { code, isDeleted: false },
      updateData,
      { new: true }
    );
    
    if (!updatedSoftware) {
      return res.status(404).json({ message: '소프트웨어를 찾을 수 없습니다.' });
    }
    
    res.status(200).json(updatedSoftware);
    
  } catch (error) {
    console.error('소프트웨어 수정 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

// 소프트웨어 데이터 삭제 (코드로 조회) - 소프트 삭제
router.delete('/code/:code', async (req, res) => {
  try {
    const { code } = req.params;
    
    // 소프트 삭제 (isDeleted 필드 업데이트)
    const result = await SoftwareModel.findOneAndUpdate(
      { code, isDeleted: false },
      { isDeleted: true },
      { new: true }
    );
    
    if (!result) {
      return res.status(404).json({ message: '소프트웨어를 찾을 수 없습니다.' });
    }
    
    res.status(200).json({ message: '소프트웨어가 삭제되었습니다.' });
    
  } catch (error) {
    console.error('소프트웨어 삭제 오류:', error);
    res.status(500).json({ message: '서버 오류', error: error.message });
  }
});

module.exports = router; 