load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "PeerNameColorScreen",
    module_name = "PeerNameColorScreen",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/AsyncDisplayKit",
        "//submodules/Display",
        "//submodules/Postbox",
        "//submodules/TelegramCore",
        "//submodules/SSignalKit/SwiftSignalKit",
        "//submodules/TelegramPresentationData",
        "//submodules/AccountContext",
        "//submodules/ItemListUI",
        "//submodules/PresentationDataUtils",
        "//submodules/UndoUI",
        "//submodules/WallpaperBackgroundNode",
        "//submodules/ComponentFlow",
        "//submodules/TelegramUI/Components/EmojiStatusComponent",
        "//submodules/TelegramUI/Components/EntityKeyboard",
        "//submodules/SolidRoundedButtonNode",
        "//submodules/AppBundle",
        "//submodules/PremiumUI",
        "//submodules/TelegramUI/Components/PeerInfo/PeerInfoCoverComponent",
        "//submodules/AvatarNode",
        "//submodules/Components/ViewControllerComponent",
        "//submodules/Components/BundleIconComponent",
        "//submodules/TelegramUI/Components/AnimatedTextComponent",
        "//submodules/TelegramUI/Components/ButtonComponent",
        "//submodules/TelegramUI/Components/PremiumLockButtonSubtitleComponent",
        "//submodules/TelegramUI/Components/ListItemComponentAdaptor",
        "//submodules/TelegramUI/Components/ListSectionComponent",
        "//submodules/TelegramUI/Components/ListActionItemComponent",
        "//submodules/TelegramUI/Components/Settings/ThemeCarouselItem",
        "//submodules/Components/MultilineTextComponent",
        "//submodules/TelegramUI/Components/EmojiStatusSelectionComponent",
        "//submodules/TelegramUI/Components/DynamicCornerRadiusView",
        "//submodules/Components/ComponentDisplayAdapters",
        "//submodules/WallpaperResources",
        "//submodules/MediaPickerUI",
        "//submodules/TelegramUI/Components/Settings/WallpaperGalleryScreen",
        "//submodules/TelegramUI/Components/Settings/WallpaperGridScreen",
        "//submodules/TelegramUI/Components/Settings/BoostLevelIconComponent",
        "//submodules/Markdown",
        "//submodules/TelegramUI/Components/GroupStickerPackSetupController",
        "//submodules/TelegramUI/Components/Chat/ChatMessageItemImpl",
        "//submodules/TelegramUI/Components/Settings/PeerNameColorItem",
        "//submodules/TelegramUI/Components/EmojiActionIconComponent",
        "//submodules/TelegramUI/Components/TabSelectorComponent",
        "//submodules/TelegramUI/Components/PlainButtonComponent",
    ],
    visibility = [
        "//visibility:public",
    ],
)
