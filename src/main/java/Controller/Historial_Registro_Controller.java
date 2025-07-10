
package Controller;


import config.db;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "Historial_Registro_Controller", urlPatterns = {"/Historial_Registro_Controller"})

public class Historial_Registro_Controller extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {

        }
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
          
            
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
        
          Connection con = null;
            db database = new db();
            con = database.Conexion();
            
            // Buscar en la tabla huella_persona
            String query = "SELECT  r.id_registro,\n" +
"            r.registro_nombre       AS nombre,\n" +
"            r.registro_dni          AS dni,\n" +
"            i.ingresante_detalle    AS tipo_ingresante,\n" +
"            m.motivo_detalle        AS motivo,\n" +
"            r.registro_ingreso_fecha,\n" +
"			estado \n" +
"    FROM registro AS r\n" +
"    INNER JOIN ingresante AS i ON i.id_ingresante = r.registro_tipo_ingresante\n" +
"    INNER JOIN motivo     AS m ON m.id_motivo     = r.registro_motivo;";
             List<String> lista = new ArrayList<>();
            PreparedStatement stmt;

            try {
                stmt = con.prepareStatement(query);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    lista.add(String.valueOf((char) rs.getInt(1)));  // id
                    lista.add(rs.getString(2));               // nombreCompleto
                    lista.add(rs.getString(3));               // dni
                    lista.add(rs.getString(4));               // tipoIngresante
                    lista.add(rs.getString(5));               // motivo
                    lista.add(String.valueOf(rs.getTime(6))); // horaRegistro
                    lista.add(rs.getString(7));               // estado
                }

            } catch (SQLException ex) {
                Logger.getLogger(Historial_Registro_Controller.class.getName())
                      .log(Level.SEVERE, null, ex);
            }
    
            
        request.setAttribute("registros", lista);
        request.getRequestDispatcher("Historial.jsp").forward(request, response);
            
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
