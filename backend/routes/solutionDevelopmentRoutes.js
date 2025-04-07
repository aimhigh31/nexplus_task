// solution-development 엔드포인트는 system-updates와 동일한 기능을 제공하는 별칭 라우트입니다.
// 클라이언트가 두 엔드포인트 중 하나를 선택적으로 사용할 수 있도록 지원합니다.

const express = require('express');
const router = express.Router();
const SystemUpdate = require('../models/systemUpdateModel');

// systemUpdateRoutes.js와 동일한 기능을 제공하지만 URL만 다릅니다.

// 모든 시스템 업데이트 데이터 조회 (검색 및 필터링 지원)
router.get('/', async (req, res) => {
  try {
    const { 
      search, 
      targetSystem, 
      updateType, 
      status, 
      startDate, 
      endDate 
    } = req.query;
    
    // 쿼리 필터 구성
    const filter = {};
    
    // 통합 검색 (여러 필드에서 검색어 찾기)
    if (search) {
      const searchRegex = new RegExp(search, 'i');
      filter.$or = [
        { updateCode: searchRegex },
        { description: searchRegex },
        { assignee: searchRegex },
        { remarks: searchRegex }
      ];
    }
    
    // 특정 필드 필터링
    if (targetSystem) {
      filter.targetSystem = targetSystem;
    }
    
    if (updateType) {
      filter.updateType = updateType;
    }
    
    if (status) {
      filter.status = status;
    }
    
    // 날짜 범위 필터링
    if (startDate || endDate) {
      filter.regDate = {};
      
      if (startDate) {
        filter.regDate.$gte = new Date(startDate);
      }
      
      if (endDate) {
        const endDateTime = new Date(endDate);
        endDateTime.setHours(23, 59, 59, 999);
        filter.regDate.$lte = endDateTime;
      }
    }
    
    console.log('솔루션 개발 조회 필터:', JSON.stringify(filter));
    
    // 데이터 조회 및 응답
    const updates = await SystemUpdate.find(filter).sort({ no: -1 });
    res.json(updates);
  } catch (error) {
    console.error('솔루션 개발 조회 오류:', error);
    res.status(500).json({ message: '솔루션 개발 데이터 조회 중 오류가 발생했습니다.', error: error.message });
  }
});

// 특정 솔루션 개발 조회 (번호 기준)
router.get('/:id', async (req, res) => {
  try {
    const update = await SystemUpdate.findOne({ no: req.params.id });
    
    if (!update) {
      return res.status(404).json({ message: '해당 번호의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json(update);
  } catch (error) {
    console.error('솔루션 개발 상세 조회 오류:', error);
    res.status(500).json({ message: '솔루션 개발 상세 조회 중 오류가 발생했습니다.', error: error.message });
  }
});

// 특정 솔루션 개발 조회 (코드 기준)
router.get('/code/:code', async (req, res) => {
  try {
    const update = await SystemUpdate.findOne({ updateCode: req.params.code });
    
    if (!update) {
      return res.status(404).json({ message: '해당 코드의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json(update);
  } catch (error) {
    console.error('솔루션 개발 코드 조회 오류:', error);
    res.status(500).json({ message: '솔루션 개발 코드 조회 중 오류가 발생했습니다.', error: error.message });
  }
});

// 솔루션 개발 추가
router.post('/', async (req, res) => {
  try {
    // 최대 번호 조회 (없으면 기본값 0 사용)
    const maxNoDoc = await SystemUpdate.findOne().sort({ no: -1 });
    const nextNo = maxNoDoc ? maxNoDoc.no + 1 : 1;
    
    // updateCode가 없는 경우 자동 생성
    if (!req.body.updateCode) {
      const now = new Date();
      const yearMonth = `${now.getFullYear().toString().substring(2)}${(now.getMonth() + 1).toString().padStart(2, '0')}`;
      const seq = nextNo.toString().padStart(3, '0');
      req.body.updateCode = `UPD${yearMonth}${seq}`;
    }
    
    // 번호 자동 할당 (클라이언트에서 제공하지 않은 경우)
    if (!req.body.no) {
      req.body.no = nextNo;
    }
    
    // 상태 필드 설정
    if (req.body.isSaved !== undefined) {
      req.body.saveStatus = req.body.isSaved;
    }
    
    if (req.body.isModified !== undefined) {
      req.body.modifiedStatus = req.body.isModified;
    }
    
    const newUpdate = new SystemUpdate(req.body);
    const savedUpdate = await newUpdate.save();
    
    res.status(201).json(savedUpdate);
  } catch (error) {
    console.error('솔루션 개발 추가 오류:', error);
    
    // 중복 코드 오류 처리
    if (error.name === 'DuplicateError' || (error.name === 'MongoServerError' && error.code === 11000)) {
      return res.status(409).json({ message: '중복된 업데이트 코드입니다.', error: error.message });
    }
    
    res.status(500).json({ message: '솔루션 개발 추가 중 오류가 발생했습니다.', error: error.message });
  }
});

// 솔루션 개발 수정 (번호 기준)
router.put('/:id', async (req, res) => {
  try {
    const update = await SystemUpdate.findOneAndUpdate(
      { no: req.params.id }, 
      req.body, 
      { new: true, runValidators: true }
    );
    
    if (!update) {
      return res.status(404).json({ message: '해당 번호의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json(update);
  } catch (error) {
    console.error('솔루션 개발 수정 오류:', error);
    res.status(500).json({ message: '솔루션 개발 수정 중 오류가 발생했습니다.', error: error.message });
  }
});

// 솔루션 개발 수정 (코드 기준)
router.put('/code/:code', async (req, res) => {
  try {
    // updateCode는 변경하지 않도록 함
    delete req.body.updateCode;
    
    // 상태 필드 설정
    if (req.body.isSaved !== undefined) {
      req.body.saveStatus = req.body.isSaved;
    }
    
    if (req.body.isModified !== undefined) {
      req.body.modifiedStatus = req.body.isModified;
    }
    
    const update = await SystemUpdate.findOneAndUpdate(
      { updateCode: req.params.code }, 
      req.body, 
      { new: true, runValidators: true }
    );
    
    if (!update) {
      return res.status(404).json({ message: '해당 코드의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json(update);
  } catch (error) {
    console.error('솔루션 개발 코드 수정 오류:', error);
    res.status(500).json({ message: '솔루션 개발 코드 수정 중 오류가 발생했습니다.', error: error.message });
  }
});

// 솔루션 개발 삭제 (번호 기준)
router.delete('/:id', async (req, res) => {
  try {
    const update = await SystemUpdate.findOneAndDelete({ no: req.params.id });
    
    if (!update) {
      return res.status(404).json({ message: '해당 번호의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json({ message: '솔루션 개발이 성공적으로 삭제되었습니다.', deletedUpdate: update });
  } catch (error) {
    console.error('솔루션 개발 삭제 오류:', error);
    res.status(500).json({ message: '솔루션 개발 삭제 중 오류가 발생했습니다.', error: error.message });
  }
});

// 솔루션 개발 삭제 (코드 기준)
router.delete('/code/:code', async (req, res) => {
  try {
    const update = await SystemUpdate.findOneAndDelete({ updateCode: req.params.code });
    
    if (!update) {
      return res.status(404).json({ message: '해당 코드의 솔루션 개발을 찾을 수 없습니다.' });
    }
    
    res.json({ message: '솔루션 개발이 성공적으로 삭제되었습니다.', deletedUpdate: update });
  } catch (error) {
    console.error('솔루션 개발 코드 삭제 오류:', error);
    res.status(500).json({ message: '솔루션 개발 코드 삭제 중 오류가 발생했습니다.', error: error.message });
  }
});

module.exports = router; 