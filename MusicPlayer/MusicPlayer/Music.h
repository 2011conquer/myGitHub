//
//  Music.h
//  MusicPlayer
//
//  Created by the9 on 14-5-8.
//  Copyright (c) 2014年 ZhangGruorui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject
{
    NSString *name;
    NSString *type;
}

@property(retain,nonatomic)NSString *name;
@property(retain,nonatomic)NSString *type;

-(id)initWithName:(NSString *)_name andType:(NSString *)_type;

@end
