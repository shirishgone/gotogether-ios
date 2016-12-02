//
//  GTSoundManager.m
//  goTogether
//
//  Created by shirish on 13/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTSoundManager.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CFURL.h>

@implementation GTSoundManager
+ (void)playSoundAtUrl:(NSURL *)url{
    
    CFURLRef cfUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:url.path];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID(cfUrl, &soundID);
    AudioServicesPlaySystemSound (soundID);
}

#pragma mark - Sounds
+ (void)playSound_openSlide{

    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/open.wav", [[NSBundle mainBundle] resourcePath]]];
    [GTSoundManager playSoundAtUrl:url];
}

+ (void)playSound_closeSlide{
   
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/close.wav", [[NSBundle mainBundle] resourcePath]]];
    [GTSoundManager playSoundAtUrl:url];
}

+ (void)playSound_notification{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/push.wav", [[NSBundle mainBundle] resourcePath]]];
    [GTSoundManager playSoundAtUrl:url];
}

@end
