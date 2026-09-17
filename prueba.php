
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Laboratorio - Inicio</title>
    <link rel="stylesheet" href="css/prueba.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="icon" href="imagenes/unefa-logo-png_seeklogo-144842.png" type="image/png">
    <link rel="shortcut icon" href="imagenes/unefa-logo-png_seeklogo-144842.ico">

</head>
<body>

    <!-- ===== ENCABEZADO ===== -->
    <header class="site-header">
        <img src="imagenes/Imagen de WhatsApp 2025-11-05 a las 07.12.10_31de5928.jpg" 
             alt="Encabezado del laboratorio">
    </header>

    <!-- ===== NAVEGACIÓN ===== -->
    <nav class="top-nav">
        <a href="login.php">Inicio</a>
        <a href="registro.php" class="secondary">Registro</a>

        <!-- ===== BOTONES NUEVOS ===== -->
        <div class="theme-controls">
            <button id="toggle-theme" aria-label="Cambiar modo de color">🌙</button>
            <input type="color" id="accent-picker" value="#6c00ff" title="Seleccionar color principal">
        </div>
    </nav>

    <!-- ===== CONTENIDO PRINCIPAL ===== -->
    <main class="content">

        <!-- Video de fondo -->
        <div class="video-container" aria-label="Video del laboratorio">
            <video autoplay muted loop playsinline>
                <source src="videos/Mundo Globo Internacional - Free video on Pixabay.mp4" type="video/mp4">
                Tu navegador no soporta el video.
            </video>
        </div>

        <!-- Cuadro de reglas -->
        <aside class="rules" aria-labelledby="normas-titulo">
            <h3 id="normas-titulo">Normas del Laboratorio</h3>
            <p>Asegúrate de seguir todas las normas de seguridad.</p>
            <ul>
                <ul class="rules-list">
                <li><i class="fa-solid fa-ban"></i> No consumir alimentos en el laboratorio.</li>
                <li><i class="fa-solid fa-gear"></i> No cambiar la configuración del equipo sin previa autorización.</li>
                <li><i class="fa-solid fa-database"></i> Prohibido guardar información no relacionada a las materias impartidas.</li>
                <li><i class="fa-solid fa-user-check"></i> El responsable del laboratorio debe verificar la integridad de los equipos al iniciar y culminar la actividad.</li>
                <li><i class="fa-solid fa-plug-circle-xmark"></i> Prohibido la desconexión de periféricos.</li>
                <li><i class="fa-solid fa-laptop-file"></i> Si vas a ingresar un equipo ajeno al laboratorio, se debe notificar a la seguridad de la universidad para la autorización del ingreso del mismo.</li>
                <li><i class="fa-solid fa-triangle-exclamation"></i> Notificar cualquier novedad presente en el laboratorio al área de las TIC.</li>
                </ul>
            </ul>
        </aside>
    </main>

    <!-- ===== PIE DE PÁGINA ===== -->
    <footer>
        &copy; <span id="year"></span> Laboratorio — Todos los derechos reservados.
    </footer>

    <!-- ===== SCRIPTS ===== -->
    <script>
        // Actualizar año automáticamente
        document.getElementById("year").textContent = new Date().getFullYear();

        // ==== GESTOR DE TEMAS ====
        const toggleButton = document.getElementById("toggle-theme");
        const colorPicker = document.getElementById("accent-picker");
        const root = document.documentElement;

        // Cargar tema guardado o usar oscuro por defecto
        const savedTheme = localStorage.getItem("theme") || "dark";
        root.setAttribute("data-theme", savedTheme);
        toggleButton.textContent = savedTheme === "dark" ? "☀️" : "🌙";

        // Alternar tema claro/oscuro
        toggleButton.addEventListener("click", () => {
            const current = root.getAttribute("data-theme");
            const next = current === "dark" ? "light" : "dark";
            root.setAttribute("data-theme", next);
            localStorage.setItem("theme", next);
            toggleButton.textContent = next === "dark" ? "☀️" : "🌙";
        });

        // Cambiar color de acento
        colorPicker.addEventListener("input", (e) => {
            const color = e.target.value;
            root.style.setProperty("--border", color);
            root.style.setProperty("--accent", color);
            localStorage.setItem("accentColor", color);
        });

        // Cargar color guardado
        const savedColor = localStorage.getItem("accentColor");
        if (savedColor) {
            colorPicker.value = savedColor;
            root.style.setProperty("--border", savedColor);
            root.style.setProperty("--accent", savedColor);
        }
    </script>

</body>
</html>
