package config;

import java.sql.Connection;
import java.sql.DriverManager;

public class db {
    Connection con;

    // Datos de Railway
    String url = "jdbc:mysql://crossover.proxy.rlwy.net:36289/railway?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String user = "root";
    String pass = "JSqwrsvehPwsdADYTxIHpRMUixzgzPlu";

    public Connection Conexion() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            System.err.println("❌ Error al conectar con la base de datos:");
            e.printStackTrace();
        }
        return con;
    }

    public static void main(String[] args) {
        db conexion = new db();
        Connection con = conexion.Conexion();

        if (con != null) {
            System.out.println("✅ Conexión exitosa a la base de datos en Railway.");
        } else {
            System.out.println("❌ No se pudo conectar a la base de datos.");
        }
    }
}
