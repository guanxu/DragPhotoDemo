//
//  DragPhotoDeleteView.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, DeleteViewStatus){
    DeleteViewStatusPrompt = 0,       //提示删除
    DeleteViewStatusDelete            //删除
};

@interface DragPhotoDeleteView : UIView

@property (nonatomic,strong) UIImageView *iconImageView;

@property (nonatomic,strong) UILabel *textLabel;

- (void)changeStatus:(DeleteViewStatus)status;

@end

NS_ASSUME_NONNULL_END
