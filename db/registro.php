<?php
include("conexion.php");
session_start();
$conexion = (new conectar())->conexion();

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    header("Location: ../login.php");
    exit;
}

// Validar campos vacíos
if (
    empty($_POST['nombre']) ||
    empty($_POST['apellido']) ||
    empty($_POST['cedula']) ||
    empty($_POST['correo']) ||
    empty($_POST['pass']) ||
    empty($_POST['tipoUsuario'])
) {
    header("Location: ../login.php?error=campos_vacios");
    exit;
}

// Limpiar datos
$nombre      = trim($_POST['nombre']);
$apellido    = trim($_POST['apellido']);
$cedula      = trim($_POST['cedula']);
$correo      = trim($_POST['correo']);
$tipoUsuario = trim($_POST['tipoUsuario']);
$clave       = md5($_POST['pass']);

// Insertar nuevo usuario
$insertar = "INSERT INTO usuario (nombre, apellido, cedula, correo, contraseña, tipo)
             VALUES ('$nombre', '$apellido', '$cedula', '$correo','$clave', '$tipoUsuario' )";


$ejecutar = mysqli_query($conexion, $insertar);


// Comprobar si funcionó
if ($ejecutar) {
    echo '
        <script>
            alert("se registro exitosamente");
            window.location="../login.php";
        </script>
    ';
} else {
    
    echo '
        <script>
            alert("Error al registrar. Intente nuevamente.");
            window.location="../login.php?error=registro_fallido";
        </script>
    ';
}

mysqli_close($conexion);

?>