# Sistema de Validación de Ingresos – Notas para Entrega Final

Este documento resume las tareas **faltantes**, ideas **opcionales** y recomendaciones **técnicas** que deben ser consideradas para completar y mejorar el sistema de validación de ingresos desarrollado.

---

## ✅ Funcionalidades implementadas hasta ahora

- Validación de identidad mediante huella dactilar.
- Consulta a RENIEC para obtener nombres y apellidos desde un DNI.
- Verificación de pertenencia a la universidad mediante microservicio REST (`/api/validar`).
- Redirección según rol: estudiante, administrador o visita.
- Panel básico para cada tipo de usuario.

---

## 🚧 Funcionalidades pendientes

### 1. Registro de ingresos

- **Debe integrarse el guardado de cada ingreso** exitoso o fallido mediante una llamada POST al siguiente endpoint:

  ```
  https://servicio-utp.fly.dev/api/registros
  ```

- El cuerpo del request debe tener el siguiente formato (no se usan códigos, se validan los datos internamente):

  ```json
  {
    "nombre": "DYLAN AKEMI KCOMT ALVIA",
    "dni": "78943586",
    "ingresante": "Estudiante",
    "motivo": "Docencia",
    "sede": "Ate",
    "fecha": "2025-07-07 18:30:00",
    "estado": "Ingreso Exitoso"
  }
  ```

- Todo ingreso debe considerarse **un nuevo registro** → **siempre insertar, nunca actualizar**.

---

### 2. Lógica para visitas

- Actualmente el sistema redirige a una página con un `combobox` donde se selecciona el **motivo de visita**.
- Falta implementar la lógica que evalúe y **permita o deniegue el ingreso** según el motivo.
- **Cada intento también debe registrarse como ingreso**, incluso si es denegado. En ese caso, registrar como `Ingreso Fallido`.

---

## 💡 Funcionalidades opcionales sugeridas

### Tiempo de bloqueo por ingreso reciente

- Implementar una validación que **restrinja múltiples ingresos consecutivos** por parte de la misma persona en un periodo corto.
- Comparar la hora actual con la última hora de ingreso registrada para ese id que se use.
- Si se activa el bloqueo, mostrar un mensaje y denegar temporalmente el ingreso.
- Idealmente, permitir **configurar este tiempo de espera desde un panel de administración**.

---

## 🧠 Ideas de mejora / expansión

- Explorar **otros puntos del sistema donde podría delegarse lógica a un microservicio**.
  - Si alguien del equipo encuentra una oportunidad clara, discutir si conviene crear un nuevo microservicio o desarrollarlo directamente.
  - Por ejemplo: uno que maneje únicamente los registros de ingreso, otro que controle lógica de bloqueo, etc.
  - Ante cualquier idea me mandan mensaje nomás

---

## 📝 Notas técnicas

- Los registros deben hacerse siempre con `INSERT`, nunca `UPDATE`, incluso si la persona ya ha ingresado antes.
- La validación en el endpoint de registros es por **datos**, no por códigos. Asegurarse de enviar los campos correctamente.
- Validar que los formatos de fecha y hora sean compatibles con el endpoint (`YYYY-MM-DD HH:MM:SS`).
- El campo `estado` puede ser `"Ingreso Exitoso"` o `"Ingreso Fallido"` según corresponda.

---
Si necesitan hacer pruebas mandenme mensaje para levantar el railway para que puedan usar la bd y el microservicio y puedan entrar al sistema eso o entren directamente a uno de los jsps aunque no se si sigue funcionando eso xd. Los servicios de Piero si están funcionando.


Fino chatgpt xdxd
