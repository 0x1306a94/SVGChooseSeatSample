//
//  KKSVGChooseSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import "KKSVGChooseSeatView.h"

#import "KKSVGDrawSeatView.h"

#import <objc/runtime.h>

@import SVGKit;

@interface KKSVGChooseSeatView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SVGKLayeredImageView *layeredImageView;
@property (nonatomic, strong) KKSVGDrawSeatView *drawSeatView;
@end

@implementation KKSVGChooseSeatView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Initial Methods
- (void)commonInit {
    /*custom view u want draw in here*/
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    /*
     ScrollView
        CanvasView
     
     CanvasSize = {1000, 1000}
     ScrollView.contentSize = CanvasSize
     ScrollView.frame = {0, 0, 393, 546}
     ScrollView.minimumZoomScale = 0.38;
     ScrollView.maximumZoomScale = 8.18;
     ScrollView.zoomScale = 0.38;
     
     */

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *contentView = [[UIView alloc] initWithFrame:scrollView.bounds];
    self.contentView = contentView;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    SVGKLayeredImageView *layeredImageView = [[SVGKLayeredImageView alloc] initWithFrame:contentView.bounds];
    self.layeredImageView = layeredImageView;
    layeredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    KKSVGDrawSeatView *drawSeatView = [[KKSVGDrawSeatView alloc] initWithFrame:contentView.bounds];
    drawSeatView.backgroundColor = UIColor.clearColor;
    self.drawSeatView = drawSeatView;
    drawSeatView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:scrollView];
    [scrollView addSubview:contentView];
    [contentView addSubview:layeredImageView];
    [contentView addSubview:drawSeatView];

    //    scrollView.minimumZoomScale = 0.375;
    //    scrollView.maximumZoomScale = 8.18;
    //    scrollView.zoomScale = 0.375;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self adjustContentViewCenter];
}

- (void)adjustContentViewCenter {
    UIScrollView *scrollView = self.scrollView;
    CGFloat xcenter = scrollView.center.x, ycenter = scrollView.center.y;

    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。

    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : xcenter;

    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2 : ycenter;

    [self.contentView setCenter:CGPointMake(xcenter, ycenter)];
}

- (void)calculateRendererRect {
    /*
     viewport = {375, 600}
     canvasSize = {1000, 1000}
     
     */
    //    CGPoint contentOffset = self.scrollView.contentOffset;
    //    CGSize viewport = self.scrollView.frame.size;
    //    CGPoint canvasOrigin = self.contentView.frame.origin;
    /*
     
     5888 5904
     
     x 1.2
     7065 7084
     
     view size = {360, 618}
     
     svg size = {7065, 7084}
     
     n = 7065 / 360 = 19.626666
     
     if ((7084 / n) > 618 && n == 7084 / 618)
     
     */
    //    CGSize canvasSize = CGSizeMake(1000, 1002);

    //    CGRect rendererRect = CGRectMake(contentOffset.x + canvasOrigin.x, contentOffset.y + canvasOrigin.y, viewport.width, viewport.height);
    //    CGFloat scale =self.scrollView.maximumZoomScale -  self.scrollView.zoomScale;
    //    rendererRect = CGRectApplyAffineTransform(rendererRect, CGAffineTransformMakeScale(scale, scale));
    //    NSLog(@"rendererRect %@", NSStringFromCGRect(rendererRect));

    //    CGFloat minScale = self.scrollView.minimumZoomScale;
    //    CGFloat maxScale = self.scrollView.maximumZoomScale;
    //    CGFloat scale = self.scrollView.zoomScale;
    //    CGRect rendererRect = CGRectZero;
    //    if (scale == 1.0) {
    //
    //    } else {
    //        if (scale < 1.0) {
    //            // 放大
    //            scale = 1.0 + minScale / scale;
    //        } else {
    //            // 缩小
    //            scale = 1.0 - (scale / (maxScale + 1.0));
    //        }
    ////        contentOffset = CGPointApplyAffineTransform(contentOffset, CGAffineTransformMakeScale(scale, scale));
    ////        canvasOrigin = CGPointApplyAffineTransform(canvasOrigin, CGAffineTransformMakeScale(scale, scale));
    ////        viewport = CGSizeApplyAffineTransform(viewport, CGAffineTransformMakeScale(scale, scale));
    //    }

    //    rendererRect = CGRectMake(contentOffset.x + canvasOrigin.x, contentOffset.y + canvasOrigin.y, viewport.width, viewport.height);
    //    rendererRect = CGRectApplyAffineTransform(rendererRect, CGAffineTransformMakeScale(scale, scale));
    //    NSLog(@"rendererRect %@", NSStringFromCGRect(rendererRect));
    CGRect rendererRect2 = [self.scrollView convertRect:self.scrollView.bounds toView:self.contentView];
    NSLog(@"rendererRect2 %@", NSStringFromCGRect(rendererRect2));
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    [self calculateRendererRect];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidZoom");
    [self adjustContentViewCenter];
    [self calculateRendererRect];
    if (scrollView.zoomScale >= 1.5) {
        [self.drawSeatView drawSeat];
    } else if (scrollView.zoomScale < 1.5) {
        [self.drawSeatView clearSeat];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [self adjustContentViewCenter];
    [self calculateRendererRect];
    NSLog(@"scrollViewDidEndZooming %f", scale);
}

#pragma mark - public
- (void)updateBackgroudSeatImage:(SVGKImage *)seatImage {

    CGSize svgSize = seatImage.size;
    CGSize viewSize = self.bounds.size;

    CGFloat maxCanvasWidth = 1000;
    CGFloat maxCanvasHeight = (maxCanvasWidth / svgSize.width) * svgSize.height;

    NSLog(@"viewport %@ viewbox %@ size %@", NSStringFromCGRect(CGRectFromSVGRect(seatImage.DOMTree.viewport)),
          NSStringFromCGRect(CGRectFromSVGRect(seatImage.DOMTree.viewBox)),
          NSStringFromCGSize(seatImage.size));
    [seatImage scaleToFitInside:CGSizeMake(maxCanvasWidth, maxCanvasHeight)];
    NSLog(@"viewport %@ viewbox %@ size %@", NSStringFromCGRect(CGRectFromSVGRect(seatImage.DOMTree.viewport)),
          NSStringFromCGRect(CGRectFromSVGRect(seatImage.DOMTree.viewBox)),
          NSStringFromCGSize(seatImage.size));

    CGFloat minScale = viewSize.width / maxCanvasWidth;
    CGFloat maxScale = svgSize.width / maxCanvasWidth;

    self.scrollView.contentSize = CGSizeMake(maxCanvasWidth, maxCanvasHeight);
    self.contentView.bounds = (CGRect){CGPointZero, CGSizeMake(maxCanvasWidth, maxCanvasHeight)};
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = minScale;

    [self adjustContentViewCenter];
    self.layeredImageView.image = seatImage;
}

- (void)updateScale:(CGFloat)scale {
    [self.scrollView setZoomScale:scale animated:YES];
}
@end
