//
//  KKSVGDrawSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import "KKSVGDrawSeatView.h"

#import "NSBundle+SVGResources.h"

#import "KKSeatItem.h"

#import "CALayer+Bitmap.h"

@import SVGKit;

@interface KKSVGDrawSeatView ()
@property (nonatomic, strong) NSHashTable<CALayer *> *seatlayers;
@property (nonatomic, strong) SVGKImage *svgImage;
//@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *svgBitmapCache;
@property (nonatomic, strong, nullable) UIImage *svgBitmap;
@property (nonatomic, assign) BOOL drawed;
@end

@implementation KKSVGDrawSeatView
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

    self.seatlayers = [NSHashTable<CALayer *> weakObjectsHashTable];
    self.svgImage = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:[NSBundle kk_SVGResources]];

    do {
        CGRect frame = CGRectMake(0, 0, 32, 32);
        CALayer *seatLayer = [self.svgImage newCALayerTree];
        seatLayer.frame = frame;
        self.svgBitmap = [seatLayer kk_toImage:UIScreen.mainScreen.scale];
    } while (0);

    [self.svgImage scaleToFitInside:CGSizeMake(6, 6)];
}

- (void)drawSeat {
    if (self.drawed) {
        return;
    }

    NSArray<CALayer *> *seatlayers = [self.seatlayers allObjects];
    [seatlayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.seatlayers removeAllObjects];

    CALayer *canvasLayer = self.layer;

    // 仅测试
    CGFloat xOffset = 300, yOffset = 300;
    CGSize gridSize = CGSizeMake(6, 6);
    CGSize gapSize = CGSizeMake(2, 2);

    NSInteger row = 100;
    NSInteger column = 100;
    for (NSInteger r = 0; r < row; r++) {
        CGFloat y = yOffset + (r * gridSize.height) + (r * gapSize.height);
        for (NSInteger c = 0; c < column; c++) {
            CGFloat x = xOffset + (c * gridSize.width) + (c * gapSize.width);
            CGRect frame = CGRectMake(x, y, gridSize.width, gridSize.height);
            CALayer *seatLayer = nil;
            if (self.svgBitmap) {
                // 实际分析也是这种方式，提前生成好座位的bitmap
                seatLayer = [CALayer layer];
                seatLayer.contents = (id)self.svgBitmap.CGImage;
            } else {
                seatLayer = [self.svgImage newCALayerTree];
            }
            seatLayer.frame = frame;
            // 实际座位会有变换，例如朝向舞台

            [canvasLayer addSublayer:seatLayer];
            [self.seatlayers addObject:seatLayer];
        }
    }

    self.drawed = YES;
}

- (void)clearSeat {
    if (!self.drawed) {
        return;
    }
    NSArray<CALayer *> *seatlayers = [self.seatlayers allObjects];
    [seatlayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.seatlayers removeAllObjects];
    self.drawed = NO;
}

// 假设 a3 是一个包含 `location` 属性的座位模型对象
// 假设 _seatWidth 是 TCSDrawSeatView 的一个实例变量
- (CGRect)rectForSeat:(KKSeatItem *)seatModel {

    // 获取实例变量 _seatWidth
    CGFloat seatWidth = self.seatWidth;  // d10

    // 获取 seatModel 的 location 属性，通常是一个 CGPoint
    // v5 对应 location.x
    // v7 对应 location.y
    CGPoint location = [seatModel location];

    // 计算两种可能的 origin.x 和 origin.y
    // 第一种：直接使用 location.x 和 location.y
    CGFloat originX_style3 = location.x;
    CGFloat originY_style3 = location.y;

    // 第二种：将 location 视为中心点，计算左上角的坐标
    CGFloat originX_default = location.x - seatWidth;  // v9
    CGFloat originY_default = location.y - seatWidth;  // v10

    // 计算座位的宽度和高度，通常是直径
    CGFloat seatSize = seatWidth + seatWidth;  // v11

    // 获取座位的样式
    // v12 是 self->_seatStyle
    //    TCSDrawSeatStyle seatStyle = [self seatStyle];
    NSInteger seatStyle = 3;
    CGFloat rectX, rectY;

    // 根据座位样式决定使用哪种坐标
    if (seatStyle == 3) {
        rectX = originX_style3;  // v13
        rectY = originY_style3;  // v14
    } else {
        rectX = originX_default;  // v13
        rectY = originY_default;  // v14
    }

    // 创建并返回 CGRect
    // v15 对应 width
    // v16 对应 height
    // 这里的 v15 和 v16 都是 v11 的值
    CGRect rect = CGRectMake(rectX, rectY, seatSize, seatSize);

    return rect;
}
@end
