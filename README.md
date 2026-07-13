# AltTabX

Switcher de ventanas para macOS, con vista previa de miniaturas y atajos personalizables.

**Autor:** [Facundo De Lima](https://github.com/facudelima)

## Características

- Cambio rápido entre ventanas (estilo Alt+Tab de Windows)
- Miniaturas, iconos de app y títulos configurables
- Sin telemetría, sin auto-updates remotos, sin licencias Pro
- Todas las funciones desbloqueadas

## Requisitos

- macOS 10.13 o posterior
- Permiso de **Accesibilidad** (obligatorio al primer arranque)

## Instalación

### Desde release (recomendado)

1. Descargá `AltTabX-1.0.1.dmg` o `AltTabX-1.0.1.zip` desde [Releases](https://github.com/facudelima/AltTabX/releases).
2. Arrastrá **AltTabX** a **Aplicaciones**.
3. Abrí la app y concedé Accesibilidad en Ajustes del Sistema.

### Desde código

```bash
git clone https://github.com/facudelima/AltTabX.git
cd AltTabX
open AltTabX.xcodeproj   # esquema Debug → ⌘R
```

Para instalar el build local en `/Applications`:

```bash
./scripts/build-release.sh
./scripts/install-to-applications.sh dist/AltTabX.app
```

## Compilar instalable

```bash
./scripts/build-release.sh      # Release → dist/AltTabX.app
./scripts/package-installer.sh  # dist/AltTabX-1.0.0.zip y .dmg
```

## Licencia

GPL-3.0 — ver [LICENCE.md](LICENCE.md).
