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

@interface KKYuntuDrawSeatView ()
@property (nonatomic, strong) NSHashTable<CALayer *> *seatlayers;
@property (nonatomic, strong) NSMutableSet<CALayer *> *reuseLayerSet;
@property (nonatomic, strong) NSMapTable<NSString *, CALayer *> *seatlayerMap;
@property (nonatomic, strong) SVGKImage *svgImage;

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
    self.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);

    self.seatlayers = [NSHashTable<CALayer *> weakObjectsHashTable];
    self.reuseLayerSet = [NSMutableSet<CALayer *> setWithCapacity:20];
    self.seatlayerMap = [NSMapTable<NSString *, CALayer *> strongToWeakObjectsMapTable];
    self.svgImage = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:[NSBundle kk_SVGResources]];
    [self.svgImage scaleToFitInside:self.gridSize];
}

- (void)drawSeatInRect:(CGRect)rect {
    //    if (self.drawed) {
    //        return;
    //    }

    CALayer *canvasLayer = self.layer;
    NSArray<CALayer *> *sublayers = [canvasLayer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if (!CGRectIntersectsRect(rect, layer.frame)) {
            layer.hidden = YES;
            //            [layer removeFromSuperlayer];
            //            [self.reuseLayerSet addObject:layer];
        }
    }

    NSArray<KKYuntuSeatItemModel *> *seats = self.seatArea.seats;
    do {
        if (seats.count == 0) {
            break;
        }
        CGSize gridSize = self.gridSize;
        CGSize gapSize = self.gapSize;
        for (KKYuntuSeatItemModel *seat in self.seatArea.seats) {
            NSString *graphId = [seat graphId];
            CGRect frame = CGRectZero;
            frame.origin = CGPointMake(seat.graphcol * gapSize.width + seat.graphcol * gridSize.width, seat.graphrow * gapSize.height + seat.graphrow * gridSize.height);
            frame.size = gridSize;
            if (CGRectIntersectsRect(rect, frame)) {
                CALayer *seatLayer = [self.seatlayerMap objectForKey:graphId];
                if (seatLayer) {
                    seatLayer.hidden = NO;
                } else {
                    seatLayer = [self.svgImage newCALayerTree];
                    [self.seatlayerMap setObject:seatLayer forKey:graphId];
                }
                [seatLayer setValue:graphId forKey:@"graphId"];
                seatLayer.frame = frame;
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
    NSArray<CALayer *> *seatlayers = [self.seatlayers allObjects];
    [seatlayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.seatlayers removeAllObjects];
    self.drawed = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    NSArray<CALayer *> *sublayers = [self.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if (CGRectContainsPoint(layer.frame, point)) {
            NSString *graphId = [layer valueForKey:@"graphId"];
            NSLog(@"graphId %@", graphId);
            break;
        }
    }
}
@end
