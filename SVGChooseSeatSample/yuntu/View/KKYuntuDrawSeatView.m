//
//  KKYuntuDrawSeatView.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import "KKYuntuDrawSeatView.h"

#import "CALayer+Bitmap.h"
#import "KKYuntuSeatAreaDetalModel.h"
#import "KKYuntuSeatGraphGeometry.h"
#import "KKYuntuSeatItemModel.h"
#import "NSBundle+SVGResources.h"
#import "SVGKImage+ChangeStyle.h"
#import "UIColor+KKHexString.h"

@import SVGKit;

static NSString *const KKSeatLayerGraphIdKey = @"kk_graphId";
static NSString *const KKSeatLayerUniqueIdentifierKey = @"kk_uniqueIdentifier";

typedef struct {
    struct {
        char status : 4;
        char selected : 1;
        char reserve : 3;
    } flag;
} SeatBitmapKey;

int seat_bitmap_key_value_whit(NSInteger status, BOOL selected) {
    SeatBitmapKey key;
    memset(&key, 0, sizeof(SeatBitmapKey));
    key.flag.status = (char)status;
    key.flag.selected = selected;
    int value = 0;
    memcpy(&value, &key, sizeof(key.flag));
    return value;
}

@interface KKYuntuDrawSeatView ()
@property (nonatomic, strong) NSMapTable<NSNumber *, KKYuntuSeatItemModel *> *seatItemMap;
@property (nonatomic, strong) NSMapTable<NSNumber *, CALayer *> *seatlayerMap;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, SVGKImage *> *svgImageCache;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *svgBitmapCache;
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

    self.gridSize = CGSizeMake(38, 38);
    self.gapSize = CGSizeMake(10, 10);
    self.contentInset = UIEdgeInsetsMake(100, 100, 100, 100);
    _drawScale = 1.0;

    self.seatItemMap = [NSMapTable<NSNumber *, KKYuntuSeatItemModel *> strongToWeakObjectsMapTable];
    self.seatlayerMap = [NSMapTable<NSNumber *, CALayer *> strongToStrongObjectsMapTable];
    self.svgImageCache = [NSMutableDictionary<NSNumber *, SVGKImage *> dictionaryWithCapacity:10];
    self.svgBitmapCache = [NSMutableDictionary<NSNumber *, UIImage *> dictionaryWithCapacity:10];

    [self updateSvgImage];
}

- (void)updateSvgImage {
    CGSize size = CGSizeApplyAffineTransform(self.gridSize, CGAffineTransformMakeScale(self.drawScale, self.drawScale));
    NSBundle *svgBundle = [NSBundle kk_SVGResources];

    [self.svgImageCache removeAllObjects];
    [self.svgBitmapCache removeAllObjects];

    self.selectedSvgImage = [SVGKImage imageNamed:@"icon_chooseSeat_selected" inBundle:svgBundle];
    [self.selectedSvgImage scaleToFitInside:size];

    do {
        NSNumber *key = @(seat_bitmap_key_value_whit(0, NO));
        SVGKImage *image = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:svgBundle withCacheKey:key.stringValue];
        [image scaleToFitInside:size];
        [image kk_changeFillColor:@"#ccc" strokeColor:@"#666"];
        self.svgImageCache[key] = image;
    } while (0);

    do {
        NSNumber *key = @(seat_bitmap_key_value_whit(1, NO));
        SVGKImage *image = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:svgBundle withCacheKey:key.stringValue];
        [image scaleToFitInside:size];
        self.svgImageCache[key] = image;
    } while (0);

    do {
        NSNumber *key = @(seat_bitmap_key_value_whit(1, YES));
        SVGKImage *image = [SVGKImage imageNamed:@"icon_chooseSeat_selected" inBundle:svgBundle withCacheKey:key.stringValue];
        [image scaleToFitInside:size];
        self.svgImageCache[key] = image;
    } while (0);

    do {
        NSNumber *key = @(seat_bitmap_key_value_whit(2, NO));
        SVGKImage *image = [SVGKImage imageNamed:@"icon_chooseSeat_canSelected" inBundle:svgBundle withCacheKey:key.stringValue];
        [image scaleToFitInside:size];
        self.svgImageCache[key] = image;
    } while (0);

    asm("nop");
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

    NSArray<KKYuntuSeatItemModel *> *seats = [self.seatArea.seats copy];
    do {
        if (seats.count == 0) {
            break;
        }
        // 避免放大后不清晰
        CGFloat bitmapScale = UIScreen.mainScreen.scale * 2;

        CGFloat drawScale = self.drawScale;
        CGAffineTransform transform = CGAffineTransformMakeScale(drawScale, drawScale);
        CGSize gridSize = CGSizeApplyAffineTransform(self.gridSize, transform);
        CGSize gapSize = CGSizeApplyAffineTransform(self.gapSize, transform);
        UIEdgeInsets contentInset = self.contentInset;
        for (KKYuntuSeatItemModel *seat in self.seatArea.seats) {
            NSInteger graphId = [seat graphId];
            NSInteger uniqueIdentifier = [seat uniqueIdentifier];
            CGRect frame = CGRectZero;
            frame.origin = CGPointMake(contentInset.left * drawScale + seat.graphCol * gapSize.width + seat.graphCol * gridSize.width,
                                       contentInset.top * drawScale + seat.graphRow * gapSize.height + seat.graphRow * gridSize.height);
            frame.size = gridSize;
            if (CGRectIntersectsRect(rect, frame)) {
                CALayer *seatLayer = [self.seatlayerMap objectForKey:@(uniqueIdentifier)];
                if (seatLayer == nil) {
                    NSNumber *key = @(seat_bitmap_key_value_whit(seat.status, [seat selected]));
                    UIImage *image = self.svgBitmapCache[key];
                    if (!image) {
                        SVGKImage *svgImage = self.svgImageCache[key];
                        __kindof CALayer *svgLayer = [svgImage newCALayerTree];
                        svgLayer.frame = frame;
                        image = [svgLayer kk_toImage:bitmapScale];
                        self.svgBitmapCache[key] = image;
                    }

                    seatLayer = [CALayer layer];
                    seatLayer.contents = (id)image.CGImage;
                    [self.seatlayerMap setObject:seatLayer forKey:@(uniqueIdentifier)];
                }

                [seatLayer setValue:@(graphId) forKey:KKSeatLayerGraphIdKey];
                [seatLayer setValue:@(uniqueIdentifier) forKey:KKSeatLayerUniqueIdentifierKey];
                seatLayer.frame = frame;
                [canvasLayer addSublayer:seatLayer];
            } else {
            }
        }
    } while (0);

    self.drawed = YES;
}

- (void)clearSeat {
    if (!self.drawed) {
        return;
    }
    NSArray<CALayer *> *seatlayers = [[self.layer sublayers] copy];
    [seatlayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.seatlayerMap removeAllObjects];
    self.drawed = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
#if 1
    NSArray<CALayer *> *sublayers = [self.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if (CGRectContainsPoint(layer.frame, point)) {
            NSInteger graphId = [[layer valueForKey:KKSeatLayerGraphIdKey] integerValue];
            KKYuntuSeatItemModel *seat = [self.seatItemMap objectForKey:@(graphId)];
            if (seat == nil) {
                break;
            }
            if (![seat canSelected]) {
                break;
            }
            BOOL selected = ![seat selected];
            [seat updateSelected:selected];

            NSInteger uniqueIdentifier = [seat uniqueIdentifier];

            NSLog(@"graphId %ld %ld", (graphId & GRAPH_COL_MASK), ((graphId & GRAPH_ROW_MASK) >> GRAPH_ROW_SHIFT));
            [layer removeFromSuperlayer];
            CALayer *newLayer = [self.seatlayerMap objectForKey:@(uniqueIdentifier)];
            if (newLayer == nil) {
                NSNumber *key = @(seat_bitmap_key_value_whit(seat.status, [seat selected]));
                UIImage *image = self.svgBitmapCache[key];
                if (!image) {
                    SVGKImage *svgImage = self.svgImageCache[key];
                    __kindof CALayer *svgLayer = [svgImage newCALayerTree];
                    svgLayer.frame = layer.frame;
                    CGFloat bitmapScale = UIScreen.mainScreen.scale * 2;
                    image = [svgLayer kk_toImage:bitmapScale];
                    self.svgBitmapCache[key] = image;
                }
                newLayer = [CALayer layer];
                newLayer.contents = (id)image.CGImage;
            }
            newLayer.frame = layer.frame;
            [newLayer setValue:@(graphId) forKey:KKSeatLayerGraphIdKey];
            [newLayer setValue:@(uniqueIdentifier) forKey:KKSeatLayerUniqueIdentifierKey];
            [self.seatlayerMap setObject:newLayer forKey:@(uniqueIdentifier)];
            [self.layer addSublayer:newLayer];
            break;
        }
    }
#else

    CALayer *canvasLayer = self.layer;
    NSArray<KKYuntuSeatItemModel *> *seats = [self.seatArea.seats copy];
    do {
        if (seats.count == 0) {
            break;
        }
        CGFloat drawScale = self.drawScale;
        CGAffineTransform transform = CGAffineTransformMakeScale(drawScale, drawScale);
        CGSize gridSize = CGSizeApplyAffineTransform(self.gridSize, transform);
        CGSize gapSize = CGSizeApplyAffineTransform(self.gapSize, transform);
        UIEdgeInsets contentInset = self.contentInset;
        for (KKYuntuSeatItemModel *seat in self.seatArea.seats) {
            NSInteger graphId = [seat graphId];
            CGRect frame = CGRectZero;
            frame.origin = CGPointMake(contentInset.left * drawScale + seat.graphCol * gapSize.width + seat.graphCol * gridSize.width,
                                       contentInset.top * drawScale + seat.graphRow * gapSize.height + seat.graphRow * gridSize.height);
            frame.size = gridSize;
            if (CGRectContainsPoint(frame, point)) {

                BOOL selected = ![seat selected];
                [seat updateSelected:selected];
                NSInteger uniqueIdentifier = [seat uniqueIdentifier];

                CALayer *seatLayer = [self.seatlayerMap objectForKey:@(uniqueIdentifier)];
                if (seatLayer == nil) {
                    [seatLayer removeFromSuperlayer];
                    [self.seatlayerMap removeObjectForKey:@(uniqueIdentifier)];

                    SVGKImage *svgImage = [seat selected] ? self.selectedSvgImage : self.svgImageCache[@(seat.status)];
                    seatLayer = [svgImage newCALayerTree];
                    [self.seatlayerMap setObject:seatLayer forKey:@(uniqueIdentifier)];
                }

                [seatLayer setValue:@(graphId) forKey:KKSeatLayerGraphIdKey];
                [seatLayer setValue:@(uniqueIdentifier) forKey:KKSeatLayerUniqueIdentifierKey];
                seatLayer.frame = frame;
                [canvasLayer addSublayer:seatLayer];
                break;
            } else {
            }
        }
    } while (0);
#endif
}

#pragma mark - setter
- (void)setDrawScale:(CGFloat)drawScale {
    if (_drawScale != drawScale) {
        _drawScale = drawScale;
        [self updateSvgImage];
        [self clearSeat];
    }
}
@end
