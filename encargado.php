<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel UNEFA</title>
  <link rel="stylesheet" href="css/encargado.css">
  <link rel="icon" href="imagenes/unefa-logo-png_seeklogo-144842.png" type="image/png">
  <link rel="shortcut icon" href="imagenes/unefa-logo-png_seeklogo-144842.ico">
</head>
<body>
  <div class="container">
    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar">
      <div class="logo-section">
        <button class="back-btn" onclick="window.location.href='index.html'">←</button>
        <img src="imagenes/unefa-logo-png_seeklogo-144842.png" alt="UNEFA Logo" class="logo">
      </div>

      <h3 class="welcome-text">Bienvenido</h3>

      <button class="menu-btn">
        <span>👨‍🏫</span> Registro Profesores
      </button>

      <button class="menu-btn">
        <span>🏫</span> Registro de Instituto
      </button>

      <button class="menu-btn">
        <span>📘</span> Registro de Clases
      </button>

      <button class="menu-btn">
        <span>💻</span> Registro de Equipos
      </button>

      <button class="menu-btn">
        <span>👁️</span> Reportes
      </button>

      <div class="logout-section">
        <img src="imagenes/image-removebg-preview (1).png" alt="Docente" class="avatar">
        <button class="menu-btn logout">Cerrar Sesión</button>
      </div>
    </aside>

    <!-- ===== CONTENIDO PRINCIPAL ===== -->
    <main class="main-content">
      <div class="top-bar">
        <h2>Panel de Control UNEFA</h2>
      </div>

      <div id="page-content" class="page-content">
        <video autoplay muted loop id="bg-video">
          <source src="videos/Mundo Globo Internacional - Free video on Pixabay.mp4" type="video/mp4">
          Tu navegador no soporta el video.
        </video>
        <div class="overlay-text">
          <h3>Seleccione una opción del menú</h3>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
