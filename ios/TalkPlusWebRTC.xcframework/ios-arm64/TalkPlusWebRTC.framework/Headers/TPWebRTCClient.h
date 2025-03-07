#import <UIKit/UIKit.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCFieldTrials.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCSSLAdapter.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCRtpTransceiver.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCMTLVideoView.h>
//#import <WebRTC/RTCEAGLVideoView.h>
#import <TalkPlusWebRTC/TalkPlusCall.h>
#import <TalkPlusWebRTC/TalkPlusCallParams.h>

#define TALKPLUS_WEBRTC_SDK_VERSION @"1.0.0"

@protocol TPWebRTCClientDelegate <NSObject>
@required
- (void)didReceiveCallIncoming:(TalkPlusCall *_Nonnull)call;
- (void)didReceiveCallEnd:(TalkPlusCall *_Nonnull)call;
- (void)didReceiveCallConnect:(TalkPlusCall *_Nonnull)call;
- (void)didReceiveCallDisconnected:(TalkPlusCall *_Nonnull)call;
- (void)didReceiveCallFailed:(TalkPlusCall *_Nonnull)call;
@optional
- (void)didReceiveCallError:(TalkPlusCall *_Nonnull)call error:(NSDictionary *_Nonnull)error;
- (void)didReceiveStateChange:(TalkPlusCall *_Nonnull)call newState:(RTCIceConnectionState)newState;
@end

@interface TPWebRTCClient : NSObject

+ (instancetype _Nonnull)new NS_UNAVAILABLE;

- (void)addDelegate:(id<TPWebRTCClientDelegate>_Nonnull)delegate identifier:(NSString * _Nonnull)identifier
NS_SWIFT_NAME(addDelegate(_:identifier:));
- (void)removeDelegate:(NSString * _Nonnull)identifier;
- (void)removeAllDelegates;

- (void)makeCall:(TalkPlusCallParams * _Nonnull)params
      completion:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion
NS_SWIFT_NAME(makeCall(_:completion:));

- (void)acceptCall:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion;
- (void)endCall:(void(^_Nullable)(BOOL result, TalkPlusCall *_Nullable))completion;

- (void)setEnableTrack:(BOOL)isEnabled track:(RTCMediaStreamTrack * _Nonnull)track;
- (BOOL)isTrackEnabled:(RTCMediaStreamTrack * _Nonnull)track;

- (void)registerVoIPPushToken:(NSData *_Nonnull)token
                     success:(void (^_Nullable)(void))successBlock
                     failure:(void (^_Nonnull)(int errorCode, NSError * _Nullable error))failureBlock;
- (void)voipPushRegistry:(NSDictionary * _Nullable)payload;

@end
