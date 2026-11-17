import LvoqStreamCore
import SwiftUI
import LvoqStreamUIComponents

/// Lets the operator choose which IPv4 cameras should dial. Bonjour can advertise an unreachable one.
struct DirectorConnectAddressCard: View {
    let addresses: [String]
    let port: UInt16?
    let activeHost: String
    let onApply: (String) -> Void

    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BroadcastSectionHeader(BundleLocalization.string("connect.android_ip.section"), systemImage: "network")

            Text(BundleLocalization.string("Sirve para que una cámara Android encuentre al director. iPhone y iPad se descubren solos."))
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            Text(statusLine)
                .font(.caption2)
                .foregroundStyle(.secondary)

            TextField("192.168.0.10", text: $draft)
                .textFieldStyle(.roundedBorder)
                .font(.caption.monospaced())
#if os(iOS)
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
#endif
                .onSubmit { onApply(draft) }
                .padding(.horizontal, 4)

            if !addresses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(addresses, id: \.self) { address in
                            Button(address) {
                                draft = address
                                onApply(address)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .tint(address == activeHost ? .accentColor : .secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            Button(BundleLocalization.string("connect.use_this_ip")) {
                onApply(draft)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .padding(.horizontal, 4)
        }
        .onAppear { draft = activeHost }
        .onChange(of: activeHost) { _, newValue in
            draft = newValue
        }
    }

    private var statusLine: String {
        let host = activeHost.isEmpty ? BundleLocalization.string("connect.no_ip") : activeHost
        if let port {
            return String(format: BundleLocalization.string("connect.cameras_use_host_port"), host, port)
        }
        return String(format: BundleLocalization.string("connect.cameras_use_host"), host)
    }
}
