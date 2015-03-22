//
//  CircleLayout.m
//  WaterFlowLayout
//
//  Created by mac on 15/3/21.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "StackLayout.h"

@interface StackLayout ()

@property (nonatomic,strong) NSMutableArray *attributes;

@property (nonatomic,assign) CGFloat itemAngle;

@property (nonatomic,assign) CGSize itemSize;

@property (nonatomic,assign) CGPoint itemCenter;

@property (nonatomic,assign) NSInteger bottomItemZIndex;

@end

@implementation StackLayout

- (instancetype)init {
    if ( self = [super init] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealTouch:) name:@"hello" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)attributes{
    if (_attributes == nil) {
        _attributes = [[NSMutableArray alloc]init];
    }
    return _attributes;
}

- (void)prepareLayout {
    [super prepareLayout];
    if ( self.attributes.count > 0 ) return;
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    self.itemAngle = M_PI * 2 / count;
    CGFloat itemWH = self.collectionView.bounds.size.height * 0.6;
    self.itemSize = CGSizeMake(itemWH, itemWH);
    self.itemCenter = CGPointMake(self.collectionView.bounds.size.width * 0.5, self.collectionView.bounds.size.height * 0.5);
    for (NSInteger i = 0; i < count; i++) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attributes addObject:attr];
    }
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.attributes.count == [self.collectionView numberOfItemsInSection:0] ) return nil;
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.center = self.itemCenter;
    attr.frame = CGRectMake(0, 0, self.itemSize.width, self.itemSize.height);
    attr.center = self.itemCenter;
    attr.transform = CGAffineTransformMakeRotation(self.itemAngle * indexPath.item);
    attr.zIndex = indexPath.item;
    return attr;
}

#pragma mark - 手势处理函数
- (void)dealTouch:(NSNotification *)noti{
    NSIndexPath *indexPath = noti.userInfo[@"indexPath"];
    UICollectionViewLayoutAttributes *attrs = self.attributes[indexPath.item];
    attrs.zIndex = self.bottomItemZIndex--;
    attrs.center = self.itemCenter;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];

}

@end
