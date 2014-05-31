//
//  HTTPHeadersSpecs.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 17.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestVerifierTestCase.h"

@interface HTTPHeadersSpecs : RequestVerifierTestCase

@end

@implementation HTTPHeadersSpecs

- (void)setUp
{
    [super setUp];
    
    self.verifier.host = @"www.foo.com";
    
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com"];
    self.request = [NSMutableURLRequest requestWithURL:url];
    self.verifier.raiseExceptionOnFailure = NO;
}

-(void)testEmptyHeaderExpectationsShouldPass
{
    [self.request setValue:@"foo" forHTTPHeaderField:@"Cookie"];
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testHeaderExpectationsShouldPass
{
    [self.request setValue:@"foo" forHTTPHeaderField:@"Authorization"];
    [self.request setValue:@"bar" forHTTPHeaderField:@"Cookie"];
    
    self.verifier.HTTPHeaderFields = @{@"Authorization": @"foo"};
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testHeaderExpectationsShouldFail
{
    self.verifier.HTTPHeaderFields = @{@"Authorization": @"foo"};
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

@end
