//
//  DragPhotoTableViewCell.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DragPhotoTableViewCell : UITableViewCell

//背景
@property (nonatomic, strong) UIView *bgView;

//横线
@property (nonatomic, strong) UIView *lineView;

//label
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end

NS_ASSUME_NONNULL_END
