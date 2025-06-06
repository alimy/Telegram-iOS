import Foundation
import UIKit
import SwiftSignalKit
import Display
import AsyncDisplayKit
import TelegramCore
import LegacyComponents
import TelegramUIPreferences
import TelegramPresentationData
import AccountContext
import AttachmentUI

public enum WebSearchMode {
    case media
    case avatar
}

public enum WebSearchControllerMode {
    case media(attachment: Bool, completion: (ChatContextResultCollection, TGMediaSelectionContext, TGMediaEditingContext, Bool) -> Void)
    case editor(completion: (UIImage) -> Void)
    case avatar(initialQuery: String?, completion: (UIImage) -> Void)
    
    var mode: WebSearchMode {
        switch self {
        case .media, .editor:
            return .media
        case .avatar:
            return .avatar
        }
    }
}

final class WebSearchControllerInteraction {
    let openResult: (ChatContextResult) -> Void
    let setSearchQuery: (String) -> Void
    let deleteRecentQuery: (String) -> Void
    let toggleSelection: (ChatContextResult, Bool) -> Bool
    let sendSelected: (ChatContextResult?, Bool, Int32?, ChatSendMessageActionSheetController.SendParameters?) -> Void
    let schedule: (ChatSendMessageActionSheetController.SendParameters?) -> Void
    let avatarCompleted: (UIImage) -> Void
    let selectionState: TGMediaSelectionContext?
    let editingState: TGMediaEditingContext
    var hiddenMediaId: String?
    
    init(openResult: @escaping (ChatContextResult) -> Void, setSearchQuery: @escaping (String) -> Void, deleteRecentQuery: @escaping (String) -> Void, toggleSelection: @escaping (ChatContextResult, Bool) -> Bool, sendSelected: @escaping (ChatContextResult?, Bool, Int32?, ChatSendMessageActionSheetController.SendParameters?) -> Void, schedule: @escaping (ChatSendMessageActionSheetController.SendParameters?) -> Void, avatarCompleted: @escaping (UIImage) -> Void, selectionState: TGMediaSelectionContext?, editingState: TGMediaEditingContext) {
        self.openResult = openResult
        self.setSearchQuery = setSearchQuery
        self.deleteRecentQuery = deleteRecentQuery
        self.toggleSelection = toggleSelection
        self.sendSelected = sendSelected
        self.schedule = schedule
        self.avatarCompleted = avatarCompleted
        self.selectionState = selectionState
        self.editingState = editingState
    }
}

private func selectionChangedSignal(selectionState: TGMediaSelectionContext) -> Signal<Void, NoError> {
    return Signal { subscriber in
        let disposable = selectionState.selectionChangedSignal()?.start(next: { next in
            subscriber.putNext(Void())
        }, completed: {})
        return ActionDisposable {
            disposable?.dispose()
        }
    }
}

public struct WebSearchConfiguration: Equatable {
    public let gifProvider: String?
    
    public init(appConfiguration: AppConfiguration) {
        var gifProvider: String? = nil
        if let data = appConfiguration.data, let value = data["gif_search_branding"] as? String {
            gifProvider = value
        }
        self.gifProvider = gifProvider
    }
}

public final class WebSearchController: ViewController {
    private var validLayout: ContainerViewLayout?
    
    private let context: AccountContext
    let mode: WebSearchControllerMode
    private let peer: EnginePeer?
    private let chatLocation: ChatLocation?
    private let configuration: EngineConfiguration.SearchBots
    private let activateOnDisplay: Bool
    
    private var controllerNode: WebSearchControllerNode {
        return self.displayNode as! WebSearchControllerNode
    }
    
    private var _ready = Promise<Bool>()
    override public var ready: Promise<Bool> {
        return self._ready
    }
    
    private var didPlayPresentationAnimation = false
    
    private var controllerInteraction: WebSearchControllerInteraction?
    private var interfaceState: WebSearchInterfaceState
    private let interfaceStatePromise = ValuePromise<WebSearchInterfaceState>()
    
    private var disposable: Disposable?
    private let resultsDisposable = MetaDisposable()
    private var selectionDisposable: Disposable?
    
    private var navigationContentNode: WebSearchNavigationContentNode?
    
    public var getCaptionPanelView: () -> TGCaptionPanelView? = { return nil } {
        didSet {
            self.controllerNode.getCaptionPanelView = self.getCaptionPanelView
        }
    }
    
    public var presentSchedulePicker: (Bool, @escaping (Int32) -> Void) -> Void = { _, _ in }
    
    public var dismissed: () -> Void = { }
    
    public var searchingUpdated: (Bool) -> Void = { _ in }
    
    public var attemptItemSelection: (ChatContextResult) -> Bool = { _ in return true }
    
    private var searchQueryPromise = ValuePromise<String>()
    private var searchQueryDisposable: Disposable?
    
    public init(context: AccountContext, updatedPresentationData: (initial: PresentationData, signal: Signal<PresentationData, NoError>)? = nil, peer: EnginePeer?, chatLocation: ChatLocation?, configuration: EngineConfiguration.SearchBots, mode: WebSearchControllerMode, activateOnDisplay: Bool = true) {
        self.context = context
        self.mode = mode
        self.peer = peer
        self.chatLocation = chatLocation
        self.configuration = configuration
        self.activateOnDisplay = activateOnDisplay
        
        let presentationData = updatedPresentationData?.initial ?? context.sharedContext.currentPresentationData.with { $0 }
        self.interfaceState = WebSearchInterfaceState(presentationData: presentationData)
        
        var searchQuery: String?
        if case let .avatar(initialQuery, _) = mode, let query = initialQuery {
            searchQuery = query
            self.interfaceState = self.interfaceState.withUpdatedQuery(query)
        }
        
        super.init(navigationBarPresentationData: NavigationBarPresentationData(theme: NavigationBarTheme(rootControllerTheme: presentationData.theme).withUpdatedSeparatorColor(presentationData.theme.list.plainBackgroundColor).withUpdatedBackgroundColor(presentationData.theme.list.plainBackgroundColor), strings: NavigationBarStrings(presentationStrings: presentationData.strings)))
        self.statusBar.statusBarStyle = presentationData.theme.rootController.statusBarStyle.style
        
        self.scrollToTop = { [weak self] in
            if let strongSelf = self {
                strongSelf.controllerNode.scrollToTop(animated: true)
            }
        }
        
        let settings = self.context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.webSearchSettings])
        |> map { sharedData -> WebSearchSettings in
            if let current = sharedData.entries[ApplicationSpecificSharedDataKeys.webSearchSettings]?.get(WebSearchSettings.self) {
                return current
            } else {
                return WebSearchSettings.defaultSettings
            }
        }
        
        let gifProvider = self.context.account.postbox.preferencesView(keys: [PreferencesKeys.appConfiguration])
        |> map { view -> String? in
            guard let appConfiguration = view.values[PreferencesKeys.appConfiguration]?.get(AppConfiguration.self) else {
                return nil
            }
            let configuration = WebSearchConfiguration(appConfiguration: appConfiguration)
            return configuration.gifProvider
        }
        |> distinctUntilChanged

        self.disposable = ((combineLatest(settings, (updatedPresentationData?.signal ?? context.sharedContext.presentationData), gifProvider))
        |> deliverOnMainQueue).start(next: { [weak self] settings, presentationData, gifProvider in
            guard let strongSelf = self else {
                return
            }
            strongSelf.updateInterfaceState { current -> WebSearchInterfaceState in
                var updated = current
                if case .media = mode, current.state?.scope != settings.scope {
                    updated = updated.withUpdatedScope(settings.scope)
                }
                if current.presentationData !== presentationData {
                    updated = updated.withUpdatedPresentationData(presentationData)
                }
                if current.gifProvider != gifProvider {
                    updated = updated.withUpdatedGifProvider(gifProvider)
                }
                return updated
            }
        })
        
        var attachment = false
        if case let .media(attachmentValue, _) = mode {
            attachment = attachmentValue
        } else if case .editor = mode {
            attachment = true
        }
        let navigationContentNode = WebSearchNavigationContentNode(theme: presentationData.theme, strings: presentationData.strings, attachment: attachment)
        self.navigationContentNode = navigationContentNode
        navigationContentNode.setQueryUpdated { [weak self] query in
            if let strongSelf = self, strongSelf.isNodeLoaded {
                strongSelf.searchQueryPromise.set(query)
                strongSelf.searchingUpdated(!query.isEmpty)
            }
        }
        navigationContentNode.cancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.cancel()
            }
        }
        self.navigationBar?.setContentNode(navigationContentNode, animated: false)
        if let query = searchQuery {
            navigationContentNode.setQuery(query)
        }
        
        let selectionState: TGMediaSelectionContext?
        switch self.mode {
            case .media:
                selectionState = TGMediaSelectionContext()
            case .avatar:
                selectionState = nil
            case .editor:
                selectionState = nil
        }
        let editingState = TGMediaEditingContext()
        self.controllerInteraction = WebSearchControllerInteraction(openResult: { [weak self] result in
            if let strongSelf = self {
                strongSelf.controllerNode.openResult(currentResult: result, present: { [weak self] viewController, arguments in
                    if let strongSelf = self {
                        strongSelf.present(viewController, in: .window(.root), with: arguments, blockInteraction: true)
                    }
                })
            }
        }, setSearchQuery: { [weak self] query in
            if let strongSelf = self {
                strongSelf.navigationContentNode?.setQuery(query)
                strongSelf.updateSearchQuery(query)
                strongSelf.navigationContentNode?.deactivate()
            }
        }, deleteRecentQuery: { [weak self] query in
            if let strongSelf = self {
                let _ = removeRecentWebSearchQuery(engine: strongSelf.context.engine, string: query).start()
            }
        }, toggleSelection: { [weak self] result, value in
            if let strongSelf = self {
                if !strongSelf.attemptItemSelection(result) {
                    return false
                }
                let item = LegacyWebSearchItem(result: result)
                strongSelf.controllerInteraction?.selectionState?.setItem(item, selected: value)
                return true
            } else {
                return false
            }
        }, sendSelected: { [weak self] current, silently, scheduleTime, messageEffect in
            if let selectionState = selectionState, let results = self?.controllerNode.currentExternalResults {
                if let current = current {
                    let currentItem = LegacyWebSearchItem(result: current)
                    selectionState.setItem(currentItem, selected: true)
                }
                if case let .media(_, sendSelected) = mode {
                    sendSelected(results, selectionState, editingState, false)
                }
            }
        }, schedule: { [weak self] messageEffect in
            if let strongSelf = self {
                strongSelf.presentSchedulePicker(false, { [weak self] time in
                    self?.controllerInteraction?.sendSelected(nil, false, time, nil)
                })
            }
        }, avatarCompleted: { result in
            if case let .avatar(_, avatarCompleted) = mode {
                avatarCompleted(result)
            }
        }, selectionState: selectionState, editingState: editingState)
        
        selectionState?.attemptSelectingItem = { [weak self] item in
            guard let self else {
                return false
            }
            
            if let item = item as? LegacyWebSearchItem {
                return self.attemptItemSelection(item.result)
            }
            
            return true
        }
        
        if let selectionState = selectionState {
            self.selectionDisposable = (selectionChangedSignal(selectionState: selectionState)
            |> deliverOnMainQueue).start(next: { [weak self] _ in
                if let strongSelf = self {
                    strongSelf.controllerNode.updateSelectionState(animated: true)
                }
            })
        }
        
        let throttledSearchQuery = self.searchQueryPromise.get()
        |> mapToSignal { query -> Signal<String, NoError> in
            if !query.isEmpty {
                return (.complete() |> delay(1.0, queue: Queue.mainQueue()))
                |> then(.single(query))
            } else {
                return .single(query)
            }
        }
        
        self.searchQueryDisposable = (throttledSearchQuery
        |> deliverOnMainQueue).start(next: { [weak self] query in
            if let self {
                self.updateSearchQuery(query)
            }
        })
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.disposable?.dispose()
        self.resultsDisposable.dispose()
        self.selectionDisposable?.dispose()
        self.searchQueryDisposable?.dispose()
    }
    
    public func cancel() {
        self.controllerNode.dismissInput?()
        self.controllerNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false, completion: { [weak self] _ in
            self?.dismissed()
            self?.dismiss()
        })
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let presentationArguments = self.presentationArguments as? ViewControllerPresentationArguments, !self.didPlayPresentationAnimation {
            self.didPlayPresentationAnimation = true
            if case .modalSheet = presentationArguments.presentationAnimation {
                self.controllerNode.animateIn()
            }
        }
    }
    
    private var didActivateSearch = false
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var select = false
        if case let .avatar(initialQuery, _) = self.mode, let _ = initialQuery {
            select = true
        }
        if case let .media(attachment, _) = self.mode, attachment && !self.didPlayPresentationAnimation {
            self.didPlayPresentationAnimation = true
            self.controllerNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
        } else if case .editor = self.mode, !self.didPlayPresentationAnimation {
            self.didPlayPresentationAnimation = true
            self.controllerNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
        }
        if !self.didActivateSearch && self.activateOnDisplay {
            self.didActivateSearch = true
            self.navigationContentNode?.activate(select: select)
        }
    }
    
    override public func loadDisplayNode() {
        var attachment: Bool = false
        if case let .media(attachmentValue, _) = self.mode, attachmentValue {
            attachment = true
        }
        self.displayNode = WebSearchControllerNode(controller: self, context: self.context, presentationData: self.interfaceState.presentationData, controllerInteraction: self.controllerInteraction!, peer: self.peer, chatLocation: self.chatLocation, mode: self.mode.mode, attachment: attachment)
        self.controllerNode.requestUpdateInterfaceState = { [weak self] animated, f in
            if let strongSelf = self {
                strongSelf.updateInterfaceState(f)
            }
        }
        self.controllerNode.cancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.dismiss()
            }
        }
        self.controllerNode.dismissInput = { [weak self] in
            if let strongSelf = self {
                strongSelf.navigationContentNode?.deactivate()
            }
        }
        self.controllerNode.updateInterfaceState(self.interfaceState, animated: false)
        
        self._ready.set(.single(true))
        self.displayNodeDidLoad()
    }
    
    private func updateInterfaceState(animated: Bool = true, _ f: (WebSearchInterfaceState) -> WebSearchInterfaceState) {
        let previousInterfaceState = self.interfaceState
        let previousTheme = self.interfaceState.presentationData.theme
        let previousStrings = self.interfaceState.presentationData.theme
        let previousGifProvider = self.interfaceState.gifProvider
        
        let updatedInterfaceState = f(self.interfaceState)
        self.interfaceState = updatedInterfaceState
        self.interfaceStatePromise.set(updatedInterfaceState)
        
        if self.isNodeLoaded {
            if previousTheme !== updatedInterfaceState.presentationData.theme || previousStrings !== updatedInterfaceState.presentationData.strings || previousGifProvider != updatedInterfaceState.gifProvider {
                self.controllerNode.updatePresentationData(theme: updatedInterfaceState.presentationData.theme, strings: updatedInterfaceState.presentationData.strings)
            }
            if previousInterfaceState != self.interfaceState {
                self.controllerNode.updateInterfaceState(self.interfaceState, animated: animated)
            }
        }
    }
    
    private func updateSearchQuery(_ query: String) {        
        let scope: Signal<WebSearchScope?, NoError>
        switch self.mode {
            case .media:
                scope = self.interfaceStatePromise.get()
                |> map { state -> WebSearchScope? in
                    return state.state?.scope
                }
                |> distinctUntilChanged
            case .avatar, .editor:
                scope = .single(.images)
        }
        
        self.updateInterfaceState { $0.withUpdatedQuery(query) }
        
        let scopes: [WebSearchScope: Promise<((ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, Bool)>] = [.images: Promise(initializeOnFirstAccess: self.signalForQuery(query, scope: .images)
        |> mapToSignal { result -> Signal<((ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, Bool), NoError> in
            return .single((result, false))
            |> then(.single((result, true)))
        }), .gifs: Promise(initializeOnFirstAccess: self.signalForQuery(query, scope: .gifs)
        |> mapToSignal { result -> Signal<((ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, Bool), NoError> in
            return .single((result, false))
            |> then(.single((result, true)))
        })]
        
        var results = scope
        |> mapToSignal { scope -> (Signal<((ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, Bool), NoError>) in
            if let scope = scope, let scopeResults = scopes[scope] {
                return scopeResults.get()
            } else {
                return .complete()
            }
        }
        
        if query.isEmpty {
            results = .single(({ _ in return nil}, false))
            self.navigationContentNode?.setActivity(false)
        }
        
        let previousResults = Atomic<(ChatContextResultCollection, Bool)?>(value: nil)
        self.resultsDisposable.set((results
        |> deliverOnMainQueue).start(next: { [weak self] result, immediate in
            if let strongSelf = self {
                if let result = result(nil), case let .contextRequestResult(_, results) = result {
                    if let results = results {
                        let previous = previousResults.swap((results, immediate))
                        if let previous = previous, previous.0.queryId == results.queryId && !previous.1 {
                        } else {
                            strongSelf.controllerNode.updateResults(results, immediate: immediate)
                        }
                    }
                } else {
                    strongSelf.controllerNode.updateResults(nil)
                }
            }
        }))
    }
    
    private func signalForQuery(_ query: String, scope: WebSearchScope) -> Signal<(ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, NoError> {
        let delayRequest = true
        let signal: Signal<(ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, NoError> = .single({ _ in return .contextRequestResult(nil, nil) })
        
        let peerId = self.peer?.id ?? self.context.account.peerId
        
        let botName: String?
        switch scope {
            case .images:
                botName = self.configuration.imageBotUsername
            case .gifs:
                botName = self.configuration.gifBotUsername
        }
        guard let name = botName else {
            return .single({ _ in return .contextRequestResult(nil, nil) })
        }
        
        let context = self.context
        let contextBot = self.context.engine.peers.resolvePeerByName(name: name, referrer: nil)
        |> mapToSignal { result -> Signal<EnginePeer?, NoError> in
            guard case let .result(result) = result else {
                return .complete()
            }
            return .single(result)
        }
        |> mapToSignal { peer -> Signal<(ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, NoError> in
            if case let .user(user) = peer, let botInfo = user.botInfo, let _ = botInfo.inlinePlaceholder {
                let results = requestContextResults(engine: context.engine, botId: user.id, query: query, peerId: peerId, limit: 64)
                |> map { results -> (ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult? in
                    return { _ in
                        return .contextRequestResult(.user(user), results?.results)
                    }
                }
            
                let botResult: Signal<(ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, NoError> = .single({ previousResult in
                    var passthroughPreviousResult: ChatContextResultCollection?
                    if let previousResult = previousResult {
                        if case let .contextRequestResult(previousUser, previousResults) = previousResult {
                            if previousUser?.id == user.id {
                                passthroughPreviousResult = previousResults
                            }
                        }
                    }
                    return .contextRequestResult(nil, passthroughPreviousResult)
                })
                
                let maybeDelayedContextResults: Signal<(ChatPresentationInputQueryResult?) -> ChatPresentationInputQueryResult?, NoError>
                if delayRequest {
                    maybeDelayedContextResults = results |> delay(0.4, queue: Queue.concurrentDefaultQueue())
                } else {
                    maybeDelayedContextResults = results
                }
                
                return botResult |> then(maybeDelayedContextResults)
            } else {
                return .single({ _ in return nil })
            }
        }
        return (signal |> then(contextBot))
        |> deliverOnMainQueue
        |> beforeStarted { [weak self] in
            if let strongSelf = self {
                strongSelf.navigationContentNode?.setActivity(true)
            }
        }
        |> afterCompleted { [weak self] in
            if let strongSelf = self {
                strongSelf.navigationContentNode?.setActivity(false)
            }
        }
    }
    
    public var mediaPickerContext: WebSearchPickerContext? {
        if let interaction = self.controllerInteraction {
            return WebSearchPickerContext(interaction: interaction)
        } else {
            return nil
        }
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.validLayout = layout
        
        let navigationBarHeight = self.navigationLayout(layout: layout).navigationFrame.maxY
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: navigationBarHeight, transition: transition)
    }
}

public class WebSearchPickerContext: AttachmentMediaPickerContext {
    private weak var interaction: WebSearchControllerInteraction?
    
    public var selectionCount: Signal<Int, NoError> {
        return Signal { [weak self] subscriber in
            let disposable = self?.interaction?.selectionState?.selectionChangedSignal().start(next: { [weak self] value in
                subscriber.putNext(Int(self?.interaction?.selectionState?.count() ?? 0))
            }, error: { _ in }, completed: { })
            return ActionDisposable {
                disposable?.dispose()
            }
        }
    }
    
    public var caption: Signal<NSAttributedString?, NoError> {
        return Signal { [weak self] subscriber in
            let disposable = self?.interaction?.editingState.forcedCaption().start(next: { caption in
                if let caption = caption as? NSAttributedString {
                    subscriber.putNext(caption)
                } else {
                    subscriber.putNext(nil)
                }
            }, error: { _ in }, completed: { })
            return ActionDisposable {
                disposable?.dispose()
            }
        }
    }
    
    init(interaction: WebSearchControllerInteraction) {
        self.interaction = interaction
    }
    
    public func setCaption(_ caption: NSAttributedString) {
        self.interaction?.editingState.setForcedCaption(caption, skipUpdate: true)
    }
    
    public func send(mode: AttachmentMediaPickerSendMode, attachmentMode: AttachmentMediaPickerAttachmentMode, parameters: ChatSendMessageActionSheetController.SendParameters?) {
        self.interaction?.sendSelected(nil, mode == .silently, nil, parameters)
    }
    
    public func schedule(parameters: ChatSendMessageActionSheetController.SendParameters?) {
        self.interaction?.schedule(parameters)
    }
}
