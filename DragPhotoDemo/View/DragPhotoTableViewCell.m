//
//  DragPhotoTableViewCell.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "DragPhotoTableViewCell.h"
#import "Masonry.h"

@implementation DragPhotoTableViewCell

#pragma mark -
#pragma mark - life cycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self _initView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


#pragma mark -
#pragma mark - private methods
- (void)_initView{
    [self.contentView setBackgroundColor: [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1]];
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.lineView];
    [self.bgView addSubview:self.leftLabel];
    [self.bgView addSubview:self.rightLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(15);
        make.left.equalTo(self.bgView.mas_left).offset(15);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftLabel.mas_top);
        make.right.equalTo(self.bgView.mas_right).offset(-15);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel.mas_left);
        make.top.greaterThanOrEqualTo(self.leftLabel.mas_bottom).offset(15);
        make.top.equalTo(self.rightLabel.mas_bottom).offset(15);
        make.bottom.equalTo(self.bgView.mas_bottom);
        make.right.equalTo(self.bgView.mas_right);
        make.height.equalTo(@1);
    }];
}


#pragma mark -
#pragma mark - getters and setters
- (UIView *)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}
- (UIView *)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
    }
    return _lineView;
}
- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.font = [UIFont systemFontOfSize:14];
    }
    return _leftLabel;
}
- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1];
        _rightLabel.textAlignment = NSTextAlignmentLeft;
        _rightLabel.font = [UIFont systemFontOfSize:14];
    }
    return _rightLabel;
}

@end
