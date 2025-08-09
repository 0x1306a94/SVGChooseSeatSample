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

@property (nonatomic, assign) CGRect visibleContentRect;
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

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView = contentView;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    SVGKLayeredImageView *layeredImageView = [[SVGKLayeredImageView alloc] initWithFrame:self.bounds];
    self.layeredImageView = layeredImageView;
    layeredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    KKSVGDrawSeatView *drawSeatView = [[KKSVGDrawSeatView alloc] initWithFrame:self.bounds];
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

// 这是一个私有方法，用于计算并报告可见内容区域
- (void)_calculateVisibleContentRect {

    CGPoint contentOffset = self.scrollView.contentOffset;
    CGRect bounds = self.bounds;
    CGFloat zoomScale = self.scrollView.zoomScale;

    CGFloat visibleRectX = contentOffset.x / zoomScale;
    CGFloat visibleRectY = contentOffset.y / zoomScale;
    CGFloat visibleRectWidth = bounds.size.width / zoomScale;
    CGFloat visibleRectHeight = bounds.size.height / zoomScale;

    self.visibleContentRect = CGRectMake(visibleRectX, visibleRectY, visibleRectWidth, visibleRectHeight);
    !self.reportVisibleContentRectBlock ?: self.reportVisibleContentRectBlock(self.visibleContentRect);
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidZoom");
    [self adjustContentViewCenter];
    if (scrollView.zoomScale >= 1.5) {
        [self.drawSeatView drawSeat];
    } else if (scrollView.zoomScale < 1.5) {
        [self.drawSeatView clearSeat];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [self adjustContentViewCenter];
//    NSLog(@"scrollViewDidEndZooming %f", scale);
}

#pragma mark - public
- (void)updateScale:(CGFloat)scale {
    [self.scrollView setZoomScale:scale animated:YES];
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    if (self.contentView == nil) {
        return;
    }

    CGSize boundsSize = self.bounds.size;
    CGSize contentViewSize = self.contentView.frame.size;

    CGFloat widthScale = boundsSize.width / contentViewSize.width;
    CGFloat heightScale = boundsSize.height / contentViewSize.height;
    CGFloat minScale = fmin(fmin(widthScale, heightScale), 1.0);
    CGFloat maxScale = boundsSize.width / 126.0;

    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        maxScale = 4.0;
    }

    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = minScale;
    [self setNeedsLayout];
}

- (void)configureWithSize:(CGSize)size {
    self.scrollView.contentSize = size;
    [self setMaxMinZoomScalesForCurrentBounds];
    [self _calculateVisibleContentRect];
}

#pragma mark - setter
- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;

    CGRect frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.contentView.frame = frame;
    self.layeredImageView.frame = frame;
    self.drawSeatView.frame = frame;

    [self configureWithSize:contentSize];
}
@end
