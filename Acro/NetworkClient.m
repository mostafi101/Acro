//
//  NetworkClient.m
//  Acro
//
//  Created by Mostafijur Rahaman on 3/14/16.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

#import "NetworkClient.h"
#import "Meaning.h"

@implementation NetworkClient

+(NetworkClient *) sharedManager {
    
    static NetworkClient *sharedManager = nil;
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        sharedManager = [[NetworkClient alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}

- (void)getResponseForURLString: (NSString *)urlString Parameters:(NSDictionary *) parameters success:(ServiceSuccessBlock) success failure:(ServiceFailureBlock) failure
{
    
/*
 *AFURLResponseSerialization accepts @"application/json", @"text/json", @"text/javascript".
 
 *But this api is sending "Content-Type" = "text/plain;
 http://www.nactem.ac.uk/software/acromine/dictionary.py
 */
    // Below line is to accept response of any type
    self.responseSerializer.acceptableContentTypes = nil;
    
    [self GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        if (success) {
            success(task, [self parseResponseObject:responseObject]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark- Simple JSON to Object mapper methods

/* 
 * Below helper methods for object mapping and For large set of services, better implement a generic solution.
 */

-(Acronym *) parseResponseObject:(id) responseObject {
    
    if([responseObject isKindOfClass:[NSArray class]] && [responseObject count] > 0 ){
        for(NSDictionary *dict in responseObject){
            
        // the response object is of type array, but I just capturing 1st object as the response of this web service.            
            Acronym *acronym = [[Acronym alloc] init];
            [acronym setShortForm: [dict objectForKey:@"sf"]] ;
            [acronym setMeanings:[self getMeanings:[dict objectForKey:@"lfs"]]];
            return acronym;
        }
        
    }
    return nil;
}
-(NSMutableArray *) getMeanings:(NSMutableArray *) responseArray {
    NSMutableArray *meaningArray = [NSMutableArray array];
    for(NSDictionary *dict in responseArray){
        
        Meaning *meaning = [[Meaning alloc] init];
        [meaning setMeaning: [dict objectForKey:@"lf"]] ;
        [meaning setFrequency: [[dict objectForKey:@"freq"] integerValue]] ;
        [meaning setSince: [[dict objectForKey:@"since"] integerValue]] ;
        [meaning setVariations:[self getVariations:[dict objectForKey:@"vars"]]];
        [meaningArray addObject:meaning];
    }
    return meaningArray;
}

-(NSMutableArray *) getVariations:(NSMutableArray *) responseArray {
    NSMutableArray *variationsArray = [NSMutableArray array];
    for(NSDictionary *dict in responseArray){
        
        Meaning *meaning = [[Meaning alloc] init];
        [meaning setMeaning: [dict objectForKey:@"lf"]] ;
        [meaning setFrequency: [[dict objectForKey:@"freq"] integerValue]] ;
        [meaning setSince: [[dict objectForKey:@"since"] integerValue]] ;
        
        [variationsArray addObject:meaning];
    }
    return variationsArray;
}


@end
