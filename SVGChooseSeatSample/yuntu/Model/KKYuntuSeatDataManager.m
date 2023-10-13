//
//  KKYuntuSeatDataManager.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import "KKYuntuSeatDataManager.h"

#import "KKYuntuSeatAreaDetalModel.h"
#import "KKYuntuSeatAreaModel.h"
#import "KKYuntuSeatItemModel.h"

@interface KKYuntuSeatDataManager ()
@property (nonatomic, strong) NSDictionary<NSString *, KKYuntuSeatAreaModel *> *areaMaps;
@property (nonatomic, strong) NSArray<KKYuntuSeatItemModel *> *seats;

@property (nonatomic, strong) NSMutableDictionary<NSString *, KKYuntuSeatAreaDetalModel *> *allAreaMap;
@end

@implementation KKYuntuSeatDataManager
- (instancetype)initWithAreas:(NSArray<KKYuntuSeatAreaModel *> *)areas seats:(NSArray<KKYuntuSeatItemModel *> *)seats {
    if (self == [super init]) {
        NSMutableDictionary<NSString *, KKYuntuSeatAreaModel *> *areaMaps = [NSMutableDictionary<NSString *, KKYuntuSeatAreaModel *> dictionaryWithCapacity:areas.count];
        for (KKYuntuSeatAreaModel *area in areas) {
            areaMaps[area.regioncode] = area;
        }
        self.areaMaps = [areaMaps copy];
        self.seats = seats;
        self.allAreaMap = [NSMutableDictionary<NSString *, KKYuntuSeatAreaDetalModel *> dictionaryWithCapacity:areaMaps.count];
    }
    return self;
}

- (void)rebuildSeatData {

    for (KKYuntuSeatItemModel *seat in self.seats) {
        seat.regioncode = @"R1694234878897934338";
        KKYuntuSeatAreaDetalModel *deatl = self.allAreaMap[seat.regioncode];
        if (deatl == nil) {
            deatl = [KKYuntuSeatAreaDetalModel new];
            deatl.regioncode = seat.regioncode;
            self.allAreaMap[seat.regioncode] = deatl;
        }
        [deatl.seats addObject:seat];

        KKYuntuSeatGraphPoint graphMin = deatl.graphMin;
        KKYuntuSeatGraphPoint graphMax = deatl.graphMax;

        KKYuntuSeatGraphPoint seatPoint = (KKYuntuSeatGraphPoint){seat.graphCol, seat.graphRow};
        graphMin.x = MIN(graphMin.x, seatPoint.x);
        graphMin.y = MIN(graphMin.y, seatPoint.y);

        graphMax.x = MAX(graphMax.x, seatPoint.x);
        graphMax.y = MAX(graphMax.y, seatPoint.y);

        deatl.graphMin = graphMin;
        deatl.graphMax = graphMax;
    }

    asm("nop");
}

- (NSArray<KKYuntuSeatAreaModel *> *)originAreas {
    return self.areaMaps.allValues;
}

- (KKYuntuSeatAreaDetalModel *_Nullable)seatAreaDetalAtRegionCode:(NSString *)regioncode {
    KKYuntuSeatAreaDetalModel *area = self.allAreaMap[regioncode];
    return area;
}
@end
