// Función para manejar el intento de reenviar
function retryForm() {
  // Mostrar una alerta al usuario
  alert("Por favor, revisa los campos y asegúrate de enviar los datos correctamente.");

  // Recargar la página para simular "Intentar de nuevo"
  location.reload();
}

// Función que se ejecuta cuando se envía el formulario
document.getElementById("myForm").addEventListener("submit", function(event) {
  event.preventDefault();  // Evitar que se envíe el formulario por defecto

  // Obtener el valor del campo 'name'
  const nameValue = document.getElementById("name").value;

  // Simular el Error 400 (Bad Request) si el campo 'name' está vacío
  if (!nameValue) {
    // Redireccionar a la página de error 400
    window.location.href = "error_400.html";  // Cambia el nombre de la página si lo necesitas
  } 
  // Simular el Error 500 (Internal Server Error) si el nombre tiene más de 20 caracteres
  else if (nameValue.length > 20) {
    // Redireccionar a la página de error 500
    window.location.href = "error_500.html";  // Cambia el nombre de la página si lo necesitas
  } 
  // Si todo está correcto, mostrar mensaje de éxito y redirigir
  else {
    // Si el formulario es válido, puedes redirigir al usuario a otra página, por ejemplo:
    alert("Formulario enviado correctamente.");
    window.location.href = "success.html";  // Redirecciona a la página de éxito
  }
});
