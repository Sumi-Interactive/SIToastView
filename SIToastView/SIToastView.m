//
//  SIToastView.m
//
//  Created by Kevin Cao on 13-6-14.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import "SIToastView.h"
#import <QuartzCore/QuartzCore.h>

#define PADDING_HORIZONTAL 10
#define PADDING_VERTICAL 8
#define MARGIN 10
#define GAP 10
#define TRANSITION_DURATION 0.4
#define DEFAULT_OFFSET 30.0

NSString *const SIToastViewWillShowNotification = @"SIToastViewWillShowNotification";
NSString *const SIToastViewDidShowNotification = @"SIToastViewDidShowNotification";
NSString *const SIToastViewWillDismissNotification = @"SIToastViewWillDismissNotification";
NSString *const SIToastViewDidDismissNotification = @"SIToastViewDidDismissNotification";

@interface SIToastViewController : UIViewController

@property (nonatomic, strong) SIToastView *toastView;

@end

@implementation SIToastViewController

- (void)loadView
{
    self.view = self.toastView;
}

@end

@interface SIToastView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIWindow *toastWindow;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SIToastView

+ (void)initialize
{
    if (self != [SIToastView class])
        return;
    
    SIToastView *appearance = [self appearance];
    appearance.viewBackgroundColor = [UIColor whiteColor];
    appearance.messageColor = [UIColor darkGrayColor];
    appearance.messageFont = [UIFont systemFontOfSize:16];
    appearance.cornerRadius = 2.0;
    appearance.shadowRadius = 3.0;
    appearance.shadowOpacity = 0.5;
}

+ (SIToastView *)showToastWithMessage:(NSString *)message
{
    SIToastView *view = [[self alloc] init];
    [view showMessage:message];
    return view;
}

+ (SIToastView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration
{
    SIToastView *view = [[self alloc] init];
    [view showMessage:message duration:duration];
    return view;
}

+ (SIToastView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity
{
    SIToastView *view = [[self alloc] init];
    [view showMessage:message duration:duration gravity:gravity];
    return view;
}

+ (SIToastView *)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    SIToastView *view = [[self alloc] init];
    [view showMessage:message duration:duration gravity:gravity offset:offset];
    return view;
}

+ (SIToastView *)showToastWithActivityAndMessage:(NSString *)message
{
    SIToastView *view = [[self alloc] init];
    [view showActivityWithMessage:message];
    return view;
}

+ (SIToastView *)showToastWithActivityAndMessage:(NSString *)message gravity:(SIToastViewGravity)gravity
{
    SIToastView *view = [[self alloc] init];
    [view showActivityWithMessage:message gravity:gravity];
    return view;
}

+ (SIToastView *)showToastWithActivityAndMessage:(NSString *)message gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    SIToastView *view = [[self alloc] init];
    [view showActivityWithMessage:message gravity:gravity offset:offset];
    return view;
}

+ (SIToastView *)showToastWithImage:(UIImage *)image message:(NSString *)message
{
    SIToastView *view = [[self alloc] init];
    [view showImage:image message:message];
    return view;
}

+ (SIToastView *)showToastWithImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration
{
    SIToastView *view = [[self alloc] init];
    [view showImage:image message:message duration:duration];
    return view;
}

+ (SIToastView *)showToastWithImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity
{
    SIToastView *view = [[self alloc] init];
    [view showImage:image message:message duration:duration gravity:gravity];
    return view;
}

+ (SIToastView *)showToastWithImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    SIToastView *view = [[self alloc] init];
    [view showImage:image message:message duration:duration gravity:gravity offset:offset];
    return view;
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setters

- (void)setMessage:(NSString *)message
{
    if ([_message isEqualToString:message]) {
        return;
    }
    _message = [message copy];
    
    if (self.isVisible) {
        [self refresh];
    }
}

- (void)setImage:(UIImage *)image
{
    if (_image == image) {
        return;
    }
    _image = image;
    
    if (self.isVisible) {
        [self refresh];
    }
}

- (void)setShowActivity:(BOOL)showActivity
{
    if (_showActivity == showActivity) {
        return;
    }
    _showActivity = showActivity;
    
    if (self.isVisible) {
        [self refresh];
    }
}

- (void)setDuration:(NSTimeInterval)duration
{
    if (_duration == duration) {
        return;
    }
    _duration = duration;
    
    if (self.isVisible) {
        [self.timer invalidate];
        if (_duration > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
        }
    }
}

- (void)setGravity:(SIToastViewGravity)gravity
{
    if (_gravity == gravity) {
        return;
    }
    _gravity = gravity;
    if (self.isVisible) {
        [self setNeedsLayout];
    }
}

- (void)setOffset:(CGFloat)offset
{
    if (_offset == offset) {
        return;
    }
    _offset = offset;
    if (self.isVisible) {
        [self setNeedsLayout];
    }
}

#pragma mark - Getters

- (BOOL)isVisible
{
    return self.toastWindow != nil;
}

#pragma mark - Public

- (void)show
{
    if (self.isVisible) {
        return;
    }
    
    [self refresh];
    
    [self setupWindow];
    
    [self transitionIn];
}

- (void)showMessage:(NSString *)message
{
    [self showMessage:message duration:0];
}

- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showMessage:message duration:duration gravity:SIToastViewGravityBottom];
}

- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity
{
    [self showMessage:message duration:duration gravity:gravity offset:DEFAULT_OFFSET];
}

- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    if (self.isVisible) {
        return;
    }
    
    self.message = message;
    self.duration = duration;
    self.showActivity = NO;
    self.image = nil;
    self.gravity = gravity;
    self.offset = offset;
    
    [self show];
}

- (void)showActivityWithMessage:(NSString *)message
{
    [self showActivityWithMessage:message gravity:SIToastViewGravityBottom];
}

- (void)showActivityWithMessage:(NSString *)message gravity:(SIToastViewGravity)gravity
{
    [self showActivityWithMessage:message gravity:gravity offset:DEFAULT_OFFSET];
}

- (void)showActivityWithMessage:(NSString *)message gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    if (self.isVisible) {
        return;
    }
    
    self.message = message;
    self.duration = 0;
    self.showActivity = YES;
    self.image = nil;
    self.gravity = gravity;
    self.offset = offset;
    
    [self show];
}

- (void)showImage:(UIImage *)image message:(NSString *)message
{
    [self showImage:image message:message duration:0];
}

- (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showImage:image message:message duration:duration gravity:SIToastViewGravityBottom];
}

- (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity
{
    [self showImage:image message:message duration:duration gravity:gravity offset:DEFAULT_OFFSET];
}

- (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration gravity:(SIToastViewGravity)gravity offset:(CGFloat)offset
{
    if (self.isVisible) {
        return;
    }
    
    self.message = message;
    self.duration = duration;
    self.showActivity = NO;
    self.image = image;
    self.gravity = gravity;
    self.offset = offset;
    
    [self show];
}

- (void)dismiss
{
    if (!self.isVisible) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self transitionOut];
}

#pragma mark - Layout

- (CGSize)preferredSizeForContainerView
{
    CGFloat width = PADDING_HORIZONTAL * 2;
    CGFloat height = PADDING_VERTICAL * 2;
    
    CGFloat contentHeight;
    
    CGFloat widthForMessageLabel = self.bounds.size.width - PADDING_HORIZONTAL * 2 - MARGIN * 2;
    if (self.activityIndicatorView) {
        widthForMessageLabel -= self.activityIndicatorView.bounds.size.width + GAP;
        width += self.activityIndicatorView.bounds.size.width;
        contentHeight = self.activityIndicatorView.bounds.size.height;
    }
    
    if (self.imageView) {
        widthForMessageLabel -= self.imageView.bounds.size.width + GAP;
        width += self.imageView.bounds.size.width;
        contentHeight = MAX(self.imageView.bounds.size.height, contentHeight);
    }
    
    if (self.messageLabel) {
        CGFloat actualFontSize = self.messageLabel.font.pointSize;
        CGSize size = [self.messageLabel.text sizeWithFont:self.messageLabel.font
                                               minFontSize:self.messageLabel.font.pointSize * self.messageLabel.minimumScaleFactor
                                            actualFontSize:&actualFontSize
                                                  forWidth:widthForMessageLabel
                                             lineBreakMode:NSLineBreakByTruncatingTail];
        if (width > PADDING_HORIZONTAL * 2) {
            width += GAP;
        }
        width += size.width;
        contentHeight = MAX(size.height, contentHeight);
    }
    
    height += contentHeight;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews
{
    CGSize size = [self preferredSizeForContainerView];
    
    CGFloat left = PADDING_HORIZONTAL;
    
    if (self.activityIndicatorView) {
        CGRect frame = self.activityIndicatorView.frame;
        frame.origin.x = left;
        frame.origin.y = round((size.height - self.activityIndicatorView.bounds.size.height) / 2);
        self.activityIndicatorView.frame = frame;
        left += self.activityIndicatorView.bounds.size.width + GAP;
    }
    
    if (self.imageView) {
        CGRect frame = self.imageView.frame;
        frame.origin.x = left;
        frame.origin.y = round((size.height - self.imageView.bounds.size.height) / 2);
        self.imageView.frame = frame;
        left += self.imageView.bounds.size.width + GAP;
    }
    
    if (self.messageLabel) {
        self.messageLabel.frame = CGRectMake(left, PADDING_VERTICAL, size.width - PADDING_HORIZONTAL - left, size.height - PADDING_VERTICAL * 2);
    }
    
    CGFloat x = round((self.bounds.size.width - size.width) / 2);
    CGFloat y = self.gravity == SIToastViewGravityBottom ? (self.bounds.size.height - size.height - self.offset) : self.offset;
    self.containerView.frame = CGRectMake(x, y, size.width, size.height);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.cornerRadius].CGPath;
}

#pragma mark - Private

- (void)setup
{
    self.offset = DEFAULT_OFFSET;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = self.viewBackgroundColor;
    self.containerView.layer.cornerRadius = self.cornerRadius;
    self.containerView.layer.shadowRadius = self.shadowRadius;
    self.containerView.layer.shadowOpacity = self.shadowOpacity;
    self.containerView.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.containerView];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//    [self.containerView addGestureRecognizer:tap];
}

- (void)tearDown
{
    [self.containerView.layer removeAllAnimations]; // cancel animations
    
    [self.messageLabel removeFromSuperview];
    self.messageLabel = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)refresh
{
    [self tearDown];
    
    if (self.message) {
        [self setupMessageLabel];
    }
    self.messageLabel.text = self.message;
    
    if (self.showActivity) {
        [self setupActivityIndicatorView];
    } else {
        if (self.image) {
            [self setupImageView];
            self.imageView.image = self.image;
        }
    }
    
    if (self.duration > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.duration + TRANSITION_DURATION target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
    
    [self setNeedsLayout];
}

- (void)setupMessageLabel
{
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.textColor = self.messageColor;
    self.messageLabel.font = self.messageFont;
    self.messageLabel.minimumScaleFactor = 0.7;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    [self.containerView addSubview:self.messageLabel];
}

- (void)setupActivityIndicatorView
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.color = self.activityIndicatorColor;
    [self.containerView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)setupImageView
{
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.containerView addSubview:self.imageView];
}

- (void)setupWindow
{
    SIToastViewController *viewController = [[SIToastViewController alloc] init];
    viewController.wantsFullScreenLayout = YES;
    viewController.toastView = self;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.opaque = NO;
    window.windowLevel = UIWindowLevelAlert;
    window.userInteractionEnabled = NO;
    window.rootViewController = viewController;
    self.toastWindow = window;
    
    [self.toastWindow makeKeyAndVisible];
}

- (void)transitionIn
{
    if (self.willShowHandler) {
        self.willShowHandler(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewWillShowNotification object:self userInfo:nil];
    
    CGRect originalFrame = self.containerView.frame;
    CGRect rect = originalFrame;
    if (self.gravity == SIToastViewGravityBottom) {
        rect.origin.y = self.bounds.size.height;
    } else {
        rect.origin.y = -rect.size.height;
    }
    self.containerView.frame = rect;
    [UIView animateWithDuration:TRANSITION_DURATION
                     animations:^{
                         self.containerView.frame = originalFrame;
                     }
                     completion:^(BOOL finished) {
                         if (self.didShowHandler) {
                             self.didShowHandler(self);
                         }
                         [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidShowNotification object:self userInfo:nil];
                     }];
}

- (void)transitionOut
{
    if (self.willDismissHandler) {
        self.willDismissHandler(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewWillDismissNotification object:self userInfo:nil];
    
    CGRect rect = self.containerView.frame;
    if (self.gravity == SIToastViewGravityBottom) {
        rect.origin.y = self.bounds.size.height;
    } else {
        rect.origin.y = -rect.size.height;
    }
    [UIView animateWithDuration:TRANSITION_DURATION
                     animations:^{
                         self.containerView.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         if (self.didDismissHandler) {
                             self.didDismissHandler(self);
                         }
                         [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidDismissNotification object:self userInfo:nil];
                         
                         [self.toastWindow removeFromSuperview];
                         self.toastWindow = nil;
                         
                         [self tearDown];
                     }];
}

#pragma mark - UIAppearance setters

- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColor
{
    if (_viewBackgroundColor == viewBackgroundColor) {
        return;
    }
    _viewBackgroundColor = viewBackgroundColor;
    self.containerView.backgroundColor = viewBackgroundColor;
}

- (void)setMessageColor:(UIColor *)messageColor
{
    if (_messageColor == messageColor) {
        return;
    }
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setMessageFont:(UIFont *)messageFont
{
    if (_messageFont == messageFont) {
        return;
    }
    _messageFont = messageFont;
    self.messageLabel.font = messageFont;
    [self setNeedsLayout];
}

- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor
{
    if (_activityIndicatorColor == activityIndicatorColor) {
        return;
    }
    _activityIndicatorColor = activityIndicatorColor;
    self.activityIndicatorView.color = activityIndicatorColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius == shadowRadius) {
        return;
    }
    _shadowRadius = shadowRadius;
    self.containerView.layer.shadowRadius = shadowRadius;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (_shadowOpacity == shadowOpacity) {
        return;
    }
    _shadowOpacity = shadowOpacity;
    self.containerView.layer.shadowOpacity = shadowOpacity;
}

@end
