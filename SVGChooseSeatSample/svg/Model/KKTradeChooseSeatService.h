//
//  KKTradeChooseSeatService.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class KKSeatItem;

@interface KKTradeChooseSeatService : NSObject
+ (NSDictionary *)getDecodeSeatList:(NSDictionary *)seatList;
@end

NS_ASSUME_NONNULL_END
