<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Huella</title> 
        <link rel="stylesheet" href="css/navbar1.1.css">
        <link rel="stylesheet" href="css/styles1.3.css">
        <link rel="stylesheet" href="css/FormularioRegistro1.3.css"> <%-- Renombrado para consistencia --%>
        <script src="js/navbar1.js"></script>
        <script src="js/script1.js"></script>
        <script src="js/sesion.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>
    <body>
        <div class="sidebar collapsed">
            <%@ include file="navbar1.1.jsp" %>
        </div>

        <div class="header-bar">
            <%@ include file="headerbar.jsp" %>
        </div>

        <div class="main-content">
            <div class="columns-container">
                <div class="container">
                    <h2>Envío de Huella para Registro</h2>

                    <div class="area_carga" id="uploadArea">
                        <img src="https://cdn-icons-png.flaticon.com/512/724/724933.png" alt="Huella" class="fingerprint-icon">
                        <p style="margin-bottom: 15px; font-size: 13px;">Arrastre su archivo aquí o haga clic para seleccionar</p>                    

                        <input type="file" id="fileInput" accept="image/*" hidden>
                        <button class="btn" onclick="document.getElementById('fileInput').click()">Examinar Archivos</button>
                    </div>

                    <div class="previsualizacion" id="preview">
                        <img id="previewImage" src="#" alt="Previsualización" style="display: none;">
                        <button class="btn" id="processBtn" disabled>Generar Hash de Huella</button> <%-- Texto cambiado --%>
                    </div>

                    <div class="progreso" id="progressContainer" style="display: none;">
                        <div class="barra_progreso" id="progressBar"></div>
                        <span id="progressText">0%</span>
                    </div>
                     <p id="hashDisplay" style="margin-top: 15px; font-weight: bold;"></p> <%-- Para mostrar el hash --%>

                </div>

                <div class="form-container">
                    <h2 style="margin-top: 5rem">Datos de Validación</h2>

                    <form id="validacionForm" action="ValidacionController2" method="POST"> <%-- Cambiado a tu servlet --%>
                        <div class="form-grid">

                            <div class="form-group">
                                <label for="documento">Número de Documento</label>
                                <input type="text" id="documento" name="documento" class="editable-field" required> <%-- Ahora editable --%>
                                <button type="button" class="btn" id="searchDniBtn" style="margin-top: 10px;">Buscar DNI</button> <%-- Botón para buscar DNI --%>
                            </div>

                            <div class="form-group">
                                <label for="prenombres">Prenombres</label>
                                <input type="text" id="prenombres" name="prenombres" class="readonly-field" readonly>
                            </div>

                            <div class="form-group">
                                <label for="paterno">Apellido Paterno</label>
                                <input type="text" id="paterno" name="paterno" class="readonly-field" readonly>
                            </div>

                            <div class="form-group">
                                <label for="materno">Apellido Materno</label>
                                <input type="text" id="materno" name="materno" class="readonly-field" readonly>
                            </div>

                            <input type="hidden" id="imageHash" name="imageHash"> <%-- Campo oculto para enviar el hash --%>
                            <button type="submit" class="submit-btn">Registrar</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>