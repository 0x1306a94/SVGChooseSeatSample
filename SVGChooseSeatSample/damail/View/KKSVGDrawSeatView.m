//
//  KKSVGDrawSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import "KKSVGDrawSeatView.h"

#import "NSBundle+SVGResources.h"

@import SVGKit;

@interface KKSVGDrawSeatView ()
@property (nonatomic, strong) NSHashTable<CALayer *> *seatlayers;
@property (nonatomic, strong) SVGKImage *svgImage;

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

    CGFloat xOffset = 300, yOffset = 300;
    CGSize gridSize = CGSizeMake(6, 6);
    CGSize gapSize = CGSizeMake(2, 2);

    NSInteger row = 10;
    NSInteger column = 10;
    for (NSInteger r = 0; r < row; r++) {
        CGFloat y = yOffset + (r * gridSize.height) + (r * gapSize.height);
        for (NSInteger c = 0; c < column; c++) {
            CGFloat x = xOffset + (c * gridSize.width) + (c * gapSize.width);
            CGRect frame = CGRectMake(x, y, gridSize.width, gridSize.height);
            CALayer *seatLayer = [self.svgImage newCALayerTree];
            seatLayer.frame = frame;
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
@end
