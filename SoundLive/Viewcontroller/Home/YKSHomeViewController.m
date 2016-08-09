//
//  YKSHomeViewController.m
//  SoundLive
//
//  Created by Yue Shen on 16/8/8.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSHomeViewController.h"
#import "YKSHomeTableViewCell.h"
@interface YKSHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * ui_table_home;
    NSArray *dataArr;
}
@end

@implementation YKSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

#pragma mark - table delegate & datasourc
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YKSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return  cell;
}

#pragma mark - setup
- (void)setupData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"plist"];
    dataArr = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

- (void)setupUI
{
    ui_table_home = [UITableView new];
    ui_table_home.delegate = self;
    ui_table_home.dataSource = self;
    [ui_table_home registerClass:[YKSHomeTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:ui_table_home];
    [ui_table_home mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}


@end
