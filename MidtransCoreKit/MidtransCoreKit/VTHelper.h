//
//  VTHelper.h
//  MidtransCoreKit
//
//  Created by Nanang Rafsanjani on 2/18/16.
//  Copyright © 2016 Veritrans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const VTMaskedCardsUpdated;
extern NSString *const ErrorDomain;

@interface VTHelper : NSObject
+ (id)nullifyIfNil:(id)object;
@end

@interface NSArray (item)
- (NSArray *)itemsRequestData;
- (NSNumber *)itemsPriceAmount;
@end

@interface NSString (random)
+ (NSString *)randomWithLength:(NSUInteger)length;
@end

@interface UIApplication (utilities)
+ (UIViewController *)rootViewController;
@end

@interface NSMutableDictionary (utilities)
- (id)objectThenDeleteForKey:(NSString *)key;
@end


@interface NSObject (utilities)
+ (NSNumberFormatter *)numberFormatterWith:(NSString *)identifier;
+ (NSDateFormatter *)dateFormatterWithIdentifier:(NSString *)identifier;
@end