//
//  MMPageManager.m
//  MMPageManager
//
//  Created by Adam Wulf on 1/7/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMPageManager.h"


@implementation MMPageManager

+ (instancetype)sharedManager
{
    static MMPageManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MMPageManager alloc] init];
    });
    return _sharedManager;
}

@end
