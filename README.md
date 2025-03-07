
# klat-webrtc-ios

![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
![Languages](https://img.shields.io/badge/language-objc-orange.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## klat-webrtc-ios SDK 소개

iOS용 Klat WebRTC SDK는 Objective-C 언어로 작성되었으며, iOS 클라이언트 앱에 음성 및 영상 통화 기능을 구축하는데 사용할 수 있습니다. 이 저장소에서는 Klat WebRTC SDK를 프로젝트에 구현하기 전에 필요한 몇 가지 절차와 Swift 언어 및 UIKit를 활용하여 작성된 샘플 앱을 찾을 수 있습니다.

> 다자간 통화(그룹 통화)는 지원되지 않으며, 일대일 (1:1) 통화만 가능합니다.<br/>

> 통화를 하려면 채널 식별자 (Channel ID) + 유저 식별자 (User ID) 정보가 필요합니다.

## 요구사항

klat-webrtc-ios SDK 사용을 위한 최소 요구사항
- Xcode 15.3+
- iOS / iPadOS 12.0+ 설치 된 실제 디바이스 (Physical Device)
  > 2025년 4월 24일부터 앱 스토어 커넥트에 업로드하는 앱은 Xcode 16 이상 버전을 사용하여 빌드해야 합니다. 


## SDK 설치 

klat-webrtc-ios SDK는 [CocoaPods](https://cocoapods.org) 또는 [Swift Package Manager](https://swift.org/package-manager/)를 사용하여 설치할 수 있습니다.

### Swift Package Manager
>1) Xcode에서 아래 메뉴를 클릭합니다.
   Xcode - File -> Add Package Dependencies...
>2) 우측 상단 패키지 URL에 아래 저장소 URL를 입력합니다.
   https://github.com/neptunez-dev/talkplus-webrtc-ios-release.git
>3) 사용하려는 버전을 선택하고 "Add Package" 버튼을 클릭하여 SDK 설치를 완료합니다.

### Cocoapods
```ruby
pod 'talkplus-webrtc-ios'
```

macOS에서 터미널 (Terminal) 실행하고, 앱 프로젝트 디렉토리로 이동 한 다음에 아래 명령어를 활용하여 `Podfile`을 열어 주십시오.

```bash
$ open Podfile
```

`Podfile` 파일에 아래 내용이 포함되어 있는지 확인하여 주십시오.

```bash
platform :ios, '12.0'
 
target 'Project' do
    use_frameworks!
    pod 'talkplus-webrtc-ios'
end
```

**CocoaPods** CLI 명령어를 이용하여 `talkplus-webrtc-ios` framework를 설치하여 주십시오.

```bash
$ pod install --repo-update
```

## 의존성 라이브러리 (Dependencies)

 - [WebRTC](https://github.com/stasel/WebRTC)
 - [Klat Chat SDK for iOS](https://github.com/adxcorp/talkplus-ios-release)

 ## iOS 프로젝트 설정

 ### info.plist 파일 설정

 - Xcode 프로젝트 > Info > Custom iOS Target Properties > [NSMicrophoneUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription) 키 추가
 - Xcode 프로젝트 > Info > Custom iOS Target Properties > [NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription) 키 추가

### 푸시 알림 활성화
 - Xcode 프로젝트 > Signing & Capabilities > 상단 `+ Capability` 클릭 > `Push Notification` 추가

### 백그라운드 모드 설정
 - Xcode 프로젝트 > Signing & Capabilities > `Voice over IP` 체크 
 - Xcode 프로젝트 > Signing & Capabilities > `Remote Notifications` 체크 

## 샘플 앱 빌드 및 실행하기

이 저장소에 있는 샘플 앱은 [CallKit](https://developer.apple.com/documentation/callkit) 및 [PushKit](https://developer.apple.com/documentation/pushkit)를 이용하여 통화를 요청하거나 통화를 수신할 수 있도록 구성되어 있습니다.<br/>
이 샘플 앱을 테스트하기 위해서 아래의 절차를 따라 주십시오.<br/>
> [PushKit](https://developer.apple.com/documentation/pushkit) 단독으로만 사용할 수 없으며, 반드시 [CallKit](https://developer.apple.com/documentation/callkit)도 같이 추가(import)해야 합니다

> PushKit 추가 후, [pushRegistry(_:didReceiveIncomingPushWith:for:completion:)](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/pushregistry(_:didreceiveincomingpushwith:for:completion:)) 메소드가 호출되면, [reportNewIncomingCall(with:update:completion:)](https://developer.apple.com/documentation/callkit/cxprovider/reportnewincomingcall(with:update:completion:)) 메소드를 호출해야합니다. 그렇지 않으면 `비정상 종료(CRASH)`가 발생할 수 있습니다. PushKit를 통해서 수신된 VoIP 메시지 처리 방법에 관한 추가적인 설명은 아래 링크를 참조하십시오.<br/>
[PushKit를 통해서 수신된 VoIP Notification 처리](https://developer.apple.com/documentation/pushkit/responding-to-voip-notifications-from-pushkit)

### Klat 애플리케이션 생성

 1. [Klat 대시보드](https://www.klat.kr) 로그인 또는 회원 가입.
 2. Apps > 새로운 앱 만들기' 버튼을 클릭하여 톡플러스 애플리케이션 생성
 3. Apps > [생성된 앱 이름] > Settings > `App ID` 확인
 4. Apps > [생성된 앱 이름] > Settings > `익명 로그인 (Anonymous user)` 활성화
 5. Apps > [생성된 앱 이름] > Channel > `채널 생성` 클릭,<br/>채널 타입은 `PUBLIC`으로 선택, `채널명`을 입력 후 `생성` 버튼 클릭.
 6. 위의 절차를 통해서 생성된 `App ID`와 `Channel ID`에 대한 문자열 정보 확인

 ### 애플리케이션 식별자 (App ID), 채널 식별자 (Channel ID), 유저 식별자 (User ID) 입력
 1. 샘플 앱 (TalkPlusWebRTCSwift.xcworkspace) 워크스페이스 파일 열기 
 2. `AppDelegate.swift` 파일 > `application(_:didFinishLaunchingWithOptions:)` 메소드 > `YOUR_APP_ID` 문자열을 위의 이전 단계에서 생성한 `App ID`로 교체.
 3. `AppDelegate.swift` 파일 > `talkPlusLogin` 메소드 > 익명 로그인에 사용할 유저 식별자 (User ID) 확인.<br/>
     > 제공되는 샘플 앱에서는 `test1`와 `test2` 유저 식별자 (User ID)를 이용하여 로그인하는 것으로 가정<br/>

     > 만약 두 대의 디바이스가 있다면, 첫 번째 디바이스에는 `test1`라는 유저 식별자를 사용하여 앱을 실행하고, 두 번째 디바이스에서는 유저 식별자 값을 `test2`로 변경하여 앱을 실행.
 4. `VideoCallViewController.swift` 파일 > `didTapMakeCall(_:)` 메소드 > `YOUR_CHANNEL_ID` 문자열을 위의 이전 단계에서 생성한 `Channel ID`로 교체.


### VoIP 전용 인증서 및 Push Token 

일반적인 `Push Notification`이 아닌 `VoIP Push Notification` 를 이용하면 앱이 종료 되었거나 또는 백그라운드 상태에 있더라도 통화 요청을 수신 받을 수 있습니다. <br/>

> 앱이 포어그라운드 상태에서는 통화 요청 이벤트(`didReceiveCallIncoming:`)를 직접 수신 할 수 있지만, 앱이 백그라운드 또는 종료된 상태에서는 해당 이벤트를 수신 할 수 없기 때문에 [PushKit](https://developer.apple.com/documentation/pushkit)를 통해서 통화 요청 이벤트를 처리해야합니다.<br/>

통화를 요청하거나 또는 통화를 수신하려면 VoIP Push Token를 아래 메소드를 호출하여 Klat 서버로 전달이 필요합니다. </br> 
```objc
- (void)registerVoIPPushToken:(NSData *_Nonnull)token
  success:(void (^_Nullable)(void))successBlock
  failure:(void (^_Nonnull)(int errorCode, NSError * _Nullable error))failureBlock;
```
> 앱 시작 후, [PKPushRegistry](https://developer.apple.com/documentation/pushkit/pkpushregistry) 객체 생성을 통하여 [pushRegistry(_:didUpdate:for:)](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/pushregistry(_:didupdate:for:)) 메소드가 호출되면, 위의 메소드를 호출하여 푸시용 토큰을 서버로 전달하십시오.

그리고 [Apple 개발자 사이트](https://developer.apple.com)에서 VoIP 전용 인증서를 생성하여, `TalkPus`서버에 등록이 필요합니다. 이 인증서는 VoIP Push Notification를 전송하기 위한 목적으로 사용됩니다. `기술문의`를 통하여 VoIP 전용 인증서(APNs certificate)를 등록하여 주십시오.

### VoIP 전용 인증서 생성 방법
1) 애플 개발자 사이트 로그인
2) `인증서, 식별자 및 프로파일` 부분에서 `인증서` 선택 
3) `Certificate +` 버튼 클릭
4) `Services`에서 `VoIP Services Certificate` 선택 후, `Continue` 버튼 클릭
5) VoIP 서비스가 추가될 `App ID (Bundle ID)` 선택 후, `Continue` 버튼 클릭
6) MacOS 키체인 접근 (Keychain Access)를 실행 > `키체인 접근 - 인증서 지원 - 인증 기관에서 인증서 요청` 메뉴를 통하여 `Certificate Signing Request (CSR)` 파일 생성 
7) 생성된 CSR 파일 업로드 후, `Continue` 버튼 클릭
8) `Certificate Type`이 `VoIP Services`라고 표시되어 있는지 확인 후, `Download` 버튼을 클릭하여 인증서 다운로드


## APIs, Delegate

### APIs
```objc
// 영상통화 요청
- (void)makeCall:(TalkPlusCallParams * _Nonnull)params 
  completion:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion;
```

```objc
// 영상통화 요청에 대한 수락
- (void)acceptCall:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion;
```

```objc
// 영상통화 종료/거절/취소 
- (void)endCall:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion;
```

```objc
// 영상통화 관련 이벤트를 수신하기 위한 객체 등록
- (void)addDelegate:(id<TPWebRTCClientDelegate>_Nonnull)delegate 
  identifier:(NSString * _Nonnull)identifier
```

```objc
// 영상통화 관련하여 등록된 객체 등록 해제
- (void)removeDelegate:(NSString * _Nonnull)identifier;
```

```objc
// 영상통화 관련하여 등록된 모든 객체 등록 해제
- (void)removeAllDelegates;
```

```objc
// 오디오 또는 비디오 트랙의 활성화 또는 비활성화
- (void)setEnableTrack:(BOOL)isEnabled track:(RTCMediaStreamTrack * _Nonnull)track;
```

```objc
// 오디오 또는 비디오 트랙의 활성화 여부
- (BOOL)isTrackEnabled:(RTCMediaStreamTrack * _Nonnull)track;
```

```objc
// VoIP 전용 Push Notification Token를 Klat 서버로 전송
- (void)registerVoIPPushToken:(NSData *_Nonnull)token
  success:(void (^_Nullable)(void))successBlock
  failure:(void (^_Nonnull)(int errorCode, NSError * _Nullable error))failureBlock;
```

```objc
// VoIP 전용 Push Notification의 페이로드(Payload) 데이터를 SDK에서 처리
- (void)voipPushRegistry:(NSDictionary * _Nullable)payload;
```

### Delegate (Events)
```objc
@protocol TPWebRTCClientDelegate <NSObject>
@required
- (void)didReceiveCallIncoming:(TalkPlusCall *_Nonnull)call;        // 통화 요청 수신
- (void)didReceiveCallEnd:(TalkPlusCall *_Nonnull)call;             // 통화 종료/취소/거절
- (void)didReceiveCallConnect:(TalkPlusCall *_Nonnull)call;         // 통화 연결 성공
- (void)didReceiveCallDisconnected:(TalkPlusCall *_Nonnull)call;    // 연결이 일시적으로 끊힌 경우
- (void)didReceiveCallFailed:(TalkPlusCall *_Nonnull)call;          // 연결 실패 또는 재연결 불가
@optional
- (void)didReceiveCallError:(TalkPlusCall *_Nonnull)call            // 통화 연결 에러 발생
  error:(NSDictionary *_Nonnull)error;
- (void)didReceiveStateChange:(TalkPlusCall *_Nonnull)call          // 통화 연결 상태 변경
  newState:(RTCIceConnectionState)newState;
@end
```


## 작성자

Neptune Company

## 라이선스

klat-webrtc-ios SDK는 MIT 라이선스에 따라 사용할 수 있습니다.
