//
//  KKTradeSVGItemModel.m
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import "KKTradeSVGItemModel.h"

@implementation KKTradeSVGItemModel
- (instancetype)init {
    if (self == [super init]) {
        _pathRef = NULL;
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(_pathRef);
}

- (void)setPathRef:(CGPathRef)pathRef {
    if (_pathRef == pathRef) {
        return;
    }
    CGPathRelease(_pathRef);
    _pathRef = pathRef;
    CGPathRetain(_pathRef);
}
@end
