//
//  ImageModel.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageModel : NSObject

@property (nonatomic, copy) NSString *isprimary;      //0：否 1：是 是否主图

@property (nonatomic, copy) NSString *position;       //从0开始，0是主图，后面依次

@property (nonatomic, copy) NSString *imageurl;       //缩略图地址

@property (nonatomic, copy) NSString *bigimageurl;    //原图地址

@end

NS_ASSUME_NONNULL_END
