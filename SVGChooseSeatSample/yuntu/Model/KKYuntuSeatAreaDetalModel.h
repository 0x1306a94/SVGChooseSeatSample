//
//  KKYuntuSeatAreaDetalModel.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import <Foundation/Foundation.h>

#import "KKYuntuSeatGraphGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@class KKYuntuSeatAreaModel;
@class KKYuntuSeatItemModel;

@interface KKYuntuSeatAreaDetalModel : NSObject
/// 区域唯一标识
@property (nonatomic, copy) NSString *regioncode;
@property (nonatomic, assign, readonly) KKYuntuSeatGraphRect graphRect;
@property (nonatomic, assign) KKYuntuSeatGraphPoint graphMin;
@property (nonatomic, assign) KKYuntuSeatGraphPoint graphMax;
@property (nonatomic, strong) NSMutableArray<KKYuntuSeatItemModel *> *seats;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *status;
@end

NS_ASSUME_NONNULL_END
