//
//  KKRawSeatItem.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKRawSeatItem : NSObject
@property (nonatomic, strong) NSString *seatId;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) NSInteger i;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, assign) NSInteger groupPriceId;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, assign) NSInteger seatPriceId;
@property (nonatomic, strong) NSString *seatName;
@property (nonatomic, strong) NSString *areaName;
@end

NS_ASSUME_NONNULL_END
