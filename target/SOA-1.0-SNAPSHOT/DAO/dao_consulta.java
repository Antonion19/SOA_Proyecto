package DAO;
import clases.ClassRegistro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class dao_consulta {
    
     Connection con;
    String url = "jdbc:mysql://localhost:3306/bdsoan";    
    String user = "root";
    String pass = "";
    
  public Connection Conexion() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url,user,pass);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return con;
    }

    public List<ClassRegistro> listar() throws SQLException {
        String procedimiento="sp_listar_registros";
        String sql = "SELECT id_registro,\n" +
"                   CONCAT(nombre,' ',ape_pat,' ',ape_mat) AS nombreCompleto,\n" +
"                   dni, tipo, motivo, hora_registro, estado\n" +
"            FROM registros\n" +
"            ORDER BY hora_registro DESC"
          ;

        try (Connection con = Conexion();
             PreparedStatement ps = con.prepareStatement(sql);
             //ResultSet rs = ps.executeQuery()) {
             CallableStatement cs = con.prepareCall(procedimiento);
             ResultSet rs = cs.executeQuery()) {        

            List<ClassRegistro> lista = new ArrayList<>();
            while (rs.next()) {
                ClassRegistro r = new ClassRegistro();
                r.setId(rs.getInt(1));
                r.setNombreCompleto(rs.getString(2));
                r.setDni(rs.getString(3));
                r.setTipoIngresante(rs.getString(4));
                r.setMotivo(rs.getString(5));
                r.setHoraRegistro(rs.getTime(6));
                r.setEstado(rs.getString(7));
                lista.add(r);
            }
            return lista;
        }
    }
}
