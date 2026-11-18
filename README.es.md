# Asura Graphite

![Proyecto Personal](https://img.shields.io/badge/Proyecto-Personal-41454a?style=flat-square)
![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo-777c84?style=flat-square)
![Fedora](https://img.shields.io/badge/Fedora-Linux-4b4f55?style=flat-square&logo=fedora&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-34373d?style=flat-square)

> Un escritorio personal en evolución: oscuro, funcional y hecho a mi manera.

[English](README.md) · **Español**

## Sobre el proyecto

Asura Graphite es un tema personal de Hyprland en desarrollo. Combina colores oscuros inspirados en Graphite, estilo de ventanas y flujos de trabajo con teclado.

Es un tema en desarrollo, no una distribución de escritorio ni un instalador automático. Algunas opciones y rutas pueden necesitar ajustes según el equipo.

## Componentes

| Componente | Función |
| --- | --- |
| Hyprland | Gestión de ventanas, estilo y atajos |
| Hyprlock | Apariencia a juego para el bloqueo de pantalla |
| Waybar y SwayNC | Barra de estado y estilo de notificaciones |
| Rofi | Lanzador y selector de ventanas |
| Ghostty y Starship | Apariencia de la terminal y el prompt |
| Ronema | Temas Graphite para el menú de red |
| Satty y Wlogout | Configuración de capturas y menú de energía |

## Estructura

```text
config/       Configuraciones del escritorio y temas Graphite
bin/          Utilidades de escritorio personalizadas
```

## Antes de usar

Revisa los archivos antes de aplicarlos. Los nombres de monitor, la pantalla de Hyprlock, las rutas del fondo, las fuentes, las versiones y los ajustes de hardware pueden variar entre equipos. El fondo mencionado no está incluido. Respalda tus configuraciones existentes antes de reemplazarlas con enlaces simbólicos.

`bin/ronema` es una versión personalizada de [rofi-network-manager](https://github.com/P3rf/rofi-network-manager), de George Demesiotis. Su licencia MIT original se conserva en [RONEMA-LICENSE](RONEMA-LICENSE). Requiere NetworkManager, Rofi y su configuración en `config/ronema/`.

Esta configuración usa el formato Lua de Hyprland; comprueba que tu versión lo soporte.

## Estado

Asura Graphite es un proyecto personal en desarrollo. Su configuración, documentación y diseño pueden cambiar a medida que evoluciona.
