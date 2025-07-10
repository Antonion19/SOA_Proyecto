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
    String nombreCompleto = (String) session.getAttribute("nombreCompleto");

    // Fallback en caso algún campo venga null
    if (nombreCompleto == null) nombreCompleto = "-";
    if (dni == null) dni = "-";
%>

<div class="card popup-card shadow-sm border-0">
    <div class="card-body p-4">
        <div class="text-center mb-3">
                        <!-- icono en azul «información» -->
            <i class="bi bi-info-circle-fill status-icon text-info"></i>

            <!-- texto en negro -->
            <h5 class="fw-semibold mt-2 mb-0 text-dark">Ingreso Prevenido</h5>
            <small class="text-muted">Establezca su Motivo</small>
        </div>

        <table class="table table-sm table-borderless mb-0">
            <tr><th class="text-end">DNI:</th>             <td><%= dni %></td></tr>
            <tr><th class="text-end">Nombre completo:</th> <td><%= nombreCompleto %></td></tr>
        </table>
            
        <div class="mb-3 text-start">
                    <label for="motivo" class="form-label">Motivo</label>
                    <select id="motivo" name="motivo" class="form-select" required>
                        <option value="" disabled selected>Selecciona</option>
                        <option value="normal">Ingreso normal</option>
                        <option value="visita">Visita</option>
                        <option value="tardanza">Tardanza</option>
                        <option value="invalido">Inválido</option>
                    </select>
                    <div class="invalid-feedback">Selecciona un motivo.</div>
                </div>

                <!-- Botón de registrar -->
                <button class="btn btn-primary w-100" type="submit" name="accion" value="registrar">Registrar ingreso</button>

                <!-- Botón de denegar -->
                <button
                    class="btn btn-danger w-100 mt-2"
                    type="button"
                    onclick="location.href='identificacion.jsp';">
                    Denegar ingreso
                </button>  
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
