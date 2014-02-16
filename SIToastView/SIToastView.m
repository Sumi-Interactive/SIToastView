//
//  SIToastView.m
//
//  Created by Kevin Cao on 13-6-14.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import "SIToastView.h"
#import "SISecondaryWindowRootViewController.h"
#import <QuartzCore/QuartzCore.h>

#define PADDING_HORIZONTAL 10
#define PADDING_VERTICAL 8
#define MARGIN 10
#define GAP 10
#define TRANSITION_DURATION 0.3
#define DEFAULT_OFFSET 30.0

NSString *const SIToastViewWillShowNotification = @"SIToastViewWillShowNotification";
NSString *const SIToastViewDidShowNotification = @"SIToastViewDidShowNotification";
NSString *const SIToastViewWillDismissNotification = @"SIToastViewWillDismissNotification";
NSString *const SIToastViewDidDismissNotification = @"SIToastViewDidDismissNotification";

static NSMutableArray *__si_visible_toast_views;

@interface SIToastViewController : SISecondaryWindowRootViewController

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
    appearance.messageFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    appearance.cornerRadius = 2.0;
    
    __si_visible_toast_views = [NSMutableArray array];
}

+ (SIToastView *)toastView
{
    SIToastView *view = [[self alloc] init];
    return view;
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

+ (NSArray *)visibleToastViews
{
    return [__si_visible_toast_views copy];
}

+ (BOOL)isShowingToastView
{
    return __si_visible_toast_views.count > 0;
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (void)setShowsActivity:(BOOL)showActivity
{
    if (_showsActivity == showActivity) {
        return;
    }
    _showsActivity = showActivity;
    
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
    [self refresh];
    
    if (!self.isVisible) {
        [self setupWindow];
        [__si_visible_toast_views addObject:self];
        [self transitionIn];
    }
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
    _message = message;
    _duration = duration;
    _showsActivity = NO;
    _image = nil;
    _gravity = gravity;
    _offset = offset;
    
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
    _message = message;
    _duration = 0;
    _showsActivity = YES;
    _image = nil;
    _gravity = gravity;
    _offset = offset;
    
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
    _message = message;
    _duration = duration;
    _showsActivity = NO;
    _image = image;
    _gravity = gravity;
    _offset = offset;
    
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

- (void)layoutSubviews
{
    CGFloat left = PADDING_HORIZONTAL;
    CGFloat height = 0;
    
    if (self.activityIndicatorView) {
        [self setX:left forView:self.activityIndicatorView];
        left += self.activityIndicatorView.bounds.size.width + GAP;
        height = self.activityIndicatorView.bounds.size.height;
    }
    
    if (self.imageView) {
        [self setX:left forView:self.imageView];
        left += self.imageView.bounds.size.width + GAP;
        height = MAX(height, self.imageView.bounds.size.height);
    }
    
    if (self.messageLabel) {
        CGFloat maxMessageWidth = self.bounds.size.width - MARGIN * 2;
        maxMessageWidth -= left + PADDING_HORIZONTAL;
        CGRect rect = self.messageLabel.frame;
        rect.origin.x = left;
        rect.size.width = maxMessageWidth;
        self.messageLabel.frame = rect;
        [self.messageLabel sizeToFit];
        left += self.messageLabel.frame.size.width;
        height = MAX(height, self.messageLabel.bounds.size.height);
    }
    
    CGFloat width = left + PADDING_HORIZONTAL;
    height += PADDING_VERTICAL * 2;
    
    if (self.activityIndicatorView) {
        [self setY:round((height - self.activityIndicatorView.bounds.size.height) / 2) forView:self.activityIndicatorView];
    }
    
    if (self.imageView) {
        [self setY:round((height - self.imageView.bounds.size.height) / 2) forView:self.imageView];
    }
    
    if (self.messageLabel) {
        [self setY:round((height - self.messageLabel.bounds.size.height) / 2) forView:self.messageLabel];
    }
    
    CGFloat x = round((self.bounds.size.width - width) / 2);
    CGFloat y = self.gravity == SIToastViewGravityBottom ? (self.bounds.size.height - height - self.offset) : self.offset;
    self.containerView.frame = CGRectMake(x, y, width, height);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.cornerRadius].CGPath;
}

- (void)setX:(CGFloat)x forView:(UIView *)view
{
    CGRect rect = view.frame;
    rect.origin.x = x;
    view.frame = rect;
}
- (void)setY:(CGFloat)y forView:(UIView *)view
{
    CGRect rect = view.frame;
    rect.origin.y = y;
    view.frame = rect;
}

#pragma mark - Private

- (void)setup
{
    self.offset = DEFAULT_OFFSET;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView.backgroundColor = self.viewBackgroundColor;
    self.containerView.layer.cornerRadius = self.cornerRadius;
    self.containerView.layer.shadowRadius = self.shadowRadius;
    self.containerView.layer.shadowOpacity = self.shadowRadius > 0 ? 0.5 : 0;
    self.containerView.layer.shadowOffset = CGSizeZero;
    self.containerView.autoresizesSubviews = NO;
    [self addSubview:self.containerView];
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
        self.messageLabel.text = self.message;
    }
    
    if (self.showsActivity) {
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
    self.messageLabel.numberOfLines = 0;
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
    viewController.extendedLayoutIncludesOpaqueBars = YES;
    viewController.toastView = self;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.opaque = NO;
    window.windowLevel = UIWindowLevelStatusBar + [UIApplication sharedApplication].windows.count;
    window.userInteractionEnabled = NO;
    window.rootViewController = viewController;
    self.toastWindow = window;
    
//    UIWindow *oldKeyWindow = [UIApplication sharedApplication].keyWindow;
    self.toastWindow.hidden = NO;
//    [oldKeyWindow makeKeyWindow];
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
                         [self.toastWindow removeFromSuperview];
                         self.toastWindow = nil;
                         
                         [self tearDown];
                         
                         [__si_visible_toast_views removeObject:self];
                         
                         if (self.didDismissHandler) {
                             self.didDismissHandler(self);
                         }
                         [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidDismissNotification object:self userInfo:nil];
                         
                         
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
    self.containerView.layer.shadowOpacity = shadowRadius > 0 ? 0.5 : 0;
}

@end
