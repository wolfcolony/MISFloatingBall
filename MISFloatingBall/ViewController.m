//
//  ViewController.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    [self.button setTitle:@"我是底部控制器的按钮" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor blueColor];
    [self.button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(200, 300, 100, 100)];
    self.testView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.testView];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    
    [self.testView addGestureRecognizer:self.pan];
    [self.testView addGestureRecognizer:self.tap];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touch");
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint transe = [pan translationInView:self.testView];
    
    CGPoint center = self.testView.center;
    center.x += transe.x;
    center.y += transe.y;
    self.testView.center = center;
    
    [pan setTranslation:CGPointZero inView:self.testView];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    NSLog(@"tap");
}

- (void)buttonClick {
    NSLog(@"button click");
    [[AppDelegateManager shareManager].floatinBall disVisibleBall];
}

@end
