#!/usr/bin/env python3
"""Migrate user-facing Swift string literals to BundleLocalization.string(...)."""
from __future__ import annotations

import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "LvoqStream/Localization/Localizable.xcstrings"

SCAN_ROOTS = [
    ROOT / "LvoqStream",
    ROOT / "Packages/LvoqStreamUIComponents/Sources",
    ROOT / "Packages/LvoqStreamCore/Sources",
]

SKIP_DIR_NAMES = {"graphify-out", "node_modules", ".build", "Tests", "UITests"}
SKIP_FILES = {
    "BroadcastMetalSpriteBus.swift",
    "FacebookGraphClient.swift",
    "FacebookLiveService.swift",
}

UI_MARKERS = (
    "Text(", "Label(", "Button(", "Section(", "Picker(", "Toggle(", "Menu(", "help(",
    "navigationTitle(", "alert(", "BroadcastInspectorEmptyState(", "ProgressView(",
    "TextField(", "ContentUnavailableView(", "accessibilityLabel", "accessibilityHint",
    "DirectorInspectorSection(", "BroadcastSectionHeader(", "BroadcastMediaLibraryPanel",
    "var title", "var subtitle", "displayName", "statusMessage", 'return "',
    "title:", "message:", "placeholder:", "footer:",
)

# English / Portuguese for strings not yet in the catalog.
EXTRA_EN_PT: dict[str, tuple[str, str]] = {
    "Cámaras": ("Cameras", "Câmeras"),
    "PREV": ("PREV", "PREV"),
    "EN VIVO": ("ON AIR", "NO AR"),
    "PREVIEW": ("PREVIEW", "PRÉVIA"),
    "Pantalla externa": ("External display", "Tela externa"),
    "RTMPS / Redes": ("RTMPS / Networks", "RTMPS / Redes"),
    "Pantalla": ("Display", "Tela"),
    "Integrada": ("Built-in", "Integrada"),
    "Transmitir a pantalla externa, Facebook o RTMPS": (
        "Broadcast to external display, Facebook, or RTMPS",
        "Transmitir para tela externa, Facebook ou RTMPS",
    ),
    "Conecta un monitor, TV o proyector. La pantalla del director no se usa.": (
        "Connect a monitor, TV, or projector. The director display is not used.",
        "Conecte um monitor, TV ou projetor. A tela do diretor não é usada.",
    ),
    "Detener pantalla externa": ("Stop external display", "Parar tela externa"),
    "Transmitir a pantalla seleccionada": ("Broadcast to selected display", "Transmitir para a tela selecionada"),
    "Preparar transmisión Facebook": ("Prepare Facebook broadcast", "Preparar transmissão do Facebook"),
    "Configura Facebook en el inspector": ("Configure Facebook in the inspector", "Configure o Facebook no inspetor"),
    "Pasa la vista previa seleccionada al programa": (
        "Send the selected preview to program",
        "Envie a prévia selecionada para o programa",
    ),
    "Saca el programa del aire": ("Take program off air", "Tire o programa do ar"),
    "Calidad, monitor multiview y estudio": (
        "Quality, multiview monitor, and studio",
        "Qualidade, monitor multiview e estúdio",
    ),
    "Abrir monitor multiview en segunda pantalla": (
        "Open multiview monitor on a second display",
        "Abrir monitor multiview em uma segunda tela",
    ),
}

STR_RE = re.compile(r'"((?:\\.|[^"\\])*)"')


def slug_key(text: str) -> str:
    ascii_name = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", ascii_name).strip("_").lower()[:48]
    if not slug:
        slug = "text"
    h = abs(hash(text)) % 10_000_000
    return f"ui.{slug}.{h}"


def unit(value: str) -> dict:
    return {"stringUnit": {"state": "translated", "value": value}}


def looks_ui(text: str) -> bool:
    if len(text) < 2 or len(text) > 220:
        return False
    if text.startswith(("com.", "_", "http", "FMLE/", "x-", "file://")):
        return False
    if "\\(" in text:
        return False
    if text in {"image", "video", "widget", "director", "camera", "en", "es", "pt"}:
        return False
    if re.fullmatch(r"[\w\.\-]+", text) and text.islower():
        return False
    lowered = text.lower()
    spanish_markers = "áéíóúñ¿¡"
    ui_words = (
        "cámara", "ajust", "biblioteca", "programa", "director", "transmit",
        "emisi", "monitor", "widget", "al aire", "preview", "audio", "intercom",
        "facebook", "conect", "guardar", "cancelar", "eliminar", "buscar", "nuevo",
        "agregar", "quitar", "esper", "pantalla", "configur", "reconect", "manual",
        "automát", "entrada", "salida", "señal", "latencia", "animación", "plantilla",
        "título", "micrófono", "permiso", "red local", "destino", "calidad", "estudio",
        "biblioteca", "continuar", "cerrar", "abrir", "listo", "detener", "reproducir",
        "vista previa", "posicionar", "importar", "logo", "ticker", "cuenta", "hora",
    )
    if any(c in lowered for c in spanish_markers):
        return True
    if any(w in lowered for w in ui_words):
        return True
    if text.isupper() and len(text) < 24:
        return True
    return text in EXTRA_EN_PT


def should_replace_line(line: str, text: str) -> bool:
    if "BundleLocalization" in line or "L10n." in line:
        return False
    if "Logger" in line or "print(" in line or "debugDescription" in line:
        return False
    if "systemImage" in line or 'Image(systemName' in line:
        return False
    if "UserDefaults" in line or "forKey:" in line or "Notification.Name" in line:
        return False
    if not any(marker in line for marker in UI_MARKERS):
        return False
    return looks_ui(text)


def ensure_catalog_entry(strings: dict, text: str) -> str:
    if text in strings:
        locs = (strings[text].get("localizations") or {})
        if locs.get("en", {}).get("stringUnit", {}).get("value"):
            return text
    en, pt = EXTRA_EN_PT.get(text, (text, text))
    if text in strings:
        entry = strings[text]
        locs = entry.setdefault("localizations", {})
        if "en" not in locs:
            locs["en"] = unit(en if en != text else text)
        if "es" not in locs:
            locs["es"] = unit(text)
        if "pt" not in locs:
            locs["pt"] = unit(pt)
        return text
    key = text
    if not looks_ui(text):
        key = slug_key(text)
    strings[key] = {
        "extractionState": "manual",
        "localizations": {
            "en": unit(en),
            "es": unit(text if key == text else text),
            "pt": unit(pt),
        },
    }
    if key != text:
        strings[key]["localizations"]["es"] = unit(text)
    return key


def migrate_file(path: Path, strings: dict) -> bool:
    if path.name in SKIP_FILES:
        return False
    rel = path.relative_to(ROOT).as_posix()
    if "/Localization/" in rel or rel.endswith("BundleLocalization.swift"):
        return False
    if "Test.swift" in path.name:
        return False
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)
    changed = False
    replacements: list[tuple[str, str]] = []

    for i, line in enumerate(lines):
        for match in STR_RE.finditer(line):
            text = match.group(1)
            if not should_replace_line(line, text):
                continue
            key = ensure_catalog_entry(strings, text)
            replacements.append((f'"{text}"', f'BundleLocalization.string({json.dumps(key, ensure_ascii=False)})'))

    if not replacements:
        return False

    # Longest first to avoid partial replacement.
    replacements.sort(key=lambda pair: len(pair[0]), reverse=True)
    unique: dict[str, str] = {}
    for old, new in replacements:
        unique[old] = new

    updated = original
    for old, new in unique.items():
        if old not in updated:
            continue
        updated = updated.replace(old, new)
        changed = True

    if not changed:
        return False

    if "BundleLocalization" in updated and "import LvoqStreamCore" not in updated:
        if updated.startswith("import "):
            updated = re.sub(
                r"(import Foundation\n)",
                r"\1import LvoqStreamCore\n",
                updated,
                count=1,
            )
            if "import LvoqStreamCore" not in updated:
                updated = "import LvoqStreamCore\n" + updated
        else:
            updated = "import LvoqStreamCore\n" + updated

    path.write_text(updated, encoding="utf-8")
    return True


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    strings = catalog.setdefault("strings", {})
    touched = 0
    for scan_root in SCAN_ROOTS:
        for path in scan_root.rglob("*.swift"):
            if any(part in SKIP_DIR_NAMES for part in path.parts):
                continue
            if migrate_file(path, strings):
                touched += 1
    catalog["sourceLanguage"] = "en"
    CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"migrated_files={touched} catalog_keys={len(strings)}")


if __name__ == "__main__":
    main()