# AltTabNeo - Totalmente gratis

Switcher de ventanas para macOS, con vista previa de miniaturas y atajos personalizables.

**Mantenedor:** [Facundo De Lima](https://github.com/facudelima)

**Basado en:** [AltTab](https://github.com/lwouis/alt-tab-macos) de [lwouis](https://github.com/lwouis) y [contribuidores](https://github.com/lwouis/alt-tab-macos/graphs/contributors) — proyecto open source bajo GPL-3.0. AltTabNeo es un derivado modificado (misma licencia).

## Características

- Cambio rápido entre ventanas (estilo Alt+Tab de Windows)
- Miniaturas, iconos de app y títulos configurables
- Actualizaciones automáticas (Sparkle) desde GitHub Releases
- Sin telemetría ni licencias Pro — todas las funciones desbloqueadas

## Requisitos

- macOS 10.13 o posterior
- Permiso de **Accesibilidad** (obligatorio al primer arranque)

## Instalación

### Desde release (recomendado)

1. Descargá `AltTabNeo-1.1.2.dmg` o `AltTabNeo-1.1.2.zip` desde [Releases](https://github.com/facudelima/AltTabNeo/releases).
2. Arrastrá **AltTabNeo** a **Aplicaciones**.
3. Abrí la app y concedé Accesibilidad en Ajustes del Sistema.

Las versiones instaladas desde un release reciben actualizaciones solas (Menú → **Check for updates…**).

### Desde código

```bash
git clone https://github.com/facudelima/AltTabNeo.git
cd AltTabNeo
open AltTabNeo.xcodeproj   # esquema Debug → ⌘R
```

Para instalar el build local en `/Applications`:

```bash
./scripts/build-release.sh
./scripts/install-to-applications.sh dist/AltTabNeo.app
```

## Compilar instalable / publicar

```bash
./scripts/build-release.sh                 # Release → dist/AltTabNeo.app
./scripts/package-installer.sh             # zip + dmg
./scripts/publish-github-release.sh        # firma Sparkle + appcast.xml
# commit + push, luego:
./scripts/publish-github-release.sh --upload-only
```

## Licencia

**GNU GPL v3** — ver [LICENCE.md](LICENCE.md).

Este software incluye código de [AltTab](https://github.com/lwouis/alt-tab-macos) (© lwouis and contributors), redistribuido bajo la misma GPL-3.0. Las modificaciones de AltTabNeo © 2026 Facundo De Lima.

Cualquier redistribución (incluidos binarios) debe conservar esta licencia y el acceso al código fuente correspondiente.
