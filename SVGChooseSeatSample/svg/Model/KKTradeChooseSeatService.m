//
//  KKTradeChooseSeatService.m
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import "KKTradeChooseSeatService.h"

#import "KKRawSeatItem.h"
#import "KKSeatItem.h"

#import <CoreGraphics/CGGeometry.h>

@implementation KKTradeChooseSeatService

// 假设 a3 是原始的座位数据字典 (e.g., from network)
+ (NSDictionary *)getDecodeSeatList:(NSDictionary *)rawSeatListDic {

    // v25 对应 rawSeatListDic
    // 创建一个可变字典来存储最终结果
    NSMutableDictionary *processedSeatListDict = [[NSMutableDictionary alloc] init];  // v26

    // 获取所有区域的 key (e.g., "A区", "B区"...)
    NSArray *areaKeys = [rawSeatListDic allKeys];  // obj

    // 遍历所有区域的 key
    for (NSString *areaKey in areaKeys) {  // 外层循环

        // v31 对应 areaKey

        // 创建一个可变数组来存储该区域的座位
        NSMutableArray *seatsForArea = [[NSMutableArray alloc] init];  // v32

        // 获取该区域的原始座位数据数组
        NSArray *rawSeats = [rawSeatListDic objectForKey:areaKey];  // v4

        // 遍历该区域的每个原始座位数据
        for (KKRawSeatItem *rawSeatData in rawSeats) {  // 内层循环

            // v6 对应 rawSeatData

            // 创建一个自动释放池，用于处理每次循环中的临时对象
            @autoreleasepool {

                // 创建一个新的 SeatItem 实例
                KKSeatItem *seatItem = [[KKSeatItem alloc] init];  // v7

                // 设置座位状态，默认可能为8
                [seatItem setState:8];

                // 从原始数据中设置 seatId
                [seatItem setSeatId:[rawSeatData seatId]];

                // 从原始数据中设置 angle
                [seatItem setAngle:[rawSeatData angle]];

                // 从原始数据中设置 index
                [seatItem setIndex:[rawSeatData i]];

                // 从原始数据中获取 x 和 y 坐标
                CGFloat x = [rawSeatData x];  // v8
                CGFloat y = [rawSeatData y];  // v9

                // 设置位置 (location) 和原始位置 (origLocation)
                [seatItem setLocation:CGPointMake(x, y)];
                [seatItem setOrigLocation:CGPointMake(x, y)];

                // 如果是团体座位，设置相关信息
                if ([rawSeatData groupId] >= 1) {
                    [seatItem setIsGroup:YES];
                    [seatItem setGroupId:[rawSeatData groupId]];
                    [seatItem setGroupPriceId:[rawSeatData groupPriceId]];

                    // 将 groupPriceId 转换为字符串并设置
                    NSNumber *groupPriceIdNumber = @([rawSeatData groupPriceId]);  // v12
                    [seatItem setGroupPriceIdStr:[NSString stringWithFormat:@"%@", groupPriceIdNumber]];
                }

                // 设置 floorName
                [seatItem setFloorName:[rawSeatData floorName]];

                // 设置 seatPriceId
                [seatItem setSeatPriceId:[rawSeatData seatPriceId]];

                // 将 seatPriceId 转换为字符串并设置
                NSNumber *seatPriceIdNumber = @([rawSeatData seatPriceId]);  // v15
                [seatItem setPriceIdStr:[NSString stringWithFormat:@"%@", seatPriceIdNumber]];

                // 设置 areaId
                [seatItem setAreaId:[NSString stringWithFormat:@"%@", areaKey]];

                // 设置 seatName
                [seatItem setSeatName:[rawSeatData seatName]];

                // 设置 areaName
                [seatItem setAreaName:[rawSeatData areaName]];

                // 设置 rowNo (可能与 areaName 相同)
                [seatItem setRowNo:[rawSeatData areaName]];

                // 将新创建的 SeatItem 对象添加到数组
                [seatsForArea addObject:seatItem];
            }
        }

        // 将该区域的座位数组存入结果字典
        [processedSeatListDict setValue:seatsForArea forKey:areaKey];
    }

    // 返回最终结果字典
    return processedSeatListDict;
}
@end
