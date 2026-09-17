<?php
include("conexion.php");
session_start();
$conexion = (new conectar())->conexion();

// ==========================
// LOGIN
// ==========================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $userInput = trim($_POST['cedula']);
    $passInput = trim($_POST['pass']);

    $stmt = $conexion->prepare("SELECT id, nombre,cedula, contraseña, tipo FROM usuario WHERE cedula = ?");
    $stmt->bind_param("s", $userInput);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();

 


        // Validar contraseña (MD5 porque tu DB la usa así)
        if (md5($passInput) === $user['contraseña']) {
            $_SESSION['nombre'] = $user['nombre'];
            $_SESSION['cedula'] = $user['cedula'];
            $_SESSION['tipo']   = $user['tipo'];
        
        
        echo "<script>
            alert('✅ 1');
            window.location = '../docente.php';
        </script>";
            exit;
        } else {
            $_SESSION['cargando'] = 6; // Contraseña incorrecta
            
        echo "<script>
            alert('✅ 2');
            window.location = '../login.php';
        </script>";
            exit;
        }
    } else {
        $_SESSION['cargando'] = 7; // Usuario no existe
        
        echo "<script>
            alert('✅ 3');
            window.location = '../login.php';
        </script>";
        exit;   
    }

    $stmt->close();
    $conexion->close();
}
?>