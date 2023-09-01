//
//  KKYuntuSeatItemModel.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import "KKYuntuSeatItemModel.h"

@implementation KKYuntuSeatItemModel

- (NSString *)graphId {
    return [NSString stringWithFormat:@"graphId-%ld-%ld", self.graphcol, self.graphrow];
}
@end
