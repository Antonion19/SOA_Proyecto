<%@ page session="true" %>
<div class="header-content">
    <div class="titulo-left">
        <h1 style="
        font-size: 1.5rem;
        font-weight: bold;
        font-family: 'Segoe UI';
        margin-left: 0.9%;
        margin-top: 0.4%;
    ">Universidad Tecnológica del Perú</h1>
        
    </div>
    
    <div class="header-user-info">
        
        <div class="header-user-details">
            <div class="header-user-name">
                <%= session.getAttribute("nombreCompleto") != null ? session.getAttribute("nombreCompleto") : "Invitado" %>
            </div>
            <div class="header-user-role">
                <%= session.getAttribute("rol") != null ? session.getAttribute("rol") : "Sin rol" %>
            </div>
        </div>
        <div class="header-profile-pic">
            <%= session.getAttribute("nombreCompleto") != null ? session.getAttribute("nombreCompleto").toString().substring(0, 1).toUpperCase() : "U" %>
        </div>
    </div>
</div>