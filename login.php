<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Laboratorio UNEFA</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login.css">
    <link rel="icon" href="imagenes/unefa-logo-png_seeklogo-144842.png" type="image/png">
    <link rel="shortcut icon" href="imagenes/unefa-logo-png_seeklogo-144842.ico">
</head>
<body>

<div class="auth-container">

    <!-- PANEL IZQUIERDO -->
    <div class="panel-image">
        <img src="imagenes/png-transparent-desktop-computers-personal-computer-computer-icons-computer-monitors-computer-rectangle-computer-computer-monitor-accessory-thumbnail-removebg-preview.png" alt="Laboratorio">
        <h2>Laboratorio</h2>
    </div>

    <!-- PANEL DERECHO -->
    <div class="panel-form">

        <div class="form-wrapper">

            <!-- LOGIN -->
            <div class="auth-form active" id="loginForm">
                <a href="index.php" class="btn-close" aria-label="Volver a página principal">
                    <span class="close-icon">×</span>
                </a>

                <img src="imagenes/unefa-logo-png_seeklogo-144842.png" class="escudo">
                <h3>Iniciar Sesión</h3>

                <form action="db/ingresar.php" method="POST">

                    <label>Cédula</label>
                    <input type="text" name="cedula" placeholder="Ingrese su cédula" required>

                    <label>Contraseña</label>
                    <input type="password" name="pass" placeholder="Ingrese su contraseña" required>

                    <button type="submit" class="btn">Entrar</button>

                </form>

                <p class="switch-text">
                    ¿No tienes cuenta?
                    <span onclick="mostrarRegistro()">Crear cuenta</span>
                </p>
            </div>


            <!-- REGISTRO -->
           <div class="auth-form" id="registerForm">

            <img src="imagenes/unefa-logo-png_seeklogo-144842.png" class="escudo">
            <h3>Registro</h3>

            <form action="db/registro.php" method="POST">

                <label>Nombre</label>
                <input type="text" name="nombre" required>

                <label>Apellido</label>
                <input type="text" name="apellido" required>

                <label>Cédula</label>
                <input type="text" name="cedula" required>

                <label>Correo</label>
                <input type="email" name="correo" required>

                <label>Contraseña</label>
                <input type="password" name="pass" required>

                <label>Confirmar</label>
                <input type="password" name="confirmar" required>

                <label>Tipo de usuario</label>
                <select  id="tipoUsuario" name="tipoUsuario" required>
                    <option value="">Seleccione</option>
                    <option value="estudiante">Estudiante</option>
                    <option value="docente">Docente</option>
                </select>

            

                <button type="submit" class="btn">Registrar</button>

            </form>

            <p class="switch-text">
                ¿Ya tienes cuenta?
                <span onclick="mostrarLogin()">Iniciar sesión</span>
            </p>
        </div>
<script>
function mostrarRegistro() {
    document.getElementById('loginForm').classList.remove('active');
    document.getElementById('registerForm').classList.add('active');
}

function mostrarLogin() {
    document.getElementById('registerForm').classList.remove('active');
    document.getElementById('loginForm').classList.add('active');
}

const tipoUsuario = document.getElementById('tipoUsuario');


</script>

</body>
</html>
