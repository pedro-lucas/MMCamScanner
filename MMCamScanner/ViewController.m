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
#import <MBProgressHUD/MBProgressHUD.h>
#import "Validador_CPF_CNPJ.h"

@interface ViewController ()<MMCameraDelegate,MMCropDelegate,G8TesseractDelegate> {
    RippleAnimation *ripple;
}

@property (weak, nonatomic) IBOutlet UITextField *txtCNPJ;
@property (weak, nonatomic) IBOutlet UITextField *txtCPF;
@property (weak, nonatomic) IBOutlet UITextField *txtCOO;
@property (weak, nonatomic) IBOutlet UITextField *txtRS;
@property (strong, nonnull) MBProgressHUD *hud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
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
    self.cameraBut.layer.cornerRadius = self.cameraBut.frame.size.width / 2;
    self.pickerBut.layer.cornerRadius = self.pickerBut.frame.size.width / 2;
}

-(void)OCR:(UIImage *)image {
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"por+eng"];
    
//    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
//    stillImageFilter.blurRadiusInPixels = 4.0; // adjust this to tweak the blur radius of the filter, defaults to 4.0
//    
//    // Retrieve the filtered image from the filter
//    UIImage *filteredImage = [stillImageFilter imageByFilteringImage:[image g8_blackAndWhite]];
    
    operation.tesseract.charWhitelist = @"TALCNPJORFtalcnpjorf01234567890,$:/.-";
    operation.tesseract.image = image;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        [self.hud hide:YES];
        [self searchForInformationInText:[tesseract recognizedText]];
    };
    
//    operation.progressCallbackBlock = ^(G8Tesseract *tesseract) {
//        self.hud.progress = tesseract.progress;
//    };
    
    operation.tesseract.delegate = self;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];

}

- (void)searchForInformationInText:(NSString *)text {
    
    text = [text lowercaseString];
    
    NSError *error = NULL;
    NSString *cnpjRegexString = @"[0-9]{2}\\.[0-9]{3}\\.[0-9]{3}/[0-9]{4}-*[0-9]{2}";
    NSString *cooRegexString = @"[coo\\:|000\\:|0002|coo2|con\\s]{4}\\s*[0-9]{6}\\s";
    NSString *cpfRegexString = @"[0-9]{3}\\.[0-9]{3}\\.[0-9]{3}-*[0-9]{2}";
    NSString *precoRegexString = @"\\s(total|totnl|t0tal|t0tnl){1}\\s*[r$|rs]{2}\\s*[a-z0-9\\.\\,]* [0-9\\,\\.]+\\s"; //Tenho que fazer ainda
    
    NSLog(@"TEXTO: %@", text);
    
    NSRegularExpression *cnpjRegex = [NSRegularExpression regularExpressionWithPattern:cnpjRegexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSRegularExpression *cooRegex = [NSRegularExpression regularExpressionWithPattern:cooRegexString
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
    
    NSRegularExpression *cpfRegex = [NSRegularExpression regularExpressionWithPattern:cpfRegexString
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:nil];
    
    NSRegularExpression *precoRegex = [NSRegularExpression regularExpressionWithPattern:precoRegexString
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    if(error) {
        NSLog(@"Invalid regex: %@", error);
        return;
    }
    
    NSArray *cnpj = [cnpjRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSArray *coo = [cooRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSArray *cpf = [cpfRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSArray *preco = [precoRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if(cnpj.count) {
        NSTextCheckingResult *result = [cnpj objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *stringInRange = [[[[[text substringWithRange:matchRange]
                                   stringByReplacingOccurrencesOfString:@"." withString:@""]
                                   stringByReplacingOccurrencesOfString:@"/" withString:@""]
                                    stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![[Validador_CPF_CNPJ new] validarCNPJ:stringInRange]) {
            self.txtCNPJ.text = stringInRange;
        }else{
            NSLog(@"CNPJ: %@", stringInRange);
            self.txtCNPJ.text = @"O CNPJ encontrado não passou na validação";
        }
        
    }else{
        self.txtCNPJ.text = @"CNPJ não encontrado";
    }
    
    if(coo.count) {
        NSTextCheckingResult *result = [coo objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *stringInRange = [[[text substringWithRange:matchRange]
                                    substringFromIndex:4]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.txtCOO.text = stringInRange;
    }else{
        self.txtCOO.text = @"COO não encontrado";
    }
    
    if(cpf.count) {
        NSTextCheckingResult *result = [cpf objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSString *stringInRange = [[[[text substringWithRange:matchRange]
                                      stringByReplacingOccurrencesOfString:@"." withString:@""]
                                    stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(![[Validador_CPF_CNPJ new] validarCPF:stringInRange]) {
            self.txtCPF.text = stringInRange;
        }else{
            self.txtCPF.text = @"O CPF encontrado não passou na validação";
        }
        
    }else{
        self.txtCPF.text = @"CPF não encontrado";
    }
    
    
    if(preco.count) {
        NSTextCheckingResult *result = [preco objectAtIndex:0];
        NSRange matchRange = [result rangeAtIndex:0];
        NSArray *array = [[[text substringWithRange:matchRange]
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                          componentsSeparatedByString:@" "];
        NSString *stringInRange = array[array.count-1];
        self.txtRS.text = stringInRange;
    }else{
        self.txtRS.text = @"Preço não encontrado";
    }
    
    
    //NSLog(@"matches: %@", matches);
}

#pragma mark OCR delegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)cameraAction:(id)sender {
    
    MMCameraPickerController *cameraPicker = [self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
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

-(void)authorizationStatus:(BOOL)status {
    
}

#pragma mark crop delegate
-(void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj{

    [cropObj closeWithCompletion:^{
        ripple=nil;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.dimBackground = YES;
        self.hud.labelText = @"Escaneando...";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self OCR:finalCropImage];
        });
    }];
    
}



@end
