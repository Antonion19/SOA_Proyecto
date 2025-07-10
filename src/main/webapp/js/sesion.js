function cerrarSesion() {
    fetch('CerrarSesionController', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        credentials: 'include' 
    }).then(response => {
        if(response.ok) {
            return response.json();
        }
        throw new Error('Error en la respuesta');
    }).then(data => {
        window.location.href = "identificacion.jsp";
    }).catch(error => {
        console.error('Error al cerrar sesión:', error);
        
        window.location.href = "identificacion.jsp";
    });
}

