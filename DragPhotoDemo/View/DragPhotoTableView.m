//
//  DragPhotoTableView.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "DragPhotoTableView.h"
#import "DragPhotoTableViewCell.h"
#import "Masonry.h"

static NSString *cellIdentifier = @"DragPhotoTableViewCell";

@implementation DragPhotoTableView

#pragma mark -
#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerClass:[DragPhotoTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        self.tableFooterView = nil;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}


#pragma mark -
#pragma mark - private methods
- (CGFloat)_calSquareCollectionViewHeight{
    
    //行数(先要让cout成为kItemCount的倍数 才能计算)
    NSInteger arrCount = self.squareCurrArray.count != 0 ? self.squareCurrArray.count : 1 ;
    NSInteger finalTotal = arrCount%kItemCount;
    NSInteger finalCount = arrCount;
    if(finalTotal != 0){
        finalCount = arrCount+(kItemCount-finalTotal);
    }
    NSInteger rowNum = finalCount%kItemCount + finalCount/kItemCount;
    
    return 15*(rowNum+1) + kSingleItemHeight*rowNum;
}
- (CGFloat)_calLongCollectionViewHeight{
    
    //行数(先要让cout成为kItemCount的倍数 才能计算)
    NSInteger arrCount = self.longCurrArray.count != 0 ? self.longCurrArray.count : 1 ;
    NSInteger finalTotal = arrCount%kItemCount;
    NSInteger finalCount = arrCount;
    if(finalTotal != 0){
        finalCount = arrCount+(kItemCount-finalTotal);
    }
    NSInteger rowNum = finalCount%kItemCount + finalCount/kItemCount;
    
    return 15*(rowNum+1) + kSingleItemHeight*rowNum;
}


#pragma mark -
#pragma mark - delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DragPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.lineView.hidden = NO;
    
    switch (indexPath.row) {
        case 0:
            cell.leftLabel.text = @"商品编号";
            break;
        case 1:
            cell.leftLabel.text = @"商品名称";
            break;
        case 2:
            cell.leftLabel.text = @"商品品牌";
            break;
        case 3:
            cell.leftLabel.text = @"商品分类";
            cell.lineView.hidden = YES;
            break;
        case 4:
            cell.bgView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
            cell.leftLabel.text = @"方图";
            cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 5:
            cell.leftLabel.text = cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 6:
            cell.bgView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
            cell.leftLabel.text = @"长图";
            cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 7:
            cell.leftLabel.text = cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 8:
            cell.bgView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
            cell.leftLabel.text = @"透明图";
            cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 9:
            cell.leftLabel.text = cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
        case 10:
            //占位 防止删除区域弹出时遮挡透明图
            cell.bgView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
            cell.leftLabel.text = cell.rightLabel.text = @"";
            cell.lineView.hidden = YES;
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 44.f;
            break;
        case 1:
            return 44.f;
            break;
        case 3:
            return 44.f;
            break;
        case 4:
        case 6:
        case 8:
            return 40.f;
            break;
        case 5:
            return [self _calSquareCollectionViewHeight];
            break;
        case 7:
            return [self _calLongCollectionViewHeight];
            break;
        case 9:
            return 135.f;
            break;
        case 10:
            return 48.f;
            break;
        default:
            return 44.f;
            break;
    }
}

@end
