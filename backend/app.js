// 소프트웨어 라우터 가져오기
const softwareRoutes = require('./routes/softwareRoutes');

// API 라우터 등록
app.use('/api/software', softwareRoutes);
app.use('/api/solution-development/software', softwareRoutes); // 솔루션 개발과 동일한 패턴
app.use('/api/memory/software', softwareRoutes); // 대체 경로 