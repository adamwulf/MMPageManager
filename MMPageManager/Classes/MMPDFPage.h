//
//  MMPDFPage.h
//  MMPageManager
//
//  Created by Adam Wulf on 1/12/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface MMPDFPage : NSObject

- (instancetype)initWithPDFPage:(PDFPage *)pdfPage;

@property(nonatomic, readonly) CGFloat heightRatio;
@property(nonatomic, readonly) CGFloat pointWidth;
@property(nonatomic, readonly) CGSize idealSize;
@property(nonatomic, strong, readonly) UIImage *thumbnail;
@property(nonatomic, strong, readonly) PDFPage *pdfPage;
@property(nonatomic, assign) CGFloat rotation;

@end

NS_ASSUME_NONNULL_END
