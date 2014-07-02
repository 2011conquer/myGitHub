//
//  MusicViewController.m
//  MusicPlayer
//
//  Created by the9 on 14-5-7.
//  Copyright (c) 2014年 ZhangGruorui. All rights reserved.
//
 
#import "MusicViewController.h"

@interface MusicViewController ()

@end

@implementation MusicViewController
@synthesize playBtn;
@synthesize soundSlider;
@synthesize progressSlider;
@synthesize totalTimeLabel;
@synthesize currentTimeLabel;

-(void)initData{
    Music *music1 = [[Music alloc] initWithName:@"寂寞之声" andType:@"mp3"];
    Music *music2 = [[Music alloc] initWithName:@"Whataya Want From Me" andType:@"mp3"];
   // Music *music3 = [[Music alloc] initWithName:@"Tomorrow" andType:@"mp3"];
   // Music *music4 = [[Music alloc] initWithName:@"青花瓷" andType:@"m4a"];
    Music *music5 = [[Music alloc] initWithName:@"故乡的原风景" andType:@"mp3"];
    
    musicArray = [[NSMutableArray alloc] initWithCapacity:4];
    [musicArray addObject:music1];
    [musicArray addObject:music2];
  // [musicArray addObject:music3];
  //  [musicArray addObject:music4];
    [musicArray addObject:music5];
    
    
//*********
//    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:music1.name ofType:music1.type]] error:nil];
//    currentMusic = music1;//当前播放的歌曲
    
    
}

-(void)initLRC
{
    self.songsName.text = [musicArray[musicArrayNumber] name];
    
    NSString *LRCPath = [[NSBundle mainBundle] pathForResource:currentMusic.name ofType:@"lrc"];
    
    //************************
    if (LRCPath==nil) {
        self.LRCTableView.hidden = YES;
        return;
    }else
    {
        //self.LRCTableView.hidden = NO;
     
    
    NSString *contentStr = [NSString stringWithContentsOfFile:LRCPath encoding:NSUTF8StringEncoding error:nil];
   
    
   // NSLog(@"%@",contentStr);
   
    //以换行符为边界分割歌词并存入数组
    NSArray *array = [contentStr componentsSeparatedByString:@"\n"];
    //提取歌词中的时间和文字
    for (int i = 3; i<[array count]; i++) //歌词前两行没用所以从第三行开始循环
    {
        NSString *lineStr = [array objectAtIndex:i];
        //获取每一行歌词[00:00.00]寂寞之声并分割成两部分，其中后半部分为歌词
        NSArray *lineArray = [lineStr componentsSeparatedByString:@"]"];
        //获取时间戳，只需要[01:49.95]中的01:49
        //有的行没有歌词，全是空格，当用substring时会崩溃，所以要做个判断
        if ([[lineArray objectAtIndex:0] length]>5) {
             NSString *lrcStr = [lineArray objectAtIndex:1];//获取歌词
             NSString *timeStr = [[lineArray objectAtIndex:0] substringWithRange:NSMakeRange(1, 5)];
            [LRCDictionary setObject:lrcStr forKey:timeStr];//时间为键，歌词为值
            [timeArray addObject:timeStr];//时间加入到数组
         }
     }
   // NSLog(@"%@",LRCDictionary);
   // NSLog(@"%@",timeArray);
   }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    self.LRCTableView.rowHeight = 25;
    self.singtableView.rowHeight = 30;
    self.soundSlider.value = 0.5f;
    self.progressSlider.value = 0.0f;    
    isPlay = YES;//用于标记播放按钮状态
    tableHidden = YES;//控制播放列表的按钮状态
    self.singtableView.hidden = YES;//表视图开始的时候为隐藏状态

    self.LRCTableView.hidden = YES;//歌词开始为隐藏
    audioPlayer.volume = 0.5f;
    audioPlayer.currentTime = 0.0f;
    
    [self initData];//调用初始化函数
    
    //**********
    musicArrayNumber = 0;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"mp3"]] error:nil];
    currentMusic = musicArray[musicArrayNumber];//当前播放的歌曲
    
    
    
    //设置导航栏右按钮调用歌曲列表表视图
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    //连接按钮
    [btn addTarget:self action:@selector(showTableView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self initLRC];//调用获取歌词函数
   }

//控制歌词显示函数
-(void)displaySongWord:(NSUInteger)time
{
    //NSLog(@"传递过来的time = %u",time);
    //传递过来的time = 1
    
    static int index = 0;//用于控制访问timeArray数组中的位置
    
    
    //分割时间数组中的时间 01:45分割成 1 和 45存入数组
    NSArray *array = [[timeArray objectAtIndex:index] componentsSeparatedByString:@":"];
    
    //计算当前时间
    NSUInteger currentTime = [[array objectAtIndex:0] intValue]*60 + [[array objectAtIndex:1] intValue];
    
   // NSLog(@"time = %u , currentTime = %d",time,currentTime);

    //传递过来的时间多了一秒，没找到原因，按下stop按钮后，调用stop函数后可以显示歌词，传递过来的时间为0开始，但是一开始按下play按钮却从1开始，所以用减1来判断，但是这样会造成stop函数调用后歌词无法显示
   // if (time == currentTime)
    if (time-1 == currentTime) {
        [self updateLreTableView:index];//播放的当前时间与数组中的时间匹配时，调用改变歌词的方法
        index++;
        }
        
}

//歌词表视图中显示对应歌词
-(void)updateLreTableView:(NSUInteger) index
{
    //NSLog(@"lrc = %@",[LRCDictionary objectForKey:[timeArray objectAtIndex:index]]);
   //指定位置
    if (index<=[timeArray count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        //将歌词表视图滚动到选中的位置
        [self.LRCTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}


//播放列表显示控制
-(void)showTableView
{
    if (tableHidden) {
        self.singtableView.hidden = NO;
        tableHidden = NO;
    } else {
        self.singtableView.hidden = YES;
        tableHidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//上一首
- (IBAction)aboveMusic:(id)sender {
   
    //***************
    if (musicArrayNumber==0) {
        musicArrayNumber = [musicArray count];
    }
    musicArrayNumber--;
    [self updatePlayerSetting];
}


//下一首
- (IBAction)blow:(id)sender {
    
    //****************
    if (musicArrayNumber== [musicArray count]-1) {
        musicArrayNumber = -1;
    }
    musicArrayNumber++;
    [self updatePlayerSetting];
}

//*************
//更新播放列表设置
-(void)updatePlayerSetting
{
    //更新播放按钮状态
    [playBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    isPlay = NO;
     self.LRCTableView.hidden = YES;
   // NSLog(@" 歌曲路径 %@",[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"mp3"]]);
    
    //更新曲目
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[musicArray[musicArrayNumber] name] ofType:@"mp3"]] error:nil];
    
    currentMusic = musicArray[musicArrayNumber];
    //更新音量
    audioPlayer.volume = soundSlider.value;

    //重新载入歌词
//    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
//    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
   
    [self initLRC];
    
    //**********************
    //audioPlayer.delegate = self;
   
    totalTimeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)audioPlayer.duration/60,(int)audioPlayer.duration%60];
    
    //******************************
    [timer invalidate];
     timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    //******************************
    
    [audioPlayer play];
}


//按下播放按钮以后计时器每秒调用一次
-(void)showTime
{
    //NSLog(@"showTime函数调用时的当前时间%f",audioPlayer.currentTime);
    //showTime函数调用时的当前时间1.044082，即首次调用时当前时间，应该为0才对
    
    //计算当前时间的函数，用于计时器的调用
    //保持显示状态为  **：**
    if ((int)audioPlayer.currentTime%60<10)
    {
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)audioPlayer.currentTime/60,(int)audioPlayer.currentTime%60];
    }
    else{
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)audioPlayer.currentTime/60,(int)audioPlayer.currentTime%60];
    }
    
    //改变进度条的值
    progressSlider.value = audioPlayer.currentTime/audioPlayer.duration;
   
    //当歌曲播放完，播放按钮变成播放状态,歌词隐藏
    if (progressSlider.value>0.995f) {
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
         isPlay = YES;
        self.LRCTableView.hidden = YES;
    }
    
    //NSLog(@"调用 displaySongWord函数前的当前时间%f",audioPlayer.currentTime);
    //调用 displaySongWord函数前的当前时间1.050136
    
    [self displaySongWord:audioPlayer.currentTime];//调用显示歌词方法，将当前时间传递给它
    
    //NSLog(@"调用函数后的当前时间%f",audioPlayer.currentTime);
    //调用函数后的当前时间1.051156
    
}

- (IBAction)play:(id)sender {
    
    //切换图片
    if (isPlay) {
        [audioPlayer play];
        [playBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        isPlay = NO;
        self.LRCTableView.hidden =NO;//播放歌曲时歌词显示

       } else{
        [audioPlayer pause];
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        isPlay = YES;
    }
    
    //计算总时间并显示，duration方法获取的时间以秒为单位，需要转换
    totalTimeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)audioPlayer.duration/60,(int)audioPlayer.duration%60];
    
  //  NSLog(@"计时器调用函数时的当前时间%f",audioPlayer.currentTime);
  //   计时器调用函数时的当前时间0.000000
    
    //计时器，每秒调用一次showTime函数，用于显示当前播放时间
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
    
   // [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
       }


- (IBAction)stop:(id)sender {
    [audioPlayer stop];
    audioPlayer.currentTime = 0.0f;
    progressSlider.value =0.0f;
    [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
     isPlay = YES;
}

- (IBAction)progressChange:(id)sender {
    //当前时间/总时间=进度条当前值
    audioPlayer.currentTime = progressSlider.value * audioPlayer.duration;
}

- (IBAction)soundChange:(id)sender {
    audioPlayer.volume = soundSlider.value;
}

- (IBAction)soundOff:(id)sender {
    audioPlayer.volume = 0.0f;//静音的时候声音进度条也为0
    soundSlider.value = 0.0f;
}

- (IBAction)soundOn:(id)sender{
    if (soundSlider.value == 1)
    {
        audioPlayer.volume=1;
    }else{
        audioPlayer.volume +=0.1f;
        soundSlider.value = audioPlayer.volume;
    }
   }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag ==999) {
        return [musicArray count];//播放列表表视图行数为歌曲数目
    }
    else
    {
        return [timeArray count];//返回歌词的条数
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag ==999) {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
        Music *music = [musicArray objectAtIndex:indexPath.row];
        cell.textLabel.text = music.name;
        cell.textLabel.textColor = [UIColor yellowColor];
        return cell;
        }
     else{
        static NSString *cellIdentifier = @"LRCCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
     
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//选中后没有背景颜色

    cell.textLabel.text = [LRCDictionary objectForKey:[timeArray objectAtIndex:indexPath.row]];
    cell.textLabel.textColor = [UIColor blueColor];
         
    // UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    // label.text = [LRCDictionary objectForKey:[timeArray objectAtIndex:indexPath.row]];
    // [cell.contentView addSubview:label];
        return cell;
     }
}

//当点击歌词单元格时，返回空，表示单元格不能被点击
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag != 999) {
        return nil;
    }
    return indexPath;
}

//当点击播放列表的时候调用该方法
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    int  indexOflist =  indexPath.row;
//    Music *tempMusic =musicArray[indexOflist];
//    NSLog(@"播放%@",tempMusic.name);
    
    musicArrayNumber = indexPath.row;
    [self updatePlayerSetting];
    
}

//-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
//{
//    
//}
@end