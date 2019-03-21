//
//  VTPaymentController.m
//  MidtransKit
//
//  Created by Nanang Rafsanjani on 5/11/16.
//  Copyright © 2016 Veritrans. All rights reserved.
//

#import "MidtransUIPaymentController.h"
#import "VTClassHelper.h"
#import "SNPMaintainView.h"
#import "MidtransUIHudView.h"
#import "MidtransUIToast.h"
#import "MidtransPaymentStatusViewController.h"
#import "VTKeyboardAccessoryView.h"
#import "VTMultiGuideController.h"
#import "VTSingleGuideController.h"
#import "MidtransUIThemeManager.h"
#import "VTKITConstant.h"
#import "MidtransPaymentStatusViewController.h"
#import "MidtransLoadingView.h"
#import "MidtransUIConfiguration.h"
#import "VTBillpaySuccessController.h"
#import "VTVASuccessStatusController.h"
#import "VTIndomaretSuccessController.h"
#import "VTKlikbcaSuccessController.h"
#import "MIDVendorUI.h"
#import "MIDConstants.h"
#import "MIDUITrackingManager.h"

@interface MidtransUIPaymentController () <SNPMaintainViewDelegate>
@property (nonatomic) VTKeyboardAccessoryView *keyboardAccessoryView;
@property (nonatomic, strong) UIBarButtonItem *backBarButton;
@property (nonatomic) MidtransLoadingView *loadingView;
@property (nonatomic) SNPMaintainView *maintainView;
@property (nonatomic) BOOL dismissButton;

@end

@implementation MidtransUIPaymentController {
    UIImageView *testBadgeView;
}

-(instancetype)init {
    self = [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:VTBundle];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithPaymentMethod:(MIDPaymentDetail *)paymentMethod {
    self = [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:VTBundle];
    if (self) {
        self.paymentMethod = paymentMethod;
    }
    return self;
}

-(void)showBackButton:(BOOL)show  {
    if (show) {
        if (!self.backBarButton) {
            UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                              0.0f,
                                                                              24.0f,
                                                                              24.0f)];
            
            UIImage *image = [UIImage imageNamed:@"back" inBundle:VTBundle compatibleWithTraitCollection:nil];
            [backButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                        forState:UIControlStateNormal];
            [backButton addTarget:self
                           action:@selector(backButtonDidTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
            self.backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        }
        
        self.navigationItem.leftBarButtonItem = self.backBarButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
- (void)backButtonDidTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showDismissButton:(BOOL)show {
    if (show) {
        self.dismissButton = YES;
        if (!self.backBarButton) {
            self.backBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                               target:self
                                                                               action:@selector(dismissButtonDidTapped:)];
        }
        self.navigationItem.leftBarButtonItem = self.backBarButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
- (void)dismissButtonDidTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSACTION_CANCELED object:nil];
    if (self.dismissButton) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count > 1) {
        [self showBackButton:YES];
    }
    
    if ([MIDVendorUI shared].environment != MIDEnvironmentProduction) {
        testBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_badge"]];
        testBadgeView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:testBadgeView];
        NSArray *constraints = @[[testBadgeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                 [testBadgeView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                 ];
        [NSLayoutConstraint activateConstraints:constraints];
    }    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:testBadgeView];
}
-(void)showAlertViewWithTitle:(NSString *)title
                   andMessage:(NSString *)message
               andButtonTitle:(NSString *)buttonTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)addNavigationToTextFields:(NSArray <UITextField*>*)fields {
    _keyboardAccessoryView = [[VTKeyboardAccessoryView alloc] initWithFrame:CGRectZero fields:fields];
}
- (void)showMerchantLogo:(BOOL)merchantLogo {
    if (merchantLogo) {
    }
    else {
        self.title = self.title;
    }
}

-(void)showMaintainViewWithTtitle:(NSString*)title andContent:(NSString *)content andButtonTitle:(NSString *)buttonTitle {
    [self.maintainView showInView:self.navigationController.view withTitle:title andContent:content andButtonTitle:buttonTitle];
    self.maintainView.delegate = self;
}
-(void)hideMaintain {
    [self.maintainView hide];
}
- (void)maintainViewButtonDidTapped:(NSString *)title {
    [self dismissDemoBadge];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}
- (void)showLoadingWithText:(NSString *)text {
    [self.loadingView showInView:self.navigationController.view withText:text];
}

- (void)hideLoading {
    [self.loadingView hide];
}

- (SNPMaintainView *)maintainView {
    if (!_maintainView) {
        _maintainView = [VTBundle loadNibNamed:@"SNPMaintainView" owner:self options:nil].firstObject;
    }
    return _maintainView;
}
- (MidtransLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [VTBundle loadNibNamed:@"MidtransLoadingView" owner:self options:nil].firstObject;
    }
    return _loadingView;
}

- (void)handleTransactionError:(NSError *)error {
    if (UICONFIG.hideStatusPage) {
        [self dismissDemoBadge];
        NSDictionary *userInfo = @{TRANSACTION_ERROR_KEY:error};
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANSACTION_FAILED
                                                            object:nil
                                                          userInfo:userInfo];
        
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
        return;
    }
    
    VTPaymentStatusController *vc = [VTPaymentStatusController errorTransactionWithError:error paymentMethod:self.paymentMethod];
    
    if ([VTClassHelper hasKindOfController:vc onControllers:self.navigationController.viewControllers] == NO) {
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}

- (void)handleTransactionResult:(MIDPaymentResult *)result {
    if (UICONFIG.hideStatusPage) {
        NSDictionary *userInfo = @{TRANSACTION_RESULT_KEY:[result dictionaryValue]};
        [self dismissDemoBadge];
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANSACTION_PENDING object:nil userInfo:userInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    MidtransPaymentStatusViewController *paymentStatusVC = [[MidtransPaymentStatusViewController alloc] initWithTransactionResult:result];
    if ([VTClassHelper hasKindOfController:paymentStatusVC onControllers:self.navigationController.viewControllers] == NO) {
        [self.navigationController pushViewController:(UIViewController *)paymentStatusVC animated:YES];
    }
}
- (void)handleTransactionPending:(MIDPaymentResult *)result {
    NSDictionary *userInfo = @{TRANSACTION_RESULT_KEY:result.dictionaryValue};
    [self dismissDemoBadge];
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSACTION_PENDING object:nil userInfo:userInfo];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSaveCardError:(NSError *)error {
    NSDictionary *userInfo = @{TRANSACTION_RESULT_KEY:error};
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_CARD_FAILED object:nil userInfo:userInfo];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    return;
}
- (void)handleTransactionSuccess:(MIDPaymentResult *)result {
    if (UICONFIG.hideStatusPage) {
        [self dismissDemoBadge];
        NSDictionary *userInfo = @{TRANSACTION_RESULT_KEY:result.dictionaryValue};
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANSACTION_SUCCESS object:nil userInfo:userInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIViewController *vc;
    if ([result.transactionStatus isEqualToString:MIDTRANS_TRANSACTION_STATUS_DENY]) {
        NSError *error = [[NSError alloc] initWithDomain:MIDTRANS_ERROR_DOMAIN
                                                    code:result.statusCode
                                                userInfo:@{NSLocalizedDescriptionKey:result.statusMessage}];
        vc = [VTPaymentStatusController errorTransactionWithError:error paymentMethod:self.paymentMethod];
    }
    else {
        id paymentID = self.paymentMethod.paymentID;
        MIDPaymentMethod method = self.paymentMethod.method;
        
        if (method == MIDPaymentMethodBCAVA ||
            method == MIDPaymentMethodBNIVA ||
            method == MIDPaymentMethodPermataVA ||
            method == MIDPaymentMethodOtherVA) {
            vc = [[VTVASuccessStatusController alloc] initWithPaymentMethod:self.paymentMethod result:result];
        }
        else if ([paymentID isEqualToString:MIDTRANS_PAYMENT_ECHANNEL]) {
            MIDMandiriBankTransferResult *_result = (MIDMandiriBankTransferResult *)result;
            vc = [[VTBillpaySuccessController alloc] initWithPaymentMethod:self.paymentMethod result:_result];
        }
        else if ([paymentID isEqualToString:MIDTRANS_PAYMENT_INDOMARET]) {
            MIDCStoreResult *_result = (MIDCStoreResult *)result;
            vc = [[VTIndomaretSuccessController alloc] initWithResult:_result paymentMethod:self.paymentMethod];
        }
        else if ([paymentID isEqualToString:MIDTRANS_PAYMENT_KLIK_BCA]) {
            MIDKlikbcaResult *_result = (MIDKlikbcaResult *)result;
            vc = [[VTKlikbcaSuccessController alloc] initWithPaymentMethod:self.paymentMethod result:_result];
        }
        else if ([paymentID isEqualToString:MIDTRANS_PAYMENT_KIOS_ON]) {
            vc = [VTPaymentStatusController pendingTransactionWithResult:result paymentMethod:self.paymentMethod];
        }
        else {
            vc = [VTPaymentStatusController successTransactionWithResult:result paymentMethod:self.paymentMethod];
        }
    }
    if ([VTClassHelper hasKindOfController:vc onControllers:self.navigationController.viewControllers] == NO) {
        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    }
}
- (void)dismissDemoBadge {
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    if ([currentWindow viewWithTag:100101]) {
        [[currentWindow viewWithTag:100101] removeFromSuperview];
    }
    
}
- (void)showGuideViewController {
    id paymentID = self.paymentMethod.paymentID;
    
    if ([paymentID isEqualToString:MIDTRANS_PAYMENT_BCA_VA] ||
        [paymentID isEqualToString:MIDTRANS_PAYMENT_ECHANNEL] ||
        [paymentID isEqualToString:MIDTRANS_PAYMENT_PERMATA_VA] ||
        [paymentID isEqualToString:MIDTRANS_PAYMENT_ALL_VA] || [paymentID isEqualToString:MIDTRANS_PAYMENT_OTHER_VA]) {
        
        [[MIDUITrackingManager shared] trackEventName:[NSString stringWithFormat:@"pg %@ va overview",[self.paymentMethod.title lowercaseString]]];
        VTMultiGuideController *vc = [[VTMultiGuideController alloc] initWithPaymentMethodModel:self.paymentMethod];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        VTSingleGuideController *vc = [[VTSingleGuideController alloc] initWithPaymentMethodModel:self.paymentMethod];
        [self.navigationController pushViewController:vc animated:YES];
        [[MIDUITrackingManager shared] trackEventName:[NSString stringWithFormat:@"pg %@ overview",self.paymentMethod.shortName]];
    }
}
-(void)showToastInviewWithMessage:(NSString *)message {
    [MidtransUIToast createToast:message?message:@"Copied to clipboard" duration:1.5 containerView:self.view];
}

- (MIDPaymentInfo *)info {
    return [MIDVendorUI shared].info;
}

- (NSString *)snapToken {
    return [MIDVendorUI shared].snapToken;
}
@end