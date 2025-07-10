document.addEventListener('DOMContentLoaded', function() {
    
    const fileInput = document.getElementById('huellaFile');
    const fileNameDisplay = document.getElementById('fileName');
    const submitBtn = document.getElementById('submitBtn');
    const loading = document.getElementById('loading');
    const errorMessage = document.getElementById('errorMessage');
    const loginForm = document.getElementById('loginForm');

    
    loading.style.display = 'none';
    submitBtn.disabled = true;
    errorMessage.textContent = '';
    fileNameDisplay.textContent = 'No se ha seleccionado ningún archivo';

    
    fileInput.addEventListener('change', function() {
        errorMessage.textContent = '';
        
        if (this.files && this.files.length > 0) {
            const file = this.files[0];
            
            
            if (!file.type.startsWith('image/')) {
                showError('Error: El archivo debe ser una imagen');
                return;
            }

            if (file.size > 5 * 1024 * 1024) { // 5MB máximo
                showError('Error: El archivo es demasiado grande (máx. 5MB)');
                return;
            }

            // nombre del archivo y habilitar botón
            fileNameDisplay.textContent = file.name;
            submitBtn.disabled = false;
        } else {
            fileNameDisplay.textContent = 'No se ha seleccionado ningún archivo';
            submitBtn.disabled = true;
        }
    });

    // funcion para btn de validar
    submitBtn.addEventListener('click', function() {
        if (!fileInput.files || fileInput.files.length === 0) {
            showError('Por favor seleccione un archivo primero');
            return;
        }

        validateFingerprint(fileInput.files[0]);
    });

    //  errores
    function showError(message) {
        errorMessage.textContent = message;
        fileNameDisplay.textContent = 'No se ha seleccionado ningún archivo';
        submitBtn.disabled = true;
    }

    //validar la huella
    function validateFingerprint(file) {
        //  muestra estado de carga
        submitBtn.disabled = true;
        loading.style.display = 'block';
        errorMessage.textContent = '';

        
        const formData = new FormData();
        formData.append('huellaFile', file);

       
        fetch('IdentificacionController', {
            method: 'POST',
            body: formData
        })
        .then(handleResponse)
        .then(handleSuccess)
        .catch(handleError)
        .finally(() => {
            loading.style.display = 'none';
        });
    }

    
    function handleResponse(response) {
        if (!response.ok) {
            throw new Error(`Error del servidor: ${response.status}`);
        }
        return response.json();
    }

   
    function handleSuccess(data) {
       if (data.success && data.redirect) {
            window.location.href = data.redirect;
        } else {
            showError(data.message || 'Huella no reconocida');
        }
    }

    function handleError(error) {
        console.error('Error:', error);
        showError('Error al conectar con el servidor');
    }
});