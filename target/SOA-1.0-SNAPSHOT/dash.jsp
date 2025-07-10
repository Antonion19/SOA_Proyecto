<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="okhttp3.*, com.fasterxml.jackson.databind.*, java.util.*, java.time.*" %>
<%
    /* =====================  LÓGICA ORIGINAL (sin cambios)  ===================== */
    LocalDate today = LocalDate.now();
    int dMes = today.getMonthValue();
    int dAnio = today.getYear();

    /* ---- parámetros (idéntico) ---- */
    int mesDia  = Integer.parseInt(request.getParameter("mes_dia")  != null ? request.getParameter("mes_dia")  : String.valueOf(dMes));
    int anioDia = Integer.parseInt(request.getParameter("anio_dia") != null ? request.getParameter("anio_dia") : String.valueOf(dAnio));
    String sedeDia = request.getParameter("sede_dia") != null ? request.getParameter("sede_dia") : "";

    int mesSede  = Integer.parseInt(request.getParameter("mes_sede")  != null ? request.getParameter("mes_sede")  : String.valueOf(dMes));
    int anioSede = Integer.parseInt(request.getParameter("anio_sede") != null ? request.getParameter("anio_sede") : String.valueOf(dAnio));

    int mesMot  = Integer.parseInt(request.getParameter("mes_motivo")  != null ? request.getParameter("mes_motivo")  : String.valueOf(dMes));
    int anioMot = Integer.parseInt(request.getParameter("anio_motivo") != null ? request.getParameter("anio_motivo") : String.valueOf(dAnio));
    String sedeMot = request.getParameter("sede_motivo") != null ? request.getParameter("sede_motivo") : "";

    int mesEst  = Integer.parseInt(request.getParameter("mes_estado")  != null ? request.getParameter("mes_estado")  : String.valueOf(dMes));
    int anioEst = Integer.parseInt(request.getParameter("anio_estado") != null ? request.getParameter("anio_estado") : String.valueOf(dAnio));
    String sedeEst = request.getParameter("sede_estado") != null ? request.getParameter("sede_estado") : "";

    int mesIng  = Integer.parseInt(request.getParameter("mes_ing")  != null ? request.getParameter("mes_ing")  : String.valueOf(dMes));
    int anioIng = Integer.parseInt(request.getParameter("anio_ing") != null ? request.getParameter("anio_ing") : String.valueOf(dAnio));
    String sedeIng = request.getParameter("sede_ing") != null ? request.getParameter("sede_ing") : "";

    int anioMes = Integer.parseInt(request.getParameter("anio_mes") != null ? request.getParameter("anio_mes") : String.valueOf(dAnio));
    String sedeMes = request.getParameter("sede_mes") != null ? request.getParameter("sede_mes") : "";

    String[] sedesList = {"Centro","Norte","Sur","Ate","San Juan de Lurigancho"};

    OkHttpClient client = new OkHttpClient();
    ObjectMapper mapper = new ObjectMapper();

    /* ---- llamadas REST (idénticas) ---- */
    String urlDia = "https://servicio-utp.fly.dev/api/registros/StatCantDia?mes="+mesDia+"&year="+anioDia;
    if(!sedeDia.isEmpty()) urlDia += "&sede="+java.net.URLEncoder.encode(sedeDia,"UTF-8");
    JsonNode dataDia = mapper.readTree(client.newCall(new Request.Builder().url(urlDia).build()).execute().body().string());

    int daysInMonth = java.time.YearMonth.of(anioDia, mesDia).lengthOfMonth();
    int[] valoresDia = new int[daysInMonth];
    for(JsonNode n:dataDia){
        int idx=n.get("DAY(r.registro_ingreso_fecha)").asInt()-1;
        if(idx>=0 && idx<daysInMonth) valoresDia[idx]=n.get("total_anual").asInt();
    }

    JsonNode dataSede   = mapper.readTree(client.newCall(new Request.Builder().url("https://servicio-utp.fly.dev/api/registros/StatSede?mes="+mesSede+"&year="+anioSede).build()).execute().body().string());

    String urlMot = "https://servicio-utp.fly.dev/api/registros/StatMotivo?mes="+mesMot+"&year="+anioMot; if(!sedeMot.isEmpty()) urlMot += "&sede="+java.net.URLEncoder.encode(sedeMot,"UTF-8");
    JsonNode dataMot = mapper.readTree(client.newCall(new Request.Builder().url(urlMot).build()).execute().body().string());

    String urlEst = "https://servicio-utp.fly.dev/api/registros/StatEstado?mes="+mesEst+"&year="+anioEst; if(!sedeEst.isEmpty()) urlEst += "&sede="+java.net.URLEncoder.encode(sedeEst,"UTF-8");
    JsonNode dataEst = mapper.readTree(client.newCall(new Request.Builder().url(urlEst).build()).execute().body().string());

    String urlIng = "https://servicio-utp.fly.dev/api/registros/StatIngresante?mes="+mesIng+"&year="+anioIng; if(!sedeIng.isEmpty()) urlIng += "&sede="+java.net.URLEncoder.encode(sedeIng,"UTF-8");
    JsonNode dataIng = mapper.readTree(client.newCall(new Request.Builder().url(urlIng).build()).execute().body().string());

    String urlMes = "https://servicio-utp.fly.dev/api/registros/StatCantMes?year="+anioMes; if(!sedeMes.isEmpty()) urlMes += "&sede="+java.net.URLEncoder.encode(sedeMes,"UTF-8");
    JsonNode dataCantMes = mapper.readTree(client.newCall(new Request.Builder().url(urlMes).build()).execute().body().string());

    int[] mesesValores = new int[12];
    for(JsonNode n : dataCantMes){
        int mIndex = n.get("MONTH(r.registro_ingreso_fecha)").asInt()-1;
        if(mIndex>=0 && mIndex<12) mesesValores[mIndex] = n.get("total_anual").asInt();
    }
    String[] mesesNombre = {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"};
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Ingresantes</title>

    <!-- ========= ESTILOS ========= -->
   <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <link rel="stylesheet" href="css/navbar1.1.css"><!-- sidebar / header -->
    <link rel="stylesheet" href="css/styles1.3.css">
    <link rel="stylesheet" href="css/FormularioRegistro1.3.css"><!-- mismo set del proyecto -->

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="js/navbar1.js"></script>
    <script src="js/script1.js"></script>
    <script src="js/sesion.js"></script>

    <style>
        /* ---------- estilos originales de las cards ---------- */
        body{background:#f8f9fa}
        .card-chart{background:#fff;border-radius:1rem;padding:1rem 1.25rem;margin-bottom:1.5rem;box-shadow:0 .25rem 1rem rgba(0,0,0,.08)}
        .filter-form label{font-size:.75rem;margin-bottom:.1rem}
        .filter-form .form-select,.filter-form .form-control{padding:.25rem .5rem;font-size:.8rem}
        canvas{max-height:180px!important}

        /* ---------- combobox “bonito” (sin cambios) ---------- */
        .nice-select{
            appearance:none;-webkit-appearance:none;-moz-appearance:none;
            background:#fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='%233c97f2' viewBox='0 0 16 16'%3E%3Cpath d='M4.646 6.146a.5.5 0 0 1 .708 0L8 8.793l2.646-2.647a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 0 1 0-.708z'/%3E%3C/svg%3E") no-repeat right .65rem center;
            padding:.375rem 2rem .375rem .75rem;border:1px solid #c9d6f2;border-radius:.45rem;font-size:.875rem;color:#003f5c;
            transition:border-color .15s ease, box-shadow .15s ease;
        }
        .nice-select:focus{border-color:#3c97f2;box-shadow:0 0 0 .2rem rgba(60,151,242,.25);outline:0;}
        .nice-select:hover{border-color:#3c97f2;}
        .nice-select option{color:#003f5c;}
        @media (prefers-color-scheme: dark){
            .nice-select{background-color:#1d2635;border-color:#44506b;color:#e8f3ff;}
            .nice-select option{color:#e8f3ff;}
        }

        /* ---------- NUEVOS ajustes de layout ---------- */
        /* espacio para el sidebar (ancho en navbar1.1.css) */
        .main-content{margin-left:var(--sidebar-width,260px);padding-top:var(--header-height,60px);}
        .main-content .container{max-width:1200px;}            /* centra el dashboard */
        @media (max-width: 576px){
            .main-content{margin-left:0;}                      /* móvil: sidebar colapsado */
        }
    </style>
</head>
<body>
    <!-- ======= SIDEBAR / NAVBAR (includes de tu proyecto) ======= -->
    <div class="sidebar collapsed"><%@ include file="navbar1.1.jsp" %></div>
    <div class="header-bar"><%@ include file="headerbar.jsp" %></div>

    <!-- ======= CONTENIDO PRINCIPAL ======= -->
    <div class="main-content">
        <div class="container my-4"><!-- contenedor central -->

            <!-- === Día Chart === -->
            <div class="card-chart mb-4">
                <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                    <div class="col-3 col-sm-2"><label>Mes</label>
                        <select name="mes_dia" class="form-select form-select-sm">
                            <%for(int m=1;m<=12;m++){%>
                                <option value="<%=m%>" <%=m==mesDia?"selected":""%>><%=m%></option>
                            <%}%>
                        </select></div>
                    <div class="col-3 col-sm-2"><label>Año</label><input type="number" name="anio_dia" class="form-control form-control-sm" value="<%=anioDia%>"/></div>
                    <div class="col-4 col-sm-3"><label>Sede</label>
                        <select name="sede_dia" class="form-select form-select-sm">
                            <option value="" <%=sedeDia.isEmpty()?"selected":""%>>Todas</option>
                            <%for(String s:sedesList){%>
                                <option <%=s.equals(sedeDia)?"selected":""%>><%=s%></option>
                            <%}%>
                        </select></div>
                    <div class="col-2 col-sm-1 align-self-end"><button class="btn btn-sm btn-primary w-100">OK</button></div>

                    <!-- mantener resto de parámetros ocultos -->
                    <input type="hidden" name="mes_sede" value="<%=mesSede%>"><input type="hidden" name="anio_sede" value="<%=anioSede%>">
                    <input type="hidden" name="mes_motivo" value="<%=mesMot%>"><input type="hidden" name="anio_motivo" value="<%=anioMot%>"><input type="hidden" name="sede_motivo" value="<%=sedeMot%>">
                    <input type="hidden" name="mes_estado" value="<%=mesEst%>"><input type="hidden" name="anio_estado" value="<%=anioEst%>"><input type="hidden" name="sede_estado" value="<%=sedeEst%>">
                    <input type="hidden" name="mes_ing" value="<%=mesIng%>"><input type="hidden" name="anio_ing" value="<%=anioIng%>"><input type="hidden" name="sede_ing" value="<%=sedeIng%>">
                    <input type="hidden" name="anio_mes" value="<%=anioMes%>"><input type="hidden" name="sede_mes" value="<%=sedeMes%>">
                </form>
                <h6 class="mt-2">Ingresantes por Día (<%=mesDia%>/<%=anioDia%>) <%=!sedeDia.isEmpty()?"- "+sedeDia:""%></h6>
                <canvas id="chartDia"></canvas>
            </div>

            <!-- === Cantidad por Mes === -->
            <div class="card-chart mb-4">
                <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                    <div class="col-2 col-sm-1"><label>Año</label>
                        <input type="number" name="anio_mes" class="form-control form-control-sm" value="<%=anioMes%>"/>
                    </div>
                    <div class="col-3 col-sm-2"><label>Sede</label>
                        <select name="sede_mes" class="form-select form-select-sm">
                            <option value="" <%=sedeMes.isEmpty()?"selected":""%>>Todas</option>
                            <%for(String s:sedesList){%>
                                <option <%=s.equals(sedeMes)?"selected":""%>><%=s%></option>
                            <%}%>
                        </select>
                    </div>
                    <div class="col-2 col-sm-1 align-self-end">
                        <button class="btn btn-sm btn-primary w-100">OK</button>
                    </div>

                    <!-- ocultos -->
                    <input type="hidden" name="mes_sede" value="<%=mesSede%>"><input type="hidden" name="anio_sede" value="<%=anioSede%>">
                    <input type="hidden" name="mes_motivo" value="<%=mesMot%>"><input type="hidden" name="anio_motivo" value="<%=anioMot%>"><input type="hidden" name="sede_motivo" value="<%=sedeMot%>">
                    <input type="hidden" name="mes_estado" value="<%=mesEst%>"><input type="hidden" name="anio_estado" value="<%=anioEst%>"><input type="hidden" name="sede_estado" value="<%=sedeEst%>">
                    <input type="hidden" name="mes_ing" value="<%=mesIng%>"><input type="hidden" name="anio_ing" value="<%=anioIng%>"><input type="hidden" name="sede_ing" value="<%=sedeIng%>">
                </form>
                <h6 class="mt-2">Ingresantes por Mes (<%=anioMes%>) <%=!sedeMes.isEmpty()?"- "+sedeMes:""%></h6>
                <canvas id="chartMes"></canvas>
            </div>

            <!-- ========== GRID 2x2 ========= -->
            <div class="row g-4">
                <!-- Sede -->
                <div class="col-md-6">
                    <div class="card-chart">
                        <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                            <div class="col-4 col-sm-3"><label>Mes</label>
                                <select name="mes_sede" class="form-select form-select-sm">
                                    <%for(int m=1;m<=12;m++){%>
                                        <option value="<%=m%>" <%=m==mesSede?"selected":""%>><%=m%></option>
                                    <%}%>
                                </select>
                            </div>
                            <div class="col-4 col-sm-3"><label>Año</label><input type="number" name="anio_sede" class="form-control form-control-sm" value="<%=anioSede%>"/></div>
                            <div class="col-4 col-sm-3 align-self-end"><button class="btn btn-sm btn-primary w-100">OK</button></div>

                            <!-- ocultos -->
                            <input type="hidden" name="anio_mes" value="<%=anioMes%>"><input type="hidden" name="sede_mes" value="<%=sedeMes%>">
                            <input type="hidden" name="mes_motivo" value="<%=mesMot%>"><input type="hidden" name="anio_motivo" value="<%=anioMot%>"><input type="hidden" name="sede_motivo" value="<%=sedeMot%>">
                            <input type="hidden" name="mes_estado" value="<%=mesEst%>"><input type="hidden" name="anio_estado" value="<%=anioEst%>"><input type="hidden" name="sede_estado" value="<%=sedeEst%>">
                            <input type="hidden" name="mes_ing" value="<%=mesIng%>"><input type="hidden" name="anio_ing" value="<%=anioIng%>"><input type="hidden" name="sede_ing" value="<%=sedeIng%>">
                        </form>
                        <h6 class="mt-2">Ingresantes por Sede (<%=mesSede%>/<%=anioSede%>)</h6>
                        <canvas id="chartSede"></canvas>
                    </div>
                </div>

                <!-- Motivo -->
                <div class="col-md-6">
                    <div class="card-chart">
                        <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                            <div class="col-3"><label>Mes</label>
                                <select name="mes_motivo" class="form-select form-select-sm">
                                    <%for(int m=1;m<=12;m++){%>
                                        <option value="<%=m%>" <%=m==mesMot?"selected":""%>><%=m%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-3"><label>Año</label><input type="number" name="anio_motivo" class="form-control form-control-sm" value="<%=anioMot%>"></div>
                            <div class="col-4"><label>Sede</label>
                                <select name="sede_motivo" class="form-select form-select-sm">
                                    <option value="" <%=sedeMot.isEmpty()?"selected":""%>>Todas</option>
                                    <%for(String s:sedesList){%>
                                        <option <%=s.equals(sedeMot)?"selected":""%>><%=s%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-2 align-self-end"><button class="btn btn-sm btn-primary w-100">OK</button></div>

                            <!-- ocultos -->
                            <input type="hidden" name="anio_mes" value="<%=anioMes%>"><input type="hidden" name="sede_mes" value="<%=sedeMes%>">
                            <input type="hidden" name="mes_sede" value="<%=mesSede%>"><input type="hidden" name="anio_sede" value="<%=anioSede%>">
                            <input type="hidden" name="mes_estado" value="<%=mesEst%>"><input type="hidden" name="anio_estado" value="<%=anioEst%>"><input type="hidden" name="sede_estado" value="<%=sedeEst%>">
                            <input type="hidden" name="mes_ing" value="<%=mesIng%>"><input type="hidden" name="anio_ing" value="<%=anioIng%>"><input type="hidden" name="sede_ing" value="<%=sedeIng%>">
                        </form>
                        <h6 class="mt-2">Ingresantes por Motivo (<%=mesMot%>/<%=anioMot%>) <%=!sedeMot.isEmpty()?"- "+sedeMot:""%></h6>
                        <canvas id="chartMotivo"></canvas>
                    </div>
                </div>

                <!-- Estado -->
                <div class="col-md-6">
                    <div class="card-chart">
                        <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                            <div class="col-3"><label>Mes</label>
                                <select name="mes_estado" class="form-select form-select-sm">
                                    <%for(int m=1;m<=12;m++){%>
                                        <option value="<%=m%>" <%=m==mesEst?"selected":""%>><%=m%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-3"><label>Año</label><input type="number" name="anio_estado" class="form-control form-control-sm" value="<%=anioEst%>"></div>
                            <div class="col-4"><label>Sede</label>
                                <select name="sede_estado" class="form-select form-select-sm">
                                    <option value="" <%=sedeEst.isEmpty()?"selected":""%>>Todas</option>
                                    <%for(String s:sedesList){%>
                                        <option <%=s.equals(sedeEst)?"selected":""%>><%=s%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-2 align-self-end"><button class="btn btn-sm btn-primary w-100">OK</button></div>

                            <!-- ocultos -->
                            <input type="hidden" name="anio_mes" value="<%=anioMes%>"><input type="hidden" name="sede_mes" value="<%=sedeMes%>">
                            <input type="hidden" name="mes_sede" value="<%=mesSede%>"><input type="hidden" name="anio_sede" value="<%=anioSede%>">
                            <input type="hidden" name="mes_motivo" value="<%=mesMot%>"><input type="hidden" name="anio_motivo" value="<%=anioMot%>"><input type="hidden" name="sede_motivo" value="<%=sedeMot%>">
                            <input type="hidden" name="mes_ing" value="<%=mesIng%>"><input type="hidden" name="anio_ing" value="<%=anioIng%>"><input type="hidden" name="sede_ing" value="<%=sedeIng%>">
                        </form>
                        <h6 class="mt-2">Estado de Ingresos (<%=mesEst%>/<%=anioEst%>) <%=!sedeEst.isEmpty()?"- "+sedeEst:""%></h6>
                        <canvas id="chartEstado"></canvas>
                    </div>
                </div>

                <!-- Ingresante -->
                <div class="col-md-6">
                    <div class="card-chart">
                        <form class="row gx-2 gy-1 align-items-end filter-form" method="get">
                            <div class="col-3"><label>Mes</label>
                                <select name="mes_ing" class="form-select form-select-sm">
                                    <%for(int m=1;m<=12;m++){%>
                                        <option value="<%=m%>" <%=m==mesIng?"selected":""%>><%=m%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-3"><label>Año</label><input type="number" name="anio_ing" class="form-control form-control-sm" value="<%=anioIng%>"></div>
                            <div class="col-4"><label>Sede</label>
                                <select name="sede_ing" class="form-select form-select-sm">
                                    <option value="" <%=sedeIng.isEmpty()?"selected":""%>>Todas</option>
                                    <%for(String s:sedesList){%>
                                        <option <%=s.equals(sedeIng)?"selected":""%>><%=s%></option>
                                    <%}%>
                                </select></div>
                            <div class="col-2 align-self-end"><button class="btn btn-sm btn-primary w-100">OK</button></div>

                            <!-- ocultos -->
                            <input type="hidden" name="anio_mes" value="<%=anioMes%>"><input type="hidden" name="sede_mes" value="<%=sedeMes%>">
                            <input type="hidden" name="mes_sede" value="<%=mesSede%>"><input type="hidden" name="anio_sede" value="<%=anioSede%>">
                            <input type="hidden" name="mes_motivo" value="<%=mesMot%>"><input type="hidden" name="anio_motivo" value="<%=anioMot%>"><input type="hidden" name="sede_motivo" value="<%=sedeMot%>">
                            <input type="hidden" name="mes_estado" value="<%=mesEst%>"><input type="hidden" name="anio_estado" value="<%=anioEst%>"><input type="hidden" name="sede_estado" value="<%=sedeEst%>">
                        </form>
                        <h6 class="mt-2">Ingresantes por Tipo (<%=mesIng%>/<%=anioIng%>) <%=!sedeIng.isEmpty()?"- "+sedeIng:""%></h6>
                        <canvas id="chartIngresante"></canvas>
                    </div>
                </div>
            </div><!-- fin grid 2x2 -->
        </div><!-- /.container -->
    </div><!-- /.main-content -->

    <!-- ========= SCRIPTS DE CHARTS (lógica original) ========= -->
    <script>
        const palette=['#003f5c','#2f4b7c','#665191','#8b8cf2','#3c97f2','#17a2b8','#5bc0de','#9ad0ec'];
        const colorAt=i=>palette[i%palette.length];

        /*---- Día ----*/
        const diasLbl=[...Array(<%=daysInMonth%>).keys()].map(i=>i+1);
        const diasVal=[<%for(int i=0;i<daysInMonth;i++){%><%=valoresDia[i]%>,<%}%>];
        new Chart(chartDia,{type:'bar',data:{labels:diasLbl,datasets:[{data:diasVal,backgroundColor:diasLbl.map((_,i)=>colorAt(i))}]},
            options:{plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}});

        /*---- Mes ----*/
        const mesesLbl=["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];
        const mesesVal=[<%for(int i=0;i<12;i++){%><%=mesesValores[i]%>,<%}%>];
        new Chart(chartMes,{type:'line',data:{labels:mesesLbl,datasets:[{data:mesesVal,fill:false,borderColor:'#007bff',tension:.3,pointBackgroundColor:'#007bff'}]},
            options:{plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}});

        /*---- Sede ----*/
        new Chart(chartSede,{type:'bar',data:{labels:[<%for(JsonNode n:dataSede){%>'<%=n.get("sede").asText()%>',<%}%>],
            datasets:[{data:[<%for(JsonNode n:dataSede){%><%=n.get("total_ingresantes").asInt()%>,<%}%>],
            backgroundColor:[<%int i=0;for(JsonNode n:dataSede){%>colorAt(<%=i++%>),<%}%>]}]},
            options:{plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}});

        /*---- Motivo ----*/
        new Chart(chartMotivo,{type:'pie',data:{labels:[<%for(JsonNode n:dataMot){%>'<%=n.get("motivo").asText()%>',<%}%>],
            datasets:[{data:[<%for(JsonNode n:dataMot){%><%=n.get("total").asInt()%>,<%}%>],
            backgroundColor:[<%i=0;for(JsonNode n:dataMot){%>colorAt(<%=i++%>),<%}%>]}]},options:{}});

        /*---- Estado ----*/
        new Chart(chartEstado,{type:'doughnut',data:{labels:[<%for(JsonNode n:dataEst){%>'<%=n.get("estado").asText()%>',<%}%>],
            datasets:[{data:[<%for(JsonNode n:dataEst){%><%=n.get("total").asInt()%>,<%}%>],
            backgroundColor:[<%i=0;for(JsonNode n:dataEst){%>colorAt(<%=i++%>),<%}%>]}]},options:{}});

        /*---- Ingresante ----*/
        new Chart(chartIngresante,{type:'bar',data:{labels:[<%for(JsonNode n:dataIng){%>'<%=n.get("ingresante_detalle").asText()%>',<%}%>],
            datasets:[{data:[<%for(JsonNode n:dataIng){%><%=n.get("total").asInt()%>,<%}%>],
            backgroundColor:[<%i=0;for(JsonNode n:dataIng){%>colorAt(<%=i++%>),<%}%>]}]},
            options:{indexAxis:'y',plugins:{legend:{display:false}},scales:{x:{beginAtZero:true}}}});
    </script>
</body>
</html>
