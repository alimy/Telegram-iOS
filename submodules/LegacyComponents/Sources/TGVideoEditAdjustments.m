#import <LegacyComponents/TGVideoEditAdjustments.h>

#import <LegacyComponents/TGPhotoEditorUtils.h>

#import <LegacyComponents/TGPaintingData.h>

#import <LegacyComponents/PGPhotoEditorValues.h>

#import <LegacyComponents/TGPhotoPaintStickerEntity.h>
#import <LegacyComponents/TGPhotoPaintTextEntity.h>

#import "PGTintTool.h"
#import "PGCurvesTool.h"

const NSTimeInterval TGVideoEditMinimumTrimmableDuration = 1.5;
const NSTimeInterval TGVideoEditMaximumGifDuration = 30.5;

@implementation TGVideoEditAdjustments

@synthesize originalSize = _originalSize;
@synthesize cropRect = _cropRect;
@synthesize cropOrientation = _cropOrientation;
@synthesize cropRotation = _cropRotation;
@synthesize cropLockedAspectRatio = _cropLockedAspectRatio;
@synthesize cropMirrored = _cropMirrored;
@synthesize paintingData = _paintingData;
@synthesize sendAsGif = _sendAsGif;
@synthesize toolValues = _toolValues;

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize
                                       cropRect:(CGRect)cropRect
                                cropOrientation:(UIImageOrientation)cropOrientation
                                   cropRotation:(CGFloat)cropRotation
                          cropLockedAspectRatio:(CGFloat)cropLockedAspectRatio
                                   cropMirrored:(bool)cropMirrored
                                 trimStartValue:(NSTimeInterval)trimStartValue
                                   trimEndValue:(NSTimeInterval)trimEndValue
                                     toolValues:(NSDictionary *)toolValues
                                   paintingData:(TGPaintingData *)paintingData
                                      sendAsGif:(bool)sendAsGif
                                         preset:(TGMediaVideoConversionPreset)preset
{
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = originalSize;
    adjustments->_cropRect = cropRect;
    adjustments->_cropOrientation = cropOrientation;
    adjustments->_cropRotation = cropRotation;
    adjustments->_cropLockedAspectRatio = cropLockedAspectRatio;
    adjustments->_cropMirrored = cropMirrored;
    adjustments->_trimStartValue = trimStartValue;
    adjustments->_trimEndValue = trimEndValue;
    adjustments->_toolValues = toolValues;
    adjustments->_paintingData = paintingData;
    adjustments->_sendAsGif = sendAsGif;
    adjustments->_preset = preset;
    
    if (trimStartValue > trimEndValue)
        return nil;
    
    return adjustments;
}

+ (instancetype)editAdjustmentsWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary.count == 0)
        return nil;
    
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    if (dictionary[@"cropOrientation"])
        adjustments->_cropOrientation = [dictionary[@"cropOrientation"] integerValue];
    if (dictionary[@"cropRect"])
        adjustments->_cropRect = [dictionary[@"cropRect"] CGRectValue];
    if (dictionary[@"cropMirrored"])
        adjustments->_cropMirrored = [dictionary[@"cropMirrored"] boolValue];
    if (dictionary[@"trimStart"] || dictionary[@"trimEnd"])
    {
        adjustments->_trimStartValue = [dictionary[@"trimStart"] doubleValue];
        adjustments->_trimEndValue = [dictionary[@"trimEnd"] doubleValue];
    }
    if (dictionary[@"originalSize"])
        adjustments->_originalSize = [dictionary[@"originalSize"] CGSizeValue];
    if (dictionary[@"entitiesData"]) {
        adjustments->_paintingData = [TGPaintingData dataWithPaintingImagePath:dictionary[@"paintingImagePath"] entitiesData:dictionary[@"entitiesData"] hasAnimation:[dictionary[@"hasAnimation"] boolValue] stickers:dictionary[@"stickersData"]];
    } else if (dictionary[@"paintingImagePath"]) {
        adjustments->_paintingData = [TGPaintingData dataWithPaintingImagePath:dictionary[@"paintingImagePath"]];
    }
    if (dictionary[@"sendAsGif"])
        adjustments->_sendAsGif = [dictionary[@"sendAsGif"] boolValue];
    if (dictionary[@"preset"])
        adjustments->_preset = (TGMediaVideoConversionPreset)[dictionary[@"preset"] integerValue];
    if (dictionary[@"tools"]) {
        NSMutableDictionary *tools = [[NSMutableDictionary alloc] init];
        for (NSString *key in dictionary[@"tools"]) {
            id value = dictionary[@"tools"][key];
            if ([value isKindOfClass:[NSNumber class]]) {
                tools[key] = value;
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                if ([key isEqualToString:@"tint"]) {
                    PGTintToolValue *tintValue = [[PGTintToolValue alloc] initWithDictionary:value];
                    if (tintValue != nil) {
                        tools[key] = tintValue;
                    }
                } else if ([key isEqualToString:@"curves"]) {
                    PGCurvesToolValue *curvesValues = [[PGCurvesToolValue alloc] initWithDictionary:value];
                    if (curvesValues != nil) {
                        tools[key] = curvesValues;
                    }
                }
            }
        }
        adjustments->_toolValues = tools;
    }
    
    return adjustments;
}

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize
                                         preset:(TGMediaVideoConversionPreset)preset
{
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = originalSize;
    adjustments->_preset = preset;
    if (preset == TGMediaVideoConversionPresetAnimation)
        adjustments->_sendAsGif = true;
    
    return adjustments;
}

+ (instancetype)editAdjustmentsWithPhotoEditorValues:(PGPhotoEditorValues *)values preset:(TGMediaVideoConversionPreset)preset {
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = values.originalSize;
    CGRect cropRect = values.cropRect;
    if (CGRectIsEmpty(cropRect)) {
        cropRect = CGRectMake(0.0f, 0.0f, values.originalSize.width, values.originalSize.height);
    }
    adjustments->_cropRect = cropRect;
    adjustments->_cropOrientation = values.cropOrientation;
    adjustments->_cropRotation = values.cropRotation;
    adjustments->_cropLockedAspectRatio = values.cropLockedAspectRatio;
    adjustments->_cropMirrored = values.cropMirrored;
    adjustments->_paintingData = [values.paintingData dataForAnimation];
    adjustments->_sendAsGif = true;
    adjustments->_preset = preset;
    
    return adjustments;
}

+ (instancetype)editAdjustmentsWithPhotoEditorValues:(PGPhotoEditorValues *)values preset:(TGMediaVideoConversionPreset)preset documentId:(int64_t)documentId colors:(NSArray *)colors {
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = values.originalSize;
    CGRect cropRect = values.cropRect;
    if (CGRectIsEmpty(cropRect)) {
        cropRect = CGRectMake(0.0f, 0.0f, values.originalSize.width, values.originalSize.height);
    }
    adjustments->_cropRect = cropRect;
    adjustments->_cropOrientation = values.cropOrientation;
    adjustments->_cropRotation = values.cropRotation;
    adjustments->_cropLockedAspectRatio = values.cropLockedAspectRatio;
    adjustments->_cropMirrored = values.cropMirrored;
    adjustments->_paintingData = [values.paintingData dataForAnimation];
    adjustments->_sendAsGif = true;
    adjustments->_preset = preset;
    adjustments->_documentId = documentId;
    adjustments->_colors = colors;
    
    return adjustments;
}

+ (instancetype)editAdjustmentsWithPhotoEditorValues:(PGPhotoEditorValues *)values preset:(TGMediaVideoConversionPreset)preset stickerPackId:(int64_t)stickerPackId stickerPackAccessHash:(int64_t)stickerPackAccessHash documentId:(int64_t)documentId colors:(NSArray *)colors {
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = values.originalSize;
    CGRect cropRect = values.cropRect;
    if (CGRectIsEmpty(cropRect)) {
        cropRect = CGRectMake(0.0f, 0.0f, values.originalSize.width, values.originalSize.height);
    }
    adjustments->_cropRect = cropRect;
    adjustments->_cropOrientation = values.cropOrientation;
    adjustments->_cropRotation = values.cropRotation;
    adjustments->_cropLockedAspectRatio = values.cropLockedAspectRatio;
    adjustments->_cropMirrored = values.cropMirrored;
    adjustments->_paintingData = [values.paintingData dataForAnimation];
    adjustments->_sendAsGif = true;
    adjustments->_preset = preset;
    adjustments->_stickerPackId = stickerPackId;
    adjustments->_stickerPackAccessHash = stickerPackAccessHash;
    adjustments->_documentId = documentId;
    adjustments->_colors = colors;
    
    return adjustments;
}

- (instancetype)editAdjustmentsWithPreset:(TGMediaVideoConversionPreset)preset maxDuration:(NSTimeInterval)maxDuration
{
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = _originalSize;
    adjustments->_cropRect = _cropRect;
    adjustments->_cropOrientation = _cropOrientation;
    adjustments->_cropRotation = _cropRotation;
    adjustments->_cropLockedAspectRatio = _cropLockedAspectRatio;
    adjustments->_cropMirrored = _cropMirrored;
    adjustments->_trimStartValue = _trimStartValue;
    adjustments->_trimEndValue = _trimEndValue;
    adjustments->_paintingData = _paintingData;
    adjustments->_preset = preset;
    adjustments->_toolValues = _toolValues;
    adjustments->_videoStartValue = _videoStartValue;
    adjustments->_sendAsGif = preset == TGMediaVideoConversionPresetAnimation ? true : _sendAsGif;
    
    if (maxDuration > DBL_EPSILON)
    {
        if ([adjustments trimApplied])
        {
            if (adjustments.trimEndValue - adjustments.trimStartValue > maxDuration)
                adjustments->_trimEndValue = adjustments.trimStartValue + maxDuration;
        }
        else
        {
            adjustments->_trimEndValue = maxDuration;
        }
    }
        
    return adjustments;
}

- (instancetype)editAdjustmentsWithPreset:(TGMediaVideoConversionPreset)preset videoStartValue:(NSTimeInterval)videoStartValue trimStartValue:(NSTimeInterval)trimStartValue trimEndValue:(NSTimeInterval)trimEndValue
{
    TGVideoEditAdjustments *adjustments = [[[self class] alloc] init];
    adjustments->_originalSize = _originalSize;
    adjustments->_cropRect = _cropRect;
    adjustments->_cropOrientation = _cropOrientation;
    adjustments->_cropRotation = _cropRotation;
    adjustments->_cropLockedAspectRatio = _cropLockedAspectRatio;
    adjustments->_cropMirrored = _cropMirrored;
    adjustments->_trimStartValue = trimStartValue;
    adjustments->_trimEndValue = trimEndValue;
    adjustments->_paintingData = _paintingData;
    adjustments->_sendAsGif = _sendAsGif;
    adjustments->_preset = preset;
    adjustments->_toolValues = _toolValues;
    adjustments->_videoStartValue = videoStartValue;
  
    return adjustments;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cropOrientation"] = @(self.cropOrientation);
    dict[@"cropRotation"] = @(self.cropRotation);
    if ([self cropAppliedForAvatar:false])
        dict[@"cropRect"] = [NSValue valueWithCGRect:self.cropRect];
    dict[@"cropMirrored"] = @(self.cropMirrored);
    
    if (self.trimStartValue > DBL_EPSILON || self.trimEndValue > DBL_EPSILON)
    {
        dict[@"trimStart"] = @(self.trimStartValue);
        dict[@"trimEnd"] = @(self.trimEndValue);
    }
    
    dict[@"originalSize"] = [NSValue valueWithCGSize:self.originalSize];
    
    if (self.toolValues.count > 0) {
        NSMutableDictionary *tools = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.toolValues) {
            id value = self.toolValues[key];
            if ([value isKindOfClass:[NSNumber class]]) {
                tools[key] = value;
            } else if ([value isKindOfClass:[PGTintToolValue class]]) {
                tools[key] = ((PGTintToolValue *)value).dictionary;
            } else if ([value isKindOfClass:[PGCurvesToolValue class]]) {
                tools[key] = ((PGCurvesToolValue *)value).dictionary;
            }
        }
        dict[@"tools"] = tools;
    }
    
    if (self.paintingData != nil) {
        if (self.paintingData.imagePath != nil) {
               dict[@"paintingImagePath"] = self.paintingData.imagePath;
        }
        if (self.paintingData.entitiesData != nil) {
            dict[@"entitiesData"] = self.paintingData.entitiesData;
            dict[@"hasAnimation"] = @(self.paintingData.hasAnimation);
        }
    }
    
    dict[@"sendAsGif"] = @(self.sendAsGif);
    
    if (self.preset != TGMediaVideoConversionPresetCompressedDefault)
        dict[@"preset"] = @(self.preset);
    
    return dict;
}

- (bool)hasPainting
{
    return (_paintingData != nil);
}

- (bool)cropAppliedForAvatar:(bool)forAvatar
{
    CGRect defaultCropRect = CGRectMake(0, 0, _originalSize.width, _originalSize.height);
    if (forAvatar)
    {
        CGFloat shortSide = MIN(_originalSize.width, _originalSize.height);
        defaultCropRect = CGRectMake((_originalSize.width - shortSide) / 2, (_originalSize.height - shortSide) / 2, shortSide, shortSide);
    }
    
    if (_CGRectEqualToRectWithEpsilon(self.cropRect, CGRectZero, [self _cropRectEpsilon]))
        return false;
    
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, defaultCropRect, [self _cropRectEpsilon]))
        return true;
        
    if (self.cropLockedAspectRatio > FLT_EPSILON)
        return true;
    
    if (ABS(self.cropRotation) > FLT_EPSILON)
        return true;
    
    if (self.cropOrientation != UIImageOrientationUp)
        return true;
    
    if (self.cropMirrored)
        return true;
    
    return false;
}

- (bool)trimApplied
{
    return (self.trimStartValue > DBL_EPSILON || self.trimEndValue > DBL_EPSILON);
}

- (CMTimeRange)trimTimeRange
{
    return CMTimeRangeMake(CMTimeMakeWithSeconds(self.trimStartValue , NSEC_PER_SEC), CMTimeMakeWithSeconds((self.trimEndValue - self.trimStartValue), NSEC_PER_SEC));
}

- (NSDictionary *)tintValue {
    PGTintToolValue *tintValue = self.toolValues[@"tint"];
    if (tintValue != nil) {
        return @{
            @"shadowsColor": tintValue.shadowsColor,
            @"shadowsIntensity": @(tintValue.shadowsIntensity),
            @"highlightsColor": tintValue.highlightsColor,
            @"highlightsIntensity": @(tintValue.highlightsIntensity)
        };
    } else {
        return nil;
    }
}

- (NSDictionary *)curvesValue {
    PGCurvesToolValue *curvesValue = self.toolValues[@"curves"];
    if (curvesValue != nil) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        PGCurvesValue *luminanceCurve = curvesValue.luminanceCurve;
        if (luminanceCurve != nil) {
            result[@"luminance"] = @{
                @"blacks": @(luminanceCurve.blacksLevel),
                @"shadows": @(luminanceCurve.shadowsLevel),
                @"midtones": @(luminanceCurve.midtonesLevel),
                @"highlights": @(luminanceCurve.highlightsLevel),
                @"whites": @(luminanceCurve.whitesLevel)
            };
        }
        PGCurvesValue *redCurve = curvesValue.redCurve;
        if (redCurve != nil) {
            result[@"red"] = @{
                @"blacks": @(redCurve.blacksLevel),
                @"shadows": @(redCurve.shadowsLevel),
                @"midtones": @(redCurve.midtonesLevel),
                @"highlights": @(redCurve.highlightsLevel),
                @"whites": @(redCurve.whitesLevel)
            };
        }
        PGCurvesValue *greenCurve = curvesValue.greenCurve;
        if (greenCurve != nil) {
            result[@"green"] = @{
                @"blacks": @(greenCurve.blacksLevel),
                @"shadows": @(greenCurve.shadowsLevel),
                @"midtones": @(greenCurve.midtonesLevel),
                @"highlights": @(greenCurve.highlightsLevel),
                @"whites": @(greenCurve.whitesLevel)
            };
        }
        PGCurvesValue *blueCurve = curvesValue.blueCurve;
        if (blueCurve != nil) {
            result[@"blue"] = @{
                @"blacks": @(blueCurve.blacksLevel),
                @"shadows": @(blueCurve.shadowsLevel),
                @"midtones": @(blueCurve.midtonesLevel),
                @"highlights": @(blueCurve.highlightsLevel),
                @"whites": @(blueCurve.whitesLevel)
            };
        }
        return result;
    } else {
        return nil;
    }
}

- (bool)toolsApplied
{
    if (self.toolValues.count > 0)
        return true;
    
    return false;
}

- (bool)isDefaultValuesForAvatar:(bool)forAvatar
{
    return ![self cropAppliedForAvatar:forAvatar] && ![self toolsApplied] && ![self hasPainting] && !_sendAsGif && _preset == TGMediaVideoConversionPresetCompressedDefault;
}

- (bool)isCropEqualWith:(id<TGMediaEditAdjustments>)adjusments
{
    return (_CGRectEqualToRectWithEpsilon(self.cropRect, adjusments.cropRect, [self _cropRectEpsilon]));
}

- (bool)isCropAndRotationEqualWith:(id<TGMediaEditAdjustments>)adjustments
{
    return (_CGRectEqualToRectWithEpsilon(self.cropRect, adjustments.cropRect, [self _cropRectEpsilon])) && self.cropOrientation == ((TGVideoEditAdjustments *)adjustments).cropOrientation;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    TGVideoEditAdjustments *adjustments = (TGVideoEditAdjustments *)object;
    
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, adjustments.cropRect, [self _cropRectEpsilon]))
        return false;
    
    if (ABS(self.cropRotation - adjustments.cropRotation) > FLT_EPSILON)
        return false;
    
    if (self.cropOrientation != adjustments.cropOrientation)
        return false;
    
    if (ABS(self.cropLockedAspectRatio - adjustments.cropLockedAspectRatio) > FLT_EPSILON)
        return false;
    
    if (self.cropMirrored != adjustments.cropMirrored)
        return false;
    
    if (fabs(self.trimStartValue - adjustments.trimStartValue) > FLT_EPSILON)
        return false;
    
    if (fabs(self.trimEndValue - adjustments.trimEndValue) > FLT_EPSILON)
        return false;
    
    if (![self.toolValues isEqual:adjustments.toolValues])
        return false;
    
    if ((self.paintingData != nil && ![self.paintingData isEqual:adjustments.paintingData]) || (self.paintingData == nil && adjustments.paintingData != nil))
        return false;
    
    if (self.sendAsGif != adjustments.sendAsGif)
        return false;
    
    return true;
}

- (CGFloat)_cropRectEpsilon
{
    return MAX(_originalSize.width, _originalSize.height) * 0.005f;
}

@end
