const express = require('express');
const router = express.Router();
const Voc = require('../models/vocModel');

// 모든 VOC 데이터 조회 (검색 및 필터링 지원)
router.get('/', async (req, res) => {
  try {
    const { 
      search, 
      detailSearch,
      vocCategory, 
      requestType, 
      status, 
      startDate, 
      endDate, 
      dueDateStart, 
      dueDateEnd 
    } = req.query;
    
    const query = {};
    
    // 검색어 필터링
    if (search) {
      query.$or = [
        { requestDept: { $regex: search, $options: 'i' } },
        { requester: { $regex: search, $options: 'i' } },
        { systemPath: { $regex: search, $options: 'i' } },
        { request: { $regex: search, $options: 'i' } },
        { action: { $regex: search, $options: 'i' } },
        { actionTeam: { $regex: search, $options: 'i' } },
        { actionPerson: { $regex: search, $options: 'i' } }
      ];
    }
    
    // 세부내용 검색 필터링 (요청내용과 조치내용에서만 검색)
    if (detailSearch) {
      // 세부내용 검색은 요청내용과 조치내용 필드에서만 수행
      if (!query.$or) {
        query.$or = [];
      }
      
      // 기존 $or 쿼리가 있는 경우, $and로 결합
      if (search) {
        const originalOr = query.$or;
        query.$or = undefined; // 기존 $or 제거
        
        query.$and = [
          { $or: originalOr },
          { 
            $or: [
              { request: { $regex: detailSearch, $options: 'i' } },
              { action: { $regex: detailSearch, $options: 'i' } }
            ]
          }
        ];
      } else {
        // 기존 $or 쿼리가 없는 경우, 새로 생성
        query.$or = [
          { request: { $regex: detailSearch, $options: 'i' } },
          { action: { $regex: detailSearch, $options: 'i' } }
        ];
      }
    }
    
    // VOC 분류 필터
    if (vocCategory) {
      query.vocCategory = vocCategory;
    }
    
    // 요청분류 필터
    if (requestType) {
      query.requestType = requestType;
    }
    
    // 상태 필터
    if (status) {
      query.status = status;
    }
    
    // 등록일 범위 필터
    if (startDate || endDate) {
      query.regDate = {};
      if (startDate) {
        query.regDate.$gte = new Date(startDate);
      }
      if (endDate) {
        const nextDay = new Date(endDate);
        nextDay.setDate(nextDay.getDate() + 1);
        query.regDate.$lt = nextDay;
      }
    }
    
    // 마감일 범위 필터
    if (dueDateStart || dueDateEnd) {
      query.dueDate = {};
      if (dueDateStart) {
        query.dueDate.$gte = new Date(dueDateStart);
      }
      if (dueDateEnd) {
        const nextDay = new Date(dueDateEnd);
        nextDay.setDate(nextDay.getDate() + 1);
        query.dueDate.$lt = nextDay;
      }
    }
    
    // 데이터 조회 및 정렬 (번호 기준 내림차순)
    const vocData = await Voc.find(query).sort({ no: -1 });
    
    res.json(vocData);
  } catch (error) {
    console.error('VOC 데이터 조회 실패:', error);
    res.status(500).json({ message: 'VOC 데이터 조회 중 오류가 발생했습니다.' });
  }
});

// 단일 VOC 조회
router.get('/:id', async (req, res) => {
  try {
    const voc = await Voc.findOne({ no: req.params.id });
    
    if (!voc) {
      return res.status(404).json({ message: '해당 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    res.json(voc);
  } catch (error) {
    console.error('VOC 상세 조회 실패:', error);
    res.status(500).json({ message: 'VOC 상세 조회 중 오류가 발생했습니다.' });
  }
});

// VOC 추가
router.post('/', async (req, res) => {
  try {
    console.log('VOC 추가 요청 데이터:', req.body);
    
    const {
      no,
      code,
      regDate,
      vocCategory,
      requestDept,
      requester,
      systemPath,
      request,
      requestType,
      action,
      actionTeam,
      actionPerson,
      status,
      dueDate
    } = req.body;
    
    // 필수 필드 확인
    if (!vocCategory || !requestType || !status) {
      return res.status(400).json({ 
        message: '필수 필드가 누락되었습니다.',
        required: ['vocCategory', 'requestType', 'status'] 
      });
    }
    
    // 번호 할당 (클라이언트에서 지정한 번호 우선 사용)
    let newNo;
    if (no) {
      // 클라이언트에서 번호를 지정한 경우 해당 번호 사용
      newNo = no;
      console.log(`클라이언트 지정 번호 사용: ${newNo}`);
    } else {
      // 번호를 지정하지 않은 경우 자동 생성 (현재 최대값 + 1)
      const max = await Voc.findOne({}, {}, { sort: { 'no': -1 } });
      newNo = max ? max.no + 1 : 1;
      console.log(`자동 생성 번호 사용: ${newNo} (최대값 ${max?.no || 0} + 1)`);
    }
    
    // 날짜 처리 (문자열로 오는 경우 Date 객체로 변환)
    let regDateObj = new Date();
    if (regDate) {
      try {
        regDateObj = new Date(regDate);
        if (isNaN(regDateObj.getTime())) {
          console.log('유효하지 않은 등록일 형식:', regDate);
          regDateObj = new Date(); // 기본값으로 현재 날짜 사용
        }
      } catch (err) {
        console.log('등록일 변환 오류:', err);
        regDateObj = new Date();
      }
    }
    
    let dueDateObj = new Date();
    dueDateObj.setDate(dueDateObj.getDate() + 7); // 기본 마감일: 일주일 후
    
    if (dueDate) {
      try {
        dueDateObj = new Date(dueDate);
        if (isNaN(dueDateObj.getTime())) {
          console.log('유효하지 않은 마감일 형식:', dueDate);
          // 기본값 유지
        }
      } catch (err) {
        console.log('마감일 변환 오류:', err);
        // 기본값 유지
      }
    }
    
    // 새 VOC 객체 생성
    const newVoc = new Voc({
      no: newNo,
      code: code || null,  // 코드가 없으면 null로 설정
      regDate: regDateObj,
      vocCategory: vocCategory || 'MES 아산',
      requestDept: requestDept || '',
      requester: requester || '',
      systemPath: systemPath || '',
      request: request || '',
      requestType: requestType || '신규',
      action: action || '',
      actionTeam: actionTeam || '',
      actionPerson: actionPerson || '',
      status: status || '접수',
      dueDate: dueDateObj
    });
    
    console.log('저장할 VOC 데이터:', {
      no: newVoc.no,
      code: newVoc.code,
      regDate: newVoc.regDate,
      dueDate: newVoc.dueDate
    });
    
    const savedVoc = await newVoc.save();
    console.log('VOC 저장 성공:', savedVoc._id);
    res.status(201).json(savedVoc);
  } catch (error) {
    console.error('VOC 추가 실패:', error);
    res.status(500).json({ 
      message: 'VOC 추가 중 오류가 발생했습니다.',
      error: error.message 
    });
  }
});

// VOC 업데이트
router.put('/:id', async (req, res) => {
  try {
    const vocId = req.params.id;
    const updatedData = req.body;
    
    // regDate나 dueDate가 문자열로 오면 Date 객체로 변환
    if (updatedData.regDate && typeof updatedData.regDate === 'string') {
      updatedData.regDate = new Date(updatedData.regDate);
    }
    if (updatedData.dueDate && typeof updatedData.dueDate === 'string') {
      updatedData.dueDate = new Date(updatedData.dueDate);
    }
    
    const updatedVoc = await Voc.findOneAndUpdate(
      { no: vocId },
      updatedData,
      { new: true, runValidators: true }
    );
    
    if (!updatedVoc) {
      return res.status(404).json({ message: '해당 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    res.json(updatedVoc);
  } catch (error) {
    console.error('VOC 업데이트 실패:', error);
    res.status(500).json({ message: 'VOC 업데이트 중 오류가 발생했습니다.' });
  }
});

// VOC 삭제
router.delete('/:id', async (req, res) => {
  try {
    const deletedVoc = await Voc.findOneAndDelete({ no: req.params.id });
    
    if (!deletedVoc) {
      return res.status(404).json({ message: '해당 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    res.json({ message: 'VOC가 삭제되었습니다.', deletedVoc });
  } catch (error) {
    console.error('VOC 삭제 실패:', error);
    res.status(500).json({ message: 'VOC 삭제 중 오류가 발생했습니다.' });
  }
});

// 코드로 VOC 조회
router.get('/code/:code', async (req, res) => {
  try {
    const voc = await Voc.findOne({ code: req.params.code });
    
    if (!voc) {
      return res.status(404).json({ message: '해당 코드의 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    res.json(voc);
  } catch (error) {
    console.error('코드로 VOC 조회 실패:', error);
    res.status(500).json({ message: 'VOC 조회 중 오류가 발생했습니다.' });
  }
});

// 코드로 VOC 업데이트
router.put('/code/:code', async (req, res) => {
  try {
    const code = req.params.code;
    console.log(`코드 ${code}로 VOC 업데이트 요청:`, req.body);
    
    const updatedData = req.body;
    
    // 날짜 처리 (문자열로 오는 경우 Date 객체로 변환)
    if (updatedData.regDate && typeof updatedData.regDate === 'string') {
      try {
        updatedData.regDate = new Date(updatedData.regDate);
        if (isNaN(updatedData.regDate.getTime())) {
          console.log('유효하지 않은 등록일 형식:', updatedData.regDate);
          delete updatedData.regDate; // 유효하지 않은 날짜는 제외
        }
      } catch (err) {
        console.log('등록일 변환 오류:', err);
        delete updatedData.regDate;
      }
    }
    
    if (updatedData.dueDate && typeof updatedData.dueDate === 'string') {
      try {
        updatedData.dueDate = new Date(updatedData.dueDate);
        if (isNaN(updatedData.dueDate.getTime())) {
          console.log('유효하지 않은 마감일 형식:', updatedData.dueDate);
          delete updatedData.dueDate;
        }
      } catch (err) {
        console.log('마감일 변환 오류:', err);
        delete updatedData.dueDate;
      }
    }
    
    const updatedVoc = await Voc.findOneAndUpdate(
      { code },
      updatedData,
      { new: true, runValidators: true }
    );
    
    if (!updatedVoc) {
      console.log(`코드 ${code}에 해당하는 VOC를 찾을 수 없음`);
      return res.status(404).json({ message: '해당 코드의 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    console.log(`코드 ${code}의 VOC 업데이트 성공`);
    res.json(updatedVoc);
  } catch (error) {
    console.error('코드로 VOC 업데이트 실패:', error);
    res.status(500).json({ 
      message: 'VOC 업데이트 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 코드로 VOC 삭제
router.delete('/code/:code', async (req, res) => {
  try {
    const code = req.params.code;
    console.log(`코드 ${code}로 VOC 삭제 요청`);
    
    const deletedVoc = await Voc.findOneAndDelete({ code });
    
    if (!deletedVoc) {
      console.log(`코드 ${code}에 해당하는 VOC를 찾을 수 없음`);
      return res.status(404).json({ message: '해당 코드의 VOC 데이터를 찾을 수 없습니다.' });
    }
    
    console.log(`코드 ${code}의 VOC 삭제 성공`);
    res.json({ message: 'VOC가 삭제되었습니다.', deletedVoc });
  } catch (error) {
    console.error('코드로 VOC 삭제 실패:', error);
    res.status(500).json({ message: 'VOC 삭제 중 오류가 발생했습니다.' });
  }
});

module.exports = router; 