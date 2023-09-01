//
//  KKYuntuSeatAreaDetalModel.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import "KKYuntuSeatAreaDetalModel.h"

@implementation KKYuntuSeatAreaDetalModel
- (instancetype)init {
    if (self == [super init]) {
        self.graphMin = (KKYuntuSeatGraphPoint){NSIntegerMax, NSIntegerMax};
        self.graphMax = (KKYuntuSeatGraphPoint){NSIntegerMin, NSIntegerMin};
        self.seats = [NSMutableArray<KKYuntuSeatItemModel *> arrayWithCapacity:20];
        self.status = [NSMutableDictionary<NSString *, NSNumber *> dictionaryWithCapacity:20];
    }
    return self;
}

- (KKYuntuSeatGraphRect)graphRect {
    NSInteger minX = self.graphMin.x, maxX = self.graphMax.x;
    NSInteger minY = self.graphMin.y, maxY = self.graphMax.y;
    KKYuntuSeatGraphRect rect = (KKYuntuSeatGraphRect){minX, minY, maxX - minX, maxY - minY};
    return rect;
}
@end
