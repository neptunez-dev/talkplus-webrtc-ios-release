
#import <Foundation/Foundation.h>

@interface TalkPlusCallParams : NSObject
@property (readonly) NSString * _Nonnull channelId;
@property (readonly) NSString * _Nonnull callerId;
@property (readonly) NSString * _Nonnull calleeId;
@property (readonly) NSUUID * _Nonnull uuid;
@property NSMutableDictionary<NSString *, NSString *> * _Nonnull customData;

+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)init:(NSString *_Nonnull)channelId
                     callerId:(NSString *_Nonnull)callerId
                     calleeId:(NSString *_Nonnull)calleeId
                         uuid:(NSUUID *_Nonnull)uuid;
@end
