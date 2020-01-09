//
//  MMPageManagerTests.m
//  MMPageManagerTests
//
//  Created by Adam Wulf on 1/8/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MMPageManager/MMPageManager.h>


@interface MMPageManagerTests : XCTestCase

@end


@implementation MMPageManagerTests

- (MMPDFDocument *)normalPDF
{
    return [[MMPDFManager sharedManager] pdfDocumentForURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Normal" withExtension:@"pdf"]];
}

- (MMPDFDocument *)encryptedPDF
{
    return [[MMPDFManager sharedManager] pdfDocumentForURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Encrypted" withExtension:@"pdf"]];
}

- (void)testNormalPDF
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    MMPDFDocument *pdfDocument = [self normalPDF];

    XCTAssertNotNil(pdfDocument, @"Loaded a PDF");
    XCTAssertFalse([pdfDocument isEncrypted], @"not encrypted");
    XCTAssertEqualObjects([pdfDocument title], @"Normal");
    XCTAssertEqual([pdfDocument pageCount], 1, @"one page");
}

- (void)testEncryptedPDF
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    MMPDFDocument *pdfDocument = [self encryptedPDF];

    XCTAssertNotNil(pdfDocument, @"Loaded a PDF");
    XCTAssertTrue([pdfDocument isEncrypted], @"encrypted");
    XCTAssertEqual([pdfDocument pageCount], 3, @"one page");

    // can't get title
    XCTAssertNil([pdfDocument title], @"Normal");

    [pdfDocument doWhileOpen:^{
        XCTAssertFalse([pdfDocument attemptToDecrypt:@"failure"], @"wrong password");
        XCTAssertTrue([pdfDocument isEncrypted], @"encrypted");

        XCTAssertTrue([pdfDocument attemptToDecrypt:@"password"], @"correct password");
        XCTAssertFalse([pdfDocument isEncrypted], @"decrypted");
    }];
}

@end
