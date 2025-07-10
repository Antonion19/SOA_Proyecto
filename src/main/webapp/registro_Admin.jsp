<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="okhttp3.*,
                 com.fasterxml.jackson.databind.ObjectMapper,
                 java.util.*,
                 java.io.IOException" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Agregar Administrador</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!-- Estilos generales -->
    <link rel="stylesheet" href="css/navbar1.1.css" />
    <link rel="stylesheet" href="css/styles1.3.css" />

    <style>
        body{min-height:100vh;overflow-x:hidden;}
        .sidebar{width:250px;}
        @media(max-width:992px){
            .sidebar{position:fixed;top:0;left:-250px;height:100%;z-index:1045;transition:left .3s ease-in-out;}
            .sidebar.show{left:0;}
        }
        /* Restauramos barra superior clara */
        .header-bar{background:#fff;border-bottom:1px solid #dee2e6;}
        /* Centramos card */
        .content-wrapper{max-width:700px;margin:4rem auto 0 auto;padding-left:1rem;}
    </style>
</head>
<body class="d-flex">
<!-- Botón hamburguesa -->
<button class="btn btn-primary d-lg-none position-fixed top-0 start-0 m-2 z-3" id="toggleSidebar"><i class="fas fa-bars"></i></button>

<!-- Sidebar -->
<nav id="sidebarMenu" class="sidebar collapsed"><%@ include file="navbar1.1.jsp" %></nav>

<!-- Área principal -->
<div class="flex-grow-1 d-flex flex-column">
<header class="header-bar shadow-sm"><%@ include file="headerbar.jsp" %></header>

<main class="container-fluid flex-grow-1 py-4">
<div class="content-wrapper">

<%
    String mensaje=null;
    boolean exito=false;
    if("POST".equalsIgnoreCase(request.getMethod())){
        String codigo=request.getParameter("codigo");
        String nombre=request.getParameter("nombre");
        String dni=request.getParameter("dni");
        String sede=request.getParameter("sede");

        if(codigo!=null && nombre!=null && dni!=null && sede!=null && codigo.trim().length()>0){
            Map<String,String> payload=new HashMap<>();
            payload.put("codigo",codigo.trim());
            payload.put("nombre",nombre.trim());
            payload.put("dni",dni.trim());
            payload.put("restriccion","RE01");
            payload.put("rol","RO04");
            payload.put("sede",sede);

            ObjectMapper mapper=new ObjectMapper();
            String jsonBody=mapper.writeValueAsString(payload);

            OkHttpClient client=new OkHttpClient();
            RequestBody body=RequestBody.create(jsonBody, MediaType.parse("application/json; charset=utf-8"));
            Request req=new Request.Builder()
                    .url("https://servicio-utp.fly.dev/api/utp")
                    .post(body).build();
            try(Response resp=client.newCall(req).execute()){
                if(resp.isSuccessful()){
                    // Redirigir inmediatamente al listado con indicador de éxito
                    response.sendRedirect("CRUD1.1.jsp?addSuccess=1");
                    return;
                }else{
                    mensaje="Error al agregar: "+resp.code();
                }
            }catch(IOException e){
                mensaje="Error de conexión.";
            }
        }else{
            mensaje="Todos los campos son obligatorios.";
        }
    }
%>

<div class="card shadow-sm">
  <div class="card-header bg-dark text-white"><h5 class="mb-0"><i class="fas fa-user-plus me-1"></i>Nuevo Administrador</h5></div>
  <div class="card-body">
    <% if(mensaje!=null){ %>
      <div class="alert <%=exito?"alert-success":"alert-danger"%>"><%=mensaje%></div>
    <% } %>
    <form method="post" class="row g-3">
      <input type="hidden" name="restriccion" value="RE01" />
      <div class="col-md-6">
        <label class="form-label">Código</label>
        <input name="codigo" class="form-control" required maxlength="10" placeholder="ADMIN2">
      </div>
      <div class="col-md-6">
        <label class="form-label">DNI</label>
        <input name="dni" class="form-control" required pattern="[0-9]{8}" maxlength="8" inputmode="numeric" placeholder="75200328">
      </div>
      <div class="col-12">
        <label class="form-label">Nombre completo</label>
        <input name="nombre" class="form-control" required placeholder="Admin">
      </div>
      <div class="col-md-6">
        <label class="form-label">Sede</label>
        <select name="sede" class="form-select" required>
          <option value="SE01">Centro</option>
          <option value="SE02">Norte</option>
          <option value="SE03" selected>Sur</option>
          <option value="SE04">Ate</option>
          <option value="SE05">SJL</option>
        </select>
      </div>
      <div class="col-12 text-end">
        <a href="CRUD1.1.jsp" class="btn btn-secondary me-2">Cancelar</a>
        <button type="submit" class="btn btn-success"><i class="fas fa-save me-1"></i>Guardar</button>
      </div>
    </form>
  </div>
</div>

</div></main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('toggleSidebar').addEventListener('click',()=>document.getElementById('sidebarMenu').classList.toggle('show'));
</script>
</body>
</html>
