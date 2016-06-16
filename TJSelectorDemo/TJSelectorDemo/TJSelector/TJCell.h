//
//  TJCell.h
//  TJAdressDemo
//
//  Created by TanJian on 16/5/18.
//  Copyright © 2016年 Joshpell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *seprateLine;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;



-(void)setProvinceDataWithDictionary:(NSDictionary *)dict;
-(void)setCityDataWithDictionary:(NSDictionary *)dict;


@end
