//
//  MusicViewController.h
//  MusicPlayer
//
//  Created by the9 on 14-5-7.
//  Copyright (c) 2014年 ZhangGruorui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Music.h"
@interface MusicViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer; 
    NSMutableArray *musicArray; //存放歌曲
    BOOL isPlay;   //标记按钮状态
    BOOL tableHidden;//标记播放列表是否显示
    Music *currentMusic; //存放当前播放的歌曲
    NSMutableArray *timeArray; //存放歌词中提取的时间信息
    NSMutableDictionary *LRCDictionary; //存放歌词中的时间和对应文字信息
    NSInteger musicArrayNumber;//用来记录播放哪首歌曲
    NSTimer *timer;
    
}
- (IBAction)aboveMusic:(id)sender;
- (IBAction)blow:(id)sender;
- (IBAction)play:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *playBtn;
@property (retain, nonatomic) IBOutlet UISlider *soundSlider;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *singtableView;
@property (weak, nonatomic) IBOutlet UITableView *LRCTableView;
@property (weak, nonatomic) IBOutlet UILabel *songsName;

- (IBAction)stop:(id)sender; //播放停止
- (IBAction)progressChange:(id)sender; //歌曲播放进度条
- (IBAction)soundChange:(id)sender;//音量
- (IBAction)soundOff:(id)sender;//关闭声音
- (IBAction)soundOn:(id)sender;//开启声音

@end
