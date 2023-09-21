//
//  KKYuntuDrawSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import "KKYuntuDrawSeatView.h"

#import "KKYuntuSeatAreaDetalModel.h"
#import "KKYuntuSeatGraphGeometry.h"
#import "KKYuntuSeatItemModel.h"
#import "NSBundle+SVGResources.h"

@import SVGKit;

static NSString *const KKSeatLayerGraphIdKey = @"kk_graphId";
static NSString *const KKSeatLayerUniqueIdentifierKey = @"kk_uniqueIdentifier";

@interface KKYuntuDrawSeatView ()
@property (nonatomic, strong) NSMapTable<NSNumber *, KKYuntuSeatItemModel *> *seatItemMap;
@property (nonatomic, strong) NSMapTable<NSNumber *, CALayer *> *seatlayerMap;
@property (nonatomic, strong) SVGKImage *availableSvgImage;
@property (nonatomic, strong) SVGKImage *selectedSvgImage;
@property (nonatomic, assign) BOOL drawed;
@end

@implementation KKYuntuDrawSeatView

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

    self.gridSize = CGSizeMake(12, 12);
    self.gapSize = CGSizeMake(4, 4);
    self.contentInset = UIEdgeInsetsMake(30, 30, 30, 30);

    self.seatItemMap = [NSMapTable<NSNumber *, KKYuntuSeatItemModel *> strongToWeakObjectsMapTable];
    self.seatlayerMap = [NSMapTable<NSNumber *, CALayer *> strongToStrongObjectsMapTable];

    NSBundle *svgBundle = [NSBundle kk_SVGResources];
    self.availableSvgImage = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:svgBundle];
    [self.availableSvgImage scaleToFitInside:self.gridSize];

    self.selectedSvgImage = [SVGKImage imageNamed:@"icon_chooseSeat_selected" inBundle:svgBundle];
    [self.selectedSvgImage scaleToFitInside:self.gridSize];
}

- (void)setSeatArea:(KKYuntuSeatAreaDetalModel *)seatArea {
    if (_seatArea == seatArea) {
        return;
    }
    _seatArea = seatArea;

    NSArray<KKYuntuSeatItemModel *> *seats = self.seatArea.seats;
    [self.seatItemMap removeAllObjects];
    for (KKYuntuSeatItemModel *item in seats) {
        NSInteger graphId = [item graphId];
        [self.seatItemMap setObject:item forKey:@(graphId)];
    }
}

- (void)drawSeatInRect:(CGRect)rect {
    //    if (self.drawed) {
    //        return;
    //    }

//    CGPoint canvasCenter = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.05);

    CALayer *canvasLayer = self.layer;
    NSArray<CALayer *> *sublayers = [canvasLayer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if (!CGRectIntersectsRect(rect, layer.frame)) {
            NSNumber *uniqueIdentifier = [layer valueForKey:KKSeatLayerUniqueIdentifierKey];
            if (uniqueIdentifier) {
                [self.seatlayerMap setObject:layer forKey:uniqueIdentifier];
            }
            [layer removeFromSuperlayer];
        }
    }

    NSArray<KKYuntuSeatItemModel *> *seats = self.seatArea.seats;
    do {
        if (seats.count == 0) {
            break;
        }
        CGSize gridSize = self.gridSize;
        CGSize gapSize = self.gapSize;
        UIEdgeInsets contentInset = self.contentInset;
        for (KKYuntuSeatItemModel *seat in self.seatArea.seats) {
            NSInteger graphId = [seat graphId];
            NSInteger uniqueIdentifier = [seat uniqueIdentifier];
            CGRect frame = CGRectZero;
            frame.origin = CGPointMake(contentInset.left + seat.graphcol * gapSize.width + seat.graphcol * gridSize.width,
                                       contentInset.top + seat.graphrow * gapSize.height + seat.graphrow * gridSize.height);
            frame.size = gridSize;
            if (CGRectIntersectsRect(rect, frame)) {
                CALayer *seatLayer = [self.seatlayerMap objectForKey:@(uniqueIdentifier)];
                if (seatLayer == nil) {
                    seatLayer = [seat selected] ? [self.selectedSvgImage newCALayerTree] : [self.availableSvgImage newCALayerTree];
                    [self.seatlayerMap setObject:seatLayer forKey:@(uniqueIdentifier)];
                }
                CGPoint seatCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

//                CGFloat theta = atan2(canvasCenter.y - seatCenter.y, canvasCenter.x - seatCenter.x) + M_PI_2;
                [seatLayer setValue:@(graphId) forKey:KKSeatLayerGraphIdKey];
                [seatLayer setValue:@(uniqueIdentifier) forKey:KKSeatLayerUniqueIdentifierKey];
                seatLayer.frame = frame;
//                seatLayer.transform = CATransform3DMakeRotation(theta, 0, 0, 1);
                [canvasLayer addSublayer:seatLayer];
            }
        }
    } while (0);

    self.drawed = YES;
}

- (void)clearSeat {
    if (!self.drawed) {
        return;
    }
    NSArray<CALayer *> *seatlayers = [self.layer sublayers];
    [seatlayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.drawed = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    NSArray<CALayer *> *sublayers = [self.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if (CGRectContainsPoint(layer.frame, point)) {
            NSInteger graphId = [[layer valueForKey:KKSeatLayerGraphIdKey] integerValue];
            KKYuntuSeatItemModel *seate = [self.seatItemMap objectForKey:@(graphId)];
            if (seate == nil) {
                break;
            }
            BOOL selected = ![seate selected];
            [seate updateSelected:selected];

            NSInteger uniqueIdentifier = [seate uniqueIdentifier];

            NSLog(@"graphId %ld %ld", (graphId & GRAPH_COL_MASK), ((graphId & GRAPH_ROW_MASK) >> GRAPH_ROW_SHIFT));
            [layer removeFromSuperlayer];
            CALayer *newLayer = [self.seatlayerMap objectForKey:@(uniqueIdentifier)];
            if (newLayer == nil) {
                newLayer = selected ? [self.selectedSvgImage newCALayerTree] : [self.availableSvgImage newCALayerTree];
            }
            newLayer.frame = layer.frame;
            [newLayer setValue:@(graphId) forKey:KKSeatLayerGraphIdKey];
            [newLayer setValue:@(uniqueIdentifier) forKey:KKSeatLayerUniqueIdentifierKey];
            [self.seatlayerMap setObject:newLayer forKey:@(uniqueIdentifier)];
            [self.layer addSublayer:newLayer];
            break;
        }
    }
}
@end
