//
//  KKSVGDrawSeatView.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKSVGDrawSeatView : UIView
@property (nonatomic, assign) CGFloat seatWidth;
@property (nonatomic, assign) CGFloat scale;
- (void)drawSeat;
- (void)clearSeat;
@end

NS_ASSUME_NONNULL_END
