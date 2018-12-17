//
//  ViewController.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "ViewController.h"
#import "DragPhotoDeleteView.h"
#import "DragPhotoCollectionViewCell.h"
#import "Masonry.h"
#import "SDVersion.h"

@interface ViewController ()

//方图
@property (nonatomic, strong) UICollectionView *squareCollectionView;
//长图
@property (nonatomic, strong) UICollectionView *longCollectionView;
//透明图
@property (nonatomic, strong) UICollectionView *lucencyCollectionView;
//已有方图行数
@property (nonatomic, assign) NSInteger squareRow;
//已有长图行数
@property (nonatomic, assign) NSInteger longRow;
//删除区域
@property (nonatomic, strong) DragPhotoDeleteView *deleteView;

//************************方图***************************//
//记录手指所在的位置
@property (nonatomic, assign) CGPoint squareFingerLocation;
//被选中的cell的新位置
@property (nonatomic, strong) NSIndexPath *squareRelocatedIndexPath;
//被选中的cell的原始位置
@property (nonatomic, strong) NSIndexPath *squareOriginalIndexPath;
//对被选中的cell的截图
@property (nonatomic, weak) UIView *squareSnapshot;
//自动滚动的方向
@property (nonatomic, assign) RTSnapshotMeetsEdge squareAutoScrollDirection;
//cell被拖动到边缘后开启，tableview自动向上或向下滚动
@property (nonatomic, strong) CADisplayLink *squareAutoScrollTimer;
//是否第一次长按
@property (nonatomic, assign) BOOL isSquareFirstTouch;
//当前长按的是否为不能移动的cell
@property (nonatomic, assign) BOOL isSquareBlankTouched;
//是否拖拽到删除区域
@property (nonatomic, assign) BOOL isSquareInDeleteArea;
//当前长按手势起始区域
@property (nonatomic, assign) BOOL isSquareAreaTouchBegin;

//************************长图***************************//
//记录手指所在的位置
@property (nonatomic, assign) CGPoint longFingerLocation;
//被选中的cell的新位置
@property (nonatomic, strong) NSIndexPath *longRelocatedIndexPath;
//被选中的cell的原始位置
@property (nonatomic, strong) NSIndexPath *longOriginalIndexPath;
//对被选中的cell的截图
@property (nonatomic, weak) UIView *longSnapshot;
//自动滚动的方向
@property (nonatomic, assign) RTSnapshotMeetsEdge longAutoScrollDirection;
//cell被拖动到边缘后开启，tableview自动向上或向下滚动
@property (nonatomic, strong) CADisplayLink *longAutoScrollTimer;
//是否第一次长按
@property (nonatomic, assign) BOOL isLongFirstTouch;
//当前长按的是否为不能移动的cell
@property (nonatomic, assign) BOOL isLongBlankTouched;
//是否拖拽到删除区域
@property (nonatomic, assign) BOOL isLongInDeleteArea;
//当前长按手势起始区域
@property (nonatomic, assign) BOOL isLongAreaTouchBegin;
//************************透明图***************************//
//记录手指所在的位置
@property (nonatomic, assign) CGPoint lucencyFingerLocation;
//被选中的cell的新位置
@property (nonatomic, strong) NSIndexPath *lucencyRelocatedIndexPath;
//被选中的cell的原始位置
@property (nonatomic, strong) NSIndexPath *lucencyOriginalIndexPath;
//对被选中的cell的截图
@property (nonatomic, weak) UIView *lucencySnapshot;
//自动滚动的方向
@property (nonatomic, assign) RTSnapshotMeetsEdge lucencyAutoScrollDirection;
//cell被拖动到边缘后开启，tableview自动向上或向下滚动
@property (nonatomic, strong) CADisplayLink *lucencyAutoScrollTimer;
//是否第一次长按
@property (nonatomic, assign) BOOL isLucencyFirstTouch;
//当前长按的是否为不能移动的cell
@property (nonatomic, assign) BOOL isLucencyBlankTouched;
//是否拖拽到删除区域
@property (nonatomic, assign) BOOL isLucencyInDeleteArea;
//当前长按手势起始区域
@property (nonatomic, assign) BOOL isLucencyAreaTouchBegin;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DragPhoto";
    
    //初始化
    [self _initData];
    [self _initUI];
    [self _initGesture];
    
    //增减cell可能导致行高变化 需重新计算
    [self _squareUpdateCurrCollectionViewHeight];
    [self _longUpdateCurrCollectionViewHeight];
    [self _layoutCollectionView];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark - event response
- (void)squareLongPressGestureRecognized:(id)sender{
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState longPressState = longPress.state;
    
    //手指在tableView中的位置
    _squareFingerLocation = [longPress locationInView:self.squareCollectionView];
    //手指按住位置对应的indexPath，可能为nil
    _squareRelocatedIndexPath = [self.squareCollectionView indexPathForItemAtPoint:_squareFingerLocation];
    //如果最后一个是占位符，不能移动
    if(_squareRelocatedIndexPath){
        NSInteger item = _squareRelocatedIndexPath.item;
        ImageModel *model = self.squareCurrArray[item];
        if([model.imageurl isEqualToString:BLANKIMG] && self.isSquareFirstTouch){
            self.isSquareFirstTouch = NO;
            
            //当开始按住的是+时
            if(longPressState == UIGestureRecognizerStateBegan){
                self.isSquareBlankTouched = YES;
            }
            return;
        }
        //长按cell时 删除区域显示
        [self _showDeleteView];
    }
    
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{  //手势开始，对被选中cell截图，隐藏原cell
            self.isSquareAreaTouchBegin = YES;
            _squareOriginalIndexPath = [self.squareCollectionView indexPathForItemAtPoint:_squareFingerLocation];
            if (_squareOriginalIndexPath) {
                [self _squareCellSelectedAtIndexPath:_squareOriginalIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
            if(self.isSquareBlankTouched){
                return;
            }
            //截图跟随手指移动
            CGPoint center = _squareSnapshot.center;
            center.y = _squareFingerLocation.y;
            center.x = _squareFingerLocation.x;
            _squareSnapshot.center = center;
            if ([self _squareCheckIfSnapshotMeetsEdge]) {
                [self _squareStartAutoScrollTimer];
            }else{
                [self _squareStopAutoScrollTimer];
            }
            //手指按住位置对应的indexPath，可能为nil
            _squareRelocatedIndexPath = [self.squareCollectionView indexPathForItemAtPoint:_squareFingerLocation];
            if (_squareRelocatedIndexPath && ![_squareRelocatedIndexPath isEqual:_squareOriginalIndexPath]) {
                NSInteger item = _squareRelocatedIndexPath.item;
                ImageModel *model = self.squareCurrArray[item];
                if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
                    [self _squareCellRelocatedToNewIndexPath:_squareRelocatedIndexPath];
                }
            }
            break;
        }
        default:
        {
            //长按手势结束或被取消，移除截图，显示cell
            [self _squareStopAutoScrollTimer];
            [self _squareDidEndDraging];
            self.isSquareFirstTouch = YES;
            self.isSquareBlankTouched = NO;
            self.isSquareInDeleteArea = NO;
            self.isSquareAreaTouchBegin = NO;
            //刷新主图标识逻辑 需延迟执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.squareCollectionView reloadData];
            });
            break;
        }
    }
}
- (void)longLongPressGestureRecognized:(id)sender{
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState longPressState = longPress.state;
    
    //手指在tableView中的位置
    _longFingerLocation = [longPress locationInView:self.longCollectionView];
    
    //如果手指长按坐标（拖拽起始位置）不在longCollectionView内 则让其他去相应
    UICollectionViewFlowLayout *longLayout = (UICollectionViewFlowLayout *)self.longCollectionView.collectionViewLayout;
    CGFloat longCollectionViewTop = longLayout.sectionInset.top;
    CGFloat longCollectionViewBottom = longCollectionViewTop + [self _calLongCollectionViewHeight];
    //是否在Square内
    if(_longFingerLocation.y<longCollectionViewTop && longPressState==UIGestureRecognizerStateBegan){
        self.isSquareAreaTouchBegin = YES;
    }
    if(self.isSquareAreaTouchBegin){
        [self squareLongPressGestureRecognized:sender];
        return;
    }
    //是否在Lucency内
    if(_longFingerLocation.y>longCollectionViewBottom && longPressState==UIGestureRecognizerStateBegan){
        self.isLucencyAreaTouchBegin = YES;
    }
    if(self.isLucencyAreaTouchBegin){
        [self lucencyLongPressGestureRecognized:sender];
        return;
    }
    
    //手指按住位置对应的indexPath，可能为nil
    _longRelocatedIndexPath = [self.longCollectionView indexPathForItemAtPoint:_longFingerLocation];
    //如果最后一个是占位符，不能移动
    if(_longRelocatedIndexPath){
        NSInteger item = _longRelocatedIndexPath.item;
        ImageModel *model = self.longCurrArray[item];
        if([model.imageurl isEqualToString:BLANKIMG] && self.isLongFirstTouch){
            self.isLongFirstTouch = NO;
            
            //当开始按住的是+时
            if(longPressState == UIGestureRecognizerStateBegan){
                self.isLongBlankTouched = YES;
            }
            return;
        }
        //长按cell时 删除区域显示
        [self _showDeleteView];
    }
    
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{  //手势开始，对被选中cell截图，隐藏原cell
            self.isLongAreaTouchBegin = YES;
            _longOriginalIndexPath = [self.longCollectionView indexPathForItemAtPoint:_longFingerLocation];
            if (_longOriginalIndexPath) {
                [self _longCellSelectedAtIndexPath:_longOriginalIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
            if(self.isLongBlankTouched){
                return;
            }
            //截图跟随手指移动
            CGPoint center = _longSnapshot.center;
            center.y = _longFingerLocation.y;
            center.x = _longFingerLocation.x;
            _longSnapshot.center = center;
            if ([self _longCheckIfSnapshotMeetsEdge]) {
                [self _longStartAutoScrollTimer];
            }else{
                [self _longStopAutoScrollTimer];
            }
            //手指按住位置对应的indexPath，可能为nil
            _longRelocatedIndexPath = [self.longCollectionView indexPathForItemAtPoint:_longFingerLocation] ;
            if (_longRelocatedIndexPath && ![_longRelocatedIndexPath isEqual:_longOriginalIndexPath]) {
                NSInteger item = _longRelocatedIndexPath.item;
                ImageModel *model = self.longCurrArray[item];
                if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
                    [self _longCellRelocatedToNewIndexPath:_longRelocatedIndexPath];
                }
            }
            break;
        }
        default:
        {
            //长按手势结束或被取消，移除截图，显示cell
            [self _longStopAutoScrollTimer];
            [self _longDidEndDraging];
            self.isLongFirstTouch = YES;
            self.isLongBlankTouched = NO;
            self.isLongInDeleteArea = NO;
            self.isLongAreaTouchBegin = NO;
            break;
        }
    }
}
- (void)lucencyLongPressGestureRecognized:(id)sender{
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState longPressState = longPress.state;
    
    //手指在tableView中的位置
    _lucencyFingerLocation = [longPress locationInView:self.lucencyCollectionView];
    //手指按住位置对应的indexPath，可能为nil
    _lucencyRelocatedIndexPath = [self.lucencyCollectionView indexPathForItemAtPoint:_lucencyFingerLocation];
    //如果最后一个是占位符，不能移动
    if(_lucencyRelocatedIndexPath){
        NSInteger item = _lucencyRelocatedIndexPath.item;
        ImageModel *model = self.lucencyCurrArray[item];
        if([model.imageurl isEqualToString:BLANKIMG] && self.isLucencyFirstTouch){
            self.isLucencyFirstTouch = NO;
            
            //当开始按住的是+时
            if(longPressState == UIGestureRecognizerStateBegan){
                self.isSquareBlankTouched = YES;
            }
            return;
        }
        //长按cell时 删除区域显示
        [self _showDeleteView];
    }
    
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{  //手势开始，对被选中cell截图，隐藏原cell
            self.isLucencyAreaTouchBegin = YES;
            _lucencyOriginalIndexPath = [self.lucencyCollectionView indexPathForItemAtPoint:_lucencyFingerLocation];
            if (_lucencyOriginalIndexPath) {
                [self _lucencyCellSelectedAtIndexPath:_lucencyOriginalIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
            if(self.isLucencyBlankTouched){
                return;
            }
            //截图跟随手指移动
            CGPoint center = _lucencySnapshot.center;
            center.y = _lucencyFingerLocation.y;
            center.x = _lucencyFingerLocation.x;
            _lucencySnapshot.center = center;
            if ([self _lucencyCheckIfSnapshotMeetsEdge]) {
                [self _lucencyStartAutoScrollTimer];
            }else{
                [self _lucencyStopAutoScrollTimer];
            }
            //手指按住位置对应的indexPath，可能为nil
            _lucencyRelocatedIndexPath = [self.lucencyCollectionView indexPathForItemAtPoint:_lucencyFingerLocation];
            if (_lucencyRelocatedIndexPath && ![_lucencyRelocatedIndexPath isEqual:_lucencyOriginalIndexPath]) {
                NSInteger item = _lucencyRelocatedIndexPath.item;
                ImageModel *model = self.lucencyCurrArray[item];
                if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
                    [self _lucencyCellRelocatedToNewIndexPath:_lucencyRelocatedIndexPath];
                }
            }
            break;
        }
        default:
        {
            //长按手势结束或被取消，移除截图，显示cell
            [self _lucencyStopAutoScrollTimer];
            [self _lucencyDidEndDraging];
            self.isLucencyFirstTouch = YES;
            self.isLucencyBlankTouched = NO;
            self.isLucencyInDeleteArea = NO;
            self.isLucencyAreaTouchBegin = NO;
            //刷新主图标识逻辑 需延迟执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.lucencyCollectionView reloadData];
            });
            break;
        }
    }
}
- (void)tapGestureRecognized:(id)sender{
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)sender;
    //得到手指点击方图中的位置
    CGPoint squareTapLocation = [tapGesture locationInView:self.squareCollectionView];
    CGPoint longTapLocation = [tapGesture locationInView:self.longCollectionView];
    CGPoint lucencyTapLocation = [tapGesture locationInView:self.lucencyCollectionView];
    //位置转换
    NSIndexPath *tapSquareIndexPath = [self.squareCollectionView indexPathForItemAtPoint:squareTapLocation];
    NSIndexPath *tapLongIndexPath = [self.longCollectionView indexPathForItemAtPoint:longTapLocation];
    NSIndexPath *tapLucencyIndexPath = [self.lucencyCollectionView indexPathForItemAtPoint:lucencyTapLocation];
    //点击squareCollectionView区域内
    if(tapSquareIndexPath){
        NSInteger squareItem = tapSquareIndexPath.item;
        if(squareItem == self.squareCurrArray.count-1){
            if((self.squareCurrArray.count-1) == kMaxImageCount){
                
                return;
            }
            //索引与"+"匹配 调用图片sdk 或者 相册
            
        }else{
            //显示大图
            
        }
    }
    //点击longCollectionView区域内
    if(tapLongIndexPath){
        NSInteger longItem = tapLongIndexPath.item;
        if(longItem == self.longCurrArray.count-1){
            if((self.longCurrArray.count-1) == kMaxImageCount){
                
                return;
            }
            //索引与"+"匹配 调用图片sdk 或者 相册
            
        }else{
            //显示大图
        }
    }
    //点击lucencyCollectionView区域内
    if(tapLucencyIndexPath){
        //透明图只有一个
        ImageModel *model = [self.lucencyCurrArray lastObject];
        if([model.imageurl isEqualToString:BLANKIMG]){
            //索引与"+"匹配 调用图片sdk 或相册
            
        }else{
            //显示大图
            
        }
    }
}


#pragma mark -
#pragma mark - private methods
- (void)_addBlankimg{
    //squareCurrArray增加"+"
    ImageModel *squareModel = [[ImageModel alloc] init];
    squareModel.imageurl = BLANKIMG;
    [self.squareCurrArray addObject:squareModel];
    //longCurrArray增加"+"
    ImageModel *longModel = [[ImageModel alloc] init];
    longModel.imageurl = BLANKIMG;
    [self.longCurrArray addObject:longModel];
    
    if(self.lucencyCurrArray.count==0){
        //我的主图中 透明图有可能存在透明图为空需要用户添加的情况 lucencyCurrArray增加"+"
        ImageModel *lucencyModel = [[ImageModel alloc] init];
        lucencyModel.imageurl = BLANKIMG;
        [self.lucencyCurrArray addObject:lucencyModel];
    }
}
- (void)_initData{
    self.squareRow = [self _calSquareCurrRow];
    self.longRow = [self _calLongCurrRow];
    self.isSquareBlankTouched = NO;
    self.isSquareFirstTouch = YES;
    self.isSquareInDeleteArea = NO;
    self.isLongAreaTouchBegin = NO;
    self.isSquareAreaTouchBegin = NO;
    
    //可编辑状态 添加站位图
    [self _addBlankimg];
    
    self.tableView.squareCurrArray = self.squareCurrArray;
    self.tableView.longCurrArray = self.longCurrArray;
    [self.tableView reloadData];
}
- (void)_initUI{
    self.view.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.squareCollectionView];
    [self.tableView addSubview:self.lucencyCollectionView];
    [self.tableView addSubview:self.longCollectionView];
    [self.view addSubview:self.deleteView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if([SDVersion deviceSize] == Screen5Dot8inch){//iphoneX
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            }
        }else{
            make.top.equalTo(self.view.mas_top);
        }
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self.deleteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        //用浮点 获取约束时不宜冲突
        make.height.equalTo(@0.01);
    }];
}
- (void)_initGesture{
    //因为长图覆盖方图 所以给长图添加手势即可 通过坐标判断谁来处理
    UILongPressGestureRecognizer *longLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longLongPressGestureRecognized:)];
    [self.longCollectionView addGestureRecognizer:longLongPress];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.longCollectionView addGestureRecognizer:tapGesture];
}
/**
 *  cell被长按手指选中，对其进行截图，原cell隐藏
 */
- (void)_squareCellSelectedAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.squareCollectionView cellForItemAtIndexPath:indexPath] ;
    UIView *snapshot = [self _customSnapshotFromView:cell];
    //防止被下面长图cell遮盖
    [self.tableView addSubview:snapshot];
    _squareSnapshot = snapshot;
    cell.hidden = YES;
    CGPoint center = _squareSnapshot.center;
    center.y = _squareFingerLocation.y;
    [UIView animateWithDuration:0.2 animations:^{
        self.squareSnapshot.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.squareSnapshot.alpha = 0.98;
        self.squareSnapshot.center = center;
    }];
}
- (void)_longCellSelectedAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.longCollectionView cellForItemAtIndexPath:indexPath] ;
    UIView *snapshot = [self _customSnapshotFromView:cell];
    [self.longCollectionView addSubview:snapshot];
    _longSnapshot = snapshot;
    cell.hidden = YES;
    CGPoint center = _longSnapshot.center;
    center.y = _longFingerLocation.y;
    [UIView animateWithDuration:0.2 animations:^{
        self.longSnapshot.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.longSnapshot.alpha = 0.98;
        self.longSnapshot.center = center;
    }];
}
- (void)_lucencyCellSelectedAtIndexPath:(NSIndexPath *)indexPath{
    DragPhotoCollectionViewCell *cell = (DragPhotoCollectionViewCell *)[self.lucencyCollectionView cellForItemAtIndexPath:indexPath] ;
    UIView *snapshot = [self _customSnapshotFromView:cell];
    //防止被下面长图cell遮盖
    [self.tableView addSubview:snapshot];
    _lucencySnapshot = snapshot;
    CGPoint center = _lucencySnapshot.center;
    center.y = _lucencyFingerLocation.y;
    cell.iconImageView.alpha = 0.f;
    [UIView animateWithDuration:0.2 animations:^{
        self.lucencySnapshot.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.lucencySnapshot.alpha = 0.98;
        self.lucencySnapshot.center = center;
        cell.placeholderImageView.alpha = 1.0f;
    }];
}
/**
 返回一个给定view的截图.
 */
- (UIView *)_customSnapshotFromView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}
/**
 *  检查截图是否到达边缘，并作出响应
 */
- (BOOL)_squareCheckIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(_squareSnapshot.frame);
    CGFloat maxY = CGRectGetMaxY(_squareSnapshot.frame);
    
    //检测删除
    if(maxY > (self.deleteView.frame.origin.y+self.tableView.contentOffset.y)){
        self.isSquareInDeleteArea = YES;
    }else{
        self.isSquareInDeleteArea = NO;
    }
    if (minY < self.squareCollectionView.contentOffset.y) {
        _squareAutoScrollDirection = RTSnapshotMeetsEdgeTop;
        return YES;
    }
    if (maxY > self.squareCollectionView.bounds.size.height + self.squareCollectionView.contentOffset.y) {
        _squareAutoScrollDirection = RTSnapshotMeetsEdgeBottom;
        return YES;
    }
    
    return NO;
}
- (BOOL)_longCheckIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(_longSnapshot.frame);
    CGFloat maxY = CGRectGetMaxY(_longSnapshot.frame);
    if (minY < self.longCollectionView.contentOffset.y) {
        _longAutoScrollDirection = RTSnapshotMeetsEdgeTop;
        return YES;
    }
    if (maxY > self.longCollectionView.bounds.size.height + self.longCollectionView.contentOffset.y) {
        _longAutoScrollDirection = RTSnapshotMeetsEdgeBottom;
        return YES;
    }
    
    if(maxY > (self.deleteView.frame.origin.y+self.tableView.contentOffset.y)){
        //到达删除区域
        self.isLongInDeleteArea = YES;
    }else{
        self.isLongInDeleteArea = NO;
    }
    return NO;
}
- (BOOL)_lucencyCheckIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(_lucencySnapshot.frame);
    CGFloat maxY = CGRectGetMaxY(_lucencySnapshot.frame);
    
    //检测删除
    if(maxY > (self.deleteView.frame.origin.y+self.tableView.contentOffset.y)){
        self.isLucencyInDeleteArea = YES;
    }else{
        self.isLucencyInDeleteArea = NO;
    }
    if (minY < self.lucencyCollectionView.contentOffset.y) {
        _lucencyAutoScrollDirection = RTSnapshotMeetsEdgeTop;
        return YES;
    }
    if (maxY > self.lucencyCollectionView.bounds.size.height + self.lucencyCollectionView.contentOffset.y) {
        _lucencyAutoScrollDirection = RTSnapshotMeetsEdgeBottom;
        return YES;
    }
    
    return NO;
}
/**
 *  创建定时器并运行
 */
- (void)_squareStartAutoScrollTimer{
    if (!_squareAutoScrollTimer) {
        _squareAutoScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_squareStartAutoScroll)];
        [_squareAutoScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)_longStartAutoScrollTimer{
    if (!_longAutoScrollTimer) {
        _longAutoScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_longStartAutoScroll)];
        [_longAutoScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)_lucencyStartAutoScrollTimer{
    if (!_lucencyAutoScrollTimer) {
        _lucencyAutoScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_lucencyStartAutoScroll)];
        [_lucencyAutoScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
/**
 *  停止定时器并销毁
 */
- (void)_squareStopAutoScrollTimer{
    if (_squareAutoScrollTimer) {
        [_squareAutoScrollTimer invalidate];
        _squareAutoScrollTimer = nil;
    }
}
- (void)_longStopAutoScrollTimer{
    if (_longAutoScrollTimer) {
        [_longAutoScrollTimer invalidate];
        _longAutoScrollTimer = nil;
    }
}
- (void)_lucencyStopAutoScrollTimer{
    if (_lucencyAutoScrollTimer) {
        [_lucencyAutoScrollTimer invalidate];
        _lucencyAutoScrollTimer = nil;
    }
}
/**
 *  开始自动滚动
 */
- (void)_squareStartAutoScroll{
    CGFloat pixelSpeed = 4;
    if (_squareAutoScrollDirection == RTSnapshotMeetsEdgeTop) {//向下滚动
        if (self.squareCollectionView.contentOffset.y > 0) {//向下滚动最大范围限制
            [self.squareCollectionView setContentOffset:CGPointMake(0, self.squareCollectionView.contentOffset.y - pixelSpeed)];
            _squareSnapshot.center = CGPointMake(_squareSnapshot.center.x, _squareSnapshot.center.y - pixelSpeed);
        }
    }else{                                               //向上滚动
        if (self.squareCollectionView.contentOffset.y + self.squareCollectionView.bounds.size.height < self.squareCollectionView.contentSize.height) {//向下滚动最大范围限制
            [self.squareCollectionView setContentOffset:CGPointMake(0, self.squareCollectionView.contentOffset.y + pixelSpeed)];
            _squareSnapshot.center = CGPointMake(_squareSnapshot.center.x, _squareSnapshot.center.y + pixelSpeed);
        }
    }
    
    /*  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
     */
    _squareRelocatedIndexPath = [self.squareCollectionView indexPathForItemAtPoint:_squareSnapshot.center];
    if (_squareRelocatedIndexPath && ![_squareRelocatedIndexPath isEqual:_squareOriginalIndexPath]) {
        NSInteger item = _squareRelocatedIndexPath.item;
        ImageModel *model = self.squareCurrArray[item];
        if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
            [self _squareCellRelocatedToNewIndexPath:_squareRelocatedIndexPath];
        }
        
    }
}
- (void)_longStartAutoScroll{
    CGFloat pixelSpeed = 4;
    if (_longAutoScrollDirection == RTSnapshotMeetsEdgeTop) {//向下滚动
        if (self.longCollectionView.contentOffset.y > 0) {//向下滚动最大范围限制
            [self.longCollectionView setContentOffset:CGPointMake(0, self.longCollectionView.contentOffset.y - pixelSpeed)];
            _longSnapshot.center = CGPointMake(_longSnapshot.center.x, _longSnapshot.center.y - pixelSpeed);
        }
    }else{                                               //向上滚动
        if (self.longCollectionView.contentOffset.y + self.longCollectionView.bounds.size.height < self.longCollectionView.contentSize.height) {//向下滚动最大范围限制
            [self.longCollectionView setContentOffset:CGPointMake(0, self.longCollectionView.contentOffset.y + pixelSpeed)];
            _longSnapshot.center = CGPointMake(_longSnapshot.center.x, _longSnapshot.center.y + pixelSpeed);
        }
    }
    
    /*  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
     */
    _longRelocatedIndexPath = [self.longCollectionView indexPathForItemAtPoint:_longSnapshot.center] ;
    if (_longRelocatedIndexPath && ![_longRelocatedIndexPath isEqual:_longOriginalIndexPath]) {
        NSInteger item = _longRelocatedIndexPath.item;
        ImageModel *model = self.longCurrArray[item];
        if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
            [self _longCellRelocatedToNewIndexPath:_longRelocatedIndexPath];
        }
    }
}
- (void)_lucencyStartAutoScroll{
    CGFloat pixelSpeed = 4;
    if (_lucencyAutoScrollDirection == RTSnapshotMeetsEdgeTop) {//向下滚动
        if (self.lucencyCollectionView.contentOffset.y > 0) {//向下滚动最大范围限制
            [self.lucencyCollectionView setContentOffset:CGPointMake(0, self.lucencyCollectionView.contentOffset.y - pixelSpeed)];
            _lucencySnapshot.center = CGPointMake(_lucencySnapshot.center.x, _lucencySnapshot.center.y - pixelSpeed);
        }
    }else{                                               //向上滚动
        if (self.lucencyCollectionView.contentOffset.y + self.lucencyCollectionView.bounds.size.height < self.lucencyCollectionView.contentSize.height) {//向下滚动最大范围限制
            [self.lucencyCollectionView setContentOffset:CGPointMake(0, self.lucencyCollectionView.contentOffset.y + pixelSpeed)];
            _lucencySnapshot.center = CGPointMake(_lucencySnapshot.center.x, _lucencySnapshot.center.y + pixelSpeed);
        }
    }
    
    /*  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
     */
    _lucencyRelocatedIndexPath = [self.lucencyCollectionView indexPathForItemAtPoint:_lucencySnapshot.center] ;
    if (_lucencyRelocatedIndexPath && ![_lucencyRelocatedIndexPath isEqual:_lucencyOriginalIndexPath]) {
        NSInteger item = _lucencyRelocatedIndexPath.item;
        ImageModel *model = self.lucencyCurrArray[item];
        if(![model.imageurl isEqualToString:BLANKIMG]){//不是占位符移动位置
            [self _lucencyCellRelocatedToNewIndexPath:_lucencyRelocatedIndexPath];
        }
    }
}
/**
 *  截图被移动到新的indexPath范围，这时先更新数据源，重排数组，再将cell移至新位置
 *  @param indexPath 新的indexPath
 */
- (void)_squareCellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源
    [self _squareUpdateDataSource];
    //交换移动cell位置
    [self.squareCollectionView moveItemAtIndexPath:_squareOriginalIndexPath toIndexPath:indexPath];
    //更新cell的原始indexPath为当前indexPath
    _squareOriginalIndexPath = indexPath;
}
- (void)_longCellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源
    [self _longUpdateDataSource];
    //交换移动cell位置
    [self.longCollectionView moveItemAtIndexPath:_longOriginalIndexPath toIndexPath:indexPath] ;
    //更新cell的原始indexPath为当前indexPath
    _longOriginalIndexPath = indexPath;
}
- (void)_lucencyCellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源
    [self _lucencyUpdateDataSource];
    //交换移动cell位置
    [self.lucencyCollectionView moveItemAtIndexPath:_lucencyOriginalIndexPath toIndexPath:indexPath] ;
    //更新cell的原始indexPath为当前indexPath
    _lucencyOriginalIndexPath = indexPath;
}
/**修改数据源，通知外部更新数据源*/
- (void)_squareUpdateDataSource{
    //通过DataSource代理获得原始数据源数组
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObjectsFromArray:self.squareCurrArray];
    
    [self _moveObjectInMutableArray:tempArray fromIndex:_squareOriginalIndexPath.row toIndex:_squareRelocatedIndexPath.row];
    //更改数据源
    self.squareCurrArray = [NSMutableArray arrayWithArray:tempArray];
    [self _reloadPositionWithArray:self.squareCurrArray];
    
    self.tableView.squareCurrArray = self.squareCurrArray;
}
- (void)_longUpdateDataSource{
    //通过DataSource代理获得原始数据源数组
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObjectsFromArray:self.longCurrArray];
    
    [self _moveObjectInMutableArray:tempArray fromIndex:_longOriginalIndexPath.row toIndex:_longRelocatedIndexPath.row];
    //更改数据源
    self.longCurrArray = [NSMutableArray arrayWithArray:tempArray];
    [self _reloadPositionWithArray:self.longCurrArray];
    
    self.tableView.longCurrArray = self.longCurrArray;
}
- (void)_lucencyUpdateDataSource{
    //通过DataSource代理获得原始数据源数组
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObjectsFromArray:self.lucencyCurrArray];
    
    [self _moveObjectInMutableArray:tempArray fromIndex:_lucencyOriginalIndexPath.row toIndex:_lucencyRelocatedIndexPath.row];
    //更改数据源
    self.lucencyCurrArray = [NSMutableArray arrayWithArray:tempArray];
    [self _reloadPositionWithArray:self.lucencyCurrArray];
    
    //    self.tableView.lucencyCurrArray = self.lucencyCurrArray;
}
/**
 *  将可变数组中的一个对象移动到该数组中的另外一个位置
 *  @param array     要变动的数组
 *  @param fromIndex 从这个index
 *  @param toIndex   移至这个index
 */
- (void)_moveObjectInMutableArray:(NSMutableArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
}
//更新position
- (void)_reloadPositionWithArray:(NSMutableArray *)array{
    for(int i=0;i<array.count;i++){
        ImageModel *model = [array objectAtIndex:i];
        model.position = [NSString stringWithFormat:@"%ld",(long)i];
    }
}
/**
 *  拖拽结束，显示cell，并移除截图
 */
- (void)_squareDidEndDraging{
    
    UICollectionViewCell *cell = [self.squareCollectionView cellForItemAtIndexPath:_squareOriginalIndexPath] ;
    cell.hidden = NO;
    cell.alpha = 0;
    
    if(self.isSquareInDeleteArea){
        //删除
        NSInteger item = _squareOriginalIndexPath.item;
        [self.squareCurrArray removeObjectAtIndex:item];
        self.tableView.squareCurrArray = self.squareCurrArray;
        
        //squareCollectionView刷新
        [self.squareCollectionView reloadData];
        [self _squareUpdateCurrCollectionViewHeight];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.squareSnapshot.alpha = 0;
            self.squareSnapshot.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.squareSnapshot removeFromSuperview];
            self.squareSnapshot = nil;
            self.squareOriginalIndexPath = nil;
            self.squareRelocatedIndexPath = nil;
        }];
    }else{
        //回位
        [UIView animateWithDuration:0.2 animations:^{
            self.squareSnapshot.center = cell.center;
            self.squareSnapshot.alpha = 0;
            self.squareSnapshot.transform = CGAffineTransformIdentity;
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            cell.hidden = NO;
            [self.squareSnapshot removeFromSuperview];
            self.squareSnapshot = nil;
            self.squareOriginalIndexPath = nil;
            self.squareRelocatedIndexPath = nil;
        }];
    }
    [self _hiddenDeleteView];
}
- (void)_longDidEndDraging{
    
    UICollectionViewCell *cell = [self.longCollectionView cellForItemAtIndexPath:_longOriginalIndexPath] ;
    cell.hidden = NO;
    cell.alpha = 0;
    
    if(self.isLongInDeleteArea){
        //删除
        NSInteger item = _longOriginalIndexPath.item;
        [self.longCurrArray removeObjectAtIndex:item];
        self.tableView.longCurrArray = self.longCurrArray;
        
        //squareCollectionView刷新
        [self.longCollectionView reloadData];
        [self _longUpdateCurrCollectionViewHeight];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.longSnapshot.alpha = 0;
            self.longSnapshot.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.longSnapshot removeFromSuperview];
            self.longSnapshot = nil;
            self.longOriginalIndexPath = nil;
            self.longRelocatedIndexPath = nil;
        }];
    }else{
        //回位
        [UIView animateWithDuration:0.2 animations:^{
            self.longSnapshot.center = cell.center;
            self.longSnapshot.alpha = 0;
            self.longSnapshot.transform = CGAffineTransformIdentity;
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            cell.hidden = NO;
            [self.longSnapshot removeFromSuperview];
            self.longSnapshot = nil;
            self.longOriginalIndexPath = nil;
            self.longRelocatedIndexPath = nil;
        }];
    }
    [self _hiddenDeleteView];
}
- (void)_lucencyDidEndDraging{
    
    DragPhotoCollectionViewCell *cell = (DragPhotoCollectionViewCell *)[self.lucencyCollectionView cellForItemAtIndexPath:_lucencyOriginalIndexPath] ;
    
    if(self.isLucencyInDeleteArea){
        //删除
        NSInteger item = _lucencyOriginalIndexPath.item;
        [self.lucencyCurrArray removeObjectAtIndex:item];
        //透明图删除后 需要补一张占位图
        ImageModel *blankingModel = [[ImageModel alloc] init];
        blankingModel.imageurl = BLANKIMG;
        [self.lucencyCurrArray addObject:blankingModel];
        //        self.tableView.lucencyCurrArray = self.lucencyCurrArray;
        
        //squareCollectionView刷新
        [self.lucencyCollectionView reloadData];
        //        [self _lucencyUpdateCurrCollectionViewHeight];
        cell.placeholderImageView.alpha = 0.f;
        cell.iconImageView.alpha = 1.f;
        [UIView animateWithDuration:0.2 animations:^{
            self.lucencySnapshot.alpha = 0.f;
            self.lucencySnapshot.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.lucencySnapshot removeFromSuperview];
            self.lucencySnapshot = nil;
            self.lucencyOriginalIndexPath = nil;
            self.lucencyRelocatedIndexPath = nil;
        }];
    }else{
        //回位
        [UIView animateWithDuration:0.2 animations:^{
            self.lucencySnapshot.center = cell.center;
            self.lucencySnapshot.alpha = 0;
            self.lucencySnapshot.transform = CGAffineTransformIdentity;
            cell.placeholderImageView.alpha = 0.f;
        } completion:^(BOOL finished) {
            cell.iconImageView.alpha = 1.f;
            [self.lucencySnapshot removeFromSuperview];
            self.lucencySnapshot = nil;
            self.lucencyOriginalIndexPath = nil;
            self.lucencyRelocatedIndexPath = nil;
        }];
    }
    [self _hiddenDeleteView];
}
/**
 *  重新计算collectionview高度
 */
- (void)_squareUpdateCurrCollectionViewHeight{
    NSInteger newRow = [self _calSquareCurrRow];
    if(self.squareRow != newRow){
        self.squareRow = newRow;
        [self _layoutCollectionView];
        [self.tableView reloadData];
    }
}
- (void)_longUpdateCurrCollectionViewHeight{
    NSInteger newRow = [self _calLongCurrRow];
    if(self.longRow != newRow){
        self.longRow = newRow;
        [self _layoutCollectionView];
        [self.tableView reloadData];
    }
}
/**
 *  计算方图行数
 */
- (NSInteger)_calSquareCurrRow{
    
    //先要让cout成为kItemCount的倍数 才能计算
    NSInteger arrCount = self.squareCurrArray.count != 0 ? self.squareCurrArray.count : 1 ;
    NSInteger finalTotal = arrCount % kItemCount;
    NSInteger finalCount = arrCount;
    if(finalTotal != 0){
        finalCount = arrCount+(kItemCount-finalTotal);
    }
    NSInteger rowNum = finalCount%kItemCount + finalCount/kItemCount;
    return rowNum;
}
- (CGFloat)_calSquareCollectionViewHeight{
    
    NSInteger rowNum = [self _calSquareCurrRow];
    return 15*(rowNum+1) + kSingleItemHeight*rowNum;
}
/**
 *  计算长图行数
 */
- (NSInteger)_calLongCurrRow{
    
    //先要让cout成为kItemCount的倍数 才能计算
    NSInteger arrCount = self.longCurrArray.count != 0 ? self.longCurrArray.count : 1 ;
    NSInteger finalTotal = arrCount % kItemCount;
    NSInteger finalCount = arrCount;
    if(finalTotal != 0){
        finalCount = arrCount+(kItemCount-finalTotal);
    }
    NSInteger rowNum = finalCount%kItemCount + finalCount/kItemCount;
    return rowNum;
}
- (CGFloat)_calLongCollectionViewHeight{
    
    NSInteger rowNum = [self _calLongCurrRow];
    return 15*(rowNum+1) + kSingleItemHeight*rowNum;
}
/**
 *  刷新CollectionView布局
 */
- (void)_layoutCollectionView{
    
    CGFloat tableViewTopHeight = 10.f;
    CGFloat singleCellHeight = 44.f;
    CGFloat titleCellHeight = 40.f;
    CGFloat collectionCellTop = 15.f;
    CGFloat collectionEnsureHeight = 80.f;  //防止出现collection未填满底部问题
    
    CGFloat squareCollectionViewHeight = [self _calSquareCollectionViewHeight];
    CGFloat squareCollectionViewTop = self.tableView.tableHeaderView.frame.size.height+ tableViewTopHeight+singleCellHeight*4+titleCellHeight+collectionCellTop;
    
    CGFloat longCollectionViewHeight = [self _calLongCollectionViewHeight];
    CGFloat longCollectionViewTop = squareCollectionViewTop+squareCollectionViewHeight+titleCellHeight;
    
    //方图
    //更新squareCollectionView frame 足够大使cell能在屏幕范围内任意滑动
    [self.squareCollectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.contentSize.height+self.tableView.tableHeaderView.frame.size.height+collectionEnsureHeight)];
    //更新squareCollectionView layout
    UICollectionViewFlowLayout *squareLayout = (UICollectionViewFlowLayout *)self.squareCollectionView.collectionViewLayout;
    squareLayout.sectionInset = UIEdgeInsetsMake(squareCollectionViewTop, collectionCellTop, 0, collectionCellTop);
    [self.squareCollectionView setCollectionViewLayout:squareLayout];
    
    //长图
    [self.longCollectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.contentSize.height+self.tableView.tableHeaderView.frame.size.height+collectionEnsureHeight)];
    UICollectionViewFlowLayout *longLayout = (UICollectionViewFlowLayout *)self.longCollectionView.collectionViewLayout;
    longLayout.sectionInset = UIEdgeInsetsMake(longCollectionViewTop, collectionCellTop, 0, collectionCellTop);
    [self.longCollectionView setCollectionViewLayout:longLayout];
    
    //透明图
    [self.lucencyCollectionView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.tableView.contentSize.height+self.tableView.tableHeaderView.frame.size.height+collectionEnsureHeight)];
    UICollectionViewFlowLayout *lucencyLayout = (UICollectionViewFlowLayout *)self.lucencyCollectionView.collectionViewLayout;
    lucencyLayout.sectionInset = UIEdgeInsetsMake(longCollectionViewTop+longCollectionViewHeight+titleCellHeight, collectionCellTop, 0, collectionCellTop);
    [self.lucencyCollectionView setCollectionViewLayout:lucencyLayout];
    
    [self.squareCollectionView reloadData];
    [self.longCollectionView reloadData];
    [self.lucencyCollectionView reloadData];
}
//显示deleteView
- (void)_showDeleteView{
    [UIView animateWithDuration:.2f animations:^{
        for(NSLayoutConstraint *constraint in self.deleteView.constraints){
            if(constraint.constant == 0.01){
                if([SDVersion deviceSize] == Screen5Dot8inch){//iphoneX
                    if (@available(iOS 11.0, *)) {
                        //长按后 变成82
                        constraint.constant = 82;
                    }
                }else{
                    //长按后 变成48
                    constraint.constant = 48;
                }
            }
        }
        [self.view layoutIfNeeded];
    }];
}
//隐藏deleteView
- (void)_hiddenDeleteView{
    [UIView animateWithDuration:.2f animations:^{
        for(NSLayoutConstraint *constraint in self.deleteView.constraints){
            if([SDVersion deviceSize] == Screen5Dot8inch){//iphoneX
                if (@available(iOS 11.0, *)) {
                    if(constraint.constant == 82){
                        constraint.constant = 0.01;
                    }
                }
            }else{
                if(constraint.constant == 48){
                    constraint.constant = 0.01;
                }
            }
        }
        [self.view layoutIfNeeded];
    }];
}



#pragma mark -
#pragma mark - SystemDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.squareCollectionView){
        //方图
        DragPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DragPhotoCollectionViewCell" forIndexPath:indexPath];
        
        ImageModel *urlModel = [self.squareCurrArray objectAtIndex:indexPath.item];
        if(![urlModel.imageurl isEqualToString:BLANKIMG]){
//            [cell.iconImageView setImageWithURL:[NSURL URLWithString:urlModel.imageurl ? urlModel.imageurl : urlModel.bigimageurl] placeholderImage:[UIImage imageNamed:@"service_placeholder"]];
            [cell.iconImageView setImage:[UIImage imageNamed:urlModel.imageurl]];
            //主图标识
            if(indexPath.item==0){
                cell.mainView.alpha = .6f;
                cell.mainLabel.alpha = 1.f;
            }else{
                cell.mainView.alpha = .0f;
                cell.mainLabel.alpha = .0f;
            }
        }else{
            [cell.iconImageView setImage:[UIImage imageNamed:@"pic_add.png"]];
            //防止将图片都删除之后主图标记在+上
            cell.mainView.alpha = .0f;
            cell.mainLabel.alpha = .0f;
        }
        
        return cell;
    }else if(collectionView == self.longCollectionView){
        //长图
        DragPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DragPhotoCollectionViewCell" forIndexPath:indexPath];
        
        ImageModel *urlModel = [self.longCurrArray objectAtIndex:indexPath.item];
        if(![urlModel.imageurl isEqualToString:BLANKIMG]){
//            [cell.iconImageView setImageWithURL:[NSURL URLWithString:urlModel.imageurl ? urlModel.imageurl : urlModel.bigimageurl] placeholderImage:[UIImage imageNamed:@"service_placeholder"]];
            [cell.iconImageView setImage:[UIImage imageNamed:urlModel.imageurl]];
        }else{
            [cell.iconImageView setImage:[UIImage imageNamed:@"pic_add.png"]];
        }
        
        return cell;
    }else{
        //透明图
        DragPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DragPhotoCollectionViewCell" forIndexPath:indexPath];
        
        ImageModel *urlModel = [self.lucencyCurrArray objectAtIndex:indexPath.item];
        if(![urlModel.imageurl isEqualToString:BLANKIMG]){
//            [cell.iconImageView setImageWithURL:[NSURL URLWithString:urlModel.imageurl ? urlModel.imageurl : urlModel.bigimageurl] placeholderImage:[UIImage imageNamed:@"service_placeholder"]];
            [cell.iconImageView setImage:[UIImage imageNamed:urlModel.imageurl]];
        }else{
            [cell.iconImageView setImage:[UIImage imageNamed:@"pic_add.png"]];
        }
        return cell;
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == self.squareCollectionView){
        return self.squareCurrArray.count;
    }else if(collectionView == self.longCollectionView){
        return self.longCurrArray.count;
    }else{
        return self.lucencyCurrArray.count;
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}


#pragma mark -
#pragma mark - getters and setters
- (DragPhotoTableView *)tableView{
    if (!_tableView) {
        _tableView = [[DragPhotoTableView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1];
        _tableView.squareCurrArray = self.squareCurrArray;
        _tableView.longCurrArray = self.longCurrArray;
    }
    return _tableView;
}
- (UICollectionView *)squareCollectionView{
    if (!_squareCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(kSingleItemHeight,kSingleItemHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 0);
        _squareCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _squareCollectionView.scrollEnabled = NO;
        _squareCollectionView.delegate = self;
        _squareCollectionView.dataSource = self;
        [_squareCollectionView registerClass:[DragPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"DragPhotoCollectionViewCell"];
        _squareCollectionView.backgroundColor = [UIColor clearColor];
        _squareCollectionView.showsHorizontalScrollIndicator = NO;
        _squareCollectionView.showsVerticalScrollIndicator = NO;
        
        [_squareCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"currcollectionviewheader"];
    }
    
    return _squareCollectionView;
}
- (UICollectionView *)longCollectionView{
    if (!_longCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(kSingleItemHeight,kSingleItemHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 0);
        _longCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _longCollectionView.scrollEnabled = NO;
        _longCollectionView.delegate = self;
        _longCollectionView.dataSource = self;
        [_longCollectionView registerClass:[DragPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"DragPhotoCollectionViewCell"];
        _longCollectionView.backgroundColor = [UIColor clearColor];
        _longCollectionView.showsHorizontalScrollIndicator = NO;
        _longCollectionView.showsVerticalScrollIndicator = NO;
        
        [_longCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"currcollectionviewheader"];
    }
    
    return _longCollectionView;
}
- (UICollectionView *)lucencyCollectionView{
    if (!_lucencyCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(kSingleItemHeight,kSingleItemHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 0);
        _lucencyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _lucencyCollectionView.scrollEnabled = NO;
        _lucencyCollectionView.delegate = self;
        _lucencyCollectionView.dataSource = self;
        [_lucencyCollectionView registerClass:[DragPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"DragPhotoCollectionViewCell"];
        _lucencyCollectionView.backgroundColor = [UIColor clearColor];
        _lucencyCollectionView.showsHorizontalScrollIndicator = NO;
        _lucencyCollectionView.showsVerticalScrollIndicator = NO;
        
        [_lucencyCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"currcollectionviewheader"];
    }
    
    return _lucencyCollectionView;
}
- (NSMutableArray *)squareCurrArray{
    if(!_squareCurrArray){
        _squareCurrArray = [[NSMutableArray alloc] init];
        for(int i=0;i<5;i++){
            ImageModel *model = [[ImageModel alloc] init];
            model.imageurl = @"cell_image1";
            [_squareCurrArray addObject:model];
        }
    }
    return _squareCurrArray;
}
- (NSMutableArray *)longCurrArray{
    if(!_longCurrArray){
        _longCurrArray = [[NSMutableArray alloc] init];
        for(int i=0;i<5;i++){
            ImageModel *model = [[ImageModel alloc] init];
            model.imageurl = @"cell_image";
            [_longCurrArray addObject:model];
        }
    }
    return _longCurrArray;
}
- (NSMutableArray *)lucencyCurrArray{
    if(!_lucencyCurrArray){
        _lucencyCurrArray = [[NSMutableArray alloc] init];
        ImageModel *model = [[ImageModel alloc] init];
        model.imageurl = @"cell_image2";
        [_lucencyCurrArray addObject:model];
    }
    return _lucencyCurrArray;
}
- (DragPhotoDeleteView *)deleteView{
    if(!_deleteView){
        _deleteView = [[DragPhotoDeleteView alloc] initWithFrame:CGRectZero];
        _deleteView.alpha = 0.8f;
    }
    return _deleteView;
}
- (void)setIsSquareInDeleteArea:(BOOL)isSquareInDeleteArea{
    _isSquareInDeleteArea = isSquareInDeleteArea;
    //deleteView 刷新
    [self.deleteView changeStatus:_isSquareInDeleteArea ? DeleteViewStatusDelete : DeleteViewStatusPrompt];
}
- (void)setIsLongInDeleteArea:(BOOL)isLongInDeleteArea{
    _isLongInDeleteArea = isLongInDeleteArea;
    //deleteView 刷新
    [self.deleteView changeStatus:_isLongInDeleteArea ? DeleteViewStatusDelete : DeleteViewStatusPrompt];
}
- (void)setIsLucencyInDeleteArea:(BOOL)isLucencyInDeleteArea{
    _isLucencyInDeleteArea = isLucencyInDeleteArea;
    //deleteView 刷新
    [self.deleteView changeStatus:_isLucencyInDeleteArea ? DeleteViewStatusDelete : DeleteViewStatusPrompt];
}



@end
