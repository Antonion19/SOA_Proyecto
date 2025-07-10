package clases;
import java.sql.Time;


public class ClassRegistro {
    public int id;
    public String nombreCompleto;
    public String dni;
    public String tipoIngresante;
    public String motivo;
    public Time horaRegistro;
    public String estado;

    public ClassRegistro() {
    }

    public ClassRegistro(int id, String nombreCompleto, String dni, String tipoIngresante, String motivo, Time horaRegistro, String estado) {
        this.id = id;
        this.nombreCompleto = nombreCompleto;
        this.dni = dni;
        this.tipoIngresante = tipoIngresante;
        this.motivo = motivo;
        this.horaRegistro = horaRegistro;
        this.estado = estado;
    }

 

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getTipoIngresante() {
        return tipoIngresante;
    }

    public void setTipoIngresante(String tipoIngresante) {
        this.tipoIngresante = tipoIngresante;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public Time getHoraRegistro() {
        return horaRegistro;
    }

    public void setHoraRegistro(Time horaRegistro) {
        this.horaRegistro = horaRegistro;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    
}
