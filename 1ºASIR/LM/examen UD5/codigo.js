
// 1. Datos
const preguntas = [
    {
        pregunta: "¿Capital de Francia?",
        opciones: ["Madrid", "Paris", "Roma", "Berlín"],
        correcta: 1
    },
    {
        pregunta:"2+2",
        opciones: ["3","4","5","6"],
        correcta:1
    },
    {       
        pregunta:"El mejor equipo del mundo",
        opciones: ["Barcelona","Real Madrid","Bayern","PSG"],
        correcta:1
    },
    {
        pregunta:"67+3",
        opciones: ["71","70","72","73"],
        correcta:1
    },
];

// 2. Variables del estado
let actual = 0
let aciertos = 0
// 3. Elementos del DOM
const progreso = document.getElementById("progreso");
const pregunta = document.getElementById("pregunta");
const opcionesDiv = document.getElementById("opciones");
const btnSig = document.getElementById("btn-siguiente");
const resultado = document.getElementById("resultado");
const puntaje = document.getElementById("puntaje-final");
const btnReiniciar = document.getElementById("btn-reiniciar");
// 2. Variables del estado (FLUJO)
function ponerPregunta(){
    var p = preguntas[actual];
    progreso.innerHTML = "Pregunta " + (actual + 1) + " de 4 ";
    pregunta.innerHTML = p.pregunta;
    opcionesDiv.innerHTML = "";

    btnSig.setAttribute("style", "display: none");

    for (var i = 0; i < p.opciones.length; i++){
        var btn = document.createElement("button");
        btn.innerHTML = p.opciones[i];

        btn.value = i;

        btn.onclick = function(){
            var botones = opcionesDiv.querySelectorAll("button");

            for (var j = 0; j < botones.length; j++){
                botones[j].disabled = true;
            }
            if (this.value == preguntas[actual].correcta){
                this.setAttribute("style", "background: green");
                aciertos++;
            }
            else{
                this.setAttribute("style", "background: red");
                botones[preguntas[actual].correcta].setAttribute("style", "background: green");
            }

            btnSig.setAttribute("style", "display: block");
        };

        opcionesDiv.appendChild(btn);

    }
}

btnSig.onclick = function(){
    actual++;

    if (actual < preguntas.length){
        ponerPregunta();
    }
    else{
    document.getElementById("quiz-container").setAttribute("style", "display: none");
    resultado.setAttribute("style", "display: block");

    puntaje.innerHTML = aciertos + "/ 4 correctas";
    }
};

btnReiniciar.onclick = function(){

actual = 0;
aciertos = 0;
resultado.setAttribute("style", "display: none");
document.getElementById("quiz-container").setAttribute("style", "display: block");
ponerPregunta();

};

ponerPregunta();