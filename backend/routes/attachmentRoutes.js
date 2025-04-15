const express = require('express');
const router = express.Router();
const Attachment = require('../models/attachmentModel');
const upload = require('../config/multer'); // Multer 설정 가져오기
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

// POST /api/attachments - 파일 업로드 및 메타데이터 저장
router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: '파일이 업로드되지 않았습니다.' });
    }
    if (!req.body.relatedEntityId || !req.body.relatedEntityType) {
      // 임시 파일 삭제
      fs.unlinkSync(req.file.path);
      return res.status(400).json({ message: '관련 엔티티 ID와 타입은 필수입니다.' });
    }

    const { relatedEntityId, relatedEntityType } = req.body;

    const newAttachment = new Attachment({
      fileName: req.file.filename,
      originalFilename: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path, // 서버 내 저장 경로
      relatedEntityId: relatedEntityId, // ObjectId 또는 String 그대로 저장
      relatedEntityType: relatedEntityType
    });

    await newAttachment.save();
    console.log(`[Attachments API] 파일 업로드 성공: ${newAttachment.originalFilename}, ID: ${newAttachment._id}`);
    res.status(201).json(newAttachment);

  } catch (error) {
    console.error('[Attachments API] 파일 업로드 오류:', error.message);
    // 오류 발생 시 업로드된 파일 삭제 (롤백)
    if (req.file && req.file.path) {
      fs.unlink(req.file.path, (err) => {
        if (err) console.error('임시 업로드 파일 삭제 실패:', err);
      });
    }
    res.status(500).json({ message: '파일 업로드 중 서버 오류 발생', error: error.message });
  }
});

// GET /api/attachments - 관련 엔티티의 첨부파일 목록 조회
router.get('/', async (req, res) => {
  try {
    const { relatedEntityId, relatedEntityType } = req.query;
    if (!relatedEntityId || !relatedEntityType) {
      return res.status(400).json({ message: 'relatedEntityId와 relatedEntityType 쿼리 파라미터는 필수입니다.' });
    }

    const query = {
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType
    };

    console.log(`[Attachments API] 첨부파일 목록 조회 요청:`, query);
    const attachments = await Attachment.find(query).sort({ uploadDate: -1 }); // 최신순 정렬

    console.log(`[Attachments API] 조회된 첨부파일 ${attachments.length}개`);
    res.json(attachments);

  } catch (error) {
    console.error('[Attachments API] 첨부파일 목록 조회 오류:', error.message);
    res.status(500).json({ message: '첨부파일 목록 조회 중 서버 오류 발생', error: error.message });
  }
});

// GET /api/attachments/:id/download - 파일 다운로드
router.get('/:id/download', async (req, res) => {
  try {
    const attachmentId = req.params.id;
    if (!mongoose.Types.ObjectId.isValid(attachmentId)) {
      return res.status(400).json({ message: '유효하지 않은 첨부파일 ID입니다.' });
    }

    const attachment = await Attachment.findById(attachmentId);
    if (!attachment) {
      return res.status(404).json({ message: '첨부파일을 찾을 수 없습니다.' });
    }

    const filePath = path.resolve(attachment.path);
    console.log(`[Attachments API] 파일 다운로드 요청: ${attachment.originalFilename}, 경로: ${filePath}`);

    // 파일 존재 여부 확인
    if (!fs.existsSync(filePath)) {
      console.error(`[Attachments API] 파일 없음: ${filePath}`);
      return res.status(404).json({ message: '서버에서 파일을 찾을 수 없습니다. 경로: ' + attachment.path });
    }

    // Content-Disposition 헤더 설정 (파일명 인코딩)
    const encodedFilename = encodeURIComponent(attachment.originalFilename);
    res.setHeader('Content-Disposition', `attachment; filename*=UTF-8''${encodedFilename}`);
    res.setHeader('Content-Type', attachment.mimeType);

    res.download(filePath, attachment.originalFilename, (err) => {
      if (err) {
        console.error('[Attachments API] 파일 다운로드 중 오류:', err);
        // 헤더가 이미 전송된 경우 오류 처리가 어려울 수 있음
        if (!res.headersSent) {
          res.status(500).send({ message: '파일 다운로드 중 오류 발생', error: err.message });
        }
      } else {
        console.log(`[Attachments API] 파일 다운로드 성공: ${attachment.originalFilename}`);
      }
    });

  } catch (error) {
    console.error('[Attachments API] 파일 다운로드 오류:', error.message);
    if (!res.headersSent) {
      res.status(500).json({ message: '파일 다운로드 중 서버 오류 발생', error: error.message });
    }
  }
});

// DELETE /api/attachments/:id - 첨부파일 삭제 (메타데이터 및 실제 파일)
router.delete('/:id', async (req, res) => {
  try {
    const attachmentId = req.params.id;
    if (!mongoose.Types.ObjectId.isValid(attachmentId)) {
      return res.status(400).json({ message: '유효하지 않은 첨부파일 ID입니다.' });
    }

    console.log(`[Attachments API] 첨부파일 삭제 요청: ID ${attachmentId}`);
    const attachment = await Attachment.findById(attachmentId);
    if (!attachment) {
      return res.status(404).json({ message: '삭제할 첨부파일을 찾을 수 없습니다.' });
    }

    // 1. 실제 파일 삭제
    const filePath = path.resolve(attachment.path);
    if (fs.existsSync(filePath)) {
      fs.unlink(filePath, async (err) => {
        if (err) {
          console.error(`[Attachments API] 실제 파일 삭제 실패 (${filePath}):`, err.message);
          // 파일 삭제 실패해도 DB 삭제는 시도하거나, 오류 반환 결정 필요
          // return res.status(500).json({ message: '파일 시스템에서 파일 삭제 중 오류 발생', error: err.message });
        } else {
          console.log(`[Attachments API] 실제 파일 삭제 성공: ${filePath}`);
        }

        // 2. DB에서 메타데이터 삭제 (파일 삭제 성공 여부와 관계없이 시도할 수도 있음)
        try {
          const deletedAttachment = await Attachment.findByIdAndDelete(attachmentId);
          if (deletedAttachment) {
            console.log(`[Attachments API] DB 메타데이터 삭제 성공: ID ${attachmentId}`);
            res.status(200).json({ message: '첨부파일이 성공적으로 삭제되었습니다.', deletedAttachment });
          } else {
            // 이미 삭제되었거나 ID가 잘못된 경우일 수 있음
            console.warn(`[Attachments API] DB 메타데이터 삭제 시도했으나 찾지 못함: ID ${attachmentId}`);
            res.status(404).json({ message: 'DB에서 해당 첨부파일 메타데이터를 찾을 수 없습니다.' });
          }
        } catch (dbError) {
          console.error(`[Attachments API] DB 메타데이터 삭제 오류 (ID: ${attachmentId}):`, dbError.message);
          // DB 삭제 실패 시 클라이언트에게 오류 알림
          res.status(500).json({ message: '데이터베이스에서 첨부파일 정보 삭제 중 오류 발생', error: dbError.message });
        }
      });
    } else {
      console.warn(`[Attachments API] 삭제할 파일이 이미 없음: ${filePath}. DB 메타데이터만 삭제 시도.`);
      // 파일이 없어도 DB 메타데이터는 삭제 시도
      try {
        const deletedAttachment = await Attachment.findByIdAndDelete(attachmentId);
        if (deletedAttachment) {
          console.log(`[Attachments API] DB 메타데이터 삭제 성공 (파일은 이미 없음): ID ${attachmentId}`);
          res.status(200).json({ message: '첨부파일 메타데이터가 삭제되었습니다 (파일은 이미 존재하지 않음).', deletedAttachment });
        } else {
          console.warn(`[Attachments API] DB 메타데이터 삭제 시도했으나 찾지 못함 (파일 없음): ID ${attachmentId}`);
          res.status(404).json({ message: 'DB에서 해당 첨부파일 메타데이터를 찾을 수 없습니다 (파일도 없음).' });
        }
      } catch (dbError) {
        console.error(`[Attachments API] DB 메타데이터 삭제 오류 (파일 없음, ID: ${attachmentId}):`, dbError.message);
        res.status(500).json({ message: '데이터베이스에서 첨부파일 정보 삭제 중 오류 발생 (파일 없음)', error: dbError.message });
      }
    }

  } catch (error) {
    console.error('[Attachments API] 첨부파일 삭제 처리 오류:', error.message);
    res.status(500).json({ message: '첨부파일 삭제 중 서버 오류 발생', error: error.message });
  }
});

module.exports = router; 