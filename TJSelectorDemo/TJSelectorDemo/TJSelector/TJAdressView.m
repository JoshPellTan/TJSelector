//
//  TJAdressView.m
//  TJAdressDemo
//
//  Created by TanJian on 16/5/18.
//  Copyright © 2016年 Joshpell. All rights reserved.
//

#import "TJAdressView.h"
#import "TJCell.h"


#define  kDeviceWidth        [[UIScreen mainScreen] bounds].size.width
#define  kDeviceHeight       [[UIScreen mainScreen] bounds].size.height

#define  kScaleW             kDeviceWidth/375
#define  kScaleH             kDeviceHeight/667

#define kNavHeight  64
#define kColor      [UIColor redColor]

//地址显示区按钮字大小
#define redBtnFont  13*kScaleW
//地址显示圆的x,y,宽,高
#define redBtnX     15*kScaleW
#define redBtnY     20*kScaleH
#define redBtnW     60*kScaleW
#define redBtnH     60*kScaleW
//省view高度
#define redViewH    (kDeviceHeight-180*kScaleH)
//市view宽度
#define whiteBgW    90*kScaleW
//省view动画时间
#define redViewTime  0.3
//市view动画时间
#define whiteViewTime   0.2
//点击市后的延迟
#define delayTime   0.2


@interface TJAdressView ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *provinceTableView;
@property(nonatomic,strong)UITableView *cityTableView;

@property(nonatomic,strong)UIButton *redBtn;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIButton *bgButton;
@property(nonatomic,strong)UIView *redView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIView *whiteView;
@property(nonatomic,strong)UIImageView *whiteBg;


@property(nonatomic,strong)NSMutableArray *provinceCellArr;
//记录省cell数组是否已经添加过
@property(nonatomic,assign)NSInteger proLastIndex;
@property(nonatomic,strong)NSMutableArray *cityCellArr;
//记录城市cell数组是否已经添加过
@property(nonatomic,assign)NSInteger cityLastIndex;

@property(nonatomic,assign)NSInteger currentIndex;

@property(nonatomic,strong)TJCell *currentProvCell;
@property(nonatomic,strong)TJCell *currentCityCell;

//本地存储地址信息
@property(nonatomic,strong)NSMutableDictionary *positionDict;


@end

@implementation TJAdressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = NO;
        
    }
    _proLastIndex = 0;
    _cityLastIndex = 0;
    [self getCityData];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAdrBtn:) name:@"resetAdrBtnString" object:nil];
    
    return self;
}

-(void)resetAdrBtn:(NSNotification *)notify{
    
    NSDictionary *dict = notify.object;
    NSString *city = dict[@"cityname"];
    
    if (![city isEqualToString:_currentAdr]) {
        if (![city isEqualToString:@""]) {
            _currentAdr = city;
            
        }
        _currentAdr = [_currentAdr stringByReplacingOccurrencesOfString:@"市" withString:@""];
        [self setupUI];
    }else{
        if ([_currentAdr isEqualToString:@""]) {
            _currentAdr = @"定位中";
        }
        [self setupUI];
        
    }
    
}

-(void)setupUI{
    //设置圆圈显示的文字
    [self setTitleBtnWith:_currentAdr];
    
}

-(void)setTitleBtnWith:(NSString *)string{
    
    
    [self.redBtn setTitle:string forState:UIControlStateNormal];
    [_redBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (_redBtn.titleLabel.text.length>4) {
        
        long length = _redBtn.titleLabel.text.length;
        
        _redBtn.titleLabel.font = [UIFont systemFontOfSize: (redBtnFont-(length-2))*kScaleW];
        
    }else{
        
        _redBtn.titleLabel.font = [UIFont systemFontOfSize:redBtnFont];
    }
    [self addSubview:self.redBtn];

}


-(void)didButton{
    

    [self getCityData];
    //地址选择器弹出动画
    [self animationForAdressView];

}


//弹出动画
-(void)animationForAdressView{
    
    //如果地址数组为空则不执行动画
    if (self.cityDataArr.count <= 0) {
        NSLog(@"二级数据为空");
        return;
    }
    
    
    _bgView.alpha = 0.5;
    
    [self.bgView removeFromSuperview];
    [self.redView removeFromSuperview];
    [self.backButton removeFromSuperview];
    [self.whiteBg removeFromSuperview];

    [self addSubview:self.bgView];
    
    //红色长条
    [self addSubview:self.redView];
    //三角按钮
    [self addSubview:self.backButton];
    //白色选址
    [self addSubview:self.whiteBg];
    [self addSubview:self.whiteView];
    [self bringSubviewToFront:_redBtn];
    
    [UIView animateWithDuration:redViewTime animations:^{
        
        _redView.frame = CGRectMake(redBtnX, redBtnY, redBtnW, redViewH);
        _backButton.frame = CGRectMake(redBtnX, redBtnY+redViewH-redBtnH,redBtnW , redBtnH);
        _redBtn.userInteractionEnabled = NO;
        _redBtn.backgroundColor = [UIColor clearColor];
        
        
    }completion:^(BOOL finished) {
        
        //白色选址栏动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.redView addSubview:self.provinceTableView];
            
            [UIView animateWithDuration:whiteViewTime animations:^{
                _whiteBg.frame =  CGRectMake(CGRectGetMaxX(_redView.frame),redBtnY+redBtnW*0.5, whiteBgW, redViewH-redBtnH);
                
                _whiteView.frame = CGRectMake(CGRectGetMinX(_whiteBg.frame), CGRectGetMinY(_whiteBg.frame)+redBtnH*0.5+5, whiteBgW, CGRectGetHeight(_whiteBg.frame)-redBtnH-10);
                
            } completion:^(BOOL finished) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.whiteView addSubview:self.cityTableView];
                    self.userInteractionEnabled = YES;
                    
                    NSIndexPath *path=[NSIndexPath indexPathForItem:_currentIndex inSection:0];
                    [self tableView:self.provinceTableView didSelectRowAtIndexPath:path];
                });
                
            }];
        });
 
    }];
    
}


-(void)closeAnimation{
    
    //白色区域动画
    [UIView animateWithDuration:whiteViewTime*0.6 animations:^{
        _whiteBg.frame = CGRectMake(_whiteBg.frame.origin.x, _whiteBg.frame.origin.y, 0, _whiteBg.frame.size.height);
        _whiteView.frame = CGRectMake(_whiteView.frame.origin.x, _whiteView.frame.origin.y, 0, _whiteView.frame.size.height);
        _bgView.alpha = 0;
        [self.cityTableView removeFromSuperview];
        
    } completion:^(BOOL finished) {
        
        //红色区域动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(whiteViewTime*0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:redViewTime*0.6 animations:^{
                
            _redView.frame = CGRectMake(_redView.frame.origin.x, _redView.frame.origin.y, _redView.frame.size.width, redBtnH);
            _backButton.frame = CGRectMake(_backButton.frame.origin.x, _redView.frame.origin.y, redBtnW, redBtnH);
                
                
                [_backButton removeFromSuperview];
                [self.bgView removeFromSuperview];
                
                _redBtn.backgroundColor = kColor;
                
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(redViewTime*0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_redView removeFromSuperview];
                    [self.provinceTableView removeFromSuperview];
                    _redBtn.userInteractionEnabled = YES;
                    
                    self.userInteractionEnabled = NO;
                    [self.cityTableView removeFromSuperview];
                    [self.whiteBg removeFromSuperview];
                    [self.whiteView removeFromSuperview];
                });
            }];
        });
    }];
    
}


#pragma mark tableview代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:_provinceTableView]) {
        
        return _provinceDataArr.count;
    }else{
    
        return _cityDataArr.count;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 35*kScaleH;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJCell *cell = [[TJCell alloc]init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([tableView isEqual:_provinceTableView]) {
        
        if (_provinceDataArr.count > indexPath.row) {
            [cell setProvinceDataWithDictionary: _provinceDataArr[indexPath.row]];
        }
        
        if (_proLastIndex < indexPath.row) {
            _proLastIndex = indexPath.row;
        }
        
        if (self.provinceCellArr.count>_proLastIndex) {
            [self.provinceCellArr replaceObjectAtIndex:indexPath.row withObject:cell];
        }else{
            [self.provinceCellArr addObject:cell];
        }
        
        if (_currentIndex == indexPath.row) {
            cell.seprateLine.hidden = NO;
            self.currentProvCell = cell;
            
        }else{
            cell.seprateLine.hidden = YES;
        }
        
        
    }else{
        
        if (_cityDataArr.count > indexPath.row) {
            
            [cell setCityDataWithDictionary:_cityDataArr[indexPath.row]];
        }
        
        if (_cityLastIndex < indexPath.row) {
            _cityLastIndex = indexPath.row;
        }
        
        if (self.cityCellArr.count > _cityLastIndex) {
            [self.cityCellArr replaceObjectAtIndex:indexPath.row withObject:cell];
        }else{
            [self.cityCellArr addObject:cell];
        }
        
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
    _currentIndex = index;
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if ([tableView isEqual:_provinceTableView]) {
        
        self.currentProvCell.seprateLine.hidden = YES;
        
        if (_provinceCellArr.count > index ) {
            TJCell *cell = _provinceCellArr[index];
            cell.seprateLine.backgroundColor = [UIColor whiteColor];
            cell.seprateLine.hidden = NO;
            self.currentProvCell = cell;
        }
        
        _cityDataArr = _provinceDataArr[indexPath.row][@"citys"];
        
        [self.positionDict setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"index"];
        [_positionDict setValue:_provinceDataArr[indexPath.row][@"id"] forKey:@"provinceID"];
        [_positionDict setValue:_provinceDataArr[indexPath.row][@"name"] forKey:@"province"];
        
        //更新第二级tableview的数据
        [_cityCellArr removeAllObjects];
        [_cityTableView reloadData];
       
    }else{
        
        //改变下划线
//        self.currentCityCell.seprateLine.hidden = YES;
//        NSLog(@"%ld",(unsigned long)_cityCellArr.count);
//        TJCell *cell = _cityCellArr[index];
//        cell.seprateLine.backgroundColor = [UIColor lightGrayColor];
//        cell.seprateLine.hidden = NO;
//        self.currentCityCell = cell;

        NSString *city = _cityDataArr[indexPath.row][@"name"];
        if ([city isEqualToString:@"其他"]) {
            city = _positionDict[@"province"]?_positionDict[@"province"]:@"小模呵呵了";
        }
        
        city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];

        [self.positionDict setValue:city forKey:@"city"];
        [_positionDict setValue:_cityDataArr[indexPath.row][@"id"] forKey:@"cityID"];
        
        _currentAdr = city;
        if (indexPath.row == 0) {
            
            _currentAdr = _cityDataArr[0][@"name"];
            _currentAdr = [_currentAdr stringByReplacingOccurrencesOfString:@"市" withString:@""];
            
        }
        
        [self setupUI];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //将用户选择位置存入沙盒
            
            [self savePositionInfo];
            
            [self closeAnimation];
             //获取到当前两级tableview数据，通知界面刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDataWithPosition" object:nil userInfo:nil];
            
        });
        
        
    }
    
}

-(void)savePositionInfo{
    
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"currentPosition.plist"];
    

    [self.positionDict writeToFile:filePath atomically:YES];
}

-(void)getCityData{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"currentPosition.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if (!dict) {
        NSLog(@"首次登陆");
        _currentAdr = @"定位中";
        
        self.cityDataArr = _provinceDataArr[0][@"citys"];
        _currentIndex = 0;
    }else{
        
        NSString *indexStr = dict[@"index"];
        NSInteger  index = indexStr.integerValue;
        
        _currentAdr = dict[@"city"];
        _cityDataArr = _provinceDataArr[index][@"citys"];
        _currentIndex = index;
    }
}



//响应链条处理
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 当touch point是在_btn上，则hitTest返回_btn
    CGPoint btnPointInA = [_redBtn convertPoint:point fromView:self];
    CGPoint btnPointInB = [_whiteView convertPoint:point fromView:self];
    CGPoint btnPointInC = [_redView convertPoint:point fromView:self];
    if ([_redBtn pointInside:btnPointInA withEvent:event]) {
        NSLog(@"点击redbtn");
        
        return _redBtn;
    }else if ([_whiteView pointInside:btnPointInB withEvent:event]){
        _whiteView.userInteractionEnabled = YES;
        
    }else if([_redView pointInside:btnPointInC withEvent:event]){
        
    }else{

        [self closeAnimation];
        // 否则，返回默认处理
    }
    
    return [super hitTest:point withEvent:event];
    
}

#pragma mark 懒加载
-(UIView *)bgView{
    if (!_bgView) {
        
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)+kNavHeight)];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.5;
        
    }
    return _bgView;
}

-(UIButton *)bgButton{
    if (_bgButton) {
        _bgButton = [[UIButton alloc]initWithFrame:self.bounds];
        [_bgButton addTarget:self action:@selector(closeAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

-(UIView *)redView{
    if (!_redView) {
        
        _redView = [[UIView alloc]initWithFrame:CGRectMake(redBtnX, redBtnY, redBtnW, redBtnH)];
        _redView.backgroundColor = kColor;
        _redView.alpha = 0.7;
        _redView.layer.cornerRadius = _redView.frame.size.width*0.5;
        _redView.clipsToBounds = YES;
        
    }
    return _redView;
}

-(UIButton *)backButton{
    if (!_backButton) {
        
        _backButton = [[UIButton alloc]initWithFrame:_redBtn.frame];
        [_backButton setImage:[UIImage imageNamed:@"triangle"] forState:UIControlStateNormal];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(20*kScaleW, 25*kScaleW, 30*kScaleW, 25*kScaleW);
        _backButton.layer.cornerRadius = _backButton.frame.size.width * 0.5;
        _backButton.clipsToBounds = YES;
        _backButton.backgroundColor = kColor;
        
        [_backButton addTarget:self action:@selector(closeAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}


-(UIButton *)redBtn{
    
    if (!_redBtn) {
        
        _redBtn = [[UIButton alloc]initWithFrame:CGRectMake(redBtnX, redBtnY, redBtnW, redBtnH)];
        _redBtn.backgroundColor = kColor;
        _redBtn.layer.cornerRadius = _redBtn.frame.size.width*0.5;
        _redBtn.clipsToBounds = YES;
        _redBtn.alpha = 0.7;
        [_redBtn addTarget:self action:@selector(didButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redBtn;
    
}

-(UIImageView *)whiteBg{
    if (!_whiteBg) {
        _whiteBg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_redView.frame),CGRectGetMinY(_redView.frame)+CGRectGetHeight(_backButton.frame)*0.5, 0, CGRectGetHeight(_redView.frame)-CGRectGetHeight(_backButton.frame))];
        
        _whiteBg.image = [UIImage imageNamed:@"adressBg"];
    }
    return _whiteBg;
}

-(UIView *)whiteView{
    if (!_whiteView) {
        _whiteView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_whiteBg.frame), CGRectGetMinY(_whiteBg.frame)+CGRectGetHeight(_redBtn.frame)*0.5, 0, redViewH-CGRectGetHeight(_redBtn.frame))];
        _whiteView.backgroundColor = [UIColor clearColor];
    }
    return _whiteView;
}

-(UITableView *)provinceTableView{
    if (!_provinceTableView) {
        _provinceTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_redBtn.frame)+5, CGRectGetWidth(_redBtn.frame), redViewH-CGRectGetHeight(_redBtn.frame)*2 - 10)];

        _provinceTableView.delegate = self;
        _provinceTableView.dataSource = self;
        _provinceTableView.backgroundColor = [UIColor clearColor];
        _provinceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _provinceTableView;
}

-(UITableView *)cityTableView{
    if (!_cityTableView) {
        
        _cityTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, whiteBgW, redViewH-CGRectGetHeight(_redBtn.frame)*2)];
        _cityTableView.delegate = self;
        _cityTableView.dataSource = self;
        _cityTableView.backgroundColor = [UIColor clearColor];
        _cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _cityTableView;
}



-(NSMutableArray *)provinceCellArr{
    if (!_provinceCellArr) {
        _provinceCellArr = [NSMutableArray array];
    }
    return _provinceCellArr;
}

-(NSMutableArray *)cityCellArr{
    if (!_cityCellArr) {
        _cityCellArr = [NSMutableArray array];
    }
    return _cityCellArr;
}

-(NSMutableArray *)cityDataArr{
    if (!_cityDataArr) {
        _cityDataArr = [NSMutableArray array];
    }
    return _cityDataArr;
}

-(NSMutableDictionary *)positionDict{
    if (!_positionDict) {
        _positionDict = [NSMutableDictionary dictionary];
    }
    return _positionDict;
}

@end
