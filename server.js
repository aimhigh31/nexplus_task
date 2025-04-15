// MongoDB 직접 접근 API
app.post('/api/db/:collection', async (req, res) => {
  try {
    const collection = req.params.collection;
    const data = req.body;
    
    // MongoDB 연결 및 데이터 저장
    const result = await db.collection(collection).insertOne(data);
    
    console.log(`[DB API] 컬렉션 ${collection}에 데이터 저장 성공: ${result.insertedId}`);
    
    res.status(201).json({
      ...data,
      _id: result.insertedId
    });
  } catch (error) {
    console.error(`[DB API] 데이터베이스 저장 오류: ${error.message}`);
    res.status(500).json({ message: '데이터베이스 저장 오류', error: error.message });
  }
});

// MongoDB 직접 찾기 API
app.get('/api/db/:collection', async (req, res) => {
  try {
    const collection = req.params.collection;
    const query = req.query;
    
    // 쿼리 파라미터를 MongoDB 쿼리로 변환
    const filter = {};
    for (const key in query) {
      // 특수 쿼리 파라미터 처리
      if (key === 'limit' || key === 'skip') continue;
      filter[key] = query[key];
    }
    
    // MongoDB 연결 및 데이터 조회
    const limit = parseInt(query.limit) || 100;
    const skip = parseInt(query.skip) || 0;
    
    const result = await db.collection(collection).find(filter)
      .limit(limit).skip(skip).toArray();
    
    console.log(`[DB API] 컬렉션 ${collection}에서 ${result.length}개 데이터 조회 성공`);
    
    res.status(200).json(result);
  } catch (error) {
    console.error(`[DB API] 데이터베이스 조회 오류: ${error.message}`);
    res.status(500).json({ message: '데이터베이스 조회 오류', error: error.message });
  }
});

// 로그 API
app.post('/api/logs', async (req, res) => {
  try {
    const logData = req.body;
    logData.serverTimestamp = new Date();
    
    // 콘솔 및 로그 파일에 추가
    console.log(`[CLIENT LOG] [${logData.level}] ${logData.message}`);
    
    // MongoDB로 로그 저장 (선택 사항)
    await db.collection('logs').insertOne(logData);
    
    res.status(201).json({ success: true });
  } catch (error) {
    console.error(`로그 저장 오류: ${error.message}`);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 첨부파일 API
app.post('/api/db/attachments', upload.single('file'), async (req, res) => {
  try {
    const file = req.file;
    const { relatedEntityId, relatedEntityType } = req.body;
    
    // 파일 정보와 관계 정보를 DB에 저장
    const attachment = {
      fileName: file.filename,
      originalFilename: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      uploadDate: new Date(),
      path: file.path,
      relatedEntityId,
      relatedEntityType
    };
    
    const result = await db.collection('attachments').insertOne(attachment);
    
    console.log(`[첨부파일 API] 파일 업로드 성공: ${file.originalname}`);
    res.status(201).json({ ...attachment, _id: result.insertedId });
  } catch (error) {
    console.error(`첨부파일 업로드 오류: ${error.message}`);
    res.status(500).json({ message: '첨부파일 업로드 오류', error: error.message });
  }
}); 