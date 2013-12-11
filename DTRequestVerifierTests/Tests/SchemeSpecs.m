//
//  SchemeSpecs.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 19.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestVerifierTestCase.h"

@interface SchemeSpecs : RequestVerifierTestCase

@end

@implementation SchemeSpecs

- (void)setUp
{
    [super setUp];
    
    self.verifier.host = @"www.foo.com";
    
    NSURL * url = [NSURL URLWithString:@"https://www.foo.com"];
    self.request = [NSMutableURLRequest requestWithURL:url];
}

-(void)testSchemeValidation
{
    self.verifier.scheme = @"https";
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testSchemeFailure
{
    self.verifier.scheme = @"ftp";
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testDefaultScheme
{
    XCTAssert([self.verifier.scheme isEqualToString:@"http"]);
}

@end
