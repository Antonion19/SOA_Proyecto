<div class="user-profile">
            
           
            <img src="img/logoutpazul_1.png"">
            <!-- 
            <button class="toggle-btn" onclick="toggleSidebar()">
                <i class="fas fa-chevron-right"></i>
            </button>  --> 
        </div>
        
        <div class="menu">
            <div class="menu-section">
                <!--  <div class="section-title">INICIO</div> --> 
                
                <div class="menu-item" onclick="toggleSidebar()">
                    <i class="fa-solid fa-bars"></i>
                </div>
                
                <div class="menu-item" onclick="window.location.href='dash.jsp'">
                    <i class="fas fa-th-large"></i>  
                    <span class="menu-item-text">Dashboard</span>
                </div>
                
                <div class="menu-item" onclick="window.location.href='Registro_1.jsp'">
                    <i class="fas fa-user-plus"></i>
                    <span class="menu-item-text">Registro</span>
                    
                </div>
                <div class="menu-item" onclick="window.location.href='CRUD1.1.jsp'">
                    <i class="fas fa-database"></i>
                    <span class="menu-item-text">CRUD</span>
                   
                </div>
                <div class="menu-item" onclick="window.location.href='Historial.jsp'">
                    <i class="fas fa-history"></i>
                    <span class="menu-item-text">Historial</span>
                </div>
            </div>
            
            
            <div class="menu-section">
                
                <div class="menu-item" onclick="cerrarSesion()">
                    <i class="fas fa-sign-out-alt"></i>
                    <span class="menu-item-text">Cerrar Sesión</span>
                </div>
                
            </div>
        </div>