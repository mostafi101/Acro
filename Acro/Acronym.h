//
//  Acronym.h
//  Acro
//
//  Created by Mostafijur Rahaman on 3/14/16.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Acronym : NSObject

@property (nonatomic,copy) NSString *shortForm;
@property (nonatomic,strong) NSMutableArray *meanings;
@end
