# flutter_actual_refactoring

Refactored code from Codefactory's Flutter course

----------
## 개요
인프런 플러터 강의 - [코드팩토리] [중급] Flutter 수강 완료 후 코드 리팩토링

참조 링크
1. 강의 주소 - https://www.inflearn.com/course/플러터-실전
2. 강의 코드 - https://github.com/codefactory-co/flutter-lv2-rest-api
----------
## 강의 주요 내용
+ Riverpod 상태 관리
+ Pagination 
+ JWT 토큰관리 및 인증
+ JsonSerializable
+ GoRouter
+ Retrofit
+ Dio 토큰관리 자동화
+ OOP
+ Debounce and Throttle
----------
## 리팩토링 내역
+ 라이브러리 최신 버전으로 상향 및 코드 개선
+ 패키지 구성 변경
  + 서비스 화면 별 디렉토리 분류 -> 기능 디렉토리로 분류 변경
  + as is
    > 서비스 화면
      > 기능
  + to be
    > 기능
      > 서비스 화면
+ 이미지 변경
  + 강의 과정에서 사용한 임시 이미지 삭제
  +로고 이미지를 Flutter 로고 대체
  +svg 이미지 연동
+ Pagination Error 개선
  + Throttling 적용 후, 새로 고침 불가능하고 Throttling 적용 전은 새로 고침 가능한 오류
    + 리스트가 짧은 경우, pagination 조건이 계속 충족되면서 페이징이 계속되는 오류
    + 서버 응답 기준으로 데이터가 더 있는 경우만 조건 실행으로 개선
+ JsonSerializable & Dio 5.x 에서 toJson 오류 개선
  + 인스턴스까지 toJson 명시적으로 선언
  + Example of explicitToJson: false (default)
  '''
  Map<String, dynamic> toJson() => {'child': child};    
  '''
  + Example of explicitToJson: true
  '''
  Map<String, dynamic> toJson() => {'child': child?.toJson()};
  '''
----------
### Preview
![](https://github.com/koreaken/flutter_actual_refactoring/blob/develop/screenshot/preview.gif)