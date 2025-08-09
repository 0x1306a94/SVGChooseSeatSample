//
//  KKYuntuSeatAreaModel.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 座位区域
@interface KKYuntuSeatAreaModel : NSObject
@property (nonatomic, copy) NSString *hallcode;
/// 区域唯一标识
@property (nonatomic, copy) NSString *regioncode;
@property (nonatomic, copy) NSString *floorcode;
@property (nonatomic, copy) NSString *shape;
@property (nonatomic, copy) NSString *shapestyle;
@property (nonatomic, copy) NSString *nstyle;
@property (nonatomic, copy) NSString *nstyle2;
@property (nonatomic, copy) NSString *fzzstyle;
@property (nonatomic, copy) NSString *color;
@end

NS_ASSUME_NONNULL_END
