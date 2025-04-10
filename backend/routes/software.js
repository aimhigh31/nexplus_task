const express = require('express');
const router = express.Router();
const Software = require('../models/Software');

/**
 * @desc    모든 소프트웨어 자산 가져오기
 * @route   GET /api/software
 * @access  Public
 */
router.get('/', async (req, res) => {
  try {
    // 쿼리 파라미터
    const search = req.query.search;
    const assetType = req.query.assetType;
    const costType = req.query.costType;
    const startDate = req.query.startDate;
    const endDate = req.query.endDate;

    // 검색 쿼리 구성
    const query = {};

    // 통합 검색 (여러 필드에서 검색)
    if (search) {
      query.$or = [
        { code: { $regex: search, $options: 'i' } },
        { assetType: { $regex: search, $options: 'i' } },
        { assetCode: { $regex: search, $options: 'i' } },
        { assetName: { $regex: search, $options: 'i' } },
        { vendor: { $regex: search, $options: 'i' } },
        { user: { $regex: search, $options: 'i' } },
        { remarks: { $regex: search, $options: 'i' } },
      ];
    }

    // 자산분류 필터
    if (assetType) {
      query.assetType = assetType;
    }

    // 비용형태 필터
    if (costType) {
      query.costType = costType;
    }

    // 날짜 범위 필터
    if (startDate && endDate) {
      query.regDate = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    } else if (startDate) {
      query.regDate = { $gte: new Date(startDate) };
    } else if (endDate) {
      query.regDate = { $lte: new Date(endDate) };
    }

    // 소프트웨어 검색 및 정렬
    const softwares = await Software.find(query).sort({ no: -1 });

    res.json(softwares);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('서버 오류');
  }
});

/**
 * @desc    코드로 소프트웨어 자산 찾기
 * @route   GET /api/software/code/:code
 * @access  Public
 */
router.get('/code/:code', async (req, res) => {
  try {
    const software = await Software.findOne({ code: req.params.code });

    if (!software) {
      return res.status(404).json({ message: '소프트웨어를 찾을 수 없습니다' });
    }

    res.json(software);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('서버 오류');
  }
});

/**
 * @desc    새 소프트웨어 자산 추가
 * @route   POST /api/software
 * @access  Public
 */
router.post('/', async (req, res) => {
  try {
    // 필수 필드 검증
    const { assetCode, assetType, assetName } = req.body;
    if (!assetCode || !assetType || !assetName) {
      return res.status(400).json({ message: '필수 필드를 입력해주세요' });
    }

    // 코드 중복 검사
    if (req.body.code) {
      const existingSoftware = await Software.findOne({ code: req.body.code });
      if (existingSoftware) {
        return res.status(400).json({ message: '이미 존재하는 코드입니다' });
      }
    }

    // 신규 소프트웨어 생성
    const software = new Software(req.body);
    await software.save();

    res.status(201).json(software);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('서버 오류');
  }
});

/**
 * @desc    소프트웨어 자산 업데이트
 * @route   PUT /api/software/code/:code
 * @access  Public
 */
router.put('/code/:code', async (req, res) => {
  try {
    // 소프트웨어 존재 확인
    let software = await Software.findOne({ code: req.params.code });
    if (!software) {
      return res.status(404).json({ message: '소프트웨어를 찾을 수 없습니다' });
    }

    // 필수 필드 검증
    const { assetCode, assetType, assetName } = req.body;
    if (!assetCode || !assetType || !assetName) {
      return res.status(400).json({ message: '필수 필드를 입력해주세요' });
    }

    // 업데이트 (ID는 변경하지 않음)
    const updateData = { ...req.body };
    delete updateData._id;

    // 업데이트 수행
    software = await Software.findOneAndUpdate(
      { code: req.params.code },
      { $set: updateData },
      { new: true }
    );

    res.json(software);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('서버 오류');
  }
});

/**
 * @desc    소프트웨어 자산 삭제
 * @route   DELETE /api/software/code/:code
 * @access  Public
 */
router.delete('/code/:code', async (req, res) => {
  try {
    // 소프트웨어 존재 확인
    const software = await Software.findOne({ code: req.params.code });
    if (!software) {
      return res.status(404).json({ message: '소프트웨어를 찾을 수 없습니다' });
    }

    // 소프트웨어 삭제
    await Software.findOneAndDelete({ code: req.params.code });

    res.json({ message: '소프트웨어가 삭제되었습니다' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('서버 오류');
  }
});

module.exports = router; 