import Foundation
import UIKit
import LegacyComponents
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import DeviceAccess
import AccountContext
import LegacyUI
import SaveToCameraRoll
import Photos

public func defaultVideoPresetForContext(_ context: AccountContext) -> TGMediaVideoConversionPreset {
    var networkType: NetworkType = .wifi
    let _ = (context.account.networkType
    |> take(1)).start(next: { value in
        networkType = value
    })
    
    let autodownloadSettings = context.sharedContext.currentAutodownloadSettings.with { $0 }
    let presetSettings: AutodownloadPresetSettings
    switch networkType {
    case .wifi:
        presetSettings = autodownloadSettings.highPreset
    default:
        presetSettings = autodownloadSettings.mediumPreset
    }
    
    let effectiveValue: Int
    if presetSettings.videoUploadMaxbitrate == 0 {
        effectiveValue = 0
    } else {
        effectiveValue = Int(presetSettings.videoUploadMaxbitrate) * 5 / 100
    }
    
    switch effectiveValue {
    case 0:
        return TGMediaVideoConversionPresetCompressedMedium
    case 1:
        return TGMediaVideoConversionPresetCompressedVeryLow
    case 2:
        return TGMediaVideoConversionPresetCompressedLow
    case 3:
        return TGMediaVideoConversionPresetCompressedMedium
    case 4:
        return TGMediaVideoConversionPresetCompressedHigh
    case 5:
        return TGMediaVideoConversionPresetCompressedVeryHigh
    default:
        return TGMediaVideoConversionPresetCompressedMedium
    }
}

public enum LegacyAttachmentMenuMediaEditing {
    case none
    case imageOrVideo(AnyMediaReference?)
    case file
}

public enum LegacyMediaEditorMode {
    case draw
    case adjustments
}


public func legacyWallpaperEditor(context: AccountContext, item: TGMediaEditableItem, cropRect: CGRect, adjustments: TGMediaEditAdjustments?, referenceView: UIView, beginTransitionOut: ((Bool) -> Void)?, finishTransitionOut: (() -> Void)?, completion: @escaping (UIImage?, TGMediaEditAdjustments?) -> Void, fullSizeCompletion: @escaping (UIImage?) -> Void, present: @escaping (ViewController, Any?) -> Void) {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme, initialLayout: nil)
    legacyController.blocksBackgroundWhenInOverlay = true
    legacyController.acceptsFocusWhenInOverlay = true
    legacyController.statusBar.statusBarStyle = .Ignore
    legacyController.controllerLoaded = { [weak legacyController] in
        legacyController?.view.disablesInteractiveTransitionGestureRecognizer = true
    }

    let emptyController = LegacyEmptyController(context: legacyController.context)!
    emptyController.navigationBarShouldBeHidden = true
    let navigationController = makeLegacyNavigationController(rootController: emptyController)
    navigationController.setNavigationBarHidden(true, animated: false)
    legacyController.bind(controller: navigationController)

    legacyController.enableSizeClassSignal = true
    
    present(legacyController, nil)
    
    TGPhotoVideoEditor.present(with: legacyController.context, controller: emptyController, with: item, cropRect: cropRect, adjustments: adjustments, referenceView: referenceView, completion: { image, adjustments in
        completion(image, adjustments)
    }, fullSizeCompletion: { image in
        Queue.mainQueue().async {
            fullSizeCompletion(image)
        }
    }, beginTransitionOut: { saving in
        beginTransitionOut?(saving)
    }, finishTransitionOut: { [weak legacyController] in
        legacyController?.dismiss()
        finishTransitionOut?()
    })
}

public enum StoryMediaEditorResult {
    case image(UIImage)
    case video(String)
    case asset(PHAsset)
}

public func legacyStoryMediaEditor(context: AccountContext, item: TGMediaEditableItem & TGMediaSelectableItem, getCaptionPanelView: @escaping () -> TGCaptionPanelView?, completion: @escaping (StoryMediaEditorResult) -> Void, present: @escaping (ViewController, Any?) -> Void) {
    let paintStickersContext = LegacyPaintStickersContext(context: context)
    paintStickersContext.captionPanelView = {
        return getCaptionPanelView()
    }
    
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme, initialLayout: nil)
    legacyController.blocksBackgroundWhenInOverlay = true
    legacyController.acceptsFocusWhenInOverlay = true
    legacyController.statusBar.statusBarStyle = .Ignore
    legacyController.controllerLoaded = { [weak legacyController] in
        legacyController?.view.disablesInteractiveTransitionGestureRecognizer = true
    }

    let emptyController = LegacyEmptyController(context: legacyController.context)!
    emptyController.navigationBarShouldBeHidden = true
    let navigationController = makeLegacyNavigationController(rootController: emptyController)
    navigationController.setNavigationBarHidden(true, animated: false)
    legacyController.bind(controller: navigationController)

    legacyController.enableSizeClassSignal = true
    
    present(legacyController, nil)
    
    TGPhotoVideoEditor.present(with: legacyController.context, controller: emptyController, caption: NSAttributedString(), withItem: item, paint: false, adjustments: false, recipientName: "", stickersContext: paintStickersContext, from: .zero, mainSnapshot: nil, snapshots: [] as [Any], immediate: true, appeared: {
        
    }, completion: { result, editingContext in
        var completionResult: Signal<StoryMediaEditorResult, NoError>
        if let photo = result as? TGCameraCapturedPhoto {
            if let _ = editingContext?.adjustments(for: result) {
                completionResult = .single(.image(photo.existingImage))
            } else {
                completionResult = .single(.image(photo.existingImage))
            }
        } else if let video = result as? TGCameraCapturedVideo {
            completionResult = .single(.video(video.immediateAVAsset.url.absoluteString))
        } else if let asset = result as? TGMediaAsset {
            completionResult = .single(.asset(asset.backingAsset))
        } else {
            completionResult = .complete()
        }
        let _ = (completionResult
        |> deliverOnMainQueue).start(next: { value in
            completion(value)
        })
    }, dismissed: { [weak legacyController] in
        legacyController?.dismiss()
    })
}

public func legacyMediaEditor(context: AccountContext, peer: Peer, threadTitle: String?, media: AnyMediaReference, mode: LegacyMediaEditorMode, initialCaption: NSAttributedString, snapshots: [UIView], transitionCompletion: (() -> Void)?, getCaptionPanelView: @escaping () -> TGCaptionPanelView?, sendMessagesWithSignals: @escaping ([Any]?, Bool, Int32, Bool) -> Void, present: @escaping (ViewController, Any?) -> Void) {
    let _ = (fetchMediaData(context: context, postbox: context.account.postbox, userLocation: .other, mediaReference: media)
    |> deliverOnMainQueue).start(next: { (value, isImage) in
        guard case let .data(data) = value, data.complete else {
            return
        }
        
        let item: TGMediaEditableItem & TGMediaSelectableItem
        if let image = UIImage(contentsOfFile: data.path) {
            item = TGCameraCapturedPhoto(existing: image)
        } else {
            item = TGCameraCapturedVideo(url: URL(fileURLWithPath: data.path))
        }
        
        let paintStickersContext = LegacyPaintStickersContext(context: context)
        paintStickersContext.captionPanelView = {
            return getCaptionPanelView()
        }
        
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        let recipientName: String
        if let threadTitle {
            recipientName = threadTitle
        } else {
            if peer.id == context.account.peerId {
                recipientName = presentationData.strings.DialogList_SavedMessages
            } else {
                recipientName = EnginePeer(peer).displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
            }
        }
        
        let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme, initialLayout: nil)
        legacyController.blocksBackgroundWhenInOverlay = true
        legacyController.acceptsFocusWhenInOverlay = true
        legacyController.statusBar.statusBarStyle = .Ignore
        legacyController.controllerLoaded = { [weak legacyController] in
            legacyController?.view.disablesInteractiveTransitionGestureRecognizer = true
        }

        let emptyController = LegacyEmptyController(context: legacyController.context)!
        emptyController.navigationBarShouldBeHidden = true
        let navigationController = makeLegacyNavigationController(rootController: emptyController)
        navigationController.setNavigationBarHidden(true, animated: false)
        legacyController.bind(controller: navigationController)

        legacyController.enableSizeClassSignal = true
        
        present(legacyController, nil)
        
        TGPhotoVideoEditor.present(with: legacyController.context, controller: emptyController, caption: initialCaption, withItem: item, paint: mode == .draw, adjustments: mode == .adjustments, recipientName: recipientName, stickersContext: paintStickersContext, from: .zero, mainSnapshot: nil, snapshots: snapshots as [Any], immediate: transitionCompletion != nil, appeared: {
            transitionCompletion?()
        }, completion: { result, editingContext in
            let nativeGenerator = legacyAssetPickerItemGenerator()
            var selectableResult: TGMediaSelectableItem?
            if let result = result {
                selectableResult = unsafeDowncast(result, to: TGMediaSelectableItem.self)
            }
            let signals = TGCameraController.resultSignals(for: nil, editingContext: editingContext, currentItem: selectableResult, storeAssets: false, saveEditedPhotos: false, descriptionGenerator: { _1, _2, _3 in
                nativeGenerator(_1, _2, _3, nil)
            })
            let isCaptionAbove = editingContext?.isCaptionAbove() ?? false
            sendMessagesWithSignals(signals, false, 0, isCaptionAbove)
        }, dismissed: { [weak legacyController] in
            legacyController?.dismiss()
        })
    })
}
    
public func legacyAttachmentMenu(
    context: AccountContext,
    peer: Peer?,
    threadTitle: String?,
    chatLocation: ChatLocation,
    editMediaOptions: LegacyAttachmentMenuMediaEditing?,
    addingMedia: Bool,
    saveEditedPhotos: Bool,
    allowGrouping: Bool,
    hasSchedule: Bool,
    canSendPolls: Bool,
    updatedPresentationData: (initial: PresentationData, signal: Signal<PresentationData, NoError>),
    parentController: LegacyController,
    recentlyUsedInlineBots: [Peer],
    initialCaption: NSAttributedString,
    openGallery: @escaping () -> Void,
    openCamera: @escaping (TGAttachmentCameraView?, TGMenuSheetController?) -> Void,
    openFileGallery: @escaping () -> Void,
    openWebSearch: @escaping () -> Void,
    openMap: @escaping () -> Void,
    openContacts: @escaping () -> Void,
    openPoll: @escaping () -> Void,
    presentSelectionLimitExceeded: @escaping () -> Void,
    presentCantSendMultipleFiles: @escaping () -> Void,
    presentJpegConversionAlert: @escaping (@escaping (Bool) -> Void) -> Void,
    presentSchedulePicker: @escaping (Bool, @escaping (Int32) -> Void) -> Void,
    presentTimerPicker: @escaping (@escaping (Int32) -> Void) -> Void,
    sendMessagesWithSignals: @escaping ([Any]?, Bool, Int32, ((String) -> UIView?)?, @escaping () -> Void) -> Void,
    selectRecentlyUsedInlineBot: @escaping (Peer) -> Void,
    getCaptionPanelView: @escaping () -> TGCaptionPanelView?,
    present: @escaping (ViewController, Any?) -> Void
) -> TGMenuSheetController {
    let defaultVideoPreset = defaultVideoPresetForContext(context)
    UserDefaults.standard.set(defaultVideoPreset.rawValue as NSNumber, forKey: "TG_preferredVideoPreset_v0")
    
    let presentationData = updatedPresentationData.initial
    let recipientName: String
    if let threadTitle {
        recipientName = threadTitle
    } else if let peer {
        if peer.id == context.account.peerId {
            recipientName = presentationData.strings.DialogList_SavedMessages
        } else {
            recipientName = EnginePeer(peer).displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
        }
    } else {
        recipientName = ""
    }
    
    let actionSheetTheme = ActionSheetControllerTheme(presentationData: presentationData)
    let fontSize = floor(actionSheetTheme.baseFontSize * 20.0 / 17.0)
    
    let isSecretChat = peer?.id.namespace == Namespaces.Peer.SecretChat
    
    let controller = TGMenuSheetController(context: parentController.context, dark: false)!
    controller.dismissesByOutsideTap = true
    controller.hasSwipeGesture = true
    controller.maxHeight = 445.0
    controller.forceFullScreen = true
    
    var itemViews: [Any] = []
    
    var editing = false
    var canSendImageOrVideo = false
    var canEditFile = false
    var editCurrentMedia: AnyMediaReference?
    if let editMediaOptions = editMediaOptions {
        switch editMediaOptions {
        case .none:
            break
        case let .imageOrVideo(anyReference):
            editCurrentMedia = anyReference
        case .file:
            canEditFile = true
        }
        canSendImageOrVideo = true
        editing = true
    } else {
        canSendImageOrVideo = true
    }
    
    var carouselItemView: TGAttachmentCarouselItemView?
    
    var underlyingViews: [UIView] = []
    
    var selectionLimit: Int32 = 100
    var slowModeEnabled = false
    if let channel = peer as? TelegramChannel, channel.isRestrictedBySlowmode {
        slowModeEnabled = true
        selectionLimit = 10
    }
    
    let paintStickersContext = LegacyPaintStickersContext(context: context)
    paintStickersContext.captionPanelView = {
        return getCaptionPanelView()
    }
    
    if canSendImageOrVideo {
        let carouselItem = TGAttachmentCarouselItemView(context: parentController.context, camera: PGCamera.cameraAvailable(), selfPortrait: false, forProfilePhoto: false, assetType: TGMediaAssetAnyType, saveEditedPhotos: !isSecretChat && saveEditedPhotos, allowGrouping: editMediaOptions == nil && allowGrouping, allowSelection: editMediaOptions == nil, allowEditing: true, document: false, selectionLimit: selectionLimit)!
        carouselItemView = carouselItem
        carouselItem.stickersContext = paintStickersContext
        carouselItem.recipientName = recipientName
        var openedCamera = false
        controller.willDismiss = { [weak carouselItem] _ in
            if let carouselItem = carouselItem, !openedCamera {
                carouselItem.saveStartImage()
            }
        }
        carouselItem.cameraPressed = { [weak controller, weak parentController] cameraView in
            openedCamera = true
            if let controller = controller {
                if let parentController = parentController, parentController.context.currentlyInSplitView() {
                    return
                }
                
                DeviceAccess.authorizeAccess(to: .camera(.video), presentationData: updatedPresentationData.initial, present: context.sharedContext.presentGlobalController, openSettings: context.sharedContext.applicationBindings.openSettings, { value in
                    if value {
                        openCamera(cameraView, controller)
                    }
                })
            }
        }
        carouselItem.selectionLimitExceeded = {
            presentSelectionLimitExceeded()
        }
        if let peer, peer.id != context.account.peerId {
            if peer is TelegramUser {
                carouselItem.hasTimer = hasSchedule
            }
            carouselItem.hasSilentPosting = true
        }
        carouselItem.hasSchedule = hasSchedule
        carouselItem.reminder = peer?.id == context.account.peerId
        carouselItem.presentScheduleController = { media, done in
            presentSchedulePicker(media, { time in
                done?(time)
            })
        }
        carouselItem.presentTimerController = { done in
            presentTimerPicker { time in
                done?(time)
            }
        }
        carouselItem.sendPressed = { [weak controller, weak carouselItem] currentItem, asFiles, silentPosting, scheduleTime, isFromPicker in
            if let controller = controller, let carouselItem = carouselItem {
                let intent: TGMediaAssetsControllerIntent = asFiles ? TGMediaAssetsControllerSendFileIntent : TGMediaAssetsControllerSendMediaIntent
                
                var hasHeic = false
                var allItems = carouselItem.selectionContext?.selectedItems() ?? []
                if let currentItem = currentItem {
                    allItems.append(currentItem)
                }
                for item in allItems {
                    if item is TGCameraCapturedVideo {
                    } else if let asset = item as? TGMediaAsset, asset.uniformTypeIdentifier.contains("heic") {
                        hasHeic = true
                        break
                    }
                }
                
                if slowModeEnabled, allItems.count > 1 {
                    presentCantSendMultipleFiles()
                } else {
                    let process: (Bool) -> Void = { convert in
                        let signals = TGMediaAssetsController.resultSignals(for: carouselItem.selectionContext, editingContext: carouselItem.editingContext, intent: intent, currentItem: currentItem, storeAssets: true, convertToJpeg: convert, descriptionGenerator: legacyAssetPickerItemGenerator(), saveEditedPhotos: saveEditedPhotos)
                        sendMessagesWithSignals(signals, silentPosting, scheduleTime, isFromPicker ? nil : { [weak carouselItem] uniqueId in
                            if let carouselItem = carouselItem {
                                return carouselItem.getItemSnapshot(uniqueId)
                            }
                            return nil
                        }, { [weak controller] in
                            controller?.dismiss(animated: true)
                        })
                    }
                    if hasHeic && asFiles {
                        presentJpegConversionAlert({ convert in
                            process(convert)
                        })
                    } else {
                        process(false)
                    }
                   
                }
            }
        };
        carouselItem.allowCaptions = true
        if !initialCaption.string.isEmpty {
            carouselItem.editingContext.setForcedCaption(initialCaption)
        }
        itemViews.append(carouselItem)
        
        let galleryTitle: String
        if addingMedia {
            galleryTitle = presentationData.strings.AttachmentMenu_AddPhotoOrVideo
        } else {
            galleryTitle = editing ? presentationData.strings.Conversation_EditingMessageMediaChange : presentationData.strings.AttachmentMenu_PhotoOrVideo
        }
        let galleryItem = TGMenuSheetButtonItemView(title: galleryTitle, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            openGallery()
        })!
        if !editing {
            galleryItem.longPressAction = { [weak controller] in
                if let controller = controller {
                    controller.dismiss(animated: true)
                }
                openWebSearch()
            }
        }
        itemViews.append(galleryItem)
        underlyingViews.append(galleryItem)
        
        if addingMedia {
            let fileItem = TGMenuSheetButtonItemView(title: presentationData.strings.AttachmentMenu_AddDocument, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
                controller?.dismiss(animated: true)
                openFileGallery()
            })!
            itemViews.append(fileItem)
            underlyingViews.append(fileItem)
        }
    }
    
    if !editing && !addingMedia {
        let fileItem = TGMenuSheetButtonItemView(title: presentationData.strings.AttachmentMenu_File, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            openFileGallery()
        })!
        itemViews.append(fileItem)
        underlyingViews.append(fileItem)
    }
    
    if canEditFile && !addingMedia {
        let fileItem = TGMenuSheetButtonItemView(title: presentationData.strings.AttachmentMenu_File, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            openFileGallery()
        })!
        itemViews.append(fileItem)
    }
    
    if let editCurrentMedia = editCurrentMedia {
        let title: String
        if editCurrentMedia.media is TelegramMediaImage {
            title = presentationData.strings.Conversation_EditingMessageMediaEditCurrentPhoto
        } else {
            title = presentationData.strings.Conversation_EditingMessageMediaEditCurrentVideo
        }
        let editCurrentItem = TGMenuSheetButtonItemView(title: title, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            
            let _ = (fetchMediaData(context: context, postbox: context.account.postbox, userLocation: .other, mediaReference: editCurrentMedia)
            |> deliverOnMainQueue).start(next: { (value, isImage) in
                guard case let .data(data) = value, data.complete else {
                    return
                }
                
                let item: TGMediaEditableItem & TGMediaSelectableItem
                if let image = UIImage(contentsOfFile: data.path) {
                    item = TGCameraCapturedPhoto(existing: image)
                } else {
                    item = TGCameraCapturedVideo(url: URL(fileURLWithPath: data.path))
                }
                
                let legacyController = LegacyController(presentation: .custom, theme: presentationData.theme, initialLayout: nil)
                legacyController.statusBar.statusBarStyle = .Ignore
                legacyController.controllerLoaded = { [weak legacyController] in
                    legacyController?.view.disablesInteractiveTransitionGestureRecognizer = true
                }
                
                let emptyController = LegacyEmptyController(context: legacyController.context)!
                emptyController.navigationBarShouldBeHidden = true
                let navigationController = makeLegacyNavigationController(rootController: emptyController)
                navigationController.setNavigationBarHidden(true, animated: false)
                legacyController.bind(controller: navigationController)
                
                let recipientName: String
                if let peer {
                    recipientName = EnginePeer(peer).displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
                } else {
                    recipientName = ""
                }

                legacyController.enableSizeClassSignal = true
                
                let presentationDisposable = updatedPresentationData.signal.start(next: { [weak legacyController] presentationData in
                    if let legacyController = legacyController, let controller = legacyController.legacyController as? TGMenuSheetController  {
                        controller.pallete = legacyMenuPaletteFromTheme(presentationData.theme, forceDark: false)
                    }
                })
                legacyController.disposables.add(presentationDisposable)
                
                present(legacyController, nil)
                
                TGPhotoVideoEditor.present(with: legacyController.context, controller: emptyController, caption: initialCaption, withItem: item, paint: false, adjustments: false, recipientName: recipientName, stickersContext: paintStickersContext, from: .zero, mainSnapshot: nil, snapshots: [], immediate: false, appeared: {
                }, completion: { result, editingContext in
                    let nativeGenerator = legacyAssetPickerItemGenerator()
                    var selectableResult: TGMediaSelectableItem?
                    if let result = result {
                        selectableResult = unsafeDowncast(result, to: TGMediaSelectableItem.self)
                    }
                    let signals = TGCameraController.resultSignals(for: nil, editingContext: editingContext, currentItem: selectableResult, storeAssets: false, saveEditedPhotos: false, descriptionGenerator: { _1, _2, _3 in
                        nativeGenerator(_1, _2, _3, nil)
                    })
                    sendMessagesWithSignals(signals, false, 0, { _ in nil}, {})
                }, dismissed: { [weak legacyController] in
                    legacyController?.dismiss()
                })
            })
        })!
        itemViews.append(editCurrentItem)
    }
    
    if editMediaOptions == nil && !addingMedia {
        let locationItem = TGMenuSheetButtonItemView(title: presentationData.strings.Conversation_Location, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            openMap()
        })!
        itemViews.append(locationItem)
        
        var peerSupportsPolls = false
        if let peer {
            if peer is TelegramGroup || peer is TelegramChannel {
                peerSupportsPolls = true
            } else if let user = peer as? TelegramUser, let _ = user.botInfo {
                peerSupportsPolls = true
            }
        }
        if let peer, peerSupportsPolls, canSendMessagesToPeer(peer) && canSendPolls {
            let pollItem = TGMenuSheetButtonItemView(title: presentationData.strings.AttachmentMenu_Poll, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
                controller?.dismiss(animated: true)
                openPoll()
            })!
            itemViews.append(pollItem)
        }
    
        let contactItem = TGMenuSheetButtonItemView(title: presentationData.strings.Conversation_Contact, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
            controller?.dismiss(animated: true)
            openContacts()
        })!
        itemViews.append(contactItem)
    }
    
    carouselItemView?.underlyingViews = underlyingViews
    
    if editMediaOptions == nil && !addingMedia {
        for i in 0 ..< min(20, recentlyUsedInlineBots.count) {
            let peer = recentlyUsedInlineBots[i]
            let addressName = peer.addressName
            if let addressName = addressName {
                let botItem = TGMenuSheetButtonItemView(title: "@" + addressName, type: TGMenuSheetButtonTypeDefault, fontSize: fontSize, action: { [weak controller] in
                    controller?.dismiss(animated: true)
                    
                    selectRecentlyUsedInlineBot(peer)
                })!
                botItem.overflow = true
                itemViews.append(botItem)
            }
        }
    }
    
    carouselItemView?.remainingHeight = TGMenuSheetButtonItemViewHeight * CGFloat(itemViews.count - 1)
    
    let cancelItem = TGMenuSheetButtonItemView(title: presentationData.strings.Common_Cancel, type: TGMenuSheetButtonTypeCancel, fontSize: actionSheetTheme.baseFontSize, action: { [weak controller] in
        controller?.dismiss(animated: true)
    })!
    itemViews.append(cancelItem)
    
    controller.setItemViews(itemViews)
    
    return controller
}

public func legacyMenuPaletteFromTheme(_ theme: PresentationTheme, forceDark: Bool) -> TGMenuSheetPallete {
    let sheetTheme: PresentationThemeActionSheet
    if forceDark && !theme.overallDarkAppearance {
        sheetTheme = defaultDarkColorPresentationTheme.actionSheet
    } else {
        sheetTheme = theme.actionSheet
    }
    return TGMenuSheetPallete(dark: forceDark || theme.overallDarkAppearance, backgroundColor: sheetTheme.opaqueItemBackgroundColor, selectionColor: sheetTheme.opaqueItemHighlightedBackgroundColor, separatorColor: sheetTheme.opaqueItemSeparatorColor, accentColor: sheetTheme.controlAccentColor, destructiveColor: sheetTheme.destructiveActionTextColor, textColor: sheetTheme.primaryTextColor, secondaryTextColor: sheetTheme.secondaryTextColor, spinnerColor: sheetTheme.secondaryTextColor, badgeTextColor: sheetTheme.controlAccentColor, badgeImage: nil, cornersImage: generateStretchableFilledCircleImage(diameter: 11.0, color: nil, strokeColor: nil, strokeWidth: nil, backgroundColor: sheetTheme.opaqueItemBackgroundColor))
}
