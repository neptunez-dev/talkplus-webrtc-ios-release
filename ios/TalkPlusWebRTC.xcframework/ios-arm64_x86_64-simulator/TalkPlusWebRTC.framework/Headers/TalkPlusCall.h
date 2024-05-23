
#import <UIKit/UIKit.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>

typedef NS_ENUM(NSInteger, TPEndCallReason) {
    TPEndCallReasonUnknown,
    TPEndCallReasonCompleted,
    TPEndCallReasonDeclined,
    TPEndCallReasonCanceled,
};


@interface TalkPlusCall : NSObject
@property (readonly) NSString * _Nonnull channelId;
@property (readonly) NSString * _Nonnull callerId;
@property (readonly) NSString * _Nonnull calleeId;
@property (readonly) NSUUID * _Nonnull uuid;
@property (readonly) TPEndCallReason endReasonCode;

@property UIView * _Nullable localRendererView;
@property UIView * _Nullable remoteRendererView;
@property RTCVideoTrack * _Nullable localVideoTrack;
@property RTCAudioTrack * _Nullable localAudioTrack;
@property RTCVideoTrack * _Nullable remoteVideoTrack;
@property RTCAudioTrack * _Nullable remoteAudioTrack;

+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)init:(NSString *_Nonnull)channelId
                     callerId:(NSString *_Nonnull)callerId
                     calleeId:(NSString *_Nonnull)calleeId
                   uuidString:(NSString *_Nonnull)uuidString;

- (instancetype _Nonnull)init:(NSString *_Nonnull)channelId
                     callerId:(NSString *_Nonnull)callerId
                     calleeId:(NSString *_Nonnull)calleeId
                   uuidString:(NSString *_Nonnull)uuidString
                endReasonCode:(TPEndCallReason)endReasonCode;

+ (NSString * _Nonnull)getEndReasonMessage:(TPEndCallReason)reasonCode;

@end
