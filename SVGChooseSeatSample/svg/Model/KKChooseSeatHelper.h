//
//  KKChooseSeatHelper.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SVGKImage;
@class KKTradeSVGModel;
@interface KKChooseSeatHelper : NSObject
+ (KKTradeSVGModel *)parserWithSVGImage:(SVGKImage *)image;

+ (CGFloat)getSvgScaleWithSvgMode:(KKTradeSVGModel *)svgModel;
@end

NS_ASSUME_NONNULL_END
