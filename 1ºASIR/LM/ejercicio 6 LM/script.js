var numeroSecreto = Math.floor(Math.random() * 100) + 1;
var intentos = 0;

function jugar(){

var cajaInput = document.getElementById("numeroCaja");
var numeroUsuario = parseInt(cajaInput.value);

if(isNaN(numeroUsuario) || numeroUsuario < 1 || numeroUsuario > 100){
alert("Introduce un numero entre 1 y 100");
return;
}

intentos++;

var mensaje = document.getElementById("mensaje");
var historial = document.getElementById("historial");
var celda = document.getElementById("intento"+intentos);

historial.innerHTML += numeroUsuario + " ";

celda.innerHTML = "X";
celda.classList.add("intentoHecho");

if(numeroUsuario === numeroSecreto){

mensaje.innerHTML = "HAS ACERTADO";
mensaje.style.background = "limegreen";

document.getElementById("btnJugar").disabled = true;

}

else if(intentos === 10){

mensaje.innerHTML = "HAS PERDIDO. El numero era " + numeroSecreto;
mensaje.style.background = "yellow";

document.getElementById("btnJugar").disabled = true;

}

else if(numeroUsuario > numeroSecreto){

mensaje.innerHTML = numeroUsuario + " ES MAYOR";
mensaje.style.background = "red";

}

else{

mensaje.innerHTML = numeroUsuario + " ES MENOR";
mensaje.style.background = "red";

}

cajaInput.value="";
cajaInput.focus();

}