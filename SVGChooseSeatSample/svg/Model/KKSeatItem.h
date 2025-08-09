//
//  KKSeatItem.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKSeatItem : NSObject
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSString *seatId;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGPoint origLocation;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, assign) NSInteger groupPriceId;
@property (nonatomic, strong) NSString *groupPriceIdStr;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, assign) NSInteger seatPriceId;
@property (nonatomic, strong) NSString *priceIdStr;
@property (nonatomic, strong) NSString *areaId;
@property (nonatomic, strong) NSString *seatName;
@property (nonatomic, strong) NSString *areaName;
@property (nonatomic, strong) NSString *rowNo;
@end

NS_ASSUME_NONNULL_END
