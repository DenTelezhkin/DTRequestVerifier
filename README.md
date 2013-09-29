DTRequestVerifier
=================

Easy, extensible NSURLRequest verification for unit testing.

### Sample usage with XCTest:

```objective-c
NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"www.google.com/test?query=foo&data=bar"]];
DTRequestVerifier * verifier = [DTRequestVerifier verifier];
verifier.host = @"www.google.com";
verifier.path = @"/test";
verifier.queryParams = @{@"query":@"foo",@"data":@"bar"};
XCTAssertFalse([verifier verifyRequest:request], @"");
```

### Advanced example

```objective-c
NSDictionary * parameters = @{@"foo":@"bar", @"apikey":@"12345"};
NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"www.google.com/user/create"]];
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
XCTAssertFalse([verifier verifyRequest:request], @"");
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

[AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking) introduced great request serialization system, that can greatly reduce amount of code needed to create NSURLRequests. You should definitely check it out! =)

## Roadmap

* Support for raw parameters query in body data
* Support for multipart requests verification
* CocoaPods!
