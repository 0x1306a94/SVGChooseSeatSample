//
//  KKYuntuSeatItemModel.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import "KKYuntuSeatItemModel.h"

@implementation KKYuntuSeatItemModel

@synthesize uniqueIdentifier = _uniqueIdentifier;
- (instancetype)init {
    if (self == [super init]) {
        _uniqueIdentifier = 0;
    }
    return self;
}

- (NSString *)graphId {
    return [NSString stringWithFormat:@"graphId-%ld-%ld", self.graphcol, self.graphrow];
}

//- (NSInteger)uniqueIdentifier {
//    NSInteger col = (self.graphcol & 0xFFFF);
//    NSInteger row = (self.graphrow & 0xFFFF) << GRAPH_ROW_SHIFT;
//    NSInteger value = col | row | (1UL << GRAPH_SELECT_SHIFT);
//    return value;
//}

- (void)setGraphcol:(NSInteger)graphcol {
    _graphcol = graphcol;
    _uniqueIdentifier |= (graphcol & 0xFFFF);
}

- (void)setGraphrow:(NSInteger)graphrow {
    _graphrow = graphrow;
    _uniqueIdentifier |= ((graphrow & 0xFFFF) << GRAPH_ROW_SHIFT);
}

- (void)updateSelected:(BOOL)selected {
    if (selected) {
        _uniqueIdentifier |= (1UL << GRAPH_SELECT_SHIFT);
    } else {
        _uniqueIdentifier &= ~(1UL << GRAPH_SELECT_SHIFT);
    }
}
@end
