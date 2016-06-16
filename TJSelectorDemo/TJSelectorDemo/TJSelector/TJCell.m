//
//  TJCell.m
//  TJAdressDemo
//
//  Created by TanJian on 16/5/18.
//  Copyright © 2016年 Joshpell. All rights reserved.
//

#import "TJCell.h"

#define  kDeviceWidth        [[UIScreen mainScreen] bounds].size.width
#define  kDeviceHeight       [[UIScreen mainScreen] bounds].size.height

#define kscale kDeviceWidth/375
@implementation TJCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    _seprateLine.hidden = YES;
    _contentLabel.font = [UIFont systemFontOfSize:14*kscale];
}

- (instancetype)init
{
    
    return [[NSBundle mainBundle]loadNibNamed:@"TJCell" owner:self options:nil].lastObject;
}

-(void)setProvinceDataWithDictionary:(NSDictionary *)dict{
    
    _contentLabel.text = dict[@"name"];
    if (_contentLabel.text.length>4) {
        [_contentLabel setAdjustsFontSizeToFitWidth:YES];
    }
    _contentLabel.textColor = [UIColor whiteColor];
    _seprateLine.backgroundColor = [UIColor whiteColor];
    
}

-(void)setCityDataWithDictionary:(NSDictionary *)dict{
    
    NSString *str = dict[@"name"];
    str = [str stringByReplacingOccurrencesOfString:@"市" withString:@""];
    _contentLabel.text = str;
    
    if (_contentLabel.text.length>6) {
        [_contentLabel setAdjustsFontSizeToFitWidth:YES];
    }
    _contentLabel.textColor = [UIColor grayColor];
    _seprateLine.backgroundColor = [UIColor grayColor];
}

-(void)setFontWithString:(NSString *)str{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
