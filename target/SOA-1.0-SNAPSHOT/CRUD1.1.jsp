<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="okhttp3.*,
                 com.fasterxml.jackson.databind.*,
                 com.fasterxml.jackson.core.type.TypeReference,
                 java.util.*, java.io.IOException" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Administradores – Gestión de Restricciones</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!-- Estilos propios (opcional) -->
    <link rel="stylesheet" href="css/navbar1.1.css" />
    <link rel="stylesheet" href="css/styles1.3.css" />

    <style>
        body{min-height:100vh;overflow-x:hidden;}
        .sidebar{width:250px;}
        @media(max-width:992px){
            .sidebar{position:fixed;top:0;left:-250px;height:100%;z-index:1045;transition:left .3s ease-in-out;}
            .sidebar.show{left:0;}
        }
        .header-bar{background:#fff;border-bottom:1px solid #dee2e6;}
        .content-wrapper{max-width:1200px;margin:2.5rem auto;padding-left:1rem;}
        .table-fixed-height{min-height:40vh;max-height:60vh;overflow-y:auto;position:relative;}
        .table-fixed-height thead th{position:sticky;top:0;z-index:2;background:#343a40;color:#fff;}
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

<!-- -------- FORMULARIO DE FILTRO -------- -->
<div class="card shadow-sm mb-4"><div class="card-body">
<form class="row gy-2 gx-3 align-items-end" method="get">
  <div class="col-md-3">
    <label class="form-label">DNI</label>
    <input type="text" name="dni" class="form-control" maxlength="8" pattern="[0-9]{8}" inputmode="numeric" placeholder="Ej. 75992629" value="<%=request.getParameter("dni")!=null?request.getParameter("dni"):""%>">
  </div>
  <div class="col-md-3">
    <% String restrSel=request.getParameter("restriccion");if(restrSel==null||restrSel.isEmpty()) restrSel="Sin Restricción";%>
    <label class="form-label">Restricción</label>
    <select name="restriccion" class="form-select">
      <option value="Sin Restricción" <%="Sin Restricción".equals(restrSel)?"selected":""%>>Sin Restricción</option>
      <option value="Dejó de trabajar" <%="Dejó de trabajar".equals(restrSel)?"selected":""%>>Dejó de trabajar</option>
    </select>
  </div>
  <div class="col-md-3 d-grid">
    <button class="btn btn-primary" type="submit"><i class="fas fa-search me-1"></i>Buscar</button>
  </div>
</form>
</div></div>

<%
/* ---- 1. PATCH si corresponde ---- */
String accion=request.getParameter("accion");
if("patch".equals(accion)){
  String dniAcc=request.getParameter("dni_accion");
  String nuevaRest=request.getParameter("nueva_restriccion");
  if(dniAcc!=null && nuevaRest!=null){
    OkHttpClient pc=new OkHttpClient();
    MediaType JSON=MediaType.parse("application/json; charset=utf-8");
    RequestBody body=RequestBody.create("{\"restriccion\":\""+nuevaRest+"\"}", JSON);
    Request pr=new Request.Builder().url("https://servicio-utp.fly.dev/api/utp/"+dniAcc).patch(body).build();
    try(Response r=pc.newCall(pr).execute()){} // sin manejo
  }
}

/* ---- 2. Traer datos ---- */
String dniP=request.getParameter("dni");
String codP=request.getParameter("codigo");
String apiUrl=(dniP!=null&&!dniP.isEmpty())?"https://servicio-utp.fly.dev/api/utp/"+dniP:
             (codP!=null&&!codP.isEmpty())?"https://servicio-utp.fly.dev/api/utpCOD/"+codP:
             "https://servicio-utp.fly.dev/api/utp";

OkHttpClient cl=new OkHttpClient();
Request rq=new Request.Builder().url(apiUrl).build();
Response rp=cl.newCall(rq).execute();
List<Map<String,Object>> todos=new ArrayList<>();
if(rp.isSuccessful()){
  String js=rp.body().string();
  ObjectMapper mp=new ObjectMapper();
  if(js.trim().startsWith("[")){
    todos=mp.readValue(js,new TypeReference<List<Map<String,Object>>>(){});
  }else if(!js.trim().isEmpty()){
    Map<String,Object> ob=mp.readValue(js,new TypeReference<Map<String,Object>>(){});
    todos.add(ob);
  }
}

/* ---- 3. Filtrado ---- */
List<Map<String,Object>> lista=new ArrayList<>();
for(Map<String,Object> u: todos){
  String rol=(String)u.get("rol");
  String res=(String)u.get("restriccion");
  if(rol!=null && res!=null && (rol.equalsIgnoreCase("Administrador")||rol.equalsIgnoreCase("RO04")) && res.equalsIgnoreCase(restrSel)){
    lista.add(u);
  }
}
%>

<a href="registro_Admin.jsp" class="btn btn-success mb-3"><i class="fas fa-user-plus me-1"></i>Agregar Registro</a>

<div class="card shadow-sm"><div id="tableWrapper" class="table-responsive">
<table class="table table-striped align-middle mb-0">
<thead class="table-dark text-center"><tr><th>#</th><th>Código</th><th>Nombre</th><th>DNI</th><th>Restricción</th><th>Rol</th><th>Sede</th><th>Acciones</th></tr></thead>
<tbody class="text-center">
<%
int i=1;
for(Map<String,Object> row: lista){
 String dni=(String)row.get("dni");
 String res=(String)row.get("restriccion");
 boolean activa="Sin Restricción".equalsIgnoreCase(res);
 String badge=activa?"bg-success":"bg-danger";
 String newRes=activa?"RE05":"RE01";
%>
<tr>
  <td><%=i++%></td>
  <td><%=row.get("codigo")%></td>
  <td class="text-start"><%=row.get("nombre")%></td>
  <td><%=dni%></td>
  <td><span class="badge <%=badge%>"><%=res%></span></td>
  <td><%=row.get("rol")%></td>
  <td><%=row.get("sede")%></td>
  <td>
    <form method="post" style="display:inline-block;" onsubmit="return confirm('¿Confirmar cambio de restricción?');">
      <input type="hidden" name="accion" value="patch" />
      <input type="hidden" name="dni_accion" value="<%=dni%>" />
      <input type="hidden" name="nueva_restriccion" value="<%=newRes%>" />
      <input type="hidden" name="dni" value="<%=dniP!=null?dniP:""%>" />
      <input type="hidden" name="codigo" value="<%=codP!=null?codP:""%>" />
      <input type="hidden" name="restriccion" value="<%=restrSel%>" />
      <button class="btn btn-sm <%=activa?"btn-danger":"btn-success"%>"><i class="fas fa-power-off"></i> <%=activa?"Desactivar":"Activar"%></button>
    </form>
   <a href="editar_Admin.jsp?dni=<%=dni%>&<%=newRes%>" class="btn btn-sm btn-primary ms-1">
    <i class="fas fa-pen"></i>
</a>
  </td>
</tr>
<% } if(lista.isEmpty()){ %>
<tr><td colspan="8" class="py-4">Sin resultados.</td></tr>
<% } %>
</tbody>
</table>
</div></div>

</div></main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('toggleSidebar').addEventListener('click',()=>document.getElementById('sidebarMenu').classList.toggle('show'));
// Scroll fijo si muchas filas
window.addEventListener('load',()=>{
 const w=document.getElementById('tableWrapper');
 if(w && w.querySelectorAll('tbody tr').length>15) w.classList.add('table-fixed-height');
});
</script>

<script>
document.getElementById('toggleSidebar').addEventListener('click',()=>document.getElementById('sidebarMenu').classList.toggle('show'));
</script>
</body>
</html>
