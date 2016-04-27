//
//  ViewController.m
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

#import "ViewController.h"
#import "MMCameraPickerController.h"
#import "CropViewController.h"
#define backgroundHex @"2196f3"
#import "UIColor+HexRepresentation.h"
#import "UIImage+fixOrientation.h"
#import <TesseractOCR/TesseractOCR.h>
#import "UploadManager.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <GPUImage/GPUImage.h>

@interface ViewController ()<MMCameraDelegate,MMCropDelegate,G8TesseractDelegate>
{
    RippleAnimation *ripple;
    
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUI];
      self.view.backgroundColor=[UIColor colorWithHexString:@"f44336"];
//    [self uploadReceiptImage:@"Camera.png"];
//    [UploadManager shared];
    NSArray *imgArr=@[@"sample.jpg",@"Camera.png",@"Crop.png",@"Done.png",@"Gallery.png"];
    for (int i=0; i<imgArr.count; i++) {
//        [self uploadReceiptImage:[imgArr objectAtIndex:i]];
        NSLog(@"%d URL Hit",i);
    }
    
//    NSLog(@"%lu",(unsigned long)UIImagePNGRepresentation([self loadImage]).length);
   
}

#pragma mark Document Directory

- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"test.png" ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
-(NSURL *)applicationDocumentsDirectory{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [paths lastObject];
}



-(void)setUI{
    self.cameraBut.tintColor=[UIColor whiteColor];
    self.cameraBut.backgroundColor=[UIColor colorWithHexString:backgroundHex];
    self.cameraBut.layer.cornerRadius = self.cameraBut.frame.size.width / 2;
    self.cameraBut.clipsToBounds=YES;
    [self.cameraBut setImage:[UIImage renderImage:@"Camera"] forState:UIControlStateNormal];

    
    self.pickerBut.tintColor=[UIColor whiteColor];
    self.pickerBut.backgroundColor=[UIColor colorWithHexString:backgroundHex];
    self.pickerBut.layer.cornerRadius = self.pickerBut.frame.size.width / 2;
    self.pickerBut.clipsToBounds=YES;
    [self.pickerBut setImage:[UIImage renderImage:@"Gallery"] forState:UIControlStateNormal];
}

-(void)OCR:(UIImage *)image {
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"por"];
    
    operation.tesseract.charWhitelist = @"01234567890CNPJORFcnpjorf,$:/.-";
    operation.tesseract.image = [[image g8_grayScale] g8_blackAndWhite];
    operation.tesseract.delegate = self;
//    operation.tesseract.maximumRecognitionTime = 2.0;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        NSLog(@"TEXTO: %@", [tesseract recognizedText]);
        [self searchForInformationInText:[tesseract recognizedText]];
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

}

- (void)searchForInformationInText:(NSString *)text {
    
    NSError *error = NULL;
    NSString *cnpjRegexString = @"CNPJ[\\:|2]*(\\s)*[0-9]{2}(\\.)*[0-9]{3}(\\.)*[0-9]{3}(/)*[0-9]{4}(-)*[0-9]{2}\\s";
    NSString *cooRegexString = @"(coo\\:|000\\:|0002|coo2)+[\\s]*[0-9]+\\s";
    //NSString *priceRegexString = @"(coo\\:|000\\:|0002|coo2)+[\\s]*[0-9]+\\s"; //Tenho que fazer ainda
    
    NSRegularExpression *cnpjRegex = [NSRegularExpression regularExpressionWithPattern:cnpjRegexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSRegularExpression *cooRegex = [NSRegularExpression regularExpressionWithPattern:cooRegexString
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    if(error) {
        NSLog(@"Invalid regex: %@", error);
        return;
    }
    
    NSArray *cnpj = [cnpjRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSArray *coo = [cooRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if(cnpj.count) {
        //O CNPJ foi encontrado
        NSTextCheckingResult *result = [cnpj objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *stringInRange = [[[[[[[text substringWithRange:matchRange]
                                   stringByReplacingOccurrencesOfString:@"CNPJ" withString:@""]
                                   stringByReplacingOccurrencesOfString:@":" withString:@""]
                                   stringByReplacingOccurrencesOfString:@"." withString:@""]
                                   stringByReplacingOccurrencesOfString:@"/" withString:@""]
                                    stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSLog(@"CNPJ - %@", stringInRange);
    }
    
    if(coo.count) {
        //O COO foi encontrado
        NSTextCheckingResult *result = [coo objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *stringInRange = [[[text substringWithRange:matchRange]
                                    substringFromIndex:4]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"COO - %@", stringInRange);
    }
    
    
    //NSLog(@"matches: %@", matches);
}

#pragma mark OCR delegate

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
//    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cameraAction:(id)sender {
    MMCameraPickerController *cameraPicker=[self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
    ripple=[[RippleAnimation alloc] init];
    cameraPicker.camdelegate=self;
    cameraPicker.transitioningDelegate=ripple;
    ripple.touchPoint=self.cameraBut.frame;
   
    [self presentViewController:cameraPicker animated:YES completion:nil];
    
    

}

- (IBAction)pickerAction:(id)sender {
    _invokeCamera = [[UIImagePickerController alloc] init];
    _invokeCamera.delegate = self;
   
    ripple=[[RippleAnimation alloc] init];
    ripple.touchPoint=self.pickerBut.frame;
    _invokeCamera.transitioningDelegate=ripple;
    _invokeCamera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _invokeCamera.allowsEditing = NO;
    
    _invokeCamera.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    
    
     [self presentViewController:_invokeCamera animated:YES completion:nil];

}

#pragma mark Picker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_invokeCamera dismissViewControllerAnimated:YES completion:nil];
    [_invokeCamera removeFromParentViewController];
    ripple=nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [_invokeCamera dismissViewControllerAnimated:YES completion:nil];
    [_invokeCamera removeFromParentViewController];
    ripple=nil;
  
    CropViewController *crop=[self.storyboard instantiateViewControllerWithIdentifier:@"crop"];
    crop.cropdelegate=self;
    ripple=[[RippleAnimation alloc] init];
    crop.transitioningDelegate=ripple;
    ripple.touchPoint=self.cameraBut.frame;

    crop.adjustedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self presentViewController:crop animated:YES completion:nil];
    
    
}

#pragma mark Camera Delegate
-(void)didFinishCaptureImage:(UIImage *)capturedImage withMMCam:(MMCameraPickerController*)cropcam{
    
    [cropcam closeWithCompletion:^{
        NSLog(@"dismissed");
        ripple=nil;
        if(capturedImage!=nil){
            CropViewController *crop=[self.storyboard instantiateViewControllerWithIdentifier:@"crop"];
            crop.cropdelegate=self;
            ripple=[[RippleAnimation alloc] init];
            crop.transitioningDelegate=ripple;
            ripple.touchPoint=self.cameraBut.frame;
            crop.adjustedImage=capturedImage;
            
            [self presentViewController:crop animated:YES completion:nil];
        }
    }];
    
    
}
-(void)authorizationStatus:(BOOL)status{
    
}

#pragma mark crop delegate
-(void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj{

    [cropObj closeWithCompletion:^{
        ripple=nil;
        [self OCR:finalCropImage];
    }];
    
}



@end
