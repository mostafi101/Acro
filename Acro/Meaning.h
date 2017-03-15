//
//  Meaning.h
//  Acro
//
//  Created by Mostafijur Rahaman on 3/14/16.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meaning : NSObject
@property (nonatomic, copy) NSString *meaning;
@property NSInteger frequency;
@property NSInteger since;
@property (nonatomic, copy) NSMutableArray *variations;

@end
