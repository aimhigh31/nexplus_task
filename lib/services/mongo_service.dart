import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/voc_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  bool _isConnected = false;
  final String _collectionName = 'voc';
  
  // 싱글톤 패턴 구현
  factory MongoService() => _instance;
  
  MongoService._internal();
  
  // MongoDB 연결
  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      // nexplus_task 데이터베이스로 연결
      String mongoUri = 'mongodb://localhost:27017/nexplus_task';
      
      _db = await Db.create(mongoUri);
      await _db!.open();
      _isConnected = true;
      
      debugPrint('MongoDB 연결 성공: ${_db!.databaseName}');
      
      // 콜렉션이 없으면 생성 및 샘플 데이터 추가
      await _initializeCollection();
    } catch (e) {
      debugPrint('MongoDB 연결 실패: $e');
      _isConnected = false;
      // 연결 실패해도 앱 동작에 영향 없게 함
    }
  }
  
  // 콜렉션 초기화 및 샘플 데이터 추가
  Future<void> _initializeCollection() async {
    if (!_isConnected || _db == null) return;
    
    try {
      var collection = _db!.collection(_collectionName);
      var count = await collection.count();
      
      // 데이터가 없으면 샘플 데이터 추가
      if (count == 0) {
        await collection.insertMany(_getSampleVocData());
        debugPrint('샘플 VOC 데이터가 추가되었습니다.');
      }
    } catch (e) {
      debugPrint('콜렉션 초기화 실패: $e');
    }
  }
  
  // VOC 데이터 조회 (검색 및 필터링 지원)
  Future<List<VocModel>> getVocData({
    String? search,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    try {
      await _ensureConnected();
      
      // MongoDB 연결 실패한 경우 샘플 데이터 반환
      if (!_isConnected || _db == null) {
        debugPrint('MongoDB 연결 안됨: 샘플 데이터 사용');
        return _getSampleVocModels();
      }
      
      var collection = _db!.collection(_collectionName);
      final Map<String, dynamic> query = {};
      
      // 검색어 필터
      if (search != null && search.isNotEmpty) {
        query[r'$or'] = [
          {'requestDept': {r'$regex': search, r'$options': 'i'}},
          {'requester': {r'$regex': search, r'$options': 'i'}},
          {'systemPath': {r'$regex': search, r'$options': 'i'}},
          {'request': {r'$regex': search, r'$options': 'i'}},
          {'action': {r'$regex': search, r'$options': 'i'}},
          {'actionTeam': {r'$regex': search, r'$options': 'i'}},
          {'actionPerson': {r'$regex': search, r'$options': 'i'}},
        ];
      }
      
      // VOC 분류 필터
      if (vocCategory != null) {
        query['vocCategory'] = vocCategory;
      }
      
      // 요청분류 필터
      if (requestType != null) {
        query['requestType'] = requestType;
      }
      
      // 상태 필터
      if (status != null) {
        query['status'] = status;
      }
      
      // 등록일 범위 필터
      if (startDate != null || endDate != null) {
        query['regDate'] = {};
        if (startDate != null) {
          query['regDate'][r'$gte'] = startDate;
        }
        if (endDate != null) {
          final nextDay = endDate.add(const Duration(days: 1));
          query['regDate'][r'$lt'] = nextDay;
        }
      }
      
      // 마감일 범위 필터
      if (dueDateStart != null || dueDateEnd != null) {
        query['dueDate'] = {};
        if (dueDateStart != null) {
          query['dueDate'][r'$gte'] = dueDateStart;
        }
        if (dueDateEnd != null) {
          final nextDay = dueDateEnd.add(const Duration(days: 1));
          query['dueDate'][r'$lt'] = nextDay;
        }
      }
      
      // 데이터 조회
      final result = await collection.find(query).toList();
      
      // JSON에서 VocModel로 변환
      return result
          .map((json) => VocModel.fromJson(json))
          .toList()
          ..sort((a, b) => b.no.compareTo(a.no)); // 번호 기준 내림차순 정렬
    } catch (e) {
      debugPrint('VOC 데이터 조회 실패: $e');
      // 오류 발생 시 샘플 데이터 반환
      return _getSampleVocModels();
    }
  }
  
  // VOC 추가
  Future<bool> addVoc(VocModel voc) async {
    await _ensureConnected();
    
    try {
      var collection = _db!.collection(_collectionName);
      
      // ObjectId 생성 (MongoDB ID)
      final json = voc.toJson();
      
      // MongoDB에 저장
      await collection.insert(json);
      debugPrint('VOC 추가 성공: ${voc.no}');
      return true;
    } catch (e) {
      debugPrint('VOC 추가 실패: $e');
      return false;
    }
  }
  
  // VOC 업데이트
  Future<bool> updateVoc(VocModel voc) async {
    await _ensureConnected();
    
    try {
      var collection = _db!.collection(_collectionName);
      
      // ObjectId로 업데이트
      final json = voc.toJson();
      if (json.containsKey('_id')) {
        final id = json['_id'];
        json.remove('_id'); // _id는 업데이트에서 제외
        
        await collection.update(
          where.eq('_id', id),
          json,
        );
      } else {
        // _id가 없으면 번호로 업데이트
        await collection.update(
          where.eq('no', voc.no),
          json,
        );
      }
      
      debugPrint('VOC 업데이트 성공: ${voc.no}');
      return true;
    } catch (e) {
      debugPrint('VOC 업데이트 실패: $e');
      return false;
    }
  }
  
  // VOC 삭제
  Future<bool> deleteVoc(int vocNo) async {
    await _ensureConnected();
    
    try {
      var collection = _db!.collection(_collectionName);
      await collection.remove(where.eq('no', vocNo));
      debugPrint('VOC 삭제 성공: $vocNo');
      return true;
    } catch (e) {
      debugPrint('VOC 삭제 실패: $e');
      return false;
    }
  }
  
  // 연결 확인 및 재연결
  Future<void> _ensureConnected() async {
    if (!_isConnected || _db == null) {
      await connect();
    }
  }
  
  // 샘플 VOC 데이터 생성
  List<Map<String, dynamic>> _getSampleVocData() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final weekAgo = now.subtract(const Duration(days: 7));
    final nextWeek = now.add(const Duration(days: 7));
    
    return [
      {
        'no': 1,
        'regDate': weekAgo,
        'vocCategory': 'MES 아산',
        'requestDept': '생산팀',
        'requester': '홍길동',
        'systemPath': '생산관리 > 작업지시',
        'request': '작업지시 화면에서 공정별 작업자 현황 조회 기능이 필요합니다.',
        'requestType': '신규',
        'action': '기능 개발 완료 및 테스트 진행 중',
        'actionTeam': '개발1팀',
        'actionPerson': '김개발',
        'status': '진행중',
        'dueDate': nextWeek,
      },
      {
        'no': 2,
        'regDate': weekAgo.add(const Duration(days: 1)),
        'vocCategory': 'QMS 아산',
        'requestDept': '품질관리팀',
        'requester': '김품질',
        'systemPath': '품질관리 > 검사결과',
        'request': '검사결과 입력 시 오류가 발생합니다.',
        'requestType': '오류',
        'action': '데이터 유효성 검사 로직 수정',
        'actionTeam': '개발2팀',
        'actionPerson': '이개발',
        'status': '완료',
        'dueDate': yesterday,
      },
      {
        'no': 3,
        'regDate': yesterday,
        'vocCategory': '그룹웨어',
        'requestDept': '인사팀',
        'requester': '박인사',
        'systemPath': '전자결재 > 휴가신청',
        'request': '휴가신청 화면에 연차 잔여일수 표시 기능을 추가해주세요.',
        'requestType': '수정',
        'action': '화면 설계 검토 중',
        'actionTeam': '개발3팀',
        'actionPerson': '최개발',
        'status': '접수',
        'dueDate': nextWeek.add(const Duration(days: 3)),
      },
      {
        'no': 4,
        'regDate': now,
        'vocCategory': 'MES 비나',
        'requestDept': '해외생산팀',
        'requester': '정해외',
        'systemPath': '재고관리 > 재고현황',
        'request': '베트남 공장 재고현황 데이터가 정확하지 않습니다.',
        'requestType': '오류',
        'action': '데이터 동기화 프로세스 검토 중',
        'actionTeam': '인프라팀',
        'actionPerson': '강개발',
        'status': '접수',
        'dueDate': nextWeek.add(const Duration(days: 5)),
      },
      {
        'no': 5,
        'regDate': weekAgo.add(const Duration(days: 3)),
        'vocCategory': '하드웨어',
        'requestDept': 'IT지원팀',
        'requester': '오지원',
        'systemPath': '네트워크 장비',
        'request': '공장동 무선네트워크 접속 불안정 문제가 있습니다.',
        'requestType': '문의',
        'action': '현장 점검 완료, AP 교체 작업 진행 예정',
        'actionTeam': '인프라팀',
        'actionPerson': '우개발',
        'status': '진행중',
        'dueDate': now.add(const Duration(days: 2)),
      },
      {
        'no': 6,
        'regDate': now.subtract(const Duration(days: 4)),
        'vocCategory': 'QMS 비나',
        'requestDept': '해외품질팀',
        'requester': '한품질',
        'systemPath': '품질관리 > 불량현황',
        'request': '비나 공장 불량유형 코드를 추가해주세요.',
        'requestType': '신규',
        'action': '코드 추가 완료',
        'actionTeam': '개발2팀',
        'actionPerson': '양개발',
        'status': '완료',
        'dueDate': yesterday.subtract(const Duration(days: 1)),
      },
      {
        'no': 7,
        'regDate': now.subtract(const Duration(days: 3)),
        'vocCategory': '소프트웨어',
        'requestDept': '경영지원팀',
        'requester': '조경영',
        'systemPath': 'Office > Excel',
        'request': 'Excel 매크로 작동 오류가 있습니다.',
        'requestType': '오류',
        'action': '보안 정책으로 인한 문제, 보안 설정 변경 필요함을 안내',
        'actionTeam': 'IT지원팀',
        'actionPerson': '배개발',
        'status': '완료',
        'dueDate': now.subtract(const Duration(days: 1)),
      },
      {
        'no': 8,
        'regDate': now.subtract(const Duration(days: 5)),
        'vocCategory': '통신',
        'requestDept': '영업팀',
        'requester': '권영업',
        'systemPath': 'VPN',
        'request': '외부에서 VPN 접속이 안됩니다.',
        'requestType': '오류',
        'action': '고객사 방화벽 이슈 확인, 협의 필요',
        'actionTeam': '인프라팀',
        'actionPerson': '방개발',
        'status': '보류',
        'dueDate': nextWeek,
      },
      {
        'no': 9,
        'regDate': weekAgo,
        'vocCategory': 'MES 아산',
        'requestDept': '자재팀',
        'requester': '임자재',
        'systemPath': '자재관리 > 입고현황',
        'request': '특정 자재코드 입고 내역이 조회되지 않습니다.',
        'requestType': '오류',
        'action': '데이터 쿼리 오류 수정',
        'actionTeam': '개발1팀',
        'actionPerson': '태개발',
        'status': '완료',
        'dueDate': yesterday.subtract(const Duration(days: 2)),
      },
      {
        'no': 10,
        'regDate': now.subtract(const Duration(days: 2)),
        'vocCategory': '기타',
        'requestDept': '총무팀',
        'requester': '신총무',
        'systemPath': '사내포털 > 공지사항',
        'request': '공지사항에 첨부파일 다운로드가 안됩니다.',
        'requestType': '오류',
        'action': '파일 서버 연결 오류 확인 중',
        'actionTeam': '개발3팀',
        'actionPerson': '손개발',
        'status': '진행중',
        'dueDate': nextWeek.subtract(const Duration(days: 1)),
      },
    ];
  }
  
  // MongoDB 연결 실패 시 사용할 샘플 VOC 모델 목록
  List<VocModel> _getSampleVocModels() {
    final sampleData = _getSampleVocData();
    return sampleData.map((json) => VocModel(
      no: json['no'] as int,
      regDate: json['regDate'] as DateTime,
      vocCategory: json['vocCategory'] as String,
      requestDept: json['requestDept'] as String,
      requester: json['requester'] as String,
      systemPath: json['systemPath'] as String,
      request: json['request'] as String,
      requestType: json['requestType'] as String,
      action: json['action'] as String,
      actionTeam: json['actionTeam'] as String,
      actionPerson: json['actionPerson'] as String,
      status: json['status'] as String,
      dueDate: json['dueDate'] as DateTime,
    )).toList();
  }
  
  // 연결 종료
  Future<void> close() async {
    if (_isConnected && _db != null) {
      await _db!.close();
      _isConnected = false;
    }
  }
} 