//
//  Path.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 12.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "RequestVerifierTestCase.h"

@interface PathSpecs : RequestVerifierTestCase

@end

@implementation PathSpecs

- (void)setUp
{
    [super setUp];
    
    self.verifier.host = @"www.foo.com";
    
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com/bar"];
    self.request = [NSMutableURLRequest requestWithURL:url];
}

-(void)testPath
{
    self.verifier.path = @"/bar";
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testPathMissing
{
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testPathWrong
{
    self.verifier.host = @"bar";
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

@end
