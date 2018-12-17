//
//  DragPhotoTableView.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DragPhotoTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

//当前方图数组（指针指向controller的squareCurrArray）
@property (nonatomic, strong) NSMutableArray *squareCurrArray;

//当前长图数组（指针指向controller的squareCurrArray）
@property (nonatomic, strong) NSMutableArray *longCurrArray;

@end

NS_ASSUME_NONNULL_END
