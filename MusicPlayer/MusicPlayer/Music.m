//
//  Music.m
//  MusicPlayer
//
//  Created by the9 on 14-5-8.
//  Copyright (c) 2014年 ZhangGruorui. All rights reserved.
//

#import "Music.h"

@implementation Music
@synthesize name,type;

-(id)initWithName:(NSString *)_name andType:(NSString *)_type
{
    if (self==[super init]) {
        self.name =_name;
        self.type = _type;
    }
    return self;
}


@end
