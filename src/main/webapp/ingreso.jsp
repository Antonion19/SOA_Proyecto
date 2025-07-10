<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ingreso exitoso</title>

    <!-- Bootstrap 5 + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            background: #f5f7fa;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .popup-card { width: 100%; max-width: 380px; }
        .status-icon { font-size: 3.2rem; }
        table th { width: 48%; }
    </style>
</head>

<body>
<%
    // Recuperar datos desde sesión
    String dni            = String.valueOf(session.getAttribute("usuario"));
    String codigo         = String.valueOf(session.getAttribute("codigo"));
    String nombreCompleto = (String) session.getAttribute("nombreCompleto");
    String rol           = (String) session.getAttribute("rol");
    String sede           = (String) session.getAttribute("sede");
    
    // Fallback en caso algún campo venga null
    if (nombreCompleto == null) nombreCompleto = "-";
    if (dni == null) dni = "-";
    if (codigo == null) codigo = "-";
    if (sede == null) sede = "-";
    if (rol == null) rol = "-";
%>

<div class="card popup-card shadow-sm border-0">
    <div class="card-body p-4">
        <div class="text-success text-center mb-3">
            <i class="bi bi-check-circle-fill status-icon"></i>
            <h5 class="fw-semibold mt-2 mb-0">Ingreso exitoso</h5>
            <small class="text-muted">Se ingresó correctamente</small>
        </div>

        <table class="table table-sm table-borderless mb-0">
            <tr><th class="text-end">DNI:</th>             <td><%= dni %></td></tr>
            <tr><th class="text-end">Código:</th>          <td><%= codigo %></td></tr>
            <tr><th class="text-end">Nombre completo:</th> <td><%= nombreCompleto %></td></tr>
            <tr><th class="text-end">Rol:</th> <td><%= rol %></td></tr>
            <tr><th class="text-end">Sede:</th>            <td><%= sede %></td></tr>
        </table>
        <button
            class="btn btn-primary w-100 mt-2"
            type="button"
            onclick="location.href='identificacion.jsp';">
            Regresar
        </button>  
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
