//
//  ViewController.m
//  SIToastViewExample
//
//  Created by Kevin Cao on 13-6-14.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import "ViewController.h"
#import "SIToastView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[SIToastView appearance] setViewBackgroundColor:[UIColor darkGrayColor]];
//    [[SIToastView appearance] setMessageColor:[UIColor whiteColor]];
	
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowHandler:) name:SIToastViewWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowHandler:) name:SIToastViewDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissHandler:) name:SIToastViewWillDismissNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissHandler:) name:SIToastViewDidDismissNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)show1:(id)sender
{
//    SIToastView *toastView = [SIToastView showToastWithActivityAndMessage:nil];
//    double delayInSeconds = 3.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [toastView dismiss];
//    });
//    [SIToastView showToastWithMessage:@"Hello Sumi!" duration:3];
    
    [SIToastView showToastWithImage:[UIImage imageNamed:@"checkmark"] message:@"Success Etiam porta sem malesuada magna mollis euismod. " duration:2 gravity:SIToastViewGravityTop offset:50];
    
//    SIToastView *toastView = [[SIToastView alloc] init];
//    toastView.message = @"Etiam porta";
//    toastView.showActivity = YES;
//    toastView.gravity = SIToastViewGravityTop;
//    toastView.offset = 30;
//    toastView.duration = 2;
//    toastView.willShowHandler = ^(SIToastView *toastView) {
//        NSLog(@"willShowHandler, %@", toastView);
//    };
//    toastView.didShowHandler = ^(SIToastView *toastView) {
//        NSLog(@"didShowHandler, %@", toastView);
//    };
//    toastView.willDismissHandler = ^(SIToastView *toastView) {
//        NSLog(@"willDismissHandler, %@", toastView);
//    };
//    toastView.didDismissHandler = ^(SIToastView *toastView) {
//        NSLog(@"didDismissHandler, %@", toastView);
//    };
//    [toastView show];
    
    SIToastView *toastView = [SIToastView showToastWithMessage:@"Ni hao" duration:5];
    toastView.duration = 1;
}

- (IBAction)show2:(id)sender
{
    SIToastView *toastView = [SIToastView showToastWithMessage:@"Etiam porta sem malesuada." duration:1 gravity:SIToastViewGravityTop];
    toastView.offset = 50;
    
    SIToastView *toastView2 = [SIToastView showToastWithActivityAndMessage:@"Etiam"];
    toastView2.activityIndicatorColor = [UIColor blueColor];
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [toastView2 dismiss];
    });
    
//    [SIToastView showActivityWithMessage:@"Etiam porta sem malesuada magna mollis euismod."];
//    [SIToastView showActivityWithMessage:@"Etiam porta sem malesuada magna mollis euismod. Donec id elit non mi porta gravida at eget metus."];
}

#pragma mark - Notifications

- (void)willShowHandler:(NSNotification *)notification
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)didShowHandler:(NSNotification *)notification
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)willDismissHandler:(NSNotification *)notification
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)didDismissHandler:(NSNotification *)notification
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

@end
