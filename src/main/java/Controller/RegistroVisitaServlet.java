/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import org.json.JSONObject; // Asegúrate de tener la librería org.json en tu classpath
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

// Anotación para mapear el servlet a una URL.
// Deberás configurar esto en tu web.xml o asegurarte de que la anotación sea procesada.
@WebServlet("/RegistroVisitaServlet")
public class RegistroVisitaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configura el tipo de contenido de la respuesta como JSON y la codificación UTF-8.
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject(); // Objeto JSON para la respuesta final al cliente.

        try {
            // Recuperar datos de la sesión
            HttpSession session = request.getSession(false); // No crear una nueva sesión si no existe
            if (session == null || session.getAttribute("usuario") == null || session.getAttribute("nombreCompleto") == null) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Sesión no válida o datos de usuario no encontrados.");
                out.print(jsonResponse.toString());
                return;
            }

            String dni = String.valueOf(session.getAttribute("usuario"));
            String nombreCompleto = (String) session.getAttribute("nombreCompleto");

            // Recuperar datos del formulario enviados por el JSP
            String motivo = request.getParameter("motivo");
            String accion = request.getParameter("accion"); // "registrar" o "denegar"

            // Validar que el motivo no sea nulo si la acción es "registrar"
            if ("registrar".equals(accion) && (motivo == null || motivo.isEmpty())) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Por favor, selecciona un motivo para registrar el ingreso.");
                out.print(jsonResponse.toString());
                return;
            }

            // Preparar el objeto JSON para enviar al servicio de registros
            JSONObject registroJson = new JSONObject();
            registroJson.put("nombre", nombreCompleto != null ? nombreCompleto : JSONObject.NULL);
            registroJson.put("dni", dni != null ? dni : JSONObject.NULL);
            registroJson.put("ingresante", "Visitante"); // Siempre "Visitante" para este flujo
            registroJson.put("motivo", motivo != null ? motivo : JSONObject.NULL); // El motivo del combobox
            registroJson.put("sede", JSONObject.NULL); // Sede se envía como NULL según lo solicitado

            // Obtener la hora actual en Lima sin zona horaria embebida, con el ajuste de +5 horas
            LocalDateTime limaTime = LocalDateTime.now(ZoneId.of("America/Lima")).plusHours(5);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            registroJson.put("fecha", limaTime.format(formatter));

            // Determinar el estado basado en la acción recibida
            String estadoRegistro = "";
            if ("registrar".equals(accion)) {
                estadoRegistro = "Ingreso Exitoso";
            } else if ("denegar".equals(accion)) {
                estadoRegistro = "Ingreso Fallido";
            } else {
                // Si la acción no es reconocida, se puede manejar como un error o un estado por defecto
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Acción no reconocida.");
                out.print(jsonResponse.toString());
                return;
            }
            registroJson.put("estado", estadoRegistro);

            System.out.println("JSON a enviar al servicio de registros: " + registroJson.toString());

            // URL del servicio de registros
            URL registroUrl = new URL("https://servicio-utp.fly.dev/api/registros");
            HttpURLConnection connRegistro = (HttpURLConnection) registroUrl.openConnection();
            connRegistro.setRequestMethod("POST");
            connRegistro.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connRegistro.setDoOutput(true); // Indicar que vamos a escribir en el cuerpo de la petición

            // Enviar el JSON al servicio externo
            try (OutputStream os = connRegistro.getOutputStream()) {
                byte[] input = registroJson.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            // Leer la respuesta del servicio externo
            int registroResponseCode = connRegistro.getResponseCode();
            if (registroResponseCode == HttpURLConnection.HTTP_OK || registroResponseCode == HttpURLConnection.HTTP_CREATED) {
                System.out.println("✔ Registro de ingreso guardado correctamente. Código: " + registroResponseCode);
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Registro de ingreso " + estadoRegistro.toLowerCase() + " exitoso.");
                // Puedes añadir una redirección aquí si es necesario, o manejarla en el JSP
            } else {
                // Leer el stream de error si el código de respuesta indica un problema
                BufferedReader errorReader = null;
                try {
                    errorReader = new BufferedReader(new InputStreamReader(connRegistro.getErrorStream(), StandardCharsets.UTF_8));
                    StringBuilder errorResponse = new StringBuilder();
                    String errorLine;
                    while ((errorLine = errorReader.readLine()) != null) {
                        errorResponse.append(errorLine);
                    }
                    System.err.println("✖ Error al registrar ingreso. Código: " + registroResponseCode + ". Respuesta: " + errorResponse.toString());
                } finally {
                    if (errorReader != null) {
                        errorReader.close();
                    }
                }

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error al registrar ingreso. Código: " + registroResponseCode);
            }

            connRegistro.disconnect(); // Desconectar la conexión HTTP

        } catch (Exception e) {
            // Captura cualquier excepción que ocurra durante el proceso
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error interno del servidor: " + e.getMessage());
            System.err.println("✖ Error en RegistroVisitaServlet:");
            e.printStackTrace();
        } finally {
            // Asegurarse de que la respuesta JSON siempre se envíe al cliente
            out.print(jsonResponse.toString());
            out.flush(); // Vaciar el buffer del escritor
        }
    }
}
