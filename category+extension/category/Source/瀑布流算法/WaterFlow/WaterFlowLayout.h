//
//  WaterFlowLayout.h
//  WaterFlowLayout
//
//  Created by mac on 15/3/22.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WaterFlowLayout;

typedef struct{
    NSInteger column;               // 列数,默认为3
    UIEdgeInsets sectionInset;      // 组内边距 ,默认为 {10, 10, 10, 10}
    CGFloat rowMargin;              // 行的间距, 默认为10
    CGFloat columnMargin;           // 列的间距, 默认为10
    CGFloat itemWidth;              // 宽度
}WaterFlowLayoutSetting;

@protocol WaterFlowLayoutDelegate <NSObject>
@required
- (CGFloat)waterFlowLayout:(WaterFlowLayout *)layout heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface WaterFlowLayout : UICollectionViewLayout

/** 该布局的配置参数 */
@property (nonatomic,assign) WaterFlowLayoutSetting setting;

@property (nonatomic,weak) id<WaterFlowLayoutDelegate> delegate;

@end
