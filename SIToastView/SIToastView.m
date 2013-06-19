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
#define MARGIN 5
#define GAP 10
#define TRANSITION_DURATION 2

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

@property (nonatomic, assign) BOOL allowTapToDismiss;
@property (nonatomic, assign) NSUInteger gravity;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, readonly, getter = isVisible) BOOL visible;

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
    appearance.messageFont = [UIFont systemFontOfSize:15];
    appearance.cornerRadius = 2.0;
    appearance.shadowRadius = 3.0;
    appearance.shadowOpacity = 0.5;
}

+ (instancetype)sharedView
{
    static dispatch_once_t pred;
    static id instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
        [instance setup];
    });
    return instance;
}

+ (void)showMessage:(NSString *)message
{
    [[self sharedView] showMessage:message];
}

+ (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration
{
    [[self sharedView] showMessage:message duration:duration];
}

+ (void)showActivityWithMessage:(NSString *)message
{
    [[self sharedView] showActivityWithMessage:message];
}

+ (void)showImage:(UIImage *)image message:(NSString *)message
{
    [[self sharedView] showImage:image message:message];
}

+ (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration
{
    [[self sharedView] showImage:image message:message duration:duration];
}

+ (void)dismiss
{
    [[self sharedView] dismiss];
}

+ (void)setAllowTapToDismiss:(BOOL)allowTapToDimiss
{
    [[self sharedView] setAllowTapToDismiss:allowTapToDimiss];
}

+ (BOOL)allowTapToDismiss
{
    return [[self sharedView] allowTapToDismiss];
}

+ (void)setGravity:(NSUInteger)gravity
{
    [[self sharedView] setGravity:gravity];
}

+ (NSUInteger)gravity
{
    return [[self sharedView] gravity];
}

+ (void)setOffset:(CGFloat)offset
{
    [[self sharedView] setOffset:offset];
}

+ (CGFloat)offset
{
    return [[self sharedView] offset];
}

+ (BOOL)isVisible
{
    return [[self sharedView] isVisible];
}

#pragma mark - Public

- (void)showMessage:(NSString *)message
{
    [self showMessage:message duration:0];
}

- (void)showMessage:(NSString *)message duration:(NSTimeInterval)duration
{
    [self tearDown];
    
    if (message) {
        [self setupMessageLabel];
    }
    
    self.messageLabel.text = message;
    [self setNeedsLayout];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewWillShowNotification object:[self class] userInfo:nil];
    
    [self transitionIn];
    
    if (duration > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:duration + TRANSITION_DURATION target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
}

- (void)showActivityWithMessage:(NSString *)message
{
    [self tearDown];
    
    [self setupActivityIndicatorView];
    if (message) {
        [self setupMessageLabel];
    }
    
    self.messageLabel.text = message;
    [self setNeedsLayout];
    
    [self transitionIn];
}

- (void)showImage:(UIImage *)image message:(NSString *)message
{
    [self showImage:image message:message duration:0];
}

- (void)showImage:(UIImage *)image message:(NSString *)message duration:(NSTimeInterval)duration
{
    [self tearDown];
    
    if (image) {
        [self setupImageView];
    }
    if (message) {
        [self setupMessageLabel];
    }
    
    self.imageView.image = image;
    self.messageLabel.text = message;
    [self setNeedsLayout];
    
    [self transitionIn];
    
    if (duration > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:duration + TRANSITION_DURATION target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
}

- (void)dismiss
{
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
    
    if (self.messageLabel) {
        self.messageLabel.frame = CGRectMake(left, PADDING_VERTICAL, size.width - PADDING_HORIZONTAL - left, size.height - PADDING_VERTICAL * 2);
    }
    
    self.containerView.frame = CGRectMake(round((self.bounds.size.width - size.width) / 2), self.bounds.size.height - size.height - self.offset - self.shadowRadius, size.width, size.height);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.cornerRadius].CGPath;
}

#pragma mark - Private

- (BOOL)isVisible
{
    return self.toastWindow != nil;
}

- (void)setup
{
//    self.gravity = 0;
    self.offset = 10.0;
    
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
    [self.timer invalidate];
    self.timer = nil;
    [self.messageLabel removeFromSuperview];
    self.messageLabel = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.containerView.layer removeAllAnimations]; // cancel animations
}

- (void)setupMessageLabel
{
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.backgroundColor = [UIColor clearColor];
//    self.messageLabel.backgroundColor = [UIColor redColor];
    self.messageLabel.textColor = self.messageColor;
    self.messageLabel.font = self.messageFont;
    self.messageLabel.minimumScaleFactor = 0.7;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    [self.containerView addSubview:self.messageLabel];
}

- (void)setupActivityIndicatorView
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.containerView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)setupImageView
{
    self.imageView = [[UIImageView alloc] init];
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
    if (self.isVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidShowNotification object:[self class] userInfo:nil];
        return;
    }
    
    [self setupWindow];

    CGRect originalFrame = self.containerView.frame;
    CGRect rect = originalFrame;
    rect.origin.y = self.bounds.size.height;
    self.containerView.frame = rect;
    [UIView animateWithDuration:TRANSITION_DURATION
                     animations:^{
                         self.containerView.frame = originalFrame;
                     }
                     completion:^(BOOL finished) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidShowNotification object:[self class] userInfo:nil];
                     }];
}

- (void)transitionOut
{
    if (!self.isVisible) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewWillDismissNotification object:[self class] userInfo:nil];
    
    CGRect rect = self.containerView.frame;
    rect.origin.y += (self.bounds.size.height - self.containerView.bounds.origin.y);
    [UIView animateWithDuration:TRANSITION_DURATION
                     animations:^{
                         self.containerView.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         if (!finished) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidDismissNotification object:[self class] userInfo:nil];
                             return;
                         }
                         
                         [self.toastWindow removeFromSuperview];
                         self.toastWindow = nil;
                         
                         [self tearDown];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:SIToastViewDidDismissNotification object:[self class] userInfo:nil];
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
