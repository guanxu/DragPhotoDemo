//
//  DragPhotoDeleteView.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "DragPhotoDeleteView.h"
#import "Masonry.h"

@implementation DragPhotoDeleteView

#pragma mark -
#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:90/255.f blue:73/255.f alpha:1];
        [self _initView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}


#pragma mark -
#pragma mark - private methods
- (void)_initView{
    [self addSubview:self.iconImageView];
    [self addSubview:self.textLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(5);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@18);
        make.height.equalTo(@18);
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(3);
        make.centerX.equalTo(self.mas_centerX);
    }];
}


#pragma mark -
#pragma mark - public methods
- (void)changeStatus:(DeleteViewStatus)status{
    if(status == DeleteViewStatusPrompt){
        //提示删除
        [self.iconImageView setImage:[UIImage imageNamed:@"commodity_delete"]];
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:90/255.f blue:73/255.f alpha:1];
        self.textLabel.text = @"拖动到此处删除";
    }else{
        //删除
        [self.iconImageView setImage:[UIImage imageNamed:@"commodity_delete_open"]];
        self.backgroundColor = [UIColor colorWithRed:217/255.f green:70/255.f blue:53/255.f alpha:1];
        self.textLabel.text = @"松手即可删除";
    }
}


#pragma mark -
#pragma mark - getters and setters
- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.text = @"拖动到此处删除";
    }
    return _textLabel;
}
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"commodity_delete"];
    }
    return _iconImageView;
}

@end
