//
//  DemoTableViewController.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/29.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoBallTitleTableViewController.h"

#import "MISFloatingBall.h"
#import "MISCustomButton.h"

#import "DemoBallSpecifiedViewController.h"

@interface Example : NSObject
@property (nonatomic,   copy) NSString *title;
@property (nonatomic, assign) SEL selctor;
@end

@implementation Example

+ (instancetype)exampleWithTitle:(NSString *)title selector:(SEL)selector {
    Example *example = [[Example alloc] init];
    example.title = title;
    example.selctor = selector;
    return example;
}
@end

@interface DemoTableViewController ()
@property (nonatomic, strong) NSArray *headerTitles;
@property (nonatomic, strong) NSArray<NSArray<Example *> *> *demoDatas;

@property (nonatomic, strong) DemoBallTitleTableViewController *titleTableVC;
@end

@implementation DemoTableViewController

- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerTitles = @[
                          @"Globally", @"SpecifiedView",
                          ];
    
    self.demoDatas = @[
                       @[
                           [Example exampleWithTitle:@"图片悬浮球 " selector:@selector(imageBall)],
                           [Example exampleWithTitle:@"标题悬浮球 " selector:@selector(titleBall)],
                           [Example exampleWithTitle:@"自定义视图" selector:@selector(customBall)],
                           [Example exampleWithTitle:@"自动靠边" selector:@selector(autoCloseEdge)],
                           [Example exampleWithTitle:@"自动向边缘缩进" selector:@selector(autoEdgeRetract)],
                           [Example exampleWithTitle:@"只能左右停靠" selector:@selector(leftRight)],
                           ],
                       @[
                           [Example exampleWithTitle:@"当前View生效ball " selector:@selector(specifiedView)],
                           ]
                       ];
}

#pragma mark - Private Methods

- (void)imageBall {
    MISFloatingBall *globallyBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    globallyBall.backgroundColor = [UIColor redColor];
    [globallyBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [globallyBall visible];
    
    __block typeof(globallyBall) blockBall = globallyBall;
    [globallyBall setClickHander:^{
        [blockBall disVisible];
    }];
}

- (void)titleBall {
    [self.navigationController pushViewController:self.titleTableVC animated:YES];
}

- (void)customBall {
    MISFloatingBall *globallyBall = [[MISFloatingBall alloc] initWithFrame: CGRectMake(30, 30, 100, 100)];
    globallyBall.backgroundColor = [UIColor blueColor];
    
    MISCustomButton *button = [[MISCustomButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.imageSize = CGSizeMake(44, 44);
    [button setImage:[UIImage imageNamed:@"apple"] forState:UIControlStateNormal];
    [button setTitle:@"一个图片" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    button.backgroundColor = [UIColor redColor];
    
    [globallyBall setContent:button contentType:MISFloatingBallContentTypeCustomView];
    [globallyBall visible];
    
    __block typeof(globallyBall) blockBall = globallyBall;
    [globallyBall setClickHander:^{
        [blockBall disVisible];
    }];
}

- (void)autoCloseEdge {
    MISFloatingBall *floating = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    // 自动靠边
    floating.autoCloseEdge = YES;
    [floating setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [floating visible];
    
    __block typeof(floating) blockBall = floating;
    [floating setClickHander:^{
        [blockBall disVisible];
    }];
}

- (void)autoEdgeRetract {
    MISFloatingBall *floating = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    floating.autoCloseEdge = YES;
    [floating setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [floating visible];
    
    // 3s后缩进
    [floating autoEdgeRetractDuration:3.0f edgeRetractConfigHander:^MISEdgeRetractConfig{
        return MISEdgeOffsetConfigMake(CGPointMake(20, 20), 0.7f);
    }];
    
    __block typeof(floating) blockBall = floating;
    [floating setClickHander:^{
        [blockBall disVisible];
    }];
}

- (void)leftRight {
    MISFloatingBall *globallyBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    globallyBall.autoCloseEdge = YES;
    // 更改靠边策略
    globallyBall.edgePolicy = MISFloatingBallEdgePolicyLeftRight;
    
    globallyBall.backgroundColor = [UIColor redColor];
    [globallyBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [globallyBall visible];
    
    __block typeof(globallyBall) blockBall = globallyBall;
    [globallyBall setClickHander:^{
        [blockBall disVisible];
    }];
}

- (void)specifiedView {
    DemoBallSpecifiedViewController *demoVC = [[DemoBallSpecifiedViewController alloc] init];
    [self.navigationController pushViewController:demoVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoDatas[section].count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [self.demoDatas objectAtIndex:indexPath.section][indexPath.item].title;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headerTitles[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Example *example = self.demoDatas[indexPath.section][indexPath.item];
    if ([self respondsToSelector:example.selctor]) {
        [self performSelector:example.selctor];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}


- (DemoBallTitleTableViewController *)titleTableVC {
    if (!_titleTableVC) {
        _titleTableVC = [[DemoBallTitleTableViewController alloc] init];
    }
    return _titleTableVC;
}
@end
