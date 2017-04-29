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

@property (nonatomic, strong) NSArray<Example *> *demoDatas;
@end

@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    self.demoDatas = @[
                       [Example exampleWithTitle:@"BallImage " selector:@selector(ballImage)],
                       [Example exampleWithTitle:@"BallTitle " selector:@selector(ballTitle)],
                       [Example exampleWithTitle:@"BallCustom" selector:@selector(ballCustom)],
                       ];
}

#pragma mark - Private Methods

- (void)ballImage {
    MISFloatingBall *floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    floatingBall.backgroundColor = [UIColor redColor];
    [floatingBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [floatingBall visible];
}

- (void)ballTitle {
    DemoBallTitleTableViewController *titleTableVC = [[DemoBallTitleTableViewController alloc] init];
    
    [self.navigationController pushViewController:titleTableVC animated:YES];
}

- (void)ballCustom {
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoDatas.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [self.demoDatas objectAtIndex:indexPath.item].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Example *example = self.demoDatas[indexPath.item];
    if ([self respondsToSelector:example.selctor]) {
        [self performSelector:example.selctor];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}
@end
