// --- script1.js (Modificado) ---
document.addEventListener('DOMContentLoaded', () => {
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('fileInput');
    const previewImage = document.getElementById('previewImage');
    const processBtn = document.getElementById('processBtn');
    const progressContainer = document.getElementById('progressContainer');
    const progressBar = document.getElementById('progressBar');
    const progressText = document.getElementById('progressText');
    const hashDisplay = document.getElementById('hashDisplay');

    const documentoInput = document.getElementById('documento');
    const prenombresInput = document.getElementById('prenombres');
    const paternoInput = document.getElementById('paterno');
    const maternoInput = document.getElementById('materno');
    const searchDniBtn = document.getElementById('searchDniBtn');
    const imageHashInput = document.getElementById('imageHash');

    let generatedHash = '';

    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.style.backgroundColor = '#f0f8ff';
    });

    uploadArea.addEventListener('dragleave', () => {
        uploadArea.style.backgroundColor = 'transparent';
    });

    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.style.backgroundColor = 'transparent';
        if (e.dataTransfer.files.length) {
            fileInput.files = e.dataTransfer.files;
            showPreview();
        }
    });

    fileInput.addEventListener('change', showPreview);

    function showPreview() {
        const file = fileInput.files[0];
        if (file && file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = (e) => {
                previewImage.src = e.target.result;
                previewImage.style.display = 'block';
                processBtn.disabled = false;
                hashDisplay.textContent = '';
                generatedHash = '';
                imageHashInput.value = '';
                resetFormFields();
            };
            reader.readAsDataURL(file);
        }
    }

    processBtn.addEventListener('click', () => {
        const file = fileInput.files[0];
        if (!file) {
            alert("Por favor seleccione un archivo primero.");
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            alert("El archivo es demasiado grande. Máximo 5MB permitido.");
            return;
        }

        progressContainer.style.display = 'block';
        processBtn.disabled = true;
        processBtn.textContent = "Generando Hash...";
        progressBar.style.width = '0%';
        progressText.textContent = '0%';

        const formData = new FormData();
        formData.append('file', file);
        // *** CAMBIO CLAVE AQUÍ: AÑADE EL PARÁMETRO 'action' AL FormData ***
        formData.append('action', 'generateHash'); 

        fetch('ValidacionController2', { // Ya no es necesario poner '?action=generateHash' en la URL
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.success && data.imageHash) {
                generatedHash = data.imageHash;
                imageHashInput.value = generatedHash;
                hashDisplay.textContent = `Hash de la huella: ${generatedHash.substring(0, 30)}...`;
                alert("Hash de huella generado correctamente.");
            } else {
                alert(data.message || "Error al generar el hash de la huella.");
            }
        })
        .catch(error => {
            console.error('Error detallado al generar hash:', error);
            alert("Error en la conexión al generar hash: " + error.message);
        })
        .finally(() => {
            progressContainer.style.display = 'none';
            processBtn.disabled = false;
            processBtn.textContent = "Generar Hash de Huella";
        });
    });

    function resetFormFields() {
        setValueIfExists('prenombres', '');
        setValueIfExists('paterno', '');
        setValueIfExists('materno', '');
    }

    searchDniBtn.addEventListener('click', () => {
        const dni = documentoInput.value.trim();
        if (!dni) {
            alert("Por favor, ingrese un número de documento para buscar.");
            return;
        }
        if (!/^\d{8}$/.test(dni)) {
            alert("El número de documento debe ser de 8 dígitos numéricos.");
            return;
        }

        searchDniBtn.disabled = true;
        searchDniBtn.textContent = "Buscando...";
        resetFormFields();

        fetch(`ValidacionController2?action=searchDni&dni=${dni}`, {
            method: 'GET'
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                setValueIfExists('prenombres', data.prenombres);
                setValueIfExists('paterno', data.paterno);
                setValueIfExists('materno', data.materno);
                alert("Datos de DNI cargados correctamente.");
            } else {
                alert(data.message || "No se encontraron datos para el DNI ingresado en RENIEC.");
                resetFormFields();
            }
        })
        .catch(error => {
            console.error('Error detallado al buscar DNI:', error);
            alert("Error en la conexión al buscar DNI: " + error.message);
            resetFormFields();
        })
        .finally(() => {
            searchDniBtn.disabled = false;
            searchDniBtn.textContent = "Buscar DNI";
        });
    });

    function setValueIfExists(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.value = value || '';
        } else {
            console.error(`Elemento con ID '${id}' no encontrado`);
        }
    }

    const validacionForm = document.getElementById('validacionForm');
    validacionForm.addEventListener('submit', (e) => {
        e.preventDefault();

        const documento = documentoInput.value.trim();
        const hash = imageHashInput.value.trim();

        if (!documento || !hash) {
            alert("Por favor, genere el hash de la huella y/o ingrese el número de documento antes de registrar.");
            return;
        }

        const formData = new FormData();
        formData.append('documento', documento);
        formData.append('imageHash', hash);
        // *** CAMBIO CLAVE AQUÍ: AÑADE EL PARÁMETRO 'action' AL FormData para el registro ***
        formData.append('action', 'registerHuella'); 

        const submitBtn = validacionForm.querySelector('.submit-btn');
        submitBtn.disabled = true;
        submitBtn.textContent = "Registrando...";

        fetch('ValidacionController2', { // Ya no es necesario poner '?action=registerHuella' en la URL
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                alert("Huella registrada exitosamente en la base de datos.");
                validacionForm.reset();
                previewImage.style.display = 'none';
                hashDisplay.textContent = '';
                generatedHash = '';
                imageHashInput.value = '';
                processBtn.disabled = true;
            } else {
                alert(data.message || "Error al registrar la huella.");
            }
        })
        .catch(error => {
            console.error('Error detallado al registrar huella:', error);
            alert("Error en la conexión al registrar huella: " + error.message);
        })
        .finally(() => {
            submitBtn.disabled = false;
            submitBtn.textContent = "Registrar";
        });
    });
});