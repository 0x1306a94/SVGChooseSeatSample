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

- (NSInteger)graphId {
    NSInteger col = (self.graphCol & 0xFFFF);
    NSInteger row = (self.graphRow & 0xFFFF) << GRAPH_ROW_SHIFT;
    NSInteger value = col | row;
    return value;
}

- (void)setGraphCol:(NSInteger)graphCol {
    _graphCol = graphCol;
    _uniqueIdentifier |= (graphCol & 0xFFFF);
}

- (void)setGraphRow:(NSInteger)graphRow {
    _graphRow = graphRow;
    _uniqueIdentifier |= ((graphRow & 0xFFFF) << GRAPH_ROW_SHIFT);
}

- (void)updateSelected:(BOOL)selected {
    if (selected) {
        _uniqueIdentifier |= (1UL << GRAPH_SELECT_SHIFT);
    } else {
        _uniqueIdentifier &= ~(1UL << GRAPH_SELECT_SHIFT);
    }
}

- (BOOL)canSelected {
    return self.status == 1;
}

- (BOOL)selected {
    return (_uniqueIdentifier & GRAPH_SELECT_MASK) == GRAPH_SELECT_MASK;
}
@end
