//
//  KKYuntuSeatItemModel.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKYuntuSeatItemModel : NSObject
/// 区域唯一标识
@property (nonatomic, copy) NSString *regioncode;
@property (nonatomic, assign) NSInteger graphrow;
@property (nonatomic, assign) NSInteger graphcol;
@property (nonatomic, assign) NSInteger seatrow;
@property (nonatomic, assign) NSInteger seatcol;
@property (nonatomic, copy) NSString *color;

@property (nonatomic, copy, readonly) NSString *graphId;
@end

NS_ASSUME_NONNULL_END
