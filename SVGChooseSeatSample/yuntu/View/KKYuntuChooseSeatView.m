//
//  KKYuntuChooseSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import "KKYuntuChooseSeatView.h"

#import "KKYuntuDrawSeatView.h"
#import "KKYuntuSeatAreaDetalModel.h"

@interface KKYuntuChooseSeatView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) KKYuntuDrawSeatView *drawSeatView;
@property (nonatomic, strong) UIImageView *seatBitmapView;
@property (nonatomic, strong) KKYuntuSeatAreaDetalModel *seatArea;
@end

@implementation KKYuntuChooseSeatView

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

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *contentView = [[UIView alloc] initWithFrame:scrollView.bounds];
    self.contentView = contentView;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    KKYuntuDrawSeatView *drawSeatView = [[KKYuntuDrawSeatView alloc] initWithFrame:contentView.bounds];
    drawSeatView.backgroundColor = UIColor.clearColor;
    self.drawSeatView = drawSeatView;
    drawSeatView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIImageView *seatBitmapView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    seatBitmapView.backgroundColor = UIColor.clearColor;
    self.seatBitmapView = seatBitmapView;
    seatBitmapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:scrollView];
    [scrollView addSubview:contentView];
    [contentView addSubview:seatBitmapView];
    [contentView addSubview:drawSeatView];
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

- (CGRect)calculateRendererRect {

    //    CGPoint contentOffset = self.scrollView.contentOffset;
    //    CGSize viewport = self.frame.size;
    //    CGPoint canvasOrigin = self.contentView.frame.origin;
    //
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
    //        contentOffset = CGPointApplyAffineTransform(contentOffset, CGAffineTransformMakeScale(scale, scale));
    //        canvasOrigin = CGPointApplyAffineTransform(canvasOrigin, CGAffineTransformMakeScale(scale, scale));
    //        viewport = CGSizeApplyAffineTransform(viewport, CGAffineTransformMakeScale(scale, scale));
    //    }
    //
    //    rendererRect = CGRectMake(contentOffset.x + canvasOrigin.x, contentOffset.y + canvasOrigin.y, viewport.width, viewport.height);
    //    //    rendererRect = CGRectApplyAffineTransform(rendererRect, CGAffineTransformMakeScale(scale, scale));

    CGRect bounds = self.scrollView.bounds;
    CGRect rendererRect = [self.scrollView convertRect:bounds toView:self.contentView];
    //    NSLog(@"rendererRect2 %@", NSStringFromCGRect(rendererRect2));
    //    rendererRect = CGRectApplyAffineTransform(rendererRect, CGAffineTransformMakeScale(1.2, 1.2));
    rendererRect = CGRectInset(rendererRect, -50, -50);
    return rendererRect;
}

- (void)drawSeatIfNeeded {
    //    CGFloat zoomScale = self.scrollView.zoomScale;
    //    if (zoomScale >= 1.5) {
    //        CGRect rendererRect = [self calculateRendererRect];
    //        [self.drawSeatView drawSeatInRect:rendererRect];
    //    } else if (zoomScale < 1.5) {
    //        [self.drawSeatView clearSeat];
    //    }
    CGRect rendererRect = [self calculateRendererRect];
    [self.drawSeatView drawSeatInRect:rendererRect];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidScroll");
    [self drawSeatIfNeeded];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidZoom");
    [self adjustContentViewCenter];
    [self drawSeatIfNeeded];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [self adjustContentViewCenter];
    [self drawSeatIfNeeded];
    //    NSLog(@"scrollViewDidEndZooming %f", scale);
}

#pragma mark - public
- (void)useSeatArea:(KKYuntuSeatAreaDetalModel *)seatArea {
    if (self.seatArea == seatArea) {
        return;
    }
    self.seatArea = seatArea;
    self.drawSeatView.seatArea = seatArea;

    KKYuntuSeatGraphPoint graphMax = seatArea.graphMax;

    CGSize gridSize = self.drawSeatView.gridSize;
    CGSize gapSize = self.drawSeatView.gapSize;

    UIEdgeInsets contentInset = self.drawSeatView.contentInset;
    CGSize graphSize = CGSizeMake((graphMax.x + 1) * gridSize.width + (graphMax.x - 1) * gapSize.width, (graphMax.y + 1) * gridSize.height + (graphMax.y - 1) * gapSize.height);
    graphSize.width += contentInset.left + contentInset.right;
    graphSize.height += contentInset.top + contentInset.bottom;

    CGFloat maxCanvasWidth = fmin(1000, graphSize.width);
    CGFloat maxCanvasHeight = (maxCanvasWidth / graphSize.width) * graphSize.height;

    CGSize viewSize = self.bounds.size;

    CGFloat minScale = viewSize.width / maxCanvasWidth;
    CGFloat maxScale = graphSize.width / maxCanvasWidth;// + 1.5;

    self.drawSeatView.drawScale = maxCanvasWidth / graphSize.width;
    self.scrollView.contentSize = CGSizeMake(maxCanvasWidth, maxCanvasHeight);
    self.contentView.bounds = (CGRect){CGPointZero, CGSizeMake(maxCanvasWidth, maxCanvasHeight)};
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = maxScale;

#if 1
    self.scrollView.zoomScale = minScale;
    [self adjustContentViewCenter];
    [self drawSeatIfNeeded];
#else
    self.scrollView.zoomScale = 1.0;
    [self adjustContentViewCenter];
    [self.drawSeatView drawSeatInRect:self.contentView.bounds];

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(maxCanvasWidth, maxCanvasHeight) format:format];

    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
        [self.contentView.layer renderInContext:rendererContext.CGContext];
    }];
    self.seatBitmapView.image = image;
    [self.drawSeatView clearSeat];
#endif
    asm("nop");
}
@end
