const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 업로드 디렉토리 확인 및 생성
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer 저장 설정
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir); // 파일을 'uploads/' 폴더에 저장
  },
  filename: function (req, file, cb) {
    // 파일 이름 중복 방지: 원래이름 + 타임스탬프 + 확장자
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + extension);
  }
});

// 파일 필터 (예: 특정 파일 형식만 허용)
const fileFilter = (req, file, cb) => {
  // 모든 파일 형식 허용 (필요 시 주석 해제하여 특정 형식만 허용)
  // if (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf') {
  //   cb(null, true);
  // } else {
  //   cb(new Error('지원하지 않는 파일 형식입니다.'), false);
  // }
  cb(null, true); // 모든 파일 허용
};

// Multer 인스턴스 생성
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 10 // 10MB 파일 크기 제한
  },
  fileFilter: fileFilter
});

module.exports = upload; 