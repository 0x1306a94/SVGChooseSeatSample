//
//  KKYuntuSeatDataManager.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KKYuntuSeatAreaModel;
@class KKYuntuSeatItemModel;
@class KKYuntuSeatAreaDetalModel;

@interface KKYuntuSeatDataManager : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithAreas:(NSArray<KKYuntuSeatAreaModel *> *)areas seats:(NSArray<KKYuntuSeatItemModel *> *)seats NS_DESIGNATED_INITIALIZER;

- (void)rebuildSeatData;

- (NSArray<KKYuntuSeatAreaModel*> *)originAreas;

- (KKYuntuSeatAreaDetalModel *_Nullable)seatAreaDetalAtRegionCode:(NSString *)regioncode;
@end

NS_ASSUME_NONNULL_END
