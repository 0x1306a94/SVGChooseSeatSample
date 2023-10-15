//
//  KKYuntuSeatItemModel.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define GRAPH_COL_SHIFT 0
#define GRAPH_COL_MASK 0xFFFF
#define GRAPH_ROW_SHIFT 16
#define GRAPH_ROW_MASK 0xFFFF0000
#define GRAPH_SELECT_SHIFT 32
#define GRAPH_SELECT_MASK 0x100000000

@interface KKYuntuSeatItemModel : NSObject
/// 区域唯一标识
@property (nonatomic, copy) NSString *regioncode;
@property (nonatomic, assign) NSInteger graphRow;
@property (nonatomic, assign) NSInteger graphCol;
@property (nonatomic, assign) NSInteger seatRow;
@property (nonatomic, assign) NSInteger seatCol;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *color;

@property (nonatomic, assign, readonly) NSInteger graphId;

@property (nonatomic, assign, readonly) NSInteger uniqueIdentifier;

- (void)updateSelected:(BOOL)selected;

- (BOOL)canSelected;
- (BOOL)selected;
@end

NS_ASSUME_NONNULL_END
