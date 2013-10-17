//
//  RequestVerifier.h
//  CommandCenter-iPad
//
//  Created by Denys Telezhkin on 25.09.13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

typedef NS_ENUM(NSInteger, DTBodySerializationType) {
    DTBodySerializationTypeRaw = 1,
    DTBodySerializationTypeJSON,
    DTBodySerializationTypePlist
};

@interface DTRequestVerifier : NSObject

+(instancetype)verifier;

-(BOOL)verifyRequest:(NSURLRequest *)request;


/*
 HTTP Method, that will be checked on request.
 
 @"GET" by default.
 */
@property (nonatomic, strong) NSString * HTTPMethod;

@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * path;

/**
 Query params keys should be NSStrings
 */
@property (nonatomic, strong) NSDictionary * queryParams;

@property (nonatomic, strong) NSDictionary * bodyParams;

@property (nonatomic, assign) DTBodySerializationType bodySerializationType;


/*
 Set this property to NO if you don't need log messages to be printed.
 
 Default value is YES;
 */
@property (nonatomic, assign) BOOL loggingEnabled;


@end
