# VideoGame

![gif](https://github.com/ZagonAb/VideoGame/blob/164cfd84fcd31a39ebb36eabd7a2ae40a172f7bb/.meta/screenshots/demo.gif)

![screen1](https://github.com/ZagonAb/VideoGame/blob/164cfd84fcd31a39ebb36eabd7a2ae40a172f7bb/.meta/screenshots/screen.png)

![screen2](https://github.com/ZagonAb/VideoGame/blob/164cfd84fcd31a39ebb36eabd7a2ae40a172f7bb/.meta/screenshots/screen1.png)

- Un tema para **Pegasus Frontend.**
- Inspirado en la colección de **"ALLGAMES"** de Titanius Launcher.
- **La interfaz estará sujeta a futuras actualizaciones con el objetivo de optimizar el código y mejorar la experiencia del usuario.**
- **Opción de búsqueda por letra:** El tema está diseñado para manejar una única colección que agrupa todos los juegos bajo la categoría "All", representada por api.allGames. Esto permite acceder a toda la biblioteca de juegos en una sola lista, con la ventaja de contar con un sistema de filtrado eficiente para encontrar rápidamente un título específico. El filtro se implementa mediante SortFilterProxyModel, que organiza los juegos alfabéticamente (RoleSorter con title) y permite buscar juegos que comiencen con una letra específica usando expresiones regulares. Cuando seleccionas una letra, el filtro actualiza la lista para mostrar únicamente los juegos cuyos títulos comienzan con esa letra. Si seleccionas **"All"**, el filtro se desactiva, mostrando nuevamente todos los juegos de la colección.
Esta funcionalidad ofrece una experiencia de usuario optimizada, facilitando la navegación por listas extensas de juegos y haciendo que encontrar un título sea rápido y sencillo.
- **Característica visual:** El tema integra el video del juego y, al finalizar su reproducción, muestra el boxFront correspondiente, mejorando la presentación visual de la interfaz.
- **Manejo de la interfaz:** Navegue por la lista de juegos utilizando las teclas de flecha arriba y abajo, o con el mouse, haciendo un clic para seleccionar un juego y doble clic para lanzarlo. También puede filtrar rápidamente su colección seleccionando una letra específica, ya sea con el mouse o con el gamepad, utilizando los botones **"LB"** y **"RB"**.

 <details>
<summary>Cambios y mejoras recientes en el Tema desde 12/24</summary> 
  <br>
  
<details>
<summary>Cambio de GaussianBlur a FastBlur</summary>

- Reemplazo de GaussianBlur con FastBlur para un mejor desempeño y menor impacto en los recursos.
</details>

<details>
<summary>Mejorando la lógica de la interfaz</summary>

- Implementación de estado de carga/sin juegos dinámico:

**Mostrara "Loading..." mientras se cargan los recursos del juego**
**Cambiara a "No games available" si no hay juegos**

- Mejorar de experiencia de usuario con carga de imágenes consistente":

**Se ha agregado una imagen de respaldo cuando fallan los recursos**
**Utilizara "assets/no-image/default.png" si no se encuentra video o imagen de portada**
</details>

</details>

## Instalación

[Descarga](https://github.com/ZagonAb/VideoGame/archive/refs/heads/main.zip) y extrae el tema a tu [directorio de temas](http://pegasus-frontend.org/docs/user-guide/installing-themes). Luego puede seleccionarlo en el menú de configuración de Pegasus.

# Licencia
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"></a>
