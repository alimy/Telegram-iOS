#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/ASActor.h>
#import <LegacyComponents/ASHandle.h>
#import <LegacyComponents/ASQueue.h>
#import <LegacyComponents/ASWatcher.h>
#import <LegacyComponents/AVURLAsset+TGMediaItem.h>
#import <LegacyComponents/Freedom.h>
#import <LegacyComponents/FreedomUIKit.h>
#import <LegacyComponents/JNWSpringAnimation.h>
#import <LegacyComponents/LegacyComponentsAccessChecker.h>
#import <LegacyComponents/LegacyComponentsContext.h>
#import <LegacyComponents/LegacyComponentsGlobals.h>
#import <LegacyComponents/LegacyHTTPRequestOperation.h>
#import <LegacyComponents/lmdb.h>
#import <LegacyComponents/NSInputStream+TL.h>
#import <LegacyComponents/NSObject+TGLock.h>
#import <LegacyComponents/PGCamera.h>
#import <LegacyComponents/PGCameraCaptureSession.h>
#import <LegacyComponents/PGCameraDeviceAngleSampler.h>
#import <LegacyComponents/PGCameraMovieWriter.h>
#import <LegacyComponents/PGCameraShotMetadata.h>
#import <LegacyComponents/PGCameraVolumeButtonHandler.h>
#import <LegacyComponents/PGPhotoEditorValues.h>
#import <LegacyComponents/POPAnimatableProperty.h>
#import <LegacyComponents/POPAnimation.h>
#import <LegacyComponents/POPAnimationEvent.h>
#import <LegacyComponents/POPAnimationTracer.h>
#import <LegacyComponents/POPBasicAnimation.h>
#import <LegacyComponents/POPCustomAnimation.h>
#import <LegacyComponents/POPDecayAnimation.h>
#import <LegacyComponents/POPGeometry.h>
#import <LegacyComponents/POPPropertyAnimation.h>
#import <LegacyComponents/POPSpringAnimation.h>
#import <LegacyComponents/PSCoding.h>
#import <LegacyComponents/PSData.h>
#import <LegacyComponents/PSKeyValueCoder.h>
#import <LegacyComponents/PSKeyValueDecoder.h>
#import <LegacyComponents/PSKeyValueEncoder.h>
#import <LegacyComponents/PSKeyValueReader.h>
#import <LegacyComponents/PSKeyValueStore.h>
#import <LegacyComponents/PSKeyValueWriter.h>
#import <LegacyComponents/PSLMDBKeyValueCursor.h>
#import <LegacyComponents/PSLMDBKeyValueReaderWriter.h>
#import <LegacyComponents/PSLMDBKeyValueStore.h>
#import <LegacyComponents/PSLMDBTable.h>
#import <LegacyComponents/RMPhoneFormat.h>
#import <LegacyComponents/SGraphListNode.h>
#import <LegacyComponents/SGraphNode.h>
#import <LegacyComponents/SGraphObjectNode.h>
#import <LegacyComponents/TGActionMediaAttachment.h>
#import <LegacyComponents/TGAnimationBlockDelegate.h>
#import <LegacyComponents/TGAttachmentCameraView.h>
#import <LegacyComponents/TGAttachmentCarouselItemView.h>
#import <LegacyComponents/TGAudioMediaAttachment.h>
#import <LegacyComponents/TGAudioWaveform.h>
#import <LegacyComponents/TGAuthorSignatureMediaAttachment.h>
#import <LegacyComponents/TGBackdropView.h>
#import <LegacyComponents/TGBotComandInfo.h>
#import <LegacyComponents/TGBotContextResultAttachment.h>
#import <LegacyComponents/TGBotInfo.h>
#import <LegacyComponents/TGBotReplyMarkup.h>
#import <LegacyComponents/TGBotReplyMarkupButton.h>
#import <LegacyComponents/TGBotReplyMarkupRow.h>
#import <LegacyComponents/TGCache.h>
#import <LegacyComponents/TGCameraCapturedPhoto.h>
#import <LegacyComponents/TGCameraCapturedVideo.h>
#import <LegacyComponents/TGCameraController.h>
#import <LegacyComponents/TGCameraFlashActiveView.h>
#import <LegacyComponents/TGCameraFlashControl.h>
#import <LegacyComponents/TGCameraFlipButton.h>
#import <LegacyComponents/TGCameraInterfaceAssets.h>
#import <LegacyComponents/TGCameraMainPhoneView.h>
#import <LegacyComponents/TGCameraMainTabletView.h>
#import <LegacyComponents/TGCameraMainView.h>
#import <LegacyComponents/TGCameraModeControl.h>
#import <LegacyComponents/TGCameraPreviewView.h>
#import <LegacyComponents/TGCameraShutterButton.h>
#import <LegacyComponents/TGCameraTimeCodeView.h>
#import <LegacyComponents/TGCameraZoomView.h>
#import <LegacyComponents/TGChannelAdminRights.h>
#import <LegacyComponents/TGChannelBannedRights.h>
#import <LegacyComponents/TGCheckButtonView.h>
#import <LegacyComponents/TGContactMediaAttachment.h>
#import <LegacyComponents/TGConversation.h>
#import <LegacyComponents/TGDatabaseMessageDraft.h>
#import <LegacyComponents/TGDataResource.h>
#import <LegacyComponents/TGDateUtils.h>
#import <LegacyComponents/TGDocumentAttributeAnimated.h>
#import <LegacyComponents/TGDocumentAttributeAudio.h>
#import <LegacyComponents/TGDocumentAttributeFilename.h>
#import <LegacyComponents/TGDocumentAttributeImageSize.h>
#import <LegacyComponents/TGDocumentAttributeSticker.h>
#import <LegacyComponents/TGDocumentAttributeVideo.h>
#import <LegacyComponents/TGDocumentMediaAttachment.h>
#import <LegacyComponents/TGDoubleTapGestureRecognizer.h>
#import <LegacyComponents/TGEmbedPIPButton.h>
#import <LegacyComponents/TGEmbedPIPPullArrowView.h>
#import <LegacyComponents/TGFileUtils.h>
#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGForwardedMessageMediaAttachment.h>
#import <LegacyComponents/TGFullscreenContainerView.h>
#import <LegacyComponents/TGGameMediaAttachment.h>
#import <LegacyComponents/TGGifConverter.h>
#import <LegacyComponents/TGHacks.h>
#import <LegacyComponents/TGIconSwitchView.h>
#import <LegacyComponents/TGImageBlur.h>
#import <LegacyComponents/TGImageDataSource.h>
#import <LegacyComponents/TGImageInfo.h>
#import <LegacyComponents/TGImageLuminanceMap.h>
#import <LegacyComponents/TGImageManager.h>
#import <LegacyComponents/TGImageManagerTask.h>
#import <LegacyComponents/TGImageMediaAttachment.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGImageView.h>
#import <LegacyComponents/TGInstantPage.h>
#import <LegacyComponents/TGInvoiceMediaAttachment.h>
#import <LegacyComponents/TGKeyCommand.h>
#import <LegacyComponents/TGKeyCommandController.h>
#import <LegacyComponents/TGLabel.h>
#import <LegacyComponents/TGListsTableView.h>
#import <LegacyComponents/TGLiveUploadInterface.h>
#import <LegacyComponents/TGLocalization.h>
#import <LegacyComponents/TGLocalMessageMetaMediaAttachment.h>
#import <LegacyComponents/TGLocationMediaAttachment.h>
#import <LegacyComponents/TGMediaAsset+TGMediaEditableItem.h>
#import <LegacyComponents/TGMediaAsset.h>
#import <LegacyComponents/TGMediaAssetFetchResult.h>
#import <LegacyComponents/TGMediaAssetFetchResultChange.h>
#import <LegacyComponents/TGMediaAssetGroup.h>
#import <LegacyComponents/TGMediaAssetImageSignals.h>
#import <LegacyComponents/TGMediaAssetMoment.h>
#import <LegacyComponents/TGMediaAssetMomentList.h>
#import <LegacyComponents/TGMediaAssetsController.h>
#import <LegacyComponents/TGMediaAssetsLibrary.h>
#import <LegacyComponents/TGMediaAssetsModernLibrary.h>
#import <LegacyComponents/TGMediaAssetsUtils.h>
#import <LegacyComponents/TGMediaAttachment.h>
#import <LegacyComponents/TGMediaAvatarEditorTransition.h>
#import <LegacyComponents/TGMediaAvatarMenuMixin.h>
#import <LegacyComponents/TGMediaEditingContext.h>
#import <LegacyComponents/TGMediaOriginInfo.h>
#import <LegacyComponents/TGMediaPickerCell.h>
#import <LegacyComponents/TGMediaPickerController.h>
#import <LegacyComponents/TGMediaPickerGalleryInterfaceView.h>
#import <LegacyComponents/TGMediaPickerGalleryItem.h>
#import <LegacyComponents/TGMediaPickerGalleryModel.h>
#import <LegacyComponents/TGMediaPickerGalleryPhotoItem.h>
#import <LegacyComponents/TGMediaPickerGallerySelectedItemsModel.h>
#import <LegacyComponents/TGMediaPickerGalleryVideoItem.h>
#import <LegacyComponents/TGMediaPickerGalleryVideoItemView.h>
#import <LegacyComponents/TGMediaPickerLayoutMetrics.h>
#import <LegacyComponents/TGMediaPickerModernGalleryMixin.h>
#import <LegacyComponents/TGMediaPickerSendActionSheetController.h>
#import <LegacyComponents/TGMediaPickerToolbarView.h>
#import <LegacyComponents/TGMediaSelectionContext.h>
#import <LegacyComponents/TGMediaVideoConverter.h>
#import <LegacyComponents/TGMemoryImageCache.h>
#import <LegacyComponents/TGMenuSheetButtonItemView.h>
#import <LegacyComponents/TGMenuSheetCollectionView.h>
#import <LegacyComponents/TGMenuSheetController.h>
#import <LegacyComponents/TGMenuSheetItemView.h>
#import <LegacyComponents/TGMenuSheetTitleItemView.h>
#import <LegacyComponents/TGMenuSheetView.h>
#import <LegacyComponents/TGMenuView.h>
#import <LegacyComponents/TGMessage.h>
#import <LegacyComponents/TGMessageEntitiesAttachment.h>
#import <LegacyComponents/TGMessageEntity.h>
#import <LegacyComponents/TGMessageEntityBold.h>
#import <LegacyComponents/TGMessageEntityBotCommand.h>
#import <LegacyComponents/TGMessageEntityCashtag.h>
#import <LegacyComponents/TGMessageEntityCode.h>
#import <LegacyComponents/TGMessageEntityEmail.h>
#import <LegacyComponents/TGMessageEntityHashtag.h>
#import <LegacyComponents/TGMessageEntityItalic.h>
#import <LegacyComponents/TGMessageEntityMention.h>
#import <LegacyComponents/TGMessageEntityMentionName.h>
#import <LegacyComponents/TGMessageEntityPhone.h>
#import <LegacyComponents/TGMessageEntityPre.h>
#import <LegacyComponents/TGMessageEntityTextUrl.h>
#import <LegacyComponents/TGMessageEntityUrl.h>
#import <LegacyComponents/TGMessageGroup.h>
#import <LegacyComponents/TGMessageHole.h>
#import <LegacyComponents/TGMessageImageViewOverlayView.h>
#import <LegacyComponents/TGMessageViewCountContentProperty.h>
#import <LegacyComponents/TGModernBackToolbarButton.h>
#import <LegacyComponents/TGModernBarButton.h>
#import <LegacyComponents/TGModernButton.h>
#import <LegacyComponents/TGModernCache.h>
#import <LegacyComponents/TGModernConversationInputMicButton.h>
#import <LegacyComponents/TGModernConversationTitleActivityIndicator.h>
#import <LegacyComponents/TGModernGalleryContainerView.h>
#import <LegacyComponents/TGModernGalleryController.h>
#import <LegacyComponents/TGModernGalleryDefaultFooterAccessoryView.h>
#import <LegacyComponents/TGModernGalleryDefaultFooterView.h>
#import <LegacyComponents/TGModernGalleryDefaultHeaderView.h>
#import <LegacyComponents/TGModernGalleryDefaultInterfaceView.h>
#import <LegacyComponents/TGModernGalleryEditableItem.h>
#import <LegacyComponents/TGModernGalleryEditableItemView.h>
#import <LegacyComponents/TGModernGalleryImageItem.h>
#import <LegacyComponents/TGModernGalleryImageItemContainerView.h>
#import <LegacyComponents/TGModernGalleryImageItemImageView.h>
#import <LegacyComponents/TGModernGalleryImageItemView.h>
#import <LegacyComponents/TGModernGalleryInterfaceView.h>
#import <LegacyComponents/TGModernGalleryItem.h>
#import <LegacyComponents/TGModernGalleryItemView.h>
#import <LegacyComponents/TGModernGalleryModel.h>
#import <LegacyComponents/TGModernGalleryScrollView.h>
#import <LegacyComponents/TGModernGallerySelectableItem.h>
#import <LegacyComponents/TGModernGalleryTransitionView.h>
#import <LegacyComponents/TGModernGalleryVideoView.h>
#import <LegacyComponents/TGModernGalleryView.h>
#import <LegacyComponents/TGModernGalleryZoomableItemView.h>
#import <LegacyComponents/TGModernGalleryZoomableItemViewContent.h>
#import <LegacyComponents/TGModernGalleryZoomableScrollView.h>
#import <LegacyComponents/TGModernGalleryZoomableScrollViewSwipeGestureRecognizer.h>
#import <LegacyComponents/TGModernMediaListItem.h>
#import <LegacyComponents/TGModernToolbarButton.h>
#import <LegacyComponents/TGNavigationBar.h>
#import <LegacyComponents/TGNavigationController.h>
#import <LegacyComponents/TGObserverProxy.h>
#import <LegacyComponents/TGOverlayController.h>
#import <LegacyComponents/TGOverlayControllerWindow.h>
#import <LegacyComponents/TGPaintingData.h>
#import <LegacyComponents/TGPaintShader.h>
#import <LegacyComponents/TGPaintUtils.h>
#import <LegacyComponents/TGPassportAttachMenu.h>
#import <LegacyComponents/TGPassportICloud.h>
#import <LegacyComponents/TGPassportMRZ.h>
#import <LegacyComponents/TGPassportOCR.h>
#import <LegacyComponents/TGPassportScanController.h>
#import <LegacyComponents/TGPeerIdAdapter.h>
#import <LegacyComponents/TGPhoneUtils.h>
#import <LegacyComponents/TGPhotoAvatarCropView.h>
#import <LegacyComponents/TGPhotoCaptionInputMixin.h>
#import <LegacyComponents/TGPhotoEditorAnimation.h>
#import <LegacyComponents/TGPhotoEditorButton.h>
#import <LegacyComponents/TGPhotoEditorController.h>
#import <LegacyComponents/TGPhotoEditorInterfaceAssets.h>
#import <LegacyComponents/TGPhotoEditorSliderView.h>
#import <LegacyComponents/TGPhotoEditorSparseView.h>
#import <LegacyComponents/TGPhotoEditorTabController.h>
#import <LegacyComponents/TGPhotoEditorToolView.h>
#import <LegacyComponents/TGPhotoEditorUtils.h>
#import <LegacyComponents/TGPhotoMaskPosition.h>
#import <LegacyComponents/TGPhotoPaintEntity.h>
#import <LegacyComponents/TGPhotoPaintEntityView.h>
#import <LegacyComponents/TGPhotoPaintStickerEntity.h>
#import <LegacyComponents/TGPhotoPaintStickersContext.h>
#import <LegacyComponents/TGPhotoPaintTextEntity.h>
#import <LegacyComponents/TGPhotoToolbarView.h>
#import <LegacyComponents/TGPhotoVideoEditor.h>
#import <LegacyComponents/TGPIPAblePlayerView.h>
#import <LegacyComponents/TGPluralization.h>
#import <LegacyComponents/TGProgressSpinnerView.h>
#import <LegacyComponents/TGProgressWindow.h>
#import <LegacyComponents/TGProxyWindow.h>
#import <LegacyComponents/TGReplyMarkupAttachment.h>
#import <LegacyComponents/TGReplyMessageMediaAttachment.h>
#import <LegacyComponents/TGRTLScreenEdgePanGestureRecognizer.h>
#import <LegacyComponents/TGSecretTimerMenu.h>
#import <LegacyComponents/TGStaticBackdropAreaData.h>
#import <LegacyComponents/TGStaticBackdropImageData.h>
#import <LegacyComponents/TGStickerAssociation.h>
#import <LegacyComponents/TGStickerPack.h>
#import <LegacyComponents/TGStickerPackReference.h>
#import <LegacyComponents/TGStringUtils.h>
#import <LegacyComponents/TGTextCheckingResult.h>
#import <LegacyComponents/TGTextField.h>
#import <LegacyComponents/TGTimerTarget.h>
#import <LegacyComponents/TGToolbarButton.h>
#import <LegacyComponents/TGTooltipView.h>
#import <LegacyComponents/TGUnsupportedMediaAttachment.h>
#import <LegacyComponents/TGViaUserAttachment.h>
#import <LegacyComponents/TGVideoCameraGLRenderer.h>
#import <LegacyComponents/TGVideoCameraGLView.h>
#import <LegacyComponents/TGVideoCameraMovieRecorder.h>
#import <LegacyComponents/TGVideoEditAdjustments.h>
#import <LegacyComponents/TGVideoInfo.h>
#import <LegacyComponents/TGVideoMediaAttachment.h>
#import <LegacyComponents/TGVideoMessageCaptureController.h>
#import <LegacyComponents/TGVideoMessageControls.h>
#import <LegacyComponents/TGVideoMessageRingView.h>
#import <LegacyComponents/TGVideoMessageScrubber.h>
#import <LegacyComponents/TGViewController+TGRecursiveEnumeration.h>
#import <LegacyComponents/TGViewController.h>
#import <LegacyComponents/TGWeakDelegate.h>
#import <LegacyComponents/TGWebDocument.h>
#import <LegacyComponents/TGWebPageMediaAttachment.h>
#import <LegacyComponents/UICollectionView+Utils.h>
#import <LegacyComponents/UIControl+HitTestEdgeInsets.h>
#import <LegacyComponents/UIDevice+PlatformInfo.h>
#import <LegacyComponents/UIImage+TG.h>
#import <LegacyComponents/UIImage+TGMediaEditableItem.h>
#import <LegacyComponents/UIScrollView+TGHacks.h>
