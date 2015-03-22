//
//  ScaleWaterFlowLayout.m
//  WaterFlowLayout
//
//  Created by mac on 15/3/20.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "ScaleWaterFlowLayout.h"

@implementation ScaleWaterFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat h = self.collectionView.bounds.size.height * 0.6;
    self.itemSize = CGSizeMake(h, h);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat inset = (self.collectionView.bounds.size.width - h ) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
}

/**
 * 返回collectionView上面所有元素（比如cell）的布局属性:这个方法决定了cell怎么排布
 * 每个cell都有自己对应的布局属性：UICollectionViewLayoutAttributes
 * 要求返回的数组中装着UICollectionViewLayoutAttributes对象
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    CGFloat centerX = self.collectionView.contentOffset.x + 0.5 * self.collectionView.bounds.size.width;
    for (UICollectionViewLayoutAttributes *item in attributes) {
        CGFloat delta = 1 - ABS(centerX - item.center.x) / (self.collectionView.bounds.size.width + self.itemSize.width );
        item.transform = CGAffineTransformMakeScale(delta, delta);
    }
    return attributes;
}

/**
 * 当uicollectionView的bounds发生改变时，是否要刷新布局
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

/**
 * targetContentOffset ：通过修改后，collectionView最终的contentOffset(取决定情况)
 * proposedContentOffset ：默认情况下，collectionView最终的contentOffset
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    // 计算最终的可见范围
    CGRect rect;
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;
    
    // 取得cell的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最终中间的x
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 计算最小的间距值
    CGFloat minDetal = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDetal) > ABS(attrs.center.x - centerX)) {
            minDetal = attrs.center.x - centerX;
        }
    }
    
    // 在原有offset的基础上进行微调
    return CGPointMake(proposedContentOffset.x + minDetal, proposedContentOffset.y);
}

@end
