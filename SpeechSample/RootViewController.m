/*****************************************************************************
 *
 * FILE:	RootViewController.m
 * DESCRIPTION:	SpeechSynthesizer: Root View Controller
 * DATE:	Thu, Nov 28 2013
 * UPDATED:	Fri, Nov 29 2013
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2013 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2013 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: RootViewController.m,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"

enum {
  kSectionRate,
  kSectionPitch,
  kSectionVolume,
  kSectionLanguage,
  kNumberOfSections
};

NS_ENUM(NSInteger, kSegmentType) {
  kSpeechSlow,
  kSpeechNormal,
  kSpeechFast
};

NS_ENUM(NSInteger, kSliderTag) {
  kTagPitch = 8801,
  kTagVolume
};

static NSString * const	kLangJapanese  = @"ja-JP";
static NSString * const	kLangUSEnglish = @"en-US";

@interface RootViewController () <UITextFieldDelegate>
@property (nonatomic,strong) UITextField *	textField;
@property (nonatomic,strong) UISegmentedControl *	segmentedControl;
@property (nonatomic,strong) NSString *	text;
@property (nonatomic,strong) NSString *	language;
@property (nonatomic,assign) float	rate;
@property (nonatomic,assign) float	pitch;
@property (nonatomic,assign) float	volume;
@end

@implementation RootViewController

-(id)init
{
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"SpeechSynthesizer", @"");

    self.text	= nil;
    self.rate	= AVSpeechUtteranceDefaultSpeechRate;
    self.pitch	= 1.0f;
    self.volume	= 1.0f;

    self.language = kLangJapanese;
  }
  return self;
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)loadView
{
  [super loadView];

  UITableView *	tableView;
  tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
  tableView.delegate	= self;
  tableView.dataSource	= self;
  tableView.allowsSelection	= NO;
  tableView.scrollEnabled	= NO;
  tableView.rowHeight		= 64.0f;
  tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
  self.tableView	= tableView;


  CGFloat	x = 8.0f;
  CGFloat	y = 8.0f;
  CGFloat	w = self.view.bounds.size.width - 8.0f * 2.0f;
  CGFloat	h = 44.0f;
  UITextField *	textField;
  textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
  textField.delegate	= self;
  textField.borderStyle	= UITextBorderStyleRoundedRect;
  textField.clearButtonMode	= UITextFieldViewModeWhileEditing;
  textField.placeholder	= NSLocalizedString(@"EnterText", @"");
  textField.adjustsFontSizeToFitWidth	= YES;
  self.tableView.tableHeaderView = textField;
  self.textField	= textField;


  UIBarButtonItem *	playItem;
  playItem = [[UIBarButtonItem alloc]
	      initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
	      target:self
	      action:@selector(playAction:)];
  self.navigationItem.rightBarButtonItem = playItem;
}

#if	0
-(void)viewDidLoad
{
  [super viewDidLoad];
}
#endif

/*****************************************************************************/

-(UITableViewCell *)create_UITableViewCell
{
  static NSString * const	reuseId = @"RootViewTableCellIdentifier";
  UITableViewCell *		cell;

  cell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
  if (cell == nil) {
    cell = [[UITableViewCell alloc]
	    initWithStyle:UITableViewCellStyleValue1
	    reuseIdentifier:reuseId];
  }
  cell.selectionStyle		= UITableViewCellSelectionStyleNone;
  cell.editingAccessoryType	= UITableViewCellAccessoryNone;
  cell.accessoryType		= UITableViewCellAccessoryNone;
  cell.accessoryView		= nil;
  cell.imageView.image		= nil;
  cell.showsReorderControl	= NO;
  cell.textLabel.lineBreakMode	= NSLineBreakByTruncatingTail;
  cell.textLabel.font		= [UIFont boldSystemFontOfSize:14.0f];
  cell.detailTextLabel.text	= nil;
  cell.detailTextLabel.textColor     = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];

  return cell;
}


-(UITableViewCell *)create_SegmentedTableCell
{
  UITableViewCell *	cell = [self create_UITableViewCell];

  NSArray *	items = @[
	NSLocalizedString(@"Slow", @""),
	NSLocalizedString(@"Normal", @""),
	NSLocalizedString(@"Fast", @"")
  ];
  UISegmentedControl *	segmented;
  segmented = [[UISegmentedControl alloc] initWithItems:items];
  segmented.selectedSegmentIndex = kSpeechSlow;
  [segmented addTarget:self
	     action:@selector(segmentedAction:)
	     forControlEvents:UIControlEventValueChanged];
  cell.accessoryView = segmented;

  return cell;
}

#pragma mark UISegmentedControl action
-(void)segmentedAction:(UISegmentedControl *)segmented
{
  switch (segmented.selectedSegmentIndex) {
    case kSpeechSlow:   self.rate = AVSpeechUtteranceMinimumSpeechRate; break;
    case kSpeechNormal: self.rate = AVSpeechUtteranceDefaultSpeechRate; break;
    case kSpeechFast:   self.rate = AVSpeechUtteranceMaximumSpeechRate; break;
  }
}


-(UITableViewCell *)create_SliderTableCell
{
  UITableViewCell *	cell = [self create_UITableViewCell];

  UISlider *	slider;
  slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 20.0f)];
  slider.minimumValue = 0.0f;
  slider.maximumValue = 1.0f;
  slider.value	= 0.5f;
  [slider addTarget:self
	  action:@selector(sliderAction:)
	  forControlEvents:UIControlEventValueChanged];
  cell.accessoryView = slider;

  return cell;
}

#pragma mark UISlider action
-(void)sliderAction:(UISlider *)slider
{
  float	value = [slider value];

  NSIndexPath *	indexPath = nil;
  NSString *	text = nil;

  switch (slider.tag) {
    case kTagPitch:
      self.pitch = value;
      indexPath = [NSIndexPath indexPathForRow:0 inSection:kSectionPitch];
      text = [NSString stringWithFormat:@"%.2f", value];
      break;
    case kTagVolume:
      self.volume = value;
      indexPath = [NSIndexPath indexPathForRow:0 inSection:kSectionVolume];
      text = [NSString stringWithFormat:@"%.0f%%", value * 100.0f];
      break;
  }

  if (indexPath) {
    UITableViewCell *	cell;
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = text;
  }
}


-(UITableViewCell *)create_SwitchTableCell
{
  UITableViewCell *	cell = [self create_UITableViewCell];

  UISwitch *	switchCtrl;
  switchCtrl = [[UISwitch alloc] initWithFrame:CGRectZero];
  [switchCtrl addTarget:self
	      action:@selector(switchAction:)
	      forControlEvents:UIControlEventValueChanged];
  cell.accessoryView = switchCtrl;

  return cell;
}

#pragma mark UISwitch action
-(void)switchAction:(UISwitch *)switchCtrl
{
  BOOL	on = switchCtrl.isOn;

  if (on) {
    self.language = kLangJapanese;
    self.segmentedControl.selectedSegmentIndex = kSpeechSlow;
  }
  else {
    self.language = kLangUSEnglish;
    self.segmentedControl.selectedSegmentIndex = kSpeechNormal;
  }
}

/*****************************************************************************/

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return kNumberOfSections;
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView
	cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger		section	= [indexPath section];
  UITableViewCell *	cell	= nil;

  NSString *	text = nil;
  switch (section) {
    case kSectionRate: {
	cell = [self create_SegmentedTableCell];
	text = NSLocalizedString(@"Rate", @"");
	self.segmentedControl = (UISegmentedControl *)cell.accessoryView;
      }
      break;
    case kSectionPitch: {
	cell = [self create_SliderTableCell];
	UISlider * slider = (UISlider *)cell.accessoryView;
	slider.tag = kTagPitch;
	slider.minimumValue = 0.5f;
	slider.maximumValue = 2.0f;
	slider.value = self.pitch;
	text = NSLocalizedString(@"Pitch", @"");
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", self.pitch];
      }
      break;
    case kSectionVolume: {
	cell = [self create_SliderTableCell];
	UISlider * slider = (UISlider *)cell.accessoryView;
	slider.tag = kTagVolume;
	slider.value = self.volume;
	text = NSLocalizedString(@"Volume", @"");
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f%%", self.volume * 100.0f];
      }
      break;
    case kSectionLanguage: {
	cell = [self create_SwitchTableCell];
	UISwitch * swCtrl = (UISwitch *)cell.accessoryView;
	if ([self.language isEqualToString:kLangJapanese]) {
	  [swCtrl setOn:YES animated:NO];
	}
	else {
	  [swCtrl setOn:NO animated:NO];
	}
	text = NSLocalizedString(@"Japanese", @"");
      }
      break;
  }
  cell.textLabel.text = text;

  return cell;
}

/*****************************************************************************/

#pragma mark UIBarButtonItem action
-(void)playAction:(id)sender
{
  if (self.text.length > 0) {
    [self makeSpeechWithText:self.text];
  }
}

/*****************************************************************************/

// スピーチ関係のコードはこれだけ！超簡単だね。
-(void)makeSpeechWithText:(NSString *)text
{
#if	0
  NSArray *	voices = [AVSpeechSynthesisVoice speechVoices];
  NSLog(@"DEBUG[voice] %@ %@",[AVSpeechSynthesisVoice currentLanguageCode],voices);
#endif
  AVSpeechUtterance *	utterance;
  utterance = [[AVSpeechUtterance alloc] initWithString:text];
  utterance.rate = self.rate;
  utterance.pitchMultiplier = self.pitch;	// [0.5 - 2.0] Default=1.0
  utterance.volume = self.volume;		// [0.0 - 1.0] Default=1.0
  utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.language];
  /*
   * XXX:
   * 以下のパラメータは読み上げ前の間と読み上げ後の間を指定するようだが、
   * 連続して読み上げる場合以外は設定しても無意味かな。
   */
  utterance.preUtteranceDelay	= 0.5;	// Default = 0.0
  utterance.postUtteranceDelay	= 0.2;	// Default = 0.0

  AVSpeechSynthesizer *	synthesizer;
  synthesizer = [AVSpeechSynthesizer new];
  [synthesizer speakUtterance:utterance]; 
}

/*****************************************************************************/

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];

  self.text = [textField text];
  if ([self.text length] > 0) {
    [self makeSpeechWithText:self.text];
  }

  return YES;
}

@end
