//
//  ViewController.h
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragPhotoTableView.h"
#import "ImageModel.h"

typedef enum{
    RTSnapshotMeetsEdgeTop,
    RTSnapshotMeetsEdgeBottom,
}RTSnapshotMeetsEdge;

@interface ViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

//当前方图数组 存储JDMCommodityCoverSkuImageUrlModel对象 (编辑状态下添加imageurl为“+”的对象,查看状态需移除)
@property (nonatomic, strong) NSMutableArray *squareCurrArray;

//当前长图数组 存储JDMCommodityCoverSkuImageUrlModel对象 (编辑状态下添加imageurl为“+”的对象,查看状态需移除)
@property (nonatomic, strong) NSMutableArray *longCurrArray;

//当前透明图数组
@property (nonatomic, strong) NSMutableArray *lucencyCurrArray;

@property (nonatomic, strong) DragPhotoTableView *tableView;

@end

