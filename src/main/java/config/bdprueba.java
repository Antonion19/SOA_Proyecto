/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package config;


import java.sql.Connection;

import java.sql.DriverManager;
import java.sql.SQLException;
public class bdprueba {
    protected Connection con = null;
    String url = "jdbc:mysql://localhost:3306/bdsoan";
    String user = "root";
    String pass = "";

    public Connection Conexion() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }

    public Connection Discconet() {
        try {
            con.close();
        } catch (SQLException ex) {
            System.out.println("Error de desconexión: " + ex.getMessage());
        }
        return null;
    }

    public static void main(String[] args) {
        bdprueba conexion = new bdprueba();
        Connection con = conexion.Conexion();
        if (con != null) {
            System.out.println("Conexión exitosa a la base de datos.");
            try {
                con.close(); 
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("No se pudo establecer conexión a la base de datos.");
        }
    }
}
