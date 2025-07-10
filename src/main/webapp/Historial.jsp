<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="okhttp3.OkHttpClient, okhttp3.Request, okhttp3.Response" %>
<%@ page import="com.fasterxml.jackson.databind.*" %>
<%@ page import="java.time.* , java.time.format.DateTimeFormatter" %>
<%@ page import="java.net.URLEncoder" %>

<%
    /* ------------------------------------------------------------------
       1. Construir la URL de la API según los filtros recibidos
       ------------------------------------------------------------------ */
    String baseUrl = "https://servicio-utp.fly.dev/api/registros/filtro";

    // Recoger parámetros del formulario
    String dni         = request.getParameter("dni");
    String sede        = request.getParameter("sede");      // SE0x o vacío
    String motivo      = request.getParameter("motivo");    // MO0x o vacío
    String estado      = request.getParameter("estado");    // Ingreso Exitoso / Fallido
    String tipo        = request.getParameter("tipo");      // ING0x o vacío
    String fechaInicio = request.getParameter("fechaInicio");
    String fechaFin    = request.getParameter("fechaFin");

    // Guardar cada par clave‑valor válido en una lista
    List<String> qs = new ArrayList<>();

    if(dni  != null && !dni.trim().isEmpty()) qs.add("dni="  + URLEncoder.encode(dni , "UTF-8"));
    if(sede != null && !sede.trim().isEmpty()) qs.add("sede=" + URLEncoder.encode(sede, "UTF-8"));
    if(motivo!=null&& !motivo.trim().isEmpty())qs.add("motivo="+ URLEncoder.encode(motivo,"UTF-8"));
    if(estado!=null&& !estado.trim().isEmpty())qs.add("estado="+ URLEncoder.encode(estado,"UTF-8"));
    if(tipo  != null && !tipo.trim().isEmpty()) qs.add("tipo=" + URLEncoder.encode(tipo , "UTF-8"));

    /*  Fechas: enviar con los nombres desde=  /  hasta=
        y el formato “yyyy-MM-dd” (sin hora)  */
    if(fechaInicio!=null && !fechaInicio.trim().isEmpty()){
        qs.add("desde=" + URLEncoder.encode(fechaInicio,"UTF-8"));
    }
    if(fechaFin!=null && !fechaFin.trim().isEmpty()){
        qs.add("hasta=" + URLEncoder.encode(fechaFin,"UTF-8"));
    }

    // Construir URL final
    String apiUrl = qs.isEmpty() ? baseUrl : baseUrl + "?" + String.join("&", qs);

    /* ------------------------------------------------------------------
       2. Consumir la API y convertir la respuesta en lista de JsonNode
       ------------------------------------------------------------------ */
    OkHttpClient client   = new OkHttpClient();
    Request      req      = new Request.Builder().url(apiUrl).build();
    Response     resp     = client.newCall(req).execute();
    String       jsonBody = resp.body().string();

    ObjectMapper mapper   = new ObjectMapper();
    JsonNode     root     = mapper.readTree(jsonBody);     // se espera un arreglo JSON

    List<JsonNode> registros = new ArrayList<>();
    if (root.isArray()) root.forEach(registros::add);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Historial de Ingresos</title>

    <!--  Bootstrap 5  -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!--  FontAwesome  -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!--  Tus CSS existentes  -->
    <link rel="stylesheet" href="css/navbar1.1.css" />
    <link rel="stylesheet" href="css/styles1.3.css" />
    <link rel="stylesheet" href="css/FormularioRegistro1.3.css" />
    <link rel="stylesheet" href="css/historial1.css" />

    <style>
        body{min-height:100vh;overflow-x:hidden;}
        .sidebar{width:250px;}
        @media(max-width:992px){
            .sidebar{position:fixed;top:0;left:-250px;height:100%;z-index:1045;transition:left .3s ease-in-out;}
            .sidebar.show{left:0;}
        }
        .header-bar{background:#fff;border-bottom:1px solid #dee2e6;}

        /*  Contenedor desplazable para tabla y header sticky  */
        .table-fixed-height{min-height:40vh;max-height:60vh;overflow-y:auto;position:relative;}
        .table-fixed-height thead th{position:sticky;top:0;z-index:2;background:#343a40;color:#fff;}

        .form-select-scroll{max-height:9.2rem;overflow-y:auto;}
        th, tr{cursor:default !important;}
    </style>
</head>
<body class="d-flex">
    <!--  Botón hamburguesa (móvil)  -->
    <button class="btn btn-primary d-lg-none position-fixed top-0 start-0 m-2 z-3" id="toggleSidebar">
        <i class="fas fa-bars"></i>
    </button>

    <!--  Sidebar  -->
    <nav id="sidebarMenu" class="sidebar collapsed"><%@ include file="navbar1.1.jsp" %></nav>

    <!--  Área principal -->
    <div class="flex-grow-1 d-flex flex-column">
        <header class="header-bar shadow-sm"><%@ include file="headerbar.jsp" %></header>

        <!--  Contenedor que evita colisiones con sidebar y navbar  -->
        <main class="container-fluid flex-grow-1 py-4">
            <div class="content-wrapper">

                <!-- Filtros -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <form class="row gy-2 gx-3 align-items-center" method="get">
                            <!-- Rango de Fechas -->
                            <div class="col-md-3">
                                <label class="form-label">Desde</label>
                                <input type="date" class="form-control" name="fechaInicio" value="<%=fechaInicio!=null?fechaInicio:""%>" />
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Hasta</label>
                                <input type="date" class="form-control" name="fechaFin" value="<%=fechaFin!=null?fechaFin:""%>" />
                            </div>

                            <!-- Sede (envía SE0x) -->
                            <div class="col-md-3">
                                <label class="form-label">Sede</label>
                                <select name="sede" class="form-select">
                                    <option value="">Todas</option>
                                    <%
                                        String[][] sedesArr={
                                            {"SE01","Centro"},
                                            {"SE02","Norte"},
                                            {"SE03","Sur"},
                                            {"SE04","Ate"},
                                            {"SE05","San Juan de Lurigancho"}
                                        };
                                        for(String[] s:sedesArr){
                                    %>
                                        <option value="<%=s[0]%>" <%=s[0].equals(sede)?"selected":""%>><%=s[1]%></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Motivo (envía MO0x) -->
                            <div class="col-md-3">
                                <label class="form-label">Motivo</label>
                                <select name="motivo" class="form-select form-select-scroll">
                                    <option value="">Todos</option>
                                    <%
                                        String[][] motivosArr={
                                            {"MO01","Estudios"},
                                            {"MO02","Docencia"},
                                            {"MO03","Labores"},
                                            {"MO04","Evento académico"},
                                            {"MO05","Solicitar información"},
                                            {"MO06","Trámite administrativo"},
                                            {"MO07","Visita institucional"},
                                            {"MO08","Acompañamiento a estudiante"},
                                            {"MO09","Entrega de documentos"}
                                        };
                                        for(String[] m:motivosArr){
                                    %>
                                        <option value="<%=m[0]%>" <%=m[0].equals(motivo)?"selected":""%>><%=m[1]%></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Estado (éxito / fallo) -->
                            <div class="col-md-3">
                                <label class="form-label">Estado</label>
                                <select name="estado" class="form-select">
                                    <option value="">Todos</option>
                                    <option <%= "Ingreso Exitoso".equals(estado)?"selected":"" %>>Ingreso Exitoso</option>
                                    <option <%= "Ingreso Fallido".equals(estado)?"selected":"" %>>Ingreso Fallido</option>
                                </select>
                            </div>

                            <!-- Tipo de Ingresante (envía ING0x) -->
                            <div class="col-md-3">
                                <label class="form-label">Tipo de Ingresante</label>
                                <select name="tipo" class="form-select">
                                    <option value="">Todos</option>
                                    <%
                                        String[][] tiposArr={
                                            {"ING01","Estudiante"},
                                            {"ING02","Profesor"},
                                            {"ING03","Trabajador"},
                                            {"ING04","Administrador"},
                                            {"ING05","Visitante"}
                                        };
                                        for(String[] t:tiposArr){
                                    %>
                                        <option value="<%=t[0]%>" <%=t[0].equals(tipo)?"selected":""%>><%=t[1]%></option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- DNI -->
                            <div class="col-md-3">
                                <label class="form-label">DNI</label>
                                <input type="text" class="form-control" name="dni" maxlength="8" pattern="\d{8}" value="<%=dni!=null?dni:""%>" />
                            </div>

                            <!-- Botón -->
                            <div class="col-md-3 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="fas fa-filter me-1"></i> Filtrar
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Tabla -->
                <div class="card shadow-sm">
                    <div id="tableWrapper" class="table-responsive table-fixed-height">
                        <table class="table table-striped align-middle mb-0">
                            <thead class="table-dark text-center">
                                <tr>
                                    <th>ID Registro</th><th>Nombre Completo</th><th>DNI</th>
                                    <th>Tipo de Ingresante</th><th>Motivo</th><th>Sede</th>
                                    <th>Fecha de Ingreso</th><th>Hora de Ingreso</th><th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                DateTimeFormatter fmtFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                                for (JsonNode reg : registros) {
                                    String iso   = reg.get("registro_ingreso_fecha").asText();
                                    ZonedDateTime lima = OffsetDateTime.parse(iso)
                                                                       .atZoneSameInstant(ZoneId.of("America/Lima"));
                                    String fecha = lima.toLocalDate().format(fmtFecha);
                                    String hora  = lima.toLocalTime().withNano(0).toString();
                            %>
                                <tr>
                                    <td><%= reg.get("id_registro").asText() %></td>
                                    <td><%= reg.get("nombre").asText() %></td>
                                    <td><%= reg.get("dni").asText() %></td>
                                    <td><%= reg.get("tipo_ingresante").asText() %></td>
                                    <td><%= reg.get("motivo").asText() %></td>
                                    <td><%= reg.get("sede").asText() %></td>
                                    <td><%= fecha %></td>
                                    <td><%= hora %></td>
                                    <td>
                                        <span class="badge <%= "Ingreso Exitoso".equals(reg.get("estado").asText()) ?
                                                                    "bg-success" : "bg-danger" %>">
                                            <%= reg.get("estado").asText() %>
                                        </span>
                                    </td>
                                </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div> <!-- /content-wrapper -->
        </main>
    </div>

    <!-- Bootstrap JS + scripts existentes -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/navbar1.js"></script><script src="js/script1.js"></script><script src="js/sesion.js"></script>

    <script>
        // Mostrar / ocultar sidebar en móvil
        document.getElementById('toggleSidebar')
                .addEventListener('click',()=>document.getElementById('sidebarMenu').classList.toggle('show'));

        // Añadir scroll fijo si supera 15 filas
        document.addEventListener('DOMContentLoaded',()=>{
            const wrapper=document.getElementById('tableWrapper');
            if(!wrapper)return;
            if(wrapper.querySelectorAll('tbody tr').length>15){
                wrapper.classList.add('table-fixed-height');
            }
        });
    </script>
    
     <style>
        body{min-height:100vh;overflow-x:hidden;}
        .sidebar{width:250px;}
        @media(max-width:992px){
            .sidebar{position:fixed;top:0;left:-250px;height:100%;z-index:1045;transition:left .3s ease-in-out;}
            .sidebar.show{left:0;}
        }
        .header-bar{background:#fff;border-bottom:1px solid #dee2e6;}

        /*  NUEVO: centramos y desplazamos filtros + tabla  */
        .content-wrapper{
            max-width:1200px;   /* ancho máximo para que no se pegue a los bordes */
            margin:2.5rem auto; /* ↓ lo baja un poco y lo centra horizontalmente */
            padding-left:1rem;  /* pequeño empuje adicional hacia la derecha */
        }

        /*  Contenedor desplazable para tabla y header sticky  */
        .table-fixed-height{min-height:40vh;max-height:60vh;overflow-y:auto;position:relative;}
        .table-fixed-height thead th{position:sticky;top:0;z-index:2;background:#343a40;color:#fff;}

        .form-select-scroll{max-height:9.2rem;overflow-y:auto;}
        th, tr{cursor:default !important;}
    </style>
</body>
</html>
