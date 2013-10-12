//
//  RequestVerifierTestCase.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 12.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "RequestVerifierTestCase.h"

@implementation RequestVerifierTestCase

-(void)setUp
{
    [super setUp];
    self.verifier = [DTRequestVerifier verifier];
    self.verifier.loggingEnabled = NO;
}

@end
