<div align="center">

<img src="docs/readme/project-banner.png" alt="PairShot" width="100%" />

# PairShot iOS

**Before·After 촬영 및 관리 애플리케이션**

**[🌐 공식 웹사이트](https://pairshot.nomadlabs.kr)** &nbsp;&nbsp; **[<img src="./docs/readme/app-store-badge.png" alt="App Store" height="18" style="vertical-align:middle;" /> 다운로드](https://apps.apple.com/kr/app/pairshot-%ED%8E%98%EC%96%B4%EC%83%B7-before-after/id6770494128)**

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS_17%2B-007AFF?style=flat-square&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![AVFoundation](https://img.shields.io/badge/AVFoundation-1F2937?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/av-foundation/)
[![License](https://img.shields.io/badge/License-Private-red?style=flat-square)]()

비포·애프터 촬영 및 관리 전용 카메라 애플리케이션.</br>
비포·애프터 촬영 및 관리 보조, 일괄 합성 등 현장 작업자의 번거로운 워크플로우를 개선합니다.

</div>


## 기술 스택

**`Core`**

![Swift](https://img.shields.io/badge/Swift_6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS_17.0%2B-000000?style=for-the-badge&logo=apple&logoColor=white)

**`Camera & Image`**

![AVFoundation](https://img.shields.io/badge/AVFoundation-1F2937?style=for-the-badge&logo=apple&logoColor=white)
![PhotoKit](https://img.shields.io/badge/PhotoKit-1F2937?style=for-the-badge&logo=apple&logoColor=white)
![ImageIO](https://img.shields.io/badge/ImageIO-1F2937?style=for-the-badge&logo=apple&logoColor=white)

**`Data & DI`**

![SwiftData](https://img.shields.io/badge/SwiftData-007AFF?style=for-the-badge&logo=swift&logoColor=white)
![UserDefaults](https://img.shields.io/badge/UserDefaults-1F2937?style=for-the-badge&logo=apple&logoColor=white)
![Keychain](https://img.shields.io/badge/Keychain-1F2937?style=for-the-badge&logo=apple&logoColor=white)

**`Sensors & Location`**

![CoreMotion](https://img.shields.io/badge/CoreMotion-1F2937?style=for-the-badge&logo=apple&logoColor=white)
![CoreLocation](https://img.shields.io/badge/CoreLocation-1F2937?style=for-the-badge&logo=apple&logoColor=white)

**`Build & Quality`**

![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white)
![SwiftFormat](https://img.shields.io/badge/SwiftFormat-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftLint](https://img.shields.io/badge/SwiftLint-F05138?style=for-the-badge&logo=swift&logoColor=white)
![Periphery](https://img.shields.io/badge/Periphery-F05138?style=for-the-badge&logo=swift&logoColor=white)

<br/>

---

## 주요 기능

### 촬영

<table>
<tr>
<td width="50%" valign="top">

#### BEFORE 오버레이 가이드
BEFORE 사진을 카메라 프리뷰에 오버레이 형식으로 표시하여 촬영 구도를 쉽게 맞출 수 있도록 보조합니다.
투명도 옵션 토글 및 조절 방식으로 사용자 별 커스텀이 가능합니다.

</td>
<td width="50%" valign="top">

#### 스트립 캐러셀
AFTER 촬영 중 매번 각 BEFORE 사진을 기기앨범 또는 홈화면에서 조회할 필요없도록, AFTER 촬영 페어가 없는 BEFORE 사진 리스트를 표시합니다.</br>
촬영 화면에서 잔여 BEFORE 사진을 슬라이드 제스처로 조회 및 선택할 수 있으며, 각 카드 별 롱프레스 제스처로 미리보기 확대 기능을 제공합니다. 

</td>
</tr>
<tr>
<td width="50%" valign="top">

#### 회전 가이드
각 BEFORE 사진이 촬영 당시 기기를 가로 또는 세로 중 어느 방향으로 촬영한 사진인지 안내합니다. </br>
BEFORE 스트립의 카드 별 고정 아이콘으로 표시하며, 카메라 프리뷰에서는 현재 기기 센서 값에 따라 동적으로 기기 회전 방향을 안내합니다.

</td>
<td width="50%" valign="top">

#### 카메라 옵션
1:1 · 4:3 · 16:9 촬영 비율 설정 옵션 및 격자 그리드, 수평계, 오버레이 토글, 야간모드, 조도 조절 옵션을 제공합니다.

</td>
</tr>

</table>


### 전·후 사진 관리

<table>
<tr>
<td width="50%" valign="top">

#### 페어 카드
전·후 사진을 개별 사진이 아닌 한 쌍의 페어 카드 UI/UX 형식으로 관리할 수 있습니다. </br>
각 카드 별 삭제 · AFTER만 삭제 · 합성 결과 미리보기 모달 · 기기저장 · Sharesheet 공유 기능을 제공합니다.

</td>
<td width="50%" valign="top">

#### 전·후 합성
페어 카드 전·후 사진의 원본 비트맵을 합성하여 단일 합성 이미지를 생성할 수 있습니다. </br>
테두리 · 레이블 설정 기능을 제공하며, 각각 색상 · 사이즈 · 두께 · 레이블 위치 등 세부 커스텀 가능한 옵션 설정 기능을 제공합니다.

</td>
</tr>
<tr>
<td valign="top">

#### 워터마크 설정
텍스트 반복 워터마크 · 로고 이미지 워터마크 자동 삽입이 가능합니다. </br>
텍스트 및 이미지의 사이즈, 투명도 등 세부 커스텀 옵션 설정 기능을 제공합니다.

</td>
<td valign="top">

#### 내보내기 및 공유
선택된 페어 카드 이미지를 내 기기에 저장 또는 Sharesheet를 통한 전송이 가능합니다. </br>
설정된 옵션 (내보낼 사진 종류, 파일 형식, 워터마크 삽입 여부, 합성 적용 여부)을 선택한 페어 카드에 일괄 적용하여 내보내기 또는 공유가 가능합니다.

</td>
</tr>
</table>

<br/>

---

## 릴리즈 노트

| 버전 | 날짜 | Build | 주요 내용 | 노트 |
|------|------|-------|-----------|------|
| [v1.3.2](docs/releases/v1.3.2.md) | 2026-08-05 | 1 | AFTER 스트립 카드 롱프레스 시 BEFORE 미리보기 흐림·미표시 회귀 수정 | [→](docs/releases/v1.3.2.md) |
| [v1.3.1](docs/releases/v1.3.1.md) | 2026-06-29 | 1 | 종횡비 다른 전후 사진 합성 50:50 분할 정상화 · AFTER 스트립 카드에 가로/세로 촬영 방향 아이콘 추가 | [→](docs/releases/v1.3.1.md) |
| [v1.3.0](docs/releases/v1.3.0.md) | 2026-06-17 | 1 | 결제 실패(재시도·유예) 구독 Pro 만료 정상화 · 첫 실행 Paywall 네이티브 닫기 버튼 추가 · adFree 전용 프로모션 차원 제거 | [→](docs/releases/v1.3.0.md) |
| [v1.2.3](docs/releases/v1.2.3.md) | 2026-06-08 | 1 | 정책·마케팅·쿠폰 API 호스트를 `pairshot.nomadlabs.kr` 로 이전 · 정책 URL 베이스를 xcconfig 주입으로 단일 출처화 | [→](docs/releases/v1.2.3.md) |
| [v1.2.2](docs/releases/v1.2.2.md) | 2026-06-01 | 1 | 결제 후 paywall 자동 닫힘·광고 즉시 제거 · Paywall 텍스트 크기 앱 정책 강제 · 설정 텍스트 크기·테마 즉시 반영 | [→](docs/releases/v1.2.2.md) |
| [v1.2.1](docs/releases/v1.2.1.md) | 2026-05-30 | 1 | 첫 실행 Paywall 무료 진입로 가독성 강조·약관 안내 순서 정리 · 카메라 진입 SF Symbol 콘솔 경고 4건 제거 | [→](docs/releases/v1.2.1.md) |
| [v1.2.0](docs/releases/v1.2.0.md) | 2026-05-30 | 1 | 내보내기 프리셋 4 슬롯 (무료 2 / Pro 4) · 페어 미리보기 액션 바·핀치 줌 패닝·After 삭제 개편 · 인앱 리뷰 prompt | [→](docs/releases/v1.2.0.md) |
| [v1.1.1](docs/releases/v1.1.1.md) | 2026-05-24 | 1 | 튜토리얼 안정화 (stuck 검출·peek-close·cold-start 복원) · Dynamic Type 앱 정책 · 카메라 재진입 프리뷰 멈춤 fix | [→](docs/releases/v1.1.1.md) |
| [v1.1.0](docs/releases/v1.1.0.md) | 2026-05-23 | 1 | 합성 설정 레이블 배치 방식(이미지/테두리) 신설 · AFTER long-press 미리보기 · ATT/UMP 정공화 | [→](docs/releases/v1.1.0.md) |
| [v1.0.0](docs/releases/v1.0.0.md) | 2026-05-19 | 1 | Before·After 페어 사진 촬영·관리·내보내기 첫 출시 | [→](docs/releases/v1.0.0.md) |

<br/>

---

<div align="center">

© 2026 NomadLabs. All rights reserved.

</div>
