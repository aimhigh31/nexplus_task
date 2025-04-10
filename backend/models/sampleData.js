const getSampleVocData = () => {
  const now = new Date();
  const yesterday = new Date(now);
  yesterday.setDate(now.getDate() - 1);
  
  const weekAgo = new Date(now);
  weekAgo.setDate(now.getDate() - 7);
  
  const nextWeek = new Date(now);
  nextWeek.setDate(now.getDate() + 7);
  
  return [
    {
      no: 1,
      regDate: weekAgo,
      vocCategory: 'MES 아산',
      requestDept: '생산팀',
      requester: '홍길동',
      systemPath: '생산관리 > 작업지시',
      request: '작업지시 화면에서 공정별 작업자 현황 조회 기능이 필요합니다.',
      requestType: '신규',
      action: '기능 개발 완료 및 테스트 진행 중',
      actionTeam: '개발1팀',
      actionPerson: '김개발',
      status: '진행중',
      dueDate: nextWeek,
    },
    {
      no: 2,
      regDate: new Date(weekAgo.getTime() + 86400000),
      vocCategory: 'QMS 아산',
      requestDept: '품질관리팀',
      requester: '김품질',
      systemPath: '품질관리 > 검사결과',
      request: '검사결과 입력 시 오류가 발생합니다.',
      requestType: '오류',
      action: '데이터 유효성 검사 로직 수정',
      actionTeam: '개발2팀',
      actionPerson: '이개발',
      status: '완료',
      dueDate: yesterday,
    },
    {
      no: 3,
      regDate: yesterday,
      vocCategory: '그룹웨어',
      requestDept: '인사팀',
      requester: '박인사',
      systemPath: '전자결재 > 휴가신청',
      request: '휴가신청 화면에 연차 잔여일수 표시 기능을 추가해주세요.',
      requestType: '수정',
      action: '화면 설계 검토 중',
      actionTeam: '개발3팀',
      actionPerson: '최개발',
      status: '접수',
      dueDate: new Date(nextWeek.getTime() + 86400000 * 3),
    },
    {
      no: 4,
      regDate: now,
      vocCategory: 'MES 비나',
      requestDept: '해외생산팀',
      requester: '정해외',
      systemPath: '재고관리 > 재고현황',
      request: '베트남 공장 재고현황 데이터가 정확하지 않습니다.',
      requestType: '오류',
      action: '데이터 동기화 프로세스 검토 중',
      actionTeam: '인프라팀',
      actionPerson: '강개발',
      status: '접수',
      dueDate: new Date(nextWeek.getTime() + 86400000 * 5),
    },
    {
      no: 5,
      regDate: new Date(weekAgo.getTime() + 86400000 * 3),
      vocCategory: '하드웨어',
      requestDept: 'IT지원팀',
      requester: '오지원',
      systemPath: '네트워크 장비',
      request: '공장동 무선네트워크 접속 불안정 문제가 있습니다.',
      requestType: '문의',
      action: '현장 점검 완료, AP 교체 작업 진행 예정',
      actionTeam: '인프라팀',
      actionPerson: '우개발',
      status: '진행중',
      dueDate: new Date(now.getTime() + 86400000 * 2),
    },
    {
      no: 6,
      regDate: new Date(now.getTime() - 86400000 * 4),
      vocCategory: 'QMS 비나',
      requestDept: '해외품질팀',
      requester: '한품질',
      systemPath: '품질관리 > 불량현황',
      request: '비나 공장 불량유형 코드를 추가해주세요.',
      requestType: '신규',
      action: '코드 추가 완료',
      actionTeam: '개발2팀',
      actionPerson: '양개발',
      status: '완료',
      dueDate: new Date(yesterday.getTime() - 86400000),
    },
    {
      no: 7,
      regDate: new Date(now.getTime() - 86400000 * 3),
      vocCategory: '소프트웨어',
      requestDept: '경영지원팀',
      requester: '조경영',
      systemPath: 'Office > Excel',
      request: 'Excel 매크로 작동 오류가 있습니다.',
      requestType: '오류',
      action: '보안 정책으로 인한 문제, 보안 설정 변경 필요함을 안내',
      actionTeam: 'IT지원팀',
      actionPerson: '배개발',
      status: '완료',
      dueDate: new Date(now.getTime() - 86400000),
    },
    {
      no: 8,
      regDate: new Date(now.getTime() - 86400000 * 5),
      vocCategory: '통신',
      requestDept: '영업팀',
      requester: '권영업',
      systemPath: 'VPN',
      request: '외부에서 VPN 접속이 안됩니다.',
      requestType: '오류',
      action: '고객사 방화벽 이슈 확인, 협의 필요',
      actionTeam: '인프라팀',
      actionPerson: '방개발',
      status: '보류',
      dueDate: nextWeek,
    },
    {
      no: 9,
      regDate: weekAgo,
      vocCategory: 'MES 아산',
      requestDept: '자재팀',
      requester: '임자재',
      systemPath: '자재관리 > 입고현황',
      request: '특정 자재코드 입고 내역이 조회되지 않습니다.',
      requestType: '오류',
      action: '데이터 쿼리 오류 수정',
      actionTeam: '개발1팀',
      actionPerson: '태개발',
      status: '완료',
      dueDate: new Date(yesterday.getTime() - 86400000 * 2),
    },
    {
      no: 10,
      regDate: new Date(now.getTime() - 86400000 * 2),
      vocCategory: '기타',
      requestDept: '총무팀',
      requester: '신총무',
      systemPath: '사내포털 > 공지사항',
      request: '공지사항에 첨부파일 다운로드가 안됩니다.',
      requestType: '오류',
      action: '파일 서버 연결 오류 확인 중',
      actionTeam: '개발3팀',
      actionPerson: '손개발',
      status: '진행중',
      dueDate: new Date(nextWeek.getTime() - 86400000),
    },
  ];
};

// 샘플 시스템 업데이트 데이터 (솔루션 개발)
function getSampleSystemUpdateData() {
  const targetSystems = ['MES', 'QMS', 'PLM', 'SPC', 'MMS', 'KPI', '그룹웨어', '백업솔루션', '기타'];
  const updateTypes = ['기능개선', '버그수정', '보안패치', 'UI변경', '데이터보정', '기타'];
  const statusList = ['계획', '진행중', '테스트', '완료', '보류'];
  
  // 25개의 샘플 데이터 생성
  return Array.from({ length: 25 }).map((_, index) => {
    const now = new Date();
    const regDate = new Date(now);
    regDate.setDate(now.getDate() - index * 3);
    
    const status = statusList[index % statusList.length];
    
    // 업데이트 코드 생성 함수
    const generateUpdateCode = (date, no) => {
      const year = date.getFullYear().toString().substring(2);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const yearMonth = `${year}${month}`;
      const seq = no.toString().padStart(3, '0');
      return `UPD${yearMonth}${seq}`;
    };
    
    // 완료일 생성 (완료 상태인 경우에만)
    let completionDate = null;
    if (status === '완료') {
      completionDate = new Date(regDate);
      completionDate.setDate(regDate.getDate() + (index % 7) + 1);
    }
    
    return {
      no: 25 - index,
      regDate: regDate,
      updateCode: generateUpdateCode(regDate, 25 - index),
      targetSystem: targetSystems[index % targetSystems.length],
      description: `시스템 기능 개선 및 버그 수정 #${25 - index}. 사용성 향상을 위한 UI 변경 포함.`,
      updateType: updateTypes[index % updateTypes.length],
      assignee: `담당자${(index % 5) + 1}`,
      status: status,
      completionDate: completionDate,
      remarks: (index % 4 === 0) ? '긴급 패치 필요' : '',
    };
  });
}

// 하드웨어 샘플 데이터 생성 함수
function getSampleHardwareData() {
  const assetNames = ['서버', '데스크탑 PC', '노트북', '모니터', '네트워크 스위치', '프린터', '기타'];
  const executionTypes = ['신규구매', '사용불출', '수리중', '홀딩', '폐기'];
  const specifications = [
    '인텔 Xeon E5-2680 v4, 64GB RAM, 2TB SSD',
    'AMD Ryzen 9 5900X, 32GB RAM, 1TB NVMe',
    'Intel Core i7-12700H, 16GB RAM, 512GB SSD',
    '32인치 4K UHD 모니터, 60Hz',
    '24포트 기가비트 관리형 스위치',
    'HP 컬러 레이젯 Pro MFP',
    'Dell XPS 13, 16GB RAM, 1TB SSD'
  ];

  const sampleData = [];
  const now = new Date();
  
  // 샘플 데이터 25개 생성
  for (let i = 0; i < 25; i++) {
    const regDate = new Date(now);
    regDate.setDate(regDate.getDate() - (i * 5)); // 5일 간격으로
    
    const no = 25 - i;
    const year = regDate.getFullYear().toString().slice(-2);
    const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
    const day = regDate.getDate().toString().padStart(2, '0');
    
    const code = `HW${year}${month}${day}-${no.toString().padStart(4, '0')}`;
    const assetName = assetNames[i % assetNames.length];
    const specification = specifications[i % specifications.length];
    const executionType = executionTypes[i % executionTypes.length];
    const quantity = (i % 3) + 1;
    
    sampleData.push({
      no: no,
      regDate: regDate,
      code: code,
      assetCode: `A${year}${month}-${no.toString().padStart(3, '0')}`,
      assetName: assetName,
      specification: specification,
      executionType: executionType,
      quantity: quantity,
      lotCode: `L${year}${month}-${(i + 100).toString()}`,
      detail: `${assetName} ${specification} (${executionType})`,
      remarks: i % 4 === 0 ? '중요 자산' : '',
      saveStatus: true,
      modifiedStatus: false,
      createdAt: regDate,
      updatedAt: regDate
    });
  }
  
  return sampleData;
}

// 소프트웨어 샘플 데이터 생성 함수
function getSampleSoftwareData() {
  const assetTypes = [
    'AutoCAD', 'ZWCAD', 'NX-UZ', 'CATIA', '금형박사', '망고보드', 
    '캡컷', 'NX', '팀뷰어', 'HADA', 'MS-OFFICE', 'WINDOWS', 
    '아래아한글', 'VMware'
  ];
  
  const assetNames = [
    'Standard', 'Professional', 'Enterprise', 'Ultimate', 
    'Developer', 'Basic', 'Premium'
  ];
  
  const costTypes = ['연구독', '월구독', '영구'];
  
  const vendors = [
    '오토데스크', '한컴', '마이크로소프트', '어도비', '지멘스', 
    'PTC', '대성소프트웨어', 'ANSYS', 'DASSAULT', 'IBM', '한국NX'
  ];
  
  const users = [
    '홍길동', '김철수', '이영희', '박지성', '최민수', 
    '정민준', '강지원', '조현우', '윤성민', '장민호'
  ];

  const sampleData = [];
  const now = new Date();
  
  // 소프트웨어 샘플 데이터 25개 생성
  for (let i = 0; i < 25; i++) {
    const regDate = new Date(now);
    regDate.setDate(regDate.getDate() - (i * 4)); // 4일 간격으로
    
    const no = 25 - i;
    const year = regDate.getFullYear().toString().slice(-2);
    const month = (regDate.getMonth() + 1).toString().padStart(2, '0');
    
    const code = `SWM-${year}${month}-${no.toString().padStart(3, '0')}`;
    const assetType = assetTypes[i % assetTypes.length];
    const assetName = assetNames[i % assetNames.length];
    const costType = costTypes[i % costTypes.length];
    const vendor = vendors[i % vendors.length];
    const user = users[i % users.length];
    
    // 라이센스 시작일/종료일 설정 (구독형인 경우)
    let startDate = null;
    let endDate = null;
    
    if (costType !== '영구') {
      startDate = new Date(regDate);
      endDate = new Date(startDate);
      
      if (costType === '연구독') {
        endDate.setFullYear(endDate.getFullYear() + 1);
      } else { // 월구독
        endDate.setMonth(endDate.getMonth() + (i % 6) + 1); // 1~6개월
      }
    }
    
    // 가격 데이터 설정
    const setupPrice = Math.round((i + 1) * 150000 / 10000) * 10000; // 15만원 단위로 증가, 만원 단위로 반올림
    const annualMaintenancePrice = costType === '영구' ? Math.round(setupPrice * 0.2 / 10000) * 10000 : 0; // 영구 라이센스의 경우 유지비는 구매가의 20%
    
    sampleData.push({
      no: no,
      regDate: regDate,
      code: code,
      assetType: assetType,
      assetName: `${assetType} ${assetName}`,
      specification: `버전 ${new Date().getFullYear() - (i % 3)}`,
      setupPrice: setupPrice,
      annualMaintenancePrice: annualMaintenancePrice,
      costType: costType,
      vendor: vendor,
      licenseKey: `SW-${year}${month}-${(Math.random().toString(36).substring(2, 8)).toUpperCase()}`,
      user: user,
      startDate: startDate,
      endDate: endDate,
      remarks: i % 5 === 0 ? '중요 라이센스' : '',
      saveStatus: true,
      modifiedStatus: false,
      isSaved: true,
      isModified: false,
      createdAt: regDate,
      updatedAt: regDate
    });
  }
  
  return sampleData;
}

// 설비 연동관리 샘플 데이터 생성 함수
function getSampleEquipmentConnectionData() {
  const lines = ['SMT 라인', '조립 라인', '포장 라인', '검사 라인', '테스트 라인'];
  const equipments = ['설비 A', '설비 B', '설비 C', '검사기 1', '검사기 2', '컨베이어'];
  const workTypes = ['MES 자동투입', 'SPC', '설비조건데이터', '기타'];
  const dataTypes = ['PLC', 'CSV', '기타'];
  const connectionTypes = ['DataAgent', 'X-DAS', 'X-SCADA', '기타'];
  const statusList = ['대기', '진행중', '완료', '보류'];
  
  // 20개의 샘플 데이터 생성
  return Array.from({ length: 20 }).map((_, index) => {
    const now = new Date();
    const regDate = new Date(now);
    regDate.setDate(now.getDate() - index * 5);
    
    const status = statusList[index % statusList.length];
    
    // 코드 생성 함수
    const generateCode = (date, no) => {
      const year = date.getFullYear().toString().substring(2);
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const seq = no.toString().padStart(3, '0');
      return `EQC-${year}${month}-${seq}`;
    };
    
    // 완료일 생성 (완료 상태인 경우에만)
    let completionDate = null;
    let startDate = new Date(regDate);
    
    if (status === '완료') {
      completionDate = new Date(startDate);
      completionDate.setDate(startDate.getDate() + (index % 10) + 5);
    }
    
    const no = 20 - index;
    
    return {
      no,
      regDate,
      code: generateCode(regDate, no),
      line: lines[index % lines.length],
      equipment: equipments[index % equipments.length],
      workType: workTypes[index % workTypes.length],
      dataType: dataTypes[index % dataTypes.length],
      connectionType: connectionTypes[index % connectionTypes.length],
      status,
      detail: `${lines[index % lines.length]} - ${equipments[index % equipments.length]} 연동 작업 진행 중`,
      startDate,
      completionDate,
      remarks: index % 3 === 0 ? '우선순위 높음' : '',
    };
  });
}

module.exports = {
  getSampleVocData,
  getSampleSystemUpdateData,
  getSampleHardwareData,
  getSampleSoftwareData,
  getSampleEquipmentConnectionData
}; 