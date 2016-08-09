//
//  YKSHomeTableViewCell.m
//  SoundLive
//
//  Created by Yue Shen on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSHomeTableViewCell.h"

@implementation YKSHomeTableViewCell
{
    UIView *ui_view_container;
    UIImageView *ui_img_poster;
    UILabel *ui_lb_title;
    UILabel *ui_lb_begin_time;
    UIImageView *ui_img_show_status;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setupUI
{
    ui_view_container = [UIView new];
    [self.contentView addSubview:ui_view_container];
    [ui_view_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(-8);
    }];
    
    ui_img_poster = [UIImageView new];
    [ui_view_container addSubview:ui_img_poster];
    [ui_img_poster mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.mas_equalTo(0);
        make.height.mas_equalTo(80);
    }];
    
    ui_lb_title = [UILabel new];
    [ui_view_container addSubview:ui_lb_title];
    [ui_lb_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.top.equalTo(ui_img_poster.mas_bottom).offset(8);
    }];
    
    ui_lb_begin_time = [UILabel new];
    [ui_view_container addSubview:ui_lb_begin_time];
    [ui_lb_begin_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.equalTo(ui_lb_title.mas_bottom).offset(8);
    }];
    
    ui_img_show_status = [UIImageView new];
    [ui_view_container addSubview:ui_img_show_status];
    [ui_img_show_status mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ui_lb_title.mas_bottom).offset(8);
        make.right.mas_equalTo(-8);
    }];
}

- (void)setDataWithDict:(NSDictionary*)dict
{
    [ui_img_show_status sd_setImageWithURL:nil];
}
@end
