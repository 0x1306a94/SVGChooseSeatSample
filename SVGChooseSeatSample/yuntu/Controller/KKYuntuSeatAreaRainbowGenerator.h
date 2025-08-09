//
//  KKYuntuSeatAreaRainbowGenerator.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@class KKYuntuSeatAreaModel;
@interface KKYuntuSeatAreaRainbowGenerator : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithBaseImage:(UIImage *)baseImage areas:(NSArray<KKYuntuSeatAreaModel *> *)areas NS_DESIGNATED_INITIALIZER;

- (void)generateWithCompleteHandler:(void (^)(UIImage *outImage))completeHandler;
@end

NS_ASSUME_NONNULL_END
