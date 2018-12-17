//
//  DragPhotoCollectionViewCell.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "DragPhotoCollectionViewCell.h"
#import "Masonry.h"

@implementation DragPhotoCollectionViewCell

#pragma mark -
#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initCellView];
    }
    return self;
}


#pragma mark -
#pragma mark - private methods
- (void)_initCellView{
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.placeholderImageView];
    [self.contentView addSubview:self.mainView];
    [self.contentView addSubview:self.mainLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(self.contentView.mas_height);
    }];
    [self.placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_top);
        make.left.equalTo(self.iconImageView.mas_left);
        make.width.equalTo(self.iconImageView.mas_width);
        make.height.equalTo(self.iconImageView.mas_height);
    }];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_left);
        make.right.equalTo(self.iconImageView.mas_right);
        make.bottom.equalTo(self.iconImageView.mas_bottom);
        make.height.equalTo(@30);
    }];
    [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.left.equalTo(self.mainView.mas_left);
        make.width.equalTo(self.mainView.mas_width);
        make.height.equalTo(self.mainView.mas_height);
    }];
    self.contentView.backgroundColor = [UIColor whiteColor];
}


#pragma mark -
#pragma mark - getters and setters
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}
- (UIImageView *)placeholderImageView{
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_placeholderImageView setImage:[UIImage imageNamed:@"pic_add.png"]];
        _placeholderImageView.alpha = 0.f;
    }
    return _placeholderImageView;
}
- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = [UIColor colorWithRed:28/255.f green:139/255.f blue:236/255.f alpha:1];
        _mainView.alpha = 0.f;
    }
    return _mainView;
}
- (UILabel *)mainLabel{
    if (!_mainLabel) {
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainLabel.textColor = [UIColor whiteColor];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        _mainLabel.font = [UIFont systemFontOfSize:13];
        _mainLabel.text = @"主图";
        _mainLabel.alpha = 0.f;
    }
    return _mainLabel;
}

@end
