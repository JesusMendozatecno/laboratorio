<?php

class conectar
{
    private $server = "localhost";
    private $user = "root";
    private $pass = "";
    private $bd = "bd-laboratorio";
    public $conexion;
    public function conexion()
    {
        $this->conexion = new mysqli(
            $this->server,
            $this->user,
            $this->pass,
            $this->bd
        );
        return $this->conexion;
    }
}

?>