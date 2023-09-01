//
//  KKSVGChooseSeatView.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SVGKImage;
@interface KKSVGChooseSeatView : UIView
- (void)updateBackgroudSeatImage:(SVGKImage *)seatImage;

- (void)updateScale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
