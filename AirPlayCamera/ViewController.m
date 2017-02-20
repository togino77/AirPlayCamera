//
//  ViewController.m
//  AirPlayCamera
//
//  Created by dso55380 on 2017/02/16.
//  Copyright © 2017年 OGINO Tetsuo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UISwitch *switchSession;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = nil;
    [self setupCaptureSessionForRunning:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self runCaptureSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopCaptureSession];
}

- (void)runCaptureSession {
    if(self.session == nil){
        [self setupCaptureSessionForRunning:YES];
    }
    if(self.session != nil && !self.session.running){
        [self.session startRunning];
        [self.switchSession setOn:YES];
    }
}

- (void)stopCaptureSession {
    if(self.session != nil && self.session.running){
        [self.session stopRunning];
        [self.switchSession setOn:NO];
    }
}

- (void)setupCaptureSessionForRunning:(BOOL)forRunning {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusDenied:
            return;
        case AVAuthorizationStatusAuthorized:
            break;
        case AVAuthorizationStatusRestricted:
            return;
        case AVAuthorizationStatusNotDetermined:
            if(forRunning){
                [self requestAccessForAVMediaTypeVideo];
            }
            return;
        default:
            break;
    }
    if(self.session == nil){
        self.session = [[AVCaptureSession alloc] init];
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        if([self.session canAddInput:self.input]){
            [self.session addInput:self.input];
        }
        self.output = [[AVCaptureMetadataOutput alloc] init];
//        [self.output setMetadataObjectsDelegate:self queue:dispatch_queue_create("myQueue.metadata", DISPATCH_QUEUE_SERIAL)];
        [self.session addOutput:self.output];
//        self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code]; //  AVMetadataObjectTypeQRCode
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.preview.bounds;
        [self.preview.layer addSublayer:self.previewLayer];
    }
}

- (void)requestAccessForAVMediaTypeVideo {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self runCaptureSession];
            });
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if(self.previewLayer != nil){
        self.previewLayer.frame = self.preview.bounds;
    }
}

- (void)releaseCaptureSession {
    if(self.session != nil){
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer = nil;
        [self.session removeOutput:self.output];
        self.output = nil;
        [self.session removeInput:self.input];
        self.input = nil;
        self.device = nil;
        self.session = nil;
    }
}
- (IBAction)pushSwitchSession:(id)sender {
    if([self.switchSession isOn]){
        [self runCaptureSession];
    }
    else {
        [self stopCaptureSession];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
