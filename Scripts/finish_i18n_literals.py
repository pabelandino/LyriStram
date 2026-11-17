#!/usr/bin/env python3
"""Add catalog keys and apply remaining UI / status literal migrations."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "LvoqStream/Localization/Localizable.xcstrings"


def add_entries(data: dict, entries: dict[str, tuple[str, str, str]]) -> None:
    strings = data.setdefault("strings", {})
    for key, (en, es, pt) in entries.items():
        strings[key] = {
            "extractionState": "manual",
            "localizations": {
                "en": {"stringUnit": {"state": "translated", "value": en}},
                "es": {"stringUnit": {"state": "translated", "value": es}},
                "pt": {"stringUnit": {"state": "translated", "value": pt}},
            },
        }


ENTRIES: dict[str, tuple[str, str, str]] = {
    "common.inspector": ("Inspector", "Inspector", "Inspetor"),
    "common.incompatible": ("Incompatible", "Incompatible", "Incompatível"),
    "common.recommended": ("Recommended", "Recomendado", "Recomendado"),
    "common.retry": ("Retry", "Reintentar", "Tentar novamente"),
    "common.reconnect": ("Reconnect", "Reconectar", "Reconectar"),
    "common.style": ("Style", "Estilo", "Estilo"),
    "common.system": ("System", "Sistema", "Sistema"),
    "common.speaker": ("Speaker", "Altavoz", "Alto-falante"),
    "common.files": ("Files", "Archivos", "Arquivos"),
    "common.monitor": ("Monitor", "Monitor", "Monitor"),
    "common.edit": ("Edit", "Editar", "Editar"),
    "common.controls": ("Controls", "Controles", "Controles"),
    "common.director": ("Director", "Director", "Diretor"),
    "remote.white_balance": ("White balance", "Balance de blancos", "Balanço de branco"),
    "remote.controls.title": ("Remote controls", "Controles remotos", "Controles remotos"),
    "director.sources.title": ("Sources", "Fuentes", "Fontes"),
    "director.menu.studio_settings": ("Studio settings", "Ajustes del estudio", "Ajustes do estúdio"),
    "director.change_role_accessibility": ("Change role", "Cambiar rol", "Mudar função"),
    "program.empty": ("No program", "Sin programa", "Sem programa"),
    "program.no_audio_sources": ("No audio sources", "Sin fuentes de audio", "Sem fontes de áudio"),
    "program.no_source": ("No source", "Sin fuente", "Sem fonte"),
    "program.fullscreen_label": ("Full screen: %@", "Pantalla completa: %@", "Tela cheia: %@"),
    "stream.connecting": ("Connecting…", "Conectando…", "Conectando…"),
    "stream.preparing": ("Preparing…", "Preparando…", "Preparando…"),
    "stream.sending_stats": (
        "Sending · %1$ld video · %2$ld audio · %3$@",
        "Enviando · %1$ld video · %2$ld audio · %3$@",
        "Enviando · %1$ld video · %2$ld audio · %3$@",
    ),
    "facebook.meta_settings_hint": (
        "In Meta: App settings → Basic (App ID) and Advanced (Client token).",
        "En Meta: App settings → Basic (App ID) y Advanced (Client token).",
        "No Meta: App settings → Basic (App ID) e Advanced (Client token).",
    ),
    "facebook.live_video_id": ("Live Video ID: %@", "Live Video ID: %@", "Live Video ID: %@"),
    "photo.library": ("Photo library", "Biblioteca de fotos", "Biblioteca de fotos"),
    "logo.optional": ("Logo (optional)", "Logo (opcional)", "Logo (opcional)"),
    "logo.optional_png": ("PNG logo (optional)", "Logo PNG (opcional)", "Logo PNG (opcional)"),
    "widget.studio.drag_position": (
        "Drag to position · %@",
        "Arrastra para posicionar · %@",
        "Arraste para posicionar · %@",
    ),
    "widget.studio.logo_spin_hint": (
        "Spins horizontally, pauses, then spins again. Play restarts it in this view.",
        "Gira en horizontal, hace una pausa y vuelve a girar. Play la reinicia en esta vista.",
        "Gira na horizontal, pausa e gira de novo. Play reinicia nesta vista.",
    ),
    "widget.studio.ticker_text_color": ("Text color", "Color del texto", "Cor da do texto"),
    "widget.studio.ticker_background_color": ("Background color", "Color de fondo", "Cor de fundo"),
    "studio.overlay.drag_hint": (
        "Drag the center to move · corner handles to resize",
        "Arrastra el centro para mover · puntos en esquinas para redimensionar",
        "Arraste o centro para mover · alças nos cantos para redimensionar",
    ),
    "monitor.display_section": ("Display", "Pantalla", "Tela"),
    "monitor.spacing_section": ("Spacing", "Separación", "Espaçamento"),
    "output.move_to_display": (
        "Move to selected display",
        "Mover a pantalla seleccionada",
        "Mover para a tela selecionada",
    ),
    "connect.android_ip.section": (
        "IP for Android cameras",
        "IP para cámaras Android",
        "IP para câmeras Android",
    ),
    "connect.use_this_ip": ("Use this IP", "Usar esta IP", "Usar este IP"),
    "connect.no_ip": ("no IP", "sin IP", "sem IP"),
    "connect.cameras_use_host_port": (
        "Cameras use %1$@:%2$u",
        "Las cámaras usan %1$@:%2$u",
        "As câmeras usam %1$@:%2$u",
    ),
    "connect.cameras_use_host": (
        "Cameras use %@",
        "Las cámaras usan %@",
        "As câmeras usam %@",
    ),
    "network.local.required_title": (
        "Local network required",
        "Red local requerida",
        "Rede local necessária",
    ),
    "monitor.page_count_full": ("Page %1$ld/%2$ld", "Página %1$ld/%2$ld", "Página %1$ld/%2$ld"),
    "session.starting": ("Starting…", "Iniciando…", "Iniciando…"),
    "session.start_error": ("Failed to start", "Error al iniciar", "Erro ao iniciar"),
    "session.off_air": ("Off air", "Fuera del aire", "Fora do ar"),
    "session.stream_error": ("Stream error", "Error de stream", "Erro de stream"),
    "session.reconnecting_named": ("Reconnecting %@…", "Reconectando %@…", "Reconectando %@…"),
    "session.source_connected": ("%@ connected", "%@ conectada", "%@ conectada"),
    "session.cameras_live_count": (
        "%1$ld camera(s) live",
        "%1$ld cámara(s) en vivo",
        "%1$ld câmera(s) ao vivo",
    ),
    "session.no_link_disconnected": (
        "No link to camera. Marked disconnected.",
        "Sin enlace con la cámara. Quedó desconectada.",
        "Sem link com a câmera. Ficou desconectada.",
    ),
    "session.reconnect_failed": ("Reconnection failed", "Reconexión fallida", "Reconexão falhou"),
    "session.camera_disconnected": ("Camera disconnected", "Cámara desconectada", "Câmera desconectada"),
    "session.no_connection_disconnected": (
        "No connection to %@. Marked disconnected.",
        "Sin conexión con %@. Quedó desconectada.",
        "Sem conexão com %@. Ficou desconectada.",
    ),
    "discovery.start_error": (
        "Failed to start discovery",
        "Error al iniciar discovery",
        "Erro ao iniciar discovery",
    ),
    "discovery.stopped": ("Stopped", "Detenido", "Parado"),
    "discovery.searching_cameras": (
        "Searching for cameras on the local network…",
        "Buscando cámaras en la red local…",
        "Procurando câmeras na rede local…",
    ),
    "discovery.searching_directors": (
        "Searching for directors on the local network…",
        "Buscando directores en la red local…",
        "Procurando diretores na rede local…",
    ),
    "discovery.devices_found": (
        "%1$ld device(s) found",
        "%1$ld dispositivo(s) encontrado(s)",
        "%1$ld dispositivo(s) encontrado(s)",
    ),
    "camera.connecting_to_director": (
        "Connecting to %@…",
        "Conectando a %@…",
        "Conectando a %@…",
    ),
    "camera.negotiating_webrtc": ("Negotiating WebRTC…", "Negociando WebRTC…", "Negociando WebRTC…"),
    "camera.negotiate_error": (
        "Failed to negotiate with %@",
        "Error al negociar con %@",
        "Erro ao negociar com %@",
    ),
    "camera.reconnect_to_director": (
        "Reconnect to Director",
        "Reconectar al Director",
        "Reconectar ao Diretor",
    ),
    "camera.reconnecting_to_director": (
        "Reconnecting…",
        "Reconectando…",
        "Reconectando…",
    ),
    "intercom.disabled": ("Intercom off", "Intercom desactivado", "Intercom desativado"),
    "intercom.starting": ("Starting intercom…", "Iniciando intercom…", "Iniciando intercom…"),
    "intercom.stopped": ("Intercom stopped", "Intercom detenido", "Intercom parado"),
    "intercom.mic_settings_required": (
        "Enable the microphone in Settings to use intercom",
        "Activa el micrófono en Ajustes para usar el intercom",
        "Ative o microfone em Ajustes para usar o intercom",
    ),
    "intercom.mic_failed": (
        "Could not enable intercom microphone",
        "No se pudo activar el micrófono del intercom",
        "Não foi possível ativar o microfone do intercom",
    ),
    "intercom.activating_with": (
        "Starting intercom with %@…",
        "Activando intercom con %@…",
        "Ativando intercom com %@…",
    ),
    "intercom.connecting_with": (
        "Connecting with %@…",
        "Conectando con %@…",
        "Conectando com %@…",
    ),
    "intercom.transmitting_to": (
        "Transmitting to %@…",
        "Transmitiendo a %@…",
        "Transmitindo para %@…",
    ),
    "intercom.ready_no_team": (
        "Intercom ready · no team",
        "Intercom listo · sin equipo",
        "Intercom pronto · sem equipe",
    ),
    "intercom.peer_named": ("Intercom · %@", "Intercom · %@", "Intercom · %@"),
    "intercom.talk_to": (
        "Intercom · talk to %@",
        "Intercom · hablar con %@",
        "Intercom · falar com %@",
    ),
    "intercom.pick_recipient": (
        "Intercom · %1$ld in channel · choose recipient",
        "Intercom · %1$ld en canal · elige destinatario",
        "Intercom · %1$ld no canal · escolha destinatário",
    ),
    "window.widget_studio": ("Widget Studio", "Widget Studio", "Widget Studio"),
    "video.quality.preset_footer": (
        "This preset is saved for live output. YouTube and Facebook use it when connected. It does not change the director picture.",
        "Este preset se guarda para la salida en vivo. YouTube y Facebook lo usarán cuando estén conectados. No cambia la imagen del director.",
        "Este preset é salvo para a saída ao vivo. YouTube e Facebook usam quando conectados. Não altera a imagem do diretor.",
    ),
    "studio.unsupported_platform": (
        "Unsupported platform",
        "Plataforma no soportada",
        "Plataforma não suportada",
    ),
}

REPLACEMENTS: list[tuple[str, str, str]] = [
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorInspectorPanel.swift",
        'Text("Inspector")',
        'Text(BundleLocalization.string("common.inspector"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/CameraClientControlsView.swift",
        'Text("Balance de blancos")',
        'Text(BundleLocalization.string("remote.white_balance"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorRemoteWhiteBalancePicker.swift",
        'Text("Balance de blancos")',
        'Text(BundleLocalization.string("remote.white_balance"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorRemoteControlsHeader.swift",
        'Text("Controles remotos")',
        'Text(BundleLocalization.string("remote.controls.title"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/LocalNetworkPermissionView.swift",
        'Label("Red local requerida"',
        'Label(BundleLocalization.string("network.local.required_title")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/LocalNetworkPermissionView.swift",
        'Button("Reintentar"',
        'Button(BundleLocalization.string("common.retry")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/TeamIntercomPanel.swift",
        'Label("Red local requerida"',
        'Label(BundleLocalization.string("network.local.required_title")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorConnectionPanel.swift",
        'Text("Incompatible")',
        'Text(BundleLocalization.string("common.incompatible"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DiscoveredDeviceRow.swift",
        'Text("Incompatible")',
        'Text(BundleLocalization.string("common.incompatible"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/RoleSelectionView.swift",
        'Text("Recomendado")',
        'Text(BundleLocalization.string("common.recommended"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorSourceListRow.swift",
        'Button("Reconectar"',
        'Button(BundleLocalization.string("common.reconnect")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorSourcesPanel.swift",
        'title: String = "Fuentes"',
        'title: String = BundleLocalization.string("director.sources.title")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorSourcesPanel.swift",
        '.accessibilityLabel("Cambiar rol")',
        '.accessibilityLabel(BundleLocalization.string("director.change_role_accessibility"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorSourcesPanel.swift",
        'Button("Ajustes del estudio"',
        'Button(BundleLocalization.string("director.menu.studio_settings")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/DirectorSourcesPanel.swift",
        'Button("Monitor"',
        'Button(BundleLocalization.string("common.monitor")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/ProgramFeedView.swift",
        'emptyStatusMessage: String = "Sin programa"',
        'emptyStatusMessage: String = BundleLocalization.string("program.empty")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/ProgramFeedView.swift",
        'Label("Sin programa"',
        'Label(BundleLocalization.string("program.empty")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/StableProgramVideoView.swift",
        'Label("Sin programa"',
        'Label(BundleLocalization.string("program.empty")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/ProgramAudioSourcePanel.swift",
        'BroadcastInspectorEmptyState("Sin fuentes de audio"',
        'BroadcastInspectorEmptyState(BundleLocalization.string("program.no_audio_sources")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/StreamDestinationPanel.swift",
        'Label("Conectando…"',
        'Label(BundleLocalization.string("stream.connecting")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastTransmissionMenu.swift",
        'Label("Preparando…"',
        'Label(BundleLocalization.string("stream.preparing")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/LvoqShowWidgetStudioFields.swift",
        'Text("Estilo")',
        'Text(BundleLocalization.string("common.style"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/ProgramOutputDestinationPanel.swift",
        'Label("Mover a pantalla seleccionada"',
        'Label(BundleLocalization.string("output.move_to_display")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioTickerFields.swift",
        'Text("Color del texto")',
        'Text(BundleLocalization.string("widget.studio.ticker_text_color"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioTickerFields.swift",
        'Text("Color de fondo")',
        'Text(BundleLocalization.string("widget.studio.ticker_background_color"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioLogoFields.swift",
        'Text("Gira en horizontal, hace una pausa y vuelve a girar. Play la reinicia en esta vista.")',
        'Text(BundleLocalization.string("widget.studio.logo_spin_hint"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioOptionalLogoImportControl.swift",
        'Label("Biblioteca de fotos"',
        'Label(BundleLocalization.string("photo.library")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioOptionalLogoImportControl.swift",
        'Label("Archivos"',
        'Label(BundleLocalization.string("common.files")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioOptionalLogoImportControl.swift",
        'Label("Logo (opcional)"',
        'Label(BundleLocalization.string("logo.optional")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioOptionalLogoImportControl.swift",
        'Label("Logo PNG (opcional)"',
        'Label(BundleLocalization.string("logo.optional_png")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioLogoImportControl.swift",
        'Label("Biblioteca de fotos"',
        'Label(BundleLocalization.string("photo.library")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/BroadcastWidgetStudioLogoImportControl.swift",
        'Label("Archivos"',
        'Label(BundleLocalization.string("common.files")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/FacebookLivePanel.swift",
        'Text("En Meta: App settings → Basic (App ID) y Advanced (Client token).")',
        'Text(BundleLocalization.string("facebook.meta_settings_hint"))',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/PreviewMonitorSettingsForm.swift",
        'DirectorInspectorSection("Pantalla"',
        'DirectorInspectorSection(BundleLocalization.string("monitor.display_section")',
    ),
    (
        "Packages/LvoqStreamUIComponents/Sources/LvoqStreamUIComponents/PreviewMonitorSettingsForm.swift",
        'DirectorInspectorSection("Separación"',
        'DirectorInspectorSection(BundleLocalization.string("monitor.spacing_section")',
    ),
    (
        "LvoqStream/Features/Director/DirectorSettingsLiveGraphicsSection.swift",
        'Button("Editar")',
        'Button(BundleLocalization.string("common.edit")',
    ),
    (
        "LvoqStream/Features/Director/DirectorConnectAddressCard.swift",
        'BroadcastSectionHeader("IP para cámaras Android"',
        'BroadcastSectionHeader(BundleLocalization.string("connect.android_ip.section")',
    ),
    (
        "LvoqStream/Features/Director/DirectorConnectAddressCard.swift",
        'Button("Usar esta IP")',
        'Button(BundleLocalization.string("connect.use_this_ip")',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramStudioHintsOverlay.swift",
        'Text("Arrastra el centro para mover · puntos en esquinas para redimensionar")',
        'Text(BundleLocalization.string("studio.overlay.drag_hint"))',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramStudioHintsOverlay.swift",
        'Label("Play", systemImage: "play.fill")',
        'Label(BundleLocalization.string("common.play"), systemImage: "play.fill")',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramAudioSettingsView.swift",
        'Text("Sin fuente").tag("")',
        'Text(BundleLocalization.string("program.no_source")).tag("")',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramAudioSettingsView.swift",
        'Text("Sistema").tag("")',
        'Text(BundleLocalization.string("common.system")).tag("")',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramAudioSettingsView.swift",
        'Text("Sistema").tag(ProgramAudioOutputChoice.system)',
        'Text(BundleLocalization.string("common.system")).tag(ProgramAudioOutputChoice.system)',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramAudioSettingsView.swift",
        'Text("Altavoz").tag(ProgramAudioOutputChoice.speaker)',
        'Text(BundleLocalization.string("common.speaker")).tag(ProgramAudioOutputChoice.speaker)',
    ),
    (
        "LvoqStream/Features/Camera/CameraSessionControlsCard.swift",
        'BroadcastSectionHeader("Controles"',
        'BroadcastSectionHeader(BundleLocalization.string("common.controls")',
    ),
    (
        "LvoqStream/Features/Camera/CameraSessionDirectorCard.swift",
        'BroadcastSectionHeader("Director"',
        'BroadcastSectionHeader(BundleLocalization.string("common.director")',
    ),
    (
        "LvoqStream/Features/Director/DirectorProgramOutputStore.swift",
        'var emptyStatusMessage = "Sin programa"',
        'var emptyStatusMessage = BundleLocalization.string("program.empty")',
    ),
    (
        "LvoqStream/Features/Director/DirectorAuxiliaryWindowViews.swift",
        'window.title = "Widget Studio"',
        'window.title = BundleLocalization.string("window.widget_studio")',
    ),
    (
        "LvoqStream/Features/Director/DirectorStudioSettingsHubPlatformLayout.swift",
        '"Plataforma no soportada"',
        'BundleLocalization.string("studio.unsupported_platform")',
    ),
]


def main() -> None:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    add_entries(data, ENTRIES)
    CATALOG.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    for rel, old, new in REPLACEMENTS:
        path = ROOT / rel
        text = path.read_text(encoding="utf-8")
        if old not in text:
            print(f"SKIP (missing): {rel}: {old[:40]}...")
            continue
        path.write_text(text.replace(old, new, 1), encoding="utf-8")
        print(f"OK: {rel}")

    print(f"catalog_keys_added={len(ENTRIES)}")


if __name__ == "__main__":
    main()