#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorthMapHelper : NSObject

+ (void)handleNavigatorUrl:(NSURL *)url               ;
+ (void)registerMaps                                  ;
+ (void)loadManager                                   ;

@end

NS_ASSUME_NONNULL_END
