//
//  DTRequestVerifierSpecs.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 29.09.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "RequestVerifierTestCase.h"

@interface HTTPMethodHostSpecs : RequestVerifierTestCase
@end

@implementation HTTPMethodHostSpecs

- (void)setUp
{
    [super setUp];
    
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com"];
    self.request = [NSMutableURLRequest requestWithURL:url];
    self.verifier.raiseExceptionOnFailure = NO;
}

-(void)testDefaultHTTPMethod
{
    XCTAssert([self.verifier.HTTPMethod isEqualToString:@"GET"]);
}

-(void)testHTTPMethodShouldFail
{
    self.verifier.HTTPMethod = @"POST";
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testHost
{
    self.verifier.host = @"www.foo.com";
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testHostMissing
{
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testHostWrong
{
    self.verifier.host = @"www.bar.com";
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

@end
