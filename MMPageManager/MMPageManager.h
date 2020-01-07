//
//  MMPageManager.h
//  MMPageManager
//
//  Created by Adam Wulf on 1/7/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for MMPageManager.
FOUNDATION_EXPORT double MMPageManagerVersionNumber;

//! Project version string for MMPageManager.
FOUNDATION_EXPORT const unsigned char MMPageManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MMPageManager/PublicHeader.h>

NS_ASSUME_NONNULL_BEGIN


@interface MMPageManager : NSObject

+ (instancetype)sharedManager;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#import <MMPageManager/MMPDFManager.h>
#import <MMPageManager/MMPDFDocument.h>
