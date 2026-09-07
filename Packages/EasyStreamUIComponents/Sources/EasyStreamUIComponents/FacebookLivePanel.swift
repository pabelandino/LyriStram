import SwiftUI
import EasyStreamFacebook

public struct FacebookLivePanel: View {
    let isConfigured: Bool
    let session: FacebookSession
    let pages: [FacebookPage]
    let selectedPageID: String?
    let isLoading: Bool
    let statusMessage: String?
    let onSignIn: () -> Void
    let onAuthorizePages: () -> Void
    let onSignOut: () -> Void
    let onSelectPage: (String) -> Void
    let onPrepareLive: () -> Void

    public init(
        isConfigured: Bool,
        session: FacebookSession,
        pages: [FacebookPage],
        selectedPageID: String?,
        isLoading: Bool,
        statusMessage: String?,
        onSignIn: @escaping () -> Void,
        onAuthorizePages: @escaping () -> Void,
        onSignOut: @escaping () -> Void,
        onSelectPage: @escaping (String) -> Void,
        onPrepareLive: @escaping () -> Void
    ) {
        self.isConfigured = isConfigured
        self.session = session
        self.pages = pages
        self.selectedPageID = selectedPageID
        self.isLoading = isLoading
        self.statusMessage = statusMessage
        self.onSignIn = onSignIn
        self.onAuthorizePages = onAuthorizePages
        self.onSignOut = onSignOut
        self.onSelectPage = onSelectPage
        self.onPrepareLive = onPrepareLive
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isConfigured {
                Text("Configura FacebookAppID y FacebookClientToken en Info.plist.")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                Text("En Meta: App settings → Basic (App ID) y Advanced (Client token).")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !session.isSignedIn {
#if os(iOS)
                Text("Primero inicia sesión con Facebook. Luego autoriza acceso a tus Páginas.")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onSignIn) {
                    Label("Iniciar sesión con Facebook", systemImage: "person.crop.circle.badge.checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .disabled(isLoading)
#else
                Text("Facebook Login solo funciona en iPad/iPhone. En Mac no está soportado.")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
#endif
            } else {
                signedInContent
            }

            if let statusMessage, !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var signedInContent: some View {
        HStack {
            if let profile = session.userProfile {
                Text(profile.name)
                    .font(.caption.weight(.semibold))
            }
            Spacer()
            Button("Cerrar sesión", action: onSignOut)
                .font(.caption)
                .disabled(isLoading)
        }

        if pages.isEmpty {
            Text("Autoriza acceso a tus Páginas de Facebook para transmitir en vivo.")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

#if os(iOS)
            Button(action: onAuthorizePages) {
                Label("Autorizar Páginas", systemImage: "rectangle.stack.badge.person.crop")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            .disabled(isLoading)

            Text(FacebookConfiguration.pagePermissionsMetaSetupHint)
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
#endif
        } else {
            Picker("Página", selection: pageSelection) {
                ForEach(pages) { page in
                    Text(page.name).tag(page.id)
                }
            }
            .pickerStyle(.menu)

            Button(action: onPrepareLive) {
                Label("Preparar transmisión", systemImage: "video.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlassBorderedButtonStyle())
            .disabled(isLoading || selectedPageID == nil)
        }

        if let liveVideoID = session.activeLiveVideoID {
            Text("Live Video ID: \(liveVideoID)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.green)
        }
    }

    private var pageSelection: Binding<String> {
        Binding(
            get: { selectedPageID ?? pages.first?.id ?? "" },
            set: { newValue in
                guard !newValue.isEmpty else { return }
                onSelectPage(newValue)
            }
        )
    }
}
