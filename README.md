DTRequestVerifier
=================

Easy, extensible NSURLRequest verification for unit testing.

### Supported properties:
* HTTP method
* Host
* Path
* Query parameters
* Body parameters (Raw, JSON, Plist)
* HTTP header fields
* any other NSURLRequest property via subclassing

### Sample usage with XCTest:

```objective-c
NSURL * url = [NSURL URLWithString:@"www.google.com/test?query=foo&count=5"] 
NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];

DTRequestVerifier * verifier = [DTRequestVerifier verifier];
verifier.host = @"www.google.com";
verifier.path = @"/test";
verifier.queryParams = @{@"query":@"foo",@"count":@"5"};

XCTAssertFalse([verifier verifyRequest:request]);
```

### Advanced example

```objective-c
NSDictionary * parameters = @{@"foo":@"bar", @"apikey":@"12345"};
NSURL * url = [NSURL URLWithString:@"www.google.com/user/create"];
NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
request.HTTPMethod = @"POST";
[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters
                                                     options:0
                                                       error:nil]];

DTRequestVerifier * verifier = [DTRequestVerifier verifier];
verifier.host = @"www.google.com";
verifier.path = @"/user/create";
verifier.HTTPMethod = @"POST";
verifier.bodyParams = parameters;

XCTAssertFalse([verifier verifyRequest:request]);
```

### OHHTTPStubs

Though DTRequestVerifier can be used as a standalone tool, it can also greatly help, when using another testing frameworks, for example [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs).

```objective-c

NSString *path =[[NSBundle mainBundle] pathForResource:@"Example" ofType:@"json"];
[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [verifier verifyRequest:request];
    } 
                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:path
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/json"}];
}];
```

### Best practices

[AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking) introduced great request serialization system, that can greatly reduce amount of code needed to create NSURLRequests. You should definitely check it out!
