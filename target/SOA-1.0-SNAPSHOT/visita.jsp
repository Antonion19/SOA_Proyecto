<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ingreso de Visitante</title>

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
            font-family: 'Inter', sans-serif; /* Usando Inter como se sugiere */
        }
        .popup-card {
            width: 100%;
            max-width: 380px;
            border-radius: 0.75rem; /* Bordes redondeados */
        }
        .status-icon { font-size: 3.2rem; }
        table th { width: 48%; }
        /* Estilos para el spinner */
        .spinner-border {
            width: 1.25rem;
            height: 1.25rem;
            vertical-align: middle;
            margin-right: 0.5rem;
        }
    </style>
</head>

<body>
<%
    // Recuperar datos desde sesión
    String dni = String.valueOf(session.getAttribute("usuario"));
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
            <tr><th class="text-end">DNI:</th><td><%= dni %></td></tr>
            <tr><th class="text-end">Nombre completo:</th><td><%= nombreCompleto %></td></tr>
        </table>

        <!-- Contenedor para mensajes de alerta -->
        <div id="messageContainer" class="mb-3"></div>
        
        <form id="visitaForm" onsubmit="return false;">
            <div class="mb-3 text-start">
                <label for="motivo" class="form-label">Motivo</label>
                <select id="motivo" name="motivo" class="form-select rounded-md" required>
                    <option value="" disabled selected>Selecciona</option>
                    <option value="Estudios">Estudios</option>
                    <option value="Docencia">Docencia</option>
                    <option value="Labores">Labores</option>
                    <option value="Evento académico">Evento académico</option>
                    <option value="Solicitar información">Solicitar información</option>
                    <option value="Trámite administrativo">Trámite administrativo</option>
                    <option value="Visita institucional">Visita institucional</option>
                    <option value="Acompañamiento a estudiante">Acompañamiento a estudiante</option>
                    <option value="Entrega de documentos">Entrega de documentos</option>
                </select>
                <div class="invalid-feedback">Selecciona un motivo.</div>
            </div>

            <!-- Botón de registrar -->
            <button id="btnRegistrar" class="btn btn-primary w-100 rounded-md" type="button">
                <span class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                Registrar ingreso
            </button>

            <!-- Botón de denegar -->
            <button
                id="btnDenegar"
                class="btn btn-danger w-100 mt-2 rounded-md"
                type="button">
                <span class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                Denegar ingreso
            </button>
        </form>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const motivoSelect = document.getElementById('motivo');
        const btnRegistrar = document.getElementById('btnRegistrar');
        const btnDenegar = document.getElementById('btnDenegar');
        const messageContainer = document.getElementById('messageContainer');

        // Guardar el texto original de los botones
        const originalRegistrarText = btnRegistrar.textContent.trim();
        const originalDenegarText = btnDenegar.textContent.trim();

        /**
         * Muestra un mensaje de alerta en el contenedor de mensajes.
         * @param {string} message El texto del mensaje.
         * @param {string} type El tipo de alerta (e.g., 'success', 'danger', 'info').
         */
        function showMessage(message, type) {
            messageContainer.innerHTML = `
                <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            `;
        }

        /**
         * Habilita o deshabilita los botones y muestra/oculta el spinner y el texto de carga.
         * @param {boolean} disabled Si los botones deben estar deshabilitados.
         */
        function toggleButtons(disabled) {
            btnRegistrar.disabled = disabled;
            btnDenegar.disabled = disabled;

            const registrarSpinner = btnRegistrar.querySelector('.spinner-border');
            const denegarSpinner = btnDenegar.querySelector('.spinner-border');

            if (disabled) {
                registrarSpinner.classList.remove('d-none');
                btnRegistrar.childNodes[1].nodeValue = ' Cargando...'; // Modifica el texto del botón
                denegarSpinner.classList.remove('d-none');
                btnDenegar.childNodes[1].nodeValue = ' Cargando...'; // Modifica el texto del botón
            } else {
                registrarSpinner.classList.add('d-none');
                btnRegistrar.childNodes[1].nodeValue = ' ' + originalRegistrarText; // Restaura el texto original
                denegarSpinner.classList.add('d-none');
                btnDenegar.childNodes[1].nodeValue = ' ' + originalDenegarText; // Restaura el texto original
            }
        }

        /**
         * Maneja la acción de registrar o denegar el ingreso.
         * @param {string} action La acción a realizar ('registrar' o 'denegar').
         */
        async function handleAction(action) {
            messageContainer.innerHTML = ''; // Limpiar mensajes anteriores
            motivoSelect.classList.remove('is-invalid'); // Limpiar validación anterior

            // Validar el motivo solo si la acción es 'registrar'
            if (action === 'registrar') {
                if (motivoSelect.value === "") {
                    motivoSelect.classList.add('is-invalid'); // Mostrar feedback de Bootstrap
                    showMessage("Por favor, selecciona un motivo para registrar el ingreso.", "danger");
                    return; // No continuar si la validación falla
                }
            }
            
            toggleButtons(true); // Deshabilitar botones y mostrar spinner

            // Preparar los datos para enviar al servlet
            const formData = new URLSearchParams();
            formData.append('motivo', motivoSelect.value);
            formData.append('accion', action);

            try {
                const response = await fetch('RegistroVisitaServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: formData.toString()
                });

                const data = await response.json();

                if (data.success) {
                    showMessage(data.message, "success");
                } else {
                    showMessage(data.message, "danger");
                }
            } catch (error) {
                console.error('Error al enviar la solicitud:', error);
                showMessage("Ocurrió un error al procesar la solicitud. Inténtalo de nuevo.", "danger");
            } finally {
                // Siempre redirigir después de mostrar el mensaje, sin re-habilitar los botones
                setTimeout(() => {
                    window.location.href = 'identificacion.jsp'; // Redirige al inicio
                }, 2000); // 2 segundos para que el usuario vea el mensaje
            }
        }

        // Asignar los event listeners a los botones
        btnRegistrar.addEventListener('click', () => handleAction('registrar'));
        btnDenegar.addEventListener('click', () => handleAction('denegar'));
    });
</script>
</body>
</html>
