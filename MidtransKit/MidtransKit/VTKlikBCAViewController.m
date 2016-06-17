//
//  VTKlikBCAViewController.m
//  MidtransKit
//
//  Created by Arie on 6/16/16.
//  Copyright © 2016 Veritrans. All rights reserved.
//

#import "VTKlikBCAViewController.h"
#import "VTKlikBCAView.h"
#import "VTClassHelper.h"
#import "VTTextField.h"
#import "VTPaymentGuideController.h"
#import "UIViewController+HeaderSubtitle.h"
#import <MidtransCoreKit/MidtransCoreKit.h>
@interface VTKlikBCAViewController ()
@property (strong, nonatomic) IBOutlet VTKlikBCAView *view;

@end

@implementation VTKlikBCAViewController
@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(self.paymentMethod.title,nil);
    NSNumberFormatter *formatter = [NSNumberFormatter indonesianCurrencyFormatter];
    self.view.totalAmountLabel.text = [formatter stringFromNumber:self.transactionDetails.grossAmount];
    self.view.orderIdLabel.text = self.transactionDetails.orderId;
}

- (IBAction)confirmPaymentButtonDidTapped:(id)sender {
    if (self.view.userIdTextField.text.isEmpty) {
        self.view.userIdTextField.warning = @"Cannot be empty";
        return;
    }
    else {
        [self showLoadingHud];
        VTPaymentKlikBCA *paymentDetails = [[VTPaymentKlikBCA alloc] initWithKlikBCAUserId:self.view.userIdTextField.text];
        VTTransaction *transaction = [[VTTransaction alloc] initWithPaymentDetails:paymentDetails transactionDetails:self.transactionDetails customerDetails:self.customerDetails itemDetails:self.itemDetails];
        [[VTMerchantClient sharedClient] performTransaction:transaction completion:^(VTTransactionResult *result, NSError *error) {
            [self hideLoadingHud];
            if (error) {
                [self handleTransactionError:error];
            } else {
                [self handleTransactionSuccess:result];
            }
        }];
    }
}
- (IBAction)guideButtonDidtapped:(id)sender {
    [self showGuideViewControllerWithPaymentName:[self.paymentMethod.title lowercaseString]];
}

@end
