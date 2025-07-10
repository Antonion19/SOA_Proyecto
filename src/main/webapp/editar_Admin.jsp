<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="okhttp3.*, com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.IOException" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Editar Sede</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  <link rel="stylesheet" href="css/navbar1.1.css" />
  <link rel="stylesheet" href="css/styles1.3.css" />
  <style>
    body{min-height:100vh;overflow-x:hidden;}
    .sidebar{width:250px;}
    @media(max-width:992px){.sidebar{position:fixed;top:0;left:-250px;height:100%;transition:left .3s;}.sidebar.show{left:0;}}
    .header-bar{background:#fff;border-bottom:1px solid #dee2e6;}
    .content-wrapper{max-width:700px;margin:4rem auto 0;padding-left:1rem;}
  </style>
</head>
<body class="d-flex">
<button class="btn btn-primary d-lg-none position-fixed top-0 start-0 m-2 z-3" id="toggleSidebar"><i class="fas fa-bars"></i></button>
<nav id="sidebarMenu" class="sidebar collapsed"><%@ include file="navbar1.1.jsp" %></nav>
<div class="flex-grow-1 d-flex flex-column">
<header class="header-bar shadow-sm"><%@ include file="headerbar.jsp" %></header>
<main class="container-fluid flex-grow-1 py-4">
<div class="content-wrapper">
<%
  String dni = request.getParameter("dni");
  // Código de restricción actual recibido como query param o default RE01
  String restrCodigo = request.getParameter("restriccion");
  if(restrCodigo==null || restrCodigo.isEmpty()) restrCodigo = "RE01";

  String mensaje = null;
  if("POST".equalsIgnoreCase(request.getMethod())){
     String sede = request.getParameter("sede");
     String restrHidden = request.getParameter("restriccion");
     if(dni!=null && sede!=null && restrHidden!=null && !dni.isEmpty() && !sede.isEmpty()){
       Map<String,String> m = new HashMap<>();
       m.put("sede", sede);
       m.put("restriccion", restrHidden); // enviar el código sin mostrarlo

       String json = new ObjectMapper().writeValueAsString(m);
       OkHttpClient cl = new OkHttpClient();
       RequestBody rb = RequestBody.create(json, MediaType.parse("application/json"));
       Request rq = new Request.Builder().url("https://servicio-utp.fly.dev/api/utp/"+dni).patch(rb).build();
       try(Response rp = cl.newCall(rq).execute()){
         if(rp.isSuccessful()){
            response.sendRedirect("CRUD1.1.jsp?editSedeSuccess=1");return;
         }else mensaje = "Error: "+rp.code();
       }catch(IOException e){mensaje="Conexión fallida";}
     }else mensaje = "Todos los campos son obligatorios";
  }
%>
<div class="card shadow-sm">
  <div class="card-header bg-dark text-white"><h5 class="mb-0"><i class="fas fa-building me-2"></i>Editar Sede del Administrador</h5></div>
  <div class="card-body">
    <% if(mensaje!=null){ %><div class="alert alert-danger"><%=mensaje%></div><% } %>
    <form method="post" class="row g-3">
      <!-- DNI readonly -->
      <div class="col-md-6">
        <label class="form-label">DNI</label>
        <input name="dni" class="form-control" readonly value="<%=dni!=null?dni:""%>" />
      </div>
      <!-- Selección de sede -->
      <div class="col-md-6">
        <label class="form-label">Nueva Sede</label>
        <select name="sede" class="form-select" required>
          <option value="" selected hidden>Seleccione sede</option>
          <option value="SE01">Centro</option>
          <option value="SE02">Norte</option>
          <option value="SE03">Sur</option>
          <option value="SE04">Ate</option>
          <option value="SE05">SJL</option>
        </select>
      </div>
      <!-- Código de restricción oculto -->
      <input type="hidden" name="restriccion" value="<%=restrCodigo%>" />

      <div class="col-12 text-end">
        <a href="CRUD1.1.jsp" class="btn btn-secondary">Cancelar</a>
        <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>Guardar</button>
      </div>
    </form>
  </div>
</div>
</div></main></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('toggleSidebar').addEventListener('click',()=>document.getElementById('sidebarMenu').classList.toggle('show'));
</script>
</body>
</html>