//
//  SIToastView.h
//
//  Created by Kevin Cao on 13-6-14.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SIToastViewWillShowNotification;
extern NSString *const SIToastViewDidShowNotification;
extern NSString *const SIToastViewWillDismissNotification;
extern NSString *const SIToastViewDidDismissNotification;

@interface SIToastView : UIView

@property (nonatomic, strong) UIColor *viewBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *messageColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *messageFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat shadowRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat shadowOpacity NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

//@property (nonatomic, assign) BOOL allowTapToDismiss;
//@property (nonatomic, assign) NSUInteger gravity;
//@property (nonatomic, assign) CGFloat offset;
//@property (nonatomic, readonly, getter = isVisible) BOOL visible;

+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration;
+ (void)showActivityWithMessage:(NSString *)message;
+ (void)showImage:(UIImage *)image message:(NSString *)message;
+ (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration;
+ (void)dismiss;
//+ (void)setAllowTapToDismiss:(BOOL)allowTapToDimiss;
//+ (BOOL)allowTapToDismiss;
+ (void)setGravity:(NSUInteger)gravity;
+ (NSUInteger)gravity;
+ (void)setOffset:(CGFloat)offset;
+ (CGFloat)offset;
+ (BOOL)isVisible;

//- (void)showMessage:(NSString *)message inView:(UIView *)view;
//- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration inView:(UIView *)view;
//- (void)showActivityWithMessage:(NSString *)message inView:(UIView *)view;
//- (void)showImage:(UIImage *)image message:(NSString *)message inView:(UIView *)view;
//- (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration inView:(UIView *)view;
//- (void)dismiss;

@end

//@interface UIView (SIToastView)
//
//- (void)showToastWithMessage:(NSString *)message;
//- (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration;
//- (void)showToastWithActivityAndMessage:(NSString *)message;
//- (void)showToastWithImage:(UIImage *)image message:(NSString *)message;
//- (void)showToastWithImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration;
//- (void)dismissToast;
//
//@end
