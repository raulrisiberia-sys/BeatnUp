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
3. Pulsa **Import** → selecciona la carpeta del proyecto
4. Pulsa **Run** (F5)

## Controles

| Acción       | Teclado          |
|--------------|------------------|
| Mover        | A / D  o  ← →    |
| Saltar       | Espacio / W      |
| Puñetazo     | J                |
| Patada       | K                |

## Multijugador local (LAN)

1. En el menú principal elige personaje (Raúl o Vanesa)
2. **Host**: pulsa "Crear partida" (abre el puerto 7777)
3. **Cliente**: escribe la IP del host (o déjala vacía para localhost) y pulsa "Unirse"
4. Cada jugador controla su propio personaje en la misma partida

También hay botón de **Jugar solo** para probar offline.

## Estructura del proyecto

```
BeatnUp/
├── project.godot
├── scenes/
│   ├── MainMenu.tscn     ← Selección de personaje + Host/Join
│   ├── Game.tscn         ← Nivel de prueba
│   └── Player.tscn       ← Personaje jugable
├── scripts/
│   ├── main_menu.gd
│   ├── game.gd
│   ├── game_state.gd     ← Autoload
│   └── player.gd
├── assets/
│   ├── sprites/
│   │   ├── raul/
│   │   └── vanesa/
│   └── audio/
└── README.md
```

## Próximos pasos

- [ ] Meter los sprites laterales de Idle / Walk / Attack
- [ ] Añadir AnimatedSprite2D con las secuencias
- [ ] Sistema de combos y hitboxes
- [ ] Enemigos básicos
- [ ] Primera fase (Neón District - Gran Vía)
- [ ] Export Android
- [ ] Mejorar sincronización de red (posiciones, ataques)

## Notas técnicas

- Multijugador con **ENet** (puerto 7777)
- Cada peer es authority de su propio personaje
- Los placeholders de color cambian según el personaje elegido (azul = Raúl, rosa = Vanesa)
- Velocidad y salto ligeramente diferentes entre personajes
