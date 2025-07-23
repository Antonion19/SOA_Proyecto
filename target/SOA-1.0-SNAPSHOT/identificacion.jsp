<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Identifícate</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Tu hoja de estilos original -->
    <link rel="stylesheet" href="css/stylesLogin.css">

    <!-- Estilos extra (puedes moverlos a stylesLogin.css si prefieres) -->
    <style>
        body { background:#f2f4f7; 
               font-family: arial;
        }

        /* Card/ventana principal */
        .card-login{
            max-width:330px;
            min-width:330px;
            border:none;
            border-radius:1.2rem;
            box-shadow:0 0.5rem 1rem rgba(0,0,0,.15);

        }

        /* Icono grande */
        .fa-fingerprint{ 
            font-size:4rem; 
            color:#6f42c1;
        }

        /* Nombre de archivo */
        .file-name { 
            font-size:.9rem;
        }
    </style>
</head>
<body>

<!-- Contenedor full‑screen para centrar -->
<div class="container-fluid d-flex align-items-center justify-content-center min-vh-100">
    <div class="card card-login p-4">

        <!-- ***IMPORTANTE: los mismos IDs y atributos para que tu JS siga funcionando*** -->
        <form id="loginForm" action="#" method="post" enctype="multipart/form-data" class="text-center">

            <h1 class="mb-4"><i class="fas fa-fingerprint"></i><br><h2>Identifícate</h2></h1>

            <!-- Input de huella oculto -->
            <input type="file" id="huellaFile" name="huellaFile" accept="image/*" hidden>

            <!-- Botón tipo etiqueta que abre el input -->
            <label for="huellaFile" class="btn btn-outline-primary w-100 py-3">
                <i class="fas fa-folder-open me-2"></i> Cargar huella
            </label>

            <!-- Nombre del archivo seleccionado -->
            <div id="fileName" class="file-name text-muted mt-2">
                No se ha seleccionado ningún archivo
            </div>

            <!-- Botón validar -->
            <button type="button" id="submitBtn" class="btn btn-primary w-100 py-2 mt-4" disabled>
                Validar
            </button>

            <!-- Spinner de carga; tu JS puede mostrar/ocultar con style/display -->
            <div id="loading" class="mt-3" style="display:none;">
                <div class="spinner-border spinner-border-sm" role="status"></div>
                <span class="ms-2">Validando huella…</span>
            </div>

            <!-- Mensajes de error -->
            <div id="errorMessage" class="alert alert-danger mt-3 d-none" role="alert"></div>
            <!-- Mensaje personalizado de rechazo de ingreso -->
            <div id="mensajeRechazo" class="alert alert-warning mt-3 d-none" role="alert"></div>
        </form>
    </div>
</div>

<!-- Bootstrap bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- ***Tu lógica original*** -->
<script src="js/scriptLogin1.js"></script>
</body>
</html>
