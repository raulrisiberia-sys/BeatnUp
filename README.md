# Beat n Up

2D side-scrolling beat 'em up ambientado en un Madrid neón/ciberpunk.  
Protagonistas: **Raúl** y **Vanesa**.

Estilo: moderno inspirado en *Streets of Rage*, gráficos high-quality painted.

## Requisitos

- **Godot 4.3** o superior (recomendado 4.3 / 4.4)
- Export templates para Android si quieres probar en móvil

## Cómo abrir el proyecto

1. Clona o descarga este repositorio
2. Abre Godot 4
3. Pulsa **Import** → selecciona la carpeta `BeatnUp` (donde está el `project.godot`)
4. Pulsa **Run** (F5) para probar el movimiento

## Controles actuales (prototipo)

| Acción       | Teclado          |
|--------------|------------------|
| Mover        | A / D  o  ← →    |
| Saltar       | Espacio / W      |
| Puñetazo     | J                |
| Patada       | K                |

## Estructura del proyecto

```
BeatnUp/
├── project.godot
├── scenes/
│   ├── Main.tscn          ← Escena principal de prueba
│   └── Player.tscn        ← Personaje jugable
├── scripts/
│   └── player.gd          ← Lógica de movimiento y combate básico
├── assets/
│   ├── sprites/
│   │   ├── raul/          ← Aquí van los sprites de Raúl
│   │   └── vanesa/        ← Aquí van los sprites de Vanesa
│   └── audio/
└── README.md
```

## Próximos pasos

- [ ] Meter los sprites de Idle / Walk / Attack
- [ ] Añadir AnimatedSprite2D con las secuencias
- [ ] Sistema de combos
- [ ] Enemigos básicos
- [ ] Primera fase (Neón District - Gran Vía)
- [ ] Export Android

## Notas

El movimiento actual usa un **CharacterBody2D** clásico de side-scroller con gravedad, salto y fricción.  
Cuando tengamos los sprites laterales, solo hay que asignarlos al `AnimatedSprite2D` del Player y conectar las animaciones en el script.
