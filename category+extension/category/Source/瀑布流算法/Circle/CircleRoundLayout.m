//
//  CircleRoundLayout.m
//  WaterFlowLayout
//
//  Created by mac on 15/3/21.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "CircleRoundLayout.h"

@interface CircleRoundLayout()

@property (nonatomic,strong) NSArray *attributes;

@property (nonatomic,assign) CGSize itemSize;

@property (nonatomic,assign) CGFloat itemRadius;

@property (nonatomic,assign) CGFloat itemAngel;

@property (nonatomic,assign) CGPoint photoCenter;

@end

@implementation CircleRoundLayout

- (void)prepareLayout {
    [super prepareLayout];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    CGFloat itemWH = self.collectionView.bounds.size.height * 0.2;
    self.itemSize = CGSizeMake(itemWH, itemWH);
    self.itemRadius = self.collectionView.bounds.size.height * 0.5 - 0.5 * itemWH;
    self.itemAngel = M_PI * 2 / count;
    self.photoCenter = CGPointMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    self.attributes = [attributes copy];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = CGRectMake(0, 0, self.itemSize.width, self.itemSize.height);
    CGFloat angel = self.startAngel + indexPath.item * self.itemAngel;
    CGFloat centerX = 0.5 * self.collectionView.bounds.size.width - cosf(angel) * self.itemRadius;
    CGFloat centerY = 0.5 * self.collectionView.bounds.size.height - sin(angel) * self.itemRadius;
    attrs.center = CGPointMake(centerX, centerY);
    attrs.zIndex = indexPath.item;
    return attrs;
}

@end
