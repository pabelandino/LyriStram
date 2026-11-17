import Foundation
import LvoqStreamCore

/// Typed keys for `Localizable.xcstrings`. To add a language: extend `AppLocale` and fill this catalog.
enum L10n {
    private static func t(_ key: String) -> String { BundleLocalization.string(key) }

    enum App {
        static var displayName: String { t("app.display_name") }
    }

    enum Common {
        static var done: String { t("common.done") }
        static var close: String { t("common.close") }
        static var cancel: String { t("common.cancel") }
        static var save: String { t("common.save") }
        static var delete: String { t("common.delete") }
        static var edit: String { t("common.edit") }
        static var add: String { t("common.add") }
        static var new: String { t("common.new") }
        static var search: String { t("common.search") }
        static var settings: String { t("common.settings") }
        static var audio: String { t("common.audio") }
        static var `continue`: String { t("common.continue") }
        static var type: String { t("common.type") }
        static var section: String { t("common.section") }
        static var library: String { t("common.library") }
        static var preview: String { t("common.preview") }
        static var program: String { t("common.program") }
        static var monitor: String { t("common.monitor") }
        static var play: String { t("common.play") }
        static var stop: String { t("common.stop") }
    }

    enum Settings {
        static var languageSection: String { t("settings.language.section") }
        static var languageFooter: String { t("settings.language.footer") }
        static var languageSystem: String { t("settings.language.option.system") }

        static func languageName(for locale: AppLocale) -> String {
            t(locale.settingsNameKey)
        }
    }

    enum StudioTab {
        static var qualityTitle: String { t("studio.tab.quality.title") }
        static var qualitySubtitle: String { t("studio.tab.quality.subtitle") }
        static var monitorTitle: String { t("studio.tab.monitor.title") }
        static var monitorSubtitle: String { t("studio.tab.monitor.subtitle") }
        static var studioTitle: String { t("studio.tab.studio.title") }
        static var studioSubtitle: String { t("studio.tab.studio.subtitle") }
        static var loadingSettings: String { t("studio.settings.loading") }
    }

    enum Director {
        static var inactiveTitle: String { t("director.inactive.title") }
        static var inactiveSettingsBody: String { t("director.inactive.settings.body") }
        static var inactiveStreamBody: String { t("director.inactive.stream.body") }
        static var inactiveWidgetBody: String { t("director.inactive.widget.body") }
        static var waitingCameras: String { t("director.waiting_cameras") }
        static var noCameras: String { t("director.no_cameras") }
        static var camerasSidebarHint: String { t("director.cameras_sidebar.hint") }
        static var studioSettingsTitle: String { t("director.studio_settings.title") }
        static var directorSettings: String { t("director.settings.toolbar") }
        static var changeRole: String { t("director.change_role") }
    }

    enum Library {
        static var kindImages: String { t("library.kind.image") }
        static var kindVideos: String { t("library.kind.video") }
        static var kindWidgets: String { t("library.kind.widget") }
        static var empty: String { t("library.empty") }
        static var searchPlaceholder: String { t("library.search.placeholder") }
    }

    enum Role {
        static var cameraTitle: String { t("role.camera.title") }
        static var changeRole: String { t("role.change") }

        static func selectionPrompt(deviceName: String) -> String {
            String(format: t("role.selection.prompt"), deviceName)
        }
    }

    enum Widget {
        static var newTemplateSheetTitle: String { t("widget.new_template.sheet_title") }
        static var studioTitle: String { t("widget.studio.title") }
        static var newChooseTemplate: String { t("widget.studio.new_choose_template") }
        static var editingPrefix: String { t("widget.studio.editing_prefix") }
        static var libraryNamePlaceholder: String { t("widget.studio.library_name") }
        static var templateSection: String { t("widget.studio.template_section") }
        static var previewSection: String { t("widget.studio.preview_section") }
        static var draftPreviewSection: String { t("widget.studio.draft_preview") }
        static var position: String { t("widget.studio.position") }
        static var addOnAir: String { t("widget.studio.add_on_air") }
        static var removeFromAir: String { t("widget.studio.remove_from_air") }
        static var applyOnAir: String { t("widget.studio.apply_on_air") }
        static var deleteTitle: String { t("widget.delete.title") }
        static var deleteMessage: String { t("widget.delete.message") }
        static var noWidgetEditing: String { t("widget.studio.none_editing") }
    }

    enum Template {
        static var animatedLogo: String { t("widget.template.animated_logo") }
        static var ticker: String { t("widget.template.ticker") }
        static var lowerThirdPro: String { t("widget.template.lower_third_pro") }
        static var clock: String { t("widget.template.clock") }
        static var countdown: String { t("widget.template.countdown") }
    }

    enum LvoqShow {
        static var onAir: String { t("lvoqShow.status.onAir") }
        static var standingBy: String { t("lvoqShow.status.standingBy") }
        static var searching: String { t("lvoqShow.status.searching") }
        static var stopped: String { t("lvoqShow.status.stopped") }
        static var widgetTitle: String { t("lvoqShow.widget.title") }
    }

    enum Camera {
        static var title: String { t("camera.title") }
        static var permissionBody: String { t("camera.permission.body") }
    }

    enum Network {
        static var permissionRequired: String { t("network.local.permission_required") }
        static var permissionHint: String { t("network.local.permission_hint") }
    }

    enum Session {
        static var starting: String { t("session.starting") }
        static var startError: String { t("session.start_error") }
        static var offAir: String { t("session.off_air") }
        static var streamError: String { t("session.stream_error") }

        static func reconnecting(_ name: String) -> String {
            String(format: t("session.reconnecting_named"), name)
        }

        static func sourceConnected(_ name: String) -> String {
            String(format: t("session.source_connected"), name)
        }

        static func camerasLiveCount(_ count: Int) -> String {
            String(format: t("session.cameras_live_count"), count)
        }

        static func noConnectionDisconnected(_ name: String) -> String {
            String(format: t("session.no_connection_disconnected"), name)
        }
    }

    enum Discovery {
        static var startError: String { t("discovery.start_error") }
        static var stopped: String { t("discovery.stopped") }
        static var searchingCameras: String { t("discovery.searching_cameras") }
        static var searchingDirectors: String { t("discovery.searching_directors") }

        static func devicesFound(_ count: Int) -> String {
            String(format: t("discovery.devices_found"), count)
        }
    }

    enum CameraSession {
        static var startError: String { t("session.start_error") }
        static var negotiatingWebRTC: String { t("camera.negotiating_webrtc") }

        static func connectingToDirector(_ name: String) -> String {
            String(format: t("camera.connecting_to_director"), name)
        }

        static func negotiateError(_ name: String) -> String {
            String(format: t("camera.negotiate_error"), name)
        }
    }
}