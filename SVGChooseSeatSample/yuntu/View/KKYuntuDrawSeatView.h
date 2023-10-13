//
//  KKYuntuDrawSeatView.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KKYuntuSeatAreaDetalModel;
@interface KKYuntuDrawSeatView : UIView
@property (nonatomic, assign) CGSize gridSize;
@property (nonatomic, assign) CGSize gapSize;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) CGFloat drawScale;

@property (nonatomic, strong) KKYuntuSeatAreaDetalModel *seatArea;
- (void)drawSeatInRect:(CGRect)rect;
- (void)clearSeat;
@end

NS_ASSUME_NONNULL_END
