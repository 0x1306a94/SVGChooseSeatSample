//
//  CALayer+Bitmap.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/10/15.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@interface CALayer (Bitmap)
- (UIImage *)kk_toImage:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
