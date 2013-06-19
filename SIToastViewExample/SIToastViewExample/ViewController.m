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
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowHandler:) name:SIToastViewWillShowNotification object:[SIToastView class]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowHandler:) name:SIToastViewDidShowNotification object:[SIToastView class]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissHandler:) name:SIToastViewWillDismissNotification object:[SIToastView class]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissHandler:) name:SIToastViewDidDismissNotification object:[SIToastView class]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)show1:(id)sender
{
//    [SIToastView showActivityWithMessage:nil];
    [SIToastView showMessage:@"Hello Sumi!" duration:3];
}

- (IBAction)show2:(id)sender
{
    [SIToastView showMessage:@"Etiam porta sem malesuada."];
//    [SIToastView showActivityWithMessage:@"Etiam porta sem malesuada magna mollis euismod."];
//    [SIToastView showActivityWithMessage:@"Etiam porta sem malesuada magna mollis euismod. Donec id elit non mi porta gravida at eget metus."];
}

#pragma mark - Notifications

- (void)willShowHandler:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didShowHandler:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)willDismissHandler:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didDismissHandler:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
