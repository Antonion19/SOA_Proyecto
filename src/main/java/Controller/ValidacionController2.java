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
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.json.JSONObject;
import java.time.LocalDateTime; // Para AUDI_FecCrea
import java.time.format.DateTimeFormatter; // Para AUDI_FecCrea


@WebServlet(name = "ValidacionController2", urlPatterns = {"/ValidacionController2"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,   // 1 MB
    maxFileSize = 1024 * 1024 * 10,    // 10 MB
    maxRequestSize = 1024 * 1024 * 50  // 50 MB
)
public class ValidacionController2 extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();

        String action = request.getParameter("action");

        if ("searchDni".equals(action)) {
            String dniStr = request.getParameter("dni");
            if (dniStr != null && !dniStr.isEmpty()) {
                try {
                    int dni = Integer.parseInt(dniStr);
                    JSONObject reniecData = validateWithReniec(dni);

                    if (reniecData != null && reniecData.has("nombres")) {
                        jsonResponse.put("success", true);
                        jsonResponse.put("documento", dni);
                        jsonResponse.put("prenombres", reniecData.optString("nombres", ""));
                        jsonResponse.put("paterno", reniecData.optString("apellidoPaterno", ""));
                        jsonResponse.put("materno", reniecData.optString("apellidoMaterno", ""));
                        System.out.println("Consulta RENIEC exitosa para DNI: " + dni);
                    } else {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "DNI no encontrado o no válido en RENIEC.");
                        System.out.println("DNI no validado por RENIEC: " + dni);
                    }
                } catch (NumberFormatException e) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Formato de DNI inválido.");
                    System.err.println("Error de formato de DNI: " + e.getMessage());
                } catch (Exception e) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Error al consultar RENIEC: " + e.getMessage());
                    System.err.println("Error al consultar RENIEC en doGet: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Parámetro 'dni' faltante.");
            }
        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Acción no reconocida.");
        }

        out.print(jsonResponse.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        Connection con = null;

        String action = request.getParameter("action"); // Obtener la acción del request

        try {
        db database = new db();
        con = database.Conexion();

        if ("generateHash".equals(action)) {
            // Lógica para generar solo el hash de la imagen
            Part filePart = request.getPart("file");
            if (filePart == null) {
                throw new IllegalArgumentException("No se ha enviado ningún archivo.");
            }

            InputStream fileContent = filePart.getInputStream();
            String imageHash = generateImageHash(fileContent);
            jsonResponse.put("success", true);
            jsonResponse.put("imageHash", imageHash);
            System.out.println("Hash generado de la imagen: " + imageHash);

        } else if ("registerHuella".equals(action)) {
            // Lógica para registrar el DNI y el hash en la BD
            String numeroDocumentoStr = request.getParameter("documento");
            String imageHash = request.getParameter("imageHash");
            String email = request.getParameter("email");
            String celular = request.getParameter("celular");

            if (numeroDocumentoStr == null || numeroDocumentoStr.isEmpty() ||
                imageHash == null || imageHash.isEmpty()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Número de documento o hash de huella no proporcionado.");
                out.print(jsonResponse.toString());
                return;
            }

            int numeroDocumento = Integer.parseInt(numeroDocumentoStr);

            String insertQuery = "INSERT INTO huella_persona (numeroDocumento, image_template) VALUES (?, ?)";
            try (PreparedStatement insertStmt = con.prepareStatement(insertQuery)) {
                insertStmt.setInt(1, numeroDocumento);
                insertStmt.setString(2, imageHash);

                int rowsAffected = insertStmt.executeUpdate();
                if (rowsAffected > 0) {
                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "Huella registrada exitosamente.");
                    System.out.println("Registro exitoso para DNI: " + numeroDocumento);
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Fallo al registrar la huella.");
                    System.err.println("Fallo al registrar la huella para DNI: " + numeroDocumento);
                }
            }

        } else {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Acción no reconocida en POST.");
        }

    } catch (Exception e) {
        jsonResponse.put("success", false);
        jsonResponse.put("message", "Error en el servidor: " + e.getMessage());
        System.err.println("Error en ValidacionController: ");
        e.printStackTrace();
    } finally {
        try {
            if (con != null) con.close();
        } catch (SQLException e) {
            System.err.println("Error al cerrar conexión: " + e.getMessage());
        }
    }
    out.print(jsonResponse.toString());
    out.flush();
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

    //consultar la API RENIEC
    private JSONObject validateWithReniec(int dni) {
        final String urlBase = "https://api.apis.net.pe/v2/reniec/dni?numero=";
        final String token = "apis-token-16231.wgH8qUVkvMVx2divIFdWBFevDLOncO8h"; // Asegúrate de que este token sea válido y seguro

        try {
            URL url = new URL(urlBase + dni);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + token); // Es común que los tokens vayan con 'Bearer'
            conn.setRequestProperty("Accept", "application/json");

            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder response = new StringBuilder();

                while ((inputLine = in.readLine()) != null) {
                    response.append(inputLine);
                }
                in.close();
                
                JSONObject jsonReniecResponse = new JSONObject(response.toString());
                // Algunas APIs de RENIEC devuelven un objeto de datos dentro de una clave, por ejemplo "data"
                // Si la respuesta de apis.net.pe/v2/reniec/dni ya es directamente los datos de la persona, no necesitas esta línea.
                // Si viene dentro de un objeto "data", por ejemplo: {"data": {"nombres": "...", ...}}
                // entonces deberías hacer: return jsonReniecResponse.optJSONObject("data", jsonReniecResponse);
                return jsonReniecResponse; 
            } else {
                BufferedReader errorReader = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                String errorLine;
                StringBuilder errorResponse = new StringBuilder();
                while ((errorLine = errorReader.readLine()) != null) {
                    errorResponse.append(errorLine);
                }
                errorReader.close();
                System.err.println("Error en API RENIEC. Código: " + responseCode + ", Mensaje: " + errorResponse.toString());
                return null;
            }
        } catch (Exception e) {
            System.err.println("Excepción al consultar RENIEC: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}