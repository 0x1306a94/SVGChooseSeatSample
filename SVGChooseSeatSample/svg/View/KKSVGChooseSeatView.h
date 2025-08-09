//
//  KKSVGChooseSeatView.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SVGKImage;
@class SVGKLayeredImageView;
@class KKSVGDrawSeatView;

@interface KKSVGChooseSeatView : UIView
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) SVGKLayeredImageView *layeredImageView;
@property (nonatomic, strong, readonly) KKSVGDrawSeatView *drawSeatView;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong, nullable) void (^reportVisibleContentRectBlock)(CGRect);

- (void)updateScale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
