<?php
session_start();

/* ===== VALIDAR SESIÓN ===== */
if (!isset($_SESSION['nombre']) || !isset($_SESSION['tipo'])) {
    header("Location: login.php");
    exit;
}

if ($_SESSION['tipo'] === 'estudiante') {
    header("Location: estudiante.php");
    exit;
}

if ($_SESSION['tipo'] === 'encargado') {
    header("Location: encargado.php");
    exit;
}

if ($_SESSION['tipo'] !== 'docente') {
    session_destroy();
    header("Location: login.php");
    exit;
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Panel UNEFA</title>

<link rel="stylesheet" href="css/docente.css">
<link rel="icon" href="imagenes/unefa-logo-png_seeklogo-144842.png">
</head>

<body>
<div class="container">

<!-- ===== SIDEBAR ===== -->
<aside class="sidebar">

  <div class="logo-section">
    <img src="imagenes/unefa-logo-png_seeklogo-144842.png" class="logo">
  </div>

  <h3 class="welcome-text">Bienvenido <?php echo $_SESSION['nombre']; ?></h3>

  <button class="menu-btn" data-page="home">🏠 Inicio</button>
  <button class="menu-btn" data-page="registrar">📚 Registrar Clase</button>
  <button class="menu-btn" data-page="reportes">👁️ Reportes</button>

  <div class="logout-section">
    <img src="imagenes/Gemini_Generated_Image_26fv8326fv8326fv-removebg-preview.png" class="avatar">
    <button class="logout" onclick="location.href='index.php'">🔒 Cerrar Sesión</button>
  </div>

</aside>

<!-- ===== MAIN ===== -->
<main class="main-content">

<div class="top-bar">
  <h2>Panel de Control UNEFA</h2>
</div>

<div class="page-content">

  <!-- ===== HOME ===== -->
  <div id="home" class="overlay-text">
    <h3>Seleccione una opción del menú</h3>
  </div>

  <!-- ===== REGISTRAR CLASE ===== -->
  <div id="registrar" class="page hidden">
    <h3>Registro de Clase</h3>

    <form>
      <div class="form-group"><label>Materia</label><input type="text"></div>
      <div class="form-group"><label>Profesor</label><input type="text"></div>
      <div class="form-group"><label>Carrera</label><input type="text"></div>
      <div class="form-group"><label>Sección</label><input type="text"></div>
      <div class="form-group">
            <label for="tipo_clase">Tipo de Clase</label>
            <select id="tipo_clase" name="tipo_clase" required>
              <option value="">Seleccione una opción</option>
              <option value="teorica">Teórica</option>
              <option value="practica">Práctica</option>
            </select>
          </div>
      <div class="form-group">
          <label for="cantidad">Cantidad de Alumnos</label>
          <input
            type="number"
            id="cantidad"
            name="cantidad"
            min="1"
            max="100"
            value="1"
            required
          >
        </div>
      <div class="form-group"><label>Hora Entrada</label><input type="time"></div>
      <div class="form-group"><label>Hora Salida</label><input type="time"></div>
      <div class="form-group">
          <label for="fecha">Fecha</label>
          <input
            type="date"
            id="fecha"
            name="fecha"
            required
          >
        </div>


      <div class="form-buttons">
        <button type="button" id="ver-clases">📄 Ver Registro</button>
      </div>
    </form>

    <!-- MODAL -->
    <div id="modal-clases" class="modal">
      <div class="modal-content">
        <span class="close-modal">&times;</span>
        <h4>Clases Registradas</h4>
        <table>
          <tr><th>Materia</th><th>Profesor</th></tr>
          <tr><td>Ejemplo</td><td>Ejemplo</td></tr>
        </table>
      </div>
    </div>

  </div>

  <!-- ===== REPORTES ===== -->
  <div id="reportes" class="page hidden">
    <h3>Reporte de Problemas</h3>

    <form>
      <div class="form-group">
        <label>Descripción</label>
        <textarea rows="4"></textarea>
      </div>

      <div class="form-buttons">
        <button type="button" id="ver-reportes">📄 Ver Reportes</button>
      </div>
    </form>

    <!-- MODAL -->
    <div id="modal-reportes" class="modal">
      <div class="modal-content">
        <span class="close-modal">&times;</span>
        <h4>Reportes</h4>
        <table>
          <tr><th>Descripción</th></tr>
          <tr><td>Ejemplo</td></tr>
        </table>
      </div>
    </div>

  </div>

</div>
</main>
</div>

<!-- ===== JS ===== -->
<script>
document.addEventListener("DOMContentLoaded", () => {

  const botones = document.querySelectorAll(".menu-btn");
  const paginas = document.querySelectorAll(".page");
  const home = document.getElementById("home");

  function ocultarTodo() {
    paginas.forEach(p => p.classList.add("hidden"));
    home.style.display = "none";
  }

  botones.forEach(btn => {
    btn.addEventListener("click", () => {
      ocultarTodo();
      const pagina = btn.dataset.page;
      if (pagina === "home") {
        home.style.display = "block";
      } else {
        document.getElementById(pagina).classList.remove("hidden");
      }
    });
  });

  home.style.display = "block";

  // MODALES
  document.getElementById("ver-clases").onclick = () =>
    document.getElementById("modal-clases").classList.add("show");

  document.getElementById("ver-reportes").onclick = () =>
    document.getElementById("modal-reportes").classList.add("show");

  document.querySelectorAll(".close-modal").forEach(btn => {
    btn.onclick = () => btn.closest(".modal").classList.remove("show");
  });

});
</script>

</body>
</html>
