//
//  DragPhotoCollectionViewCell.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DragPhotoCollectionViewCell : UICollectionViewCell

//缩略图
@property (nonatomic, strong) UIImageView *iconImageView;
//透明图 拖拽时 显示添加占位图片
@property (nonatomic, strong) UIImageView *placeholderImageView;
//主图标识
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UILabel *mainLabel;

@end

NS_ASSUME_NONNULL_END
