
package Controller;

import config.db;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import org.json.JSONObject;


@WebServlet(name = "IdentificacionController", urlPatterns = {"/IdentificacionController"})

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 1024 * 1024 * 5,    // 5MB
    maxRequestSize = 1024 * 1024 * 10  // 10MB
)

public class IdentificacionController extends HttpServlet {

    
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
    }

   
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        Connection con = null;
        boolean respuestaYaEnviada = false;

        try {
            // para obtnr el archivo de huella
            Part filePart = request.getPart("huellaFile");
            
            //Validar que sea una imagen
            if (!filePart.getContentType().startsWith("image/")) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "El archivo debe ser una imagen");
                out.print(jsonResponse.toString());
                respuestaYaEnviada = true;
                return;
            }
            
            // Generar hash 
            String hashHuella = generateImageHash(filePart.getInputStream());
            System.out.println("Hash generado de la huella: " + hashHuella);
            
            // Buscar en la base de datos 
            db database = new db();
            con = database.Conexion();
            
           
            String sql = "SELECT numeroDocumento FROM huella_persona WHERE image_template = ?";
            
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, hashHuella);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                int dni = rs.getInt("numeroDocumento");
                System.out.println("DNI encontrado: " + dni);
                
                // validar con API RENIEC
                JSONObject datosReniec = validarConReniec(dni);

                if (datosReniec != null && datosReniec.has("nombres")) {
                    // Crear sesión de usuario
                    HttpSession session = request.getSession();
                    session.setAttribute("usuario", dni);
                    session.setAttribute("nombreCompleto", 
                        datosReniec.getString("nombres") + " " +
                        datosReniec.getString("apellidoPaterno") + " " +
                        datosReniec.getString("apellidoMaterno"));
                    
                    jsonResponse.put("success", true);
                    System.out.println("Validación exitosa para DNI: " + dni);
                    // ---- LLAMADA AL MICROSERVICIO ----
                    try {
                        String urlServicio = "https://microserviciosoa-production.up.railway.app/api/validarAlumno";

                        // Crear objeto JSON con los nombres de RENIEC
                        JSONObject jsonEnvio = new JSONObject();
                        jsonEnvio.put("nombres", datosReniec.optString("nombres", ""));
                        jsonEnvio.put("apellidoPaterno", datosReniec.optString("apellidoPaterno", ""));
                        jsonEnvio.put("apellidoMaterno", datosReniec.optString("apellidoMaterno", ""));
                        System.out.println("JSON enviado al microservicio:");
                        System.out.println(jsonEnvio.toString());
                        // Crear conexión HTTP POST
                        URL url = new URL(urlServicio);
                        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                        conn.setRequestMethod("POST");
                        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                        conn.setRequestProperty("Accept", "application/json");
                        conn.setDoOutput(true);
                        // Enviar JSON al microservicio
                        try (OutputStream os = conn.getOutputStream()) {
                            String jsonUTF8 = jsonEnvio.toString();
                            byte[] input = jsonUTF8.getBytes(StandardCharsets.UTF_8); // usa esto
                            os.write(input, 0, input.length);
                        }

                        // Leer la respuesta
                        int responseCode = conn.getResponseCode();
                        if (responseCode == HttpURLConnection.HTTP_OK) {
                            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
                            String inputLine;
                            StringBuilder responseString = new StringBuilder();
                            while ((inputLine = in.readLine()) != null) {
                                responseString.append(inputLine);
                            }
                            in.close();

                            JSONObject respuestaMicro = new JSONObject(responseString.toString());

                            // Obtener datos y decidir redirección
                            String rol = respuestaMicro.optString("rol", "");
                            String destino;
                           // ---- VERIFICAR REINTENTO DE INGRESO ----
                            try {
                                String urlVerificacion = "http://localhost:8081/ValidarReintento_MServ_SOA/api/validar-reintento";

                                JSONObject jsonVerificacion = new JSONObject();
                                jsonVerificacion.put("dni", String.valueOf(dni));

                                URL urlReintento = new URL(urlVerificacion);
                                HttpURLConnection connReintento = (HttpURLConnection) urlReintento.openConnection();
                                connReintento.setRequestMethod("POST");
                                connReintento.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                                connReintento.setRequestProperty("Accept", "application/json");
                                connReintento.setDoOutput(true);

                                try (OutputStream os = connReintento.getOutputStream()) {
                                    byte[] input = jsonVerificacion.toString().getBytes(StandardCharsets.UTF_8);
                                    os.write(input, 0, input.length);
                                }

                                int responseReintento = connReintento.getResponseCode();

                                // Usar el stream correcto según el código
                                InputStream is = (responseReintento < 400)
                                        ? connReintento.getInputStream()
                                        : connReintento.getErrorStream();

                                BufferedReader inReintento = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                                StringBuilder responseStringReintento = new StringBuilder();
                                while ((inputLine = inReintento.readLine()) != null) {
                                    responseStringReintento.append(inputLine);
                                }
                                inReintento.close();

                                // Procesar JSON independientemente del código de estado
                                JSONObject respuestaReintento = new JSONObject(responseStringReintento.toString());

                                if (!respuestaReintento.optBoolean("puedeIngresar", true)) {
                                    // No se permite ingreso
                                    JSONObject json = new JSONObject();
                                    json.put("success", false);
                                    json.put("message", respuestaReintento.optString("motivo", "Ingreso denegado por intento reciente."));
                                    json.put("ultimoIngreso", respuestaReintento.optString("ultimoIngreso", ""));
                                    response.setContentType("application/json");
                                    response.setCharacterEncoding("UTF-8");
                                    response.getWriter().write(json.toString());
                                    respuestaYaEnviada = true;
                                    return;
                                }

                            } catch (Exception e) {
                                System.err.println("✖ Error al verificar reintento de ingreso: " + e.getMessage());
                                e.printStackTrace();
                            }


                               
                            // ---- ENVIAR REGISTRO DE INGRESO ----
                            try {
                                String nombreCompleto = jsonEnvio.getString("nombres") + " " +
                                                        jsonEnvio.getString("apellidoPaterno") + " " +
                                                        jsonEnvio.getString("apellidoMaterno");

                                String ingresante = "";
                                String motivo = "";

                                switch (rol) {
                                    case "Administrador":
                                        ingresante = "Administrador";
                                        motivo = "Labores";
                                        break;
                                    case "Estudiante":
                                        ingresante = "Estudiante";
                                        motivo = "Estudios";
                                        break;
                                    case "Profesor":
                                        ingresante = "Profesor";
                                        motivo = "Docencia";
                                        break;
                                    case "Trabajador":
                                        ingresante = "Trabajador";
                                        motivo = "Labores";
                                        break;
                                }

                                JSONObject registroJson = new JSONObject();
                                registroJson.put("nombre", nombreCompleto);
                                registroJson.put("dni", String.valueOf(dni));
                                registroJson.put("ingresante", ingresante);
                                registroJson.put("motivo", motivo);
                                registroJson.put("sede", respuestaMicro.optString("sede", ""));

                                // Obtener la hora actual en Lima sin zona horaria embebida
                                LocalDateTime limaTime = LocalDateTime.now(ZoneId.of("America/Lima")).plusHours(5);
                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                System.out.println("Fecha Lima +5h formateada: " + limaTime.format(formatter));
                                registroJson.put("fecha", limaTime.format(formatter));



                                registroJson.put("estado", "Ingreso Exitoso");

                                URL registroUrl = new URL("https://servicio-utp.fly.dev/api/registros");
                                HttpURLConnection connRegistro = (HttpURLConnection) registroUrl.openConnection();
                                connRegistro.setRequestMethod("POST");
                                connRegistro.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                                connRegistro.setDoOutput(true);

                                try (OutputStream os = connRegistro.getOutputStream()) {
                                    byte[] input = registroJson.toString().getBytes(StandardCharsets.UTF_8);
                                    os.write(input, 0, input.length);
                                }

                                int registroResponse = connRegistro.getResponseCode();
                                if (registroResponse == HttpURLConnection.HTTP_OK || registroResponse == HttpURLConnection.HTTP_CREATED) {
                                    System.out.println(" Registro de ingreso guardado correctamente.");
                                } else {
                                    System.err.println(" Error al registrar ingreso. Código: " + registroResponse);
                                }

                            } catch (Exception e) {
                                System.err.println("✖ Error al enviar datos de registro: " + e.getMessage());
                                e.printStackTrace();
                            }

                            if (rol.equalsIgnoreCase("Administrador")) {
                                destino = "dash.jsp";
                                //guardar registro
                            } else if (!rol.isEmpty()) {
                                destino = "ingreso.jsp";
                                //guardar registro
                            } else {
                                destino = "visita.jsp";
                            }

                            // Guardar datos en sesión
                            session = request.getSession();
                            session.setAttribute("codigo", respuestaMicro.optString("codigoUTP", ""));
                            session.setAttribute("rol", rol);
                            session.setAttribute("restriccion", respuestaMicro.optString("restriccion", ""));
                            session.setAttribute("sede", respuestaMicro.optString("sede", ""));
                            session.setAttribute("nombreCompleto", jsonEnvio.getString("nombres") + " " + 
                                                jsonEnvio.getString("apellidoPaterno") + " " + 
                                                jsonEnvio.getString("apellidoMaterno"));

                            // Redirigir
                            response.setContentType("application/json");
                            response.setCharacterEncoding("UTF-8");
                            JSONObject json = new JSONObject();
                            json.put("success", true);
                            json.put("redirect", destino);  // puede ser "dash.jsp", "ingreso.jsp", etc.
                            response.getWriter().write(json.toString());
                            respuestaYaEnviada = true;
                            return;
                        } else {
                            System.err.println("Error al consultar microservicio. Código: " + responseCode);
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Error al consultar datos del alumno");
                        }

                    } catch (Exception ex) {
                        System.err.println("Error llamando al microservicio: " + ex.getMessage());
                        ex.printStackTrace();
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Error al procesar datos del alumno");
                    }

                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "DNI no registrado en RENIEC");
                    System.out.println("DNI no válido en RENIEC: " + dni);
                    registrarIngresoFallido();
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Huella digital no reconocida");
                System.out.println("Huella no encontrada en la base de datos");
                registrarIngresoFallido();
            }
            
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error en el servidor: " + e.getMessage());
            System.err.println("Error en IdentificacionController:");
            e.printStackTrace();
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) { 
                    System.err.println("Error al cerrar conexión: " + e.getMessage());
                }
            }
            try {
                if (!respuestaYaEnviada && !response.isCommitted()) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write(jsonResponse.toString());
                }
            } catch (IOException e) {
                System.err.println("Error al escribir JSON final: " + e.getMessage());
            }
        }
    }

      private String generateImageHash(InputStream imageStream) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] buffer = new byte[8192];
        int bytesRead;

        while ((bytesRead = imageStream.read(buffer)) != -1) {
            digest.update(buffer, 0, bytesRead);
        }

        byte[] hashBytes = digest.digest();
        return java.util.Base64.getEncoder().encodeToString(hashBytes);
    }

private void registrarIngresoFallido() {
    try {
        JSONObject registroJson = new JSONObject();
        registroJson.put("nombre", JSONObject.NULL);
        registroJson.put("dni", JSONObject.NULL);
        registroJson.put("ingresante", JSONObject.NULL);
        registroJson.put("motivo", JSONObject.NULL);
        registroJson.put("sede", JSONObject.NULL);

        // Fecha Lima +5h solo para registrar correctamente
        LocalDateTime limaTime = LocalDateTime.now(ZoneId.of("America/Lima")).plusHours(5);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        registroJson.put("fecha", limaTime.format(formatter));

        registroJson.put("estado", "Ingreso Fallido");

        URL registroUrl = new URL("https://servicio-utp.fly.dev/api/registros");
        HttpURLConnection conn = (HttpURLConnection) registroUrl.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = registroJson.toString().getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_CREATED) {
            System.out.println("✔ Ingreso fallido registrado correctamente.");
        } else {
            System.err.println("✖ Error al registrar ingreso fallido. Código: " + responseCode);
        }

        conn.disconnect();

    } catch (Exception e) {
        System.err.println("✖ Error en registrarIngresoFallido: " + e.getMessage());
        e.printStackTrace();
    }
}

      
    //consultar la API RENIEC
private JSONObject validarConReniec(int dni) {
    final String urlBase = "https://api.apis.net.pe/v2/reniec/dni?numero=";
    final String token = "apis-token-16231.wgH8qUVkvMVx2divIFdWBFevDLOncO8h";

    try {
        URL url = new URL(urlBase + dni);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", token);
        conn.setRequestProperty("Accept", "application/json");

        int responseCode = conn.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            InputStream inputStream = conn.getInputStream();

            // Leer los bytes
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            byte[] data = new byte[1024];
            int nRead;
            while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }
            buffer.flush();

            byte[] responseBytes = buffer.toByteArray();


            // Convertir a String UTF-8
            String responseStr = new String(responseBytes, StandardCharsets.UTF_8);

            return new JSONObject(responseStr);
        } else {
            System.err.println("Error en API RENIEC. Código: " + responseCode);
            return null;
        }
    } catch (Exception e) {
        System.err.println("Excepción al consultar RENIEC: " + e.getMessage());
        return null;
    }
}

}
