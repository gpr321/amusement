//
//  WaterFlowLayout.m
//  WaterFlowLayout
//
//  Created by mac on 15/3/22.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "WaterFlowLayout.h"

static UIEdgeInsets defaultInset = {10, 10, 10, 10};
static CGFloat defaultRowMargin = 10;
static CGFloat defaultColumnMargin = 10;
static NSInteger defaultColumn = 3;

@interface WaterFlowLayout ()

@property (nonatomic,strong) NSMutableArray *attributes;

@property (nonatomic,strong) NSMutableArray *columnsY;

@end

@implementation WaterFlowLayout

- (instancetype)init {
    if ( self = [super init] ) {
        WaterFlowLayoutSetting setting;
        setting.column = defaultColumn;
        setting.sectionInset = defaultInset;
        setting.rowMargin = defaultRowMargin;
        setting.columnMargin = defaultColumnMargin;
        self.setting = setting;
    }
    return self;
}

- (void)setSetting:(WaterFlowLayoutSetting)setting {
    _setting = setting;
    CGFloat width = (self.collectionView.bounds.size.width - (setting.column -1) * defaultRowMargin - (setting.sectionInset.left + setting.sectionInset.right)) / setting.column;
    _setting.itemWidth = width;
}

- (NSMutableArray *)attributes{
    if (_attributes == nil) {
        _attributes = [[NSMutableArray alloc]init];
    }
    return _attributes;
}

- (NSMutableArray *)columnsY{
    if (_columnsY == nil) {
        _columnsY = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < defaultColumn; i++) {
            [_columnsY addObject:@(defaultInset.top)];
        }
    }
    return _columnsY;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.setting = self.setting;
    [self.attributes removeAllObjects];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGFloat colunmY = [self.columnsY[0] floatValue];
    NSInteger index = 0;
    for (NSInteger i = 1; i < self.columnsY.count; i++) {
        if ( colunmY > [self.columnsY[i] floatValue] ) {
            colunmY = [self.columnsY[i] floatValue];
            index = i;
        }
    }
    CGFloat width = self.setting.itemWidth;
    CGFloat x = self.setting.sectionInset.left + width * index + index * self.setting.columnMargin;
    CGFloat rowMargin = colunmY == self.setting.sectionInset.top  ? 0 : self.setting.columnMargin;
    CGFloat y = colunmY + rowMargin;
    
    CGFloat height = [self itemHeightWithIndexPath:indexPath];
    attrs.frame = CGRectMake(x, y, width, height);
    self.columnsY[index] = @(CGRectGetMaxY(attrs.frame));
    return attrs;
}

- (CGSize)collectionViewContentSize {
    CGFloat colunmY = [self.columnsY[0] floatValue];
    for (NSInteger i = 1; i < self.columnsY.count; i++) {
        if ( colunmY < [self.columnsY[i] floatValue] ) {
            colunmY = [self.columnsY[i] floatValue];
        }
    }
    return CGSizeMake(0, colunmY + self.setting.rowMargin);
}

- (CGFloat)itemHeightWithIndexPath:(NSIndexPath *)indexPath{
    NSAssert( [self.delegate respondsToSelector:@selector(waterFlowLayout:heightForRowAtIndexPath:)] , @"代理必须实现 waterFlowLayout:heightForRowAtIndexPath: 该方法");
    return [self.delegate waterFlowLayout:self heightForRowAtIndexPath:indexPath];
}

@end
