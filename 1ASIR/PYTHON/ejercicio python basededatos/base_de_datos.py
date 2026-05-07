"""
╔══════════════════════════════════════════════════════════════════╗
║           PyOS - Simulador Educativo de Sistema Operativo        ║
║                    Aprende cómo funciona un SO                   ║
╚══════════════════════════════════════════════════════════════════╝
Ejecutar: python simulador_so.py
"""

import time
import random
import threading
import queue
from collections import deque
from datetime import datetime

# ─────────────────────────── COLORES ANSI ──────────────────────────────

class Color:
    RESET   = "\033[0m"
    BOLD    = "\033[1m"
    RED     = "\033[91m"
    GREEN   = "\033[92m"
    YELLOW  = "\033[93m"
    BLUE    = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN    = "\033[96m"
    WHITE   = "\033[97m"
    BG_BLUE = "\033[44m"
    BG_GREEN= "\033[42m"

def c(text, color):
    return f"{color}{text}{Color.RESET}"

# ══════════════════════════════════════════════════════════════════════
#  1. BOOTLOADER
# ══════════════════════════════════════════════════════════════════════

class Bootloader:
    """Simula el proceso de arranque del sistema."""

    BIOS_CHECKS = [
        ("CPU",              "Intel x86-64 @ 2.4 GHz detectado"),
        ("RAM",              "4096 MB encontrados"),
        ("Disco",            "HDD virtual de 512 MB"),
        ("Teclado",          "Controlador PS/2 OK"),
        ("Pantalla",         "Modo VGA 80x25"),
        ("BIOS",             "Versión 2.0 — PyOS BIOS"),
    ]

    def run(self):
        print(c("\n╔══════════════════════════════════════╗", Color.CYAN))
        print(c("║        PyOS BIOS v2.0                ║", Color.CYAN))
        print(c("║  Presiona DEL para entrar al setup   ║", Color.CYAN))
        print(c("╚══════════════════════════════════════╝\n", Color.CYAN))
        time.sleep(0.5)

        print(c("[ POST — Power-On Self Test ]", Color.YELLOW))
        for dispositivo, info in self.BIOS_CHECKS:
            time.sleep(0.15)
            print(f"  {c('✔', Color.GREEN)}  {c(dispositivo.ljust(12), Color.WHITE)}{info}")

        print()
        print(c("Buscando dispositivo de arranque...", Color.YELLOW))
        time.sleep(0.4)
        print(f"  {c('✔', Color.GREEN)}  Sector de arranque válido encontrado (0xAA55)")
        print(f"  {c('✔', Color.GREEN)}  Cargando MBR en 0x7C00...")
        time.sleep(0.3)
        print(f"  {c('✔', Color.GREEN)}  Saltando a código del bootloader...\n")
        time.sleep(0.3)

        print(c("[ Bootloader Stage 1 ]", Color.YELLOW))
        pasos = [
            "Cambiando a modo protegido (32-bit)...",
            "Configurando GDT (Global Descriptor Table)...",
            "Habilitando A20 line...",
            "Cargando kernel en memoria (0x100000)...",
            "Saltando al kernel...",
        ]
        for paso in pasos:
            time.sleep(0.2)
            print(f"  {c('→', Color.BLUE)}  {paso}")

        print()
        time.sleep(0.3)

# ══════════════════════════════════════════════════════════════════════
#  2. GESTOR DE MEMORIA
# ══════════════════════════════════════════════════════════════════════

class GestorMemoria:
    """
    Simula un gestor de memoria con:
    - Bloques de memoria física
    - Asignación y liberación (First Fit)
    - Paginación básica
    """
    TAMANIO_TOTAL = 256  # MB simulados
    TAMANIO_PAGINA = 4   # KB por página

    def __init__(self):
        # Cada bloque: [inicio_MB, tamanio_MB, libre, propietario]
        self.bloques = [
            [0,   8,  False, "Kernel"],
            [8,   4,  False, "Drivers"],
            [12,  4,  False, "Stack Kernel"],
            [16, 240,  True,  None],
        ]
        self.paginas_totales = (self.TAMANIO_TOTAL * 1024) // self.TAMANIO_PAGINA
        self.paginas_usadas  = 12 * 1024 // self.TAMANIO_PAGINA  # kernel usa 12 MB
        self.tabla_paginas   = {}  # pid -> lista de páginas

    def _libre_mb(self):
        return sum(b[1] for b in self.bloques if b[2])

    def asignar(self, pid, nombre, mb_necesarios):
        """Algoritmo First Fit."""
        for bloque in self.bloques:
            inicio, tamanio, libre, _ = bloque
            if libre and tamanio >= mb_necesarios:
                # Asignar
                bloque[2] = False
                bloque[3] = nombre
                sobrante = tamanio - mb_necesarios
                bloque[1] = mb_necesarios
                if sobrante > 0:
                    # Fragmento libre sobrante
                    self.bloques.append([inicio + mb_necesarios, sobrante, True, None])
                    self.bloques.sort(key=lambda x: x[0])
                # Asignar páginas
                paginas = (mb_necesarios * 1024) // self.TAMANIO_PAGINA
                self.tabla_paginas[pid] = list(range(
                    self.paginas_usadas, self.paginas_usadas + paginas))
                self.paginas_usadas += paginas
                return True
        return False

    def liberar(self, pid, nombre):
        for bloque in self.bloques:
            if bloque[3] == nombre:
                bloque[2] = True
                bloque[3] = None
                self.tabla_paginas.pop(pid, None)
                paginas = (bloque[1] * 1024) // self.TAMANIO_PAGINA
                self.paginas_usadas -= paginas
                self._fusionar_bloques()
                return True
        return False

    def _fusionar_bloques(self):
        """Une bloques libres adyacentes (desfragmentación)."""
        i = 0
        while i < len(self.bloques) - 1:
            b1, b2 = self.bloques[i], self.bloques[i+1]
            if b1[2] and b2[2]:
                b1[1] += b2[1]
                self.bloques.pop(i+1)
            else:
                i += 1

    def estado(self):
        libre = self._libre_mb()
        usado = self.TAMANIO_TOTAL - libre
        pct   = int((usado / self.TAMANIO_TOTAL) * 30)
        barra = c("█" * pct, Color.GREEN) + c("░" * (30-pct), Color.WHITE)

        print(c("\n┌─── Estado de Memoria ────────────────────┐", Color.CYAN))
        print(f"│  Total : {self.TAMANIO_TOTAL} MB   "
              f"Usado: {c(str(usado)+'MB', Color.YELLOW)}   "
              f"Libre: {c(str(libre)+'MB', Color.GREEN)}")
        print(f"│  [{barra}]")
        print(c("├──────────────────────────────────────────┤", Color.CYAN))
        print(f"│  {'Inicio':>6} {'Tamaño':>8} {'Estado':>8}  Propietario")
        print(c("├──────────────────────────────────────────┤", Color.CYAN))
        for b in self.bloques:
            estado_txt = c("LIBRE", Color.GREEN) if b[2] else c("USADO", Color.RED)
            prop = b[3] or "-"
            print(f"│  {str(b[0])+'MB':>6} {str(b[1])+'MB':>8} {estado_txt:>18}  {prop}")
        print(c("└──────────────────────────────────────────┘", Color.CYAN))


# ══════════════════════════════════════════════════════════════════════
#  3. PROCESO
# ══════════════════════════════════════════════════════════════════════

ESTADOS = ["LISTO", "EJECUTANDO", "BLOQUEADO", "TERMINADO"]

class Proceso:
    _contador = 1

    def __init__(self, nombre, prioridad=1, tiempo_cpu=5, memoria_mb=8):
        self.pid        = Proceso._contador
        Proceso._contador += 1
        self.nombre     = nombre
        self.prioridad  = prioridad          # 1=baja, 3=alta
        self.tiempo_cpu = tiempo_cpu         # ráfagas de CPU necesarias
        self.tiempo_restante = tiempo_cpu
        self.memoria_mb = memoria_mb
        self.estado     = "LISTO"
        self.creado_en  = datetime.now().strftime("%H:%M:%S")
        self.cpu_usado  = 0

    def __repr__(self):
        col = {
            "LISTO":     Color.YELLOW,
            "EJECUTANDO":Color.GREEN,
            "BLOQUEADO": Color.RED,
            "TERMINADO": Color.WHITE,
        }.get(self.estado, Color.WHITE)
        return (f"PID {self.pid:>3} | {self.nombre:<16} | "
                f"Prio:{self.prioridad} | "
                f"CPU:{self.tiempo_restante:>2}/{self.tiempo_cpu} | "
                f"{c(self.estado, col)}")


# ══════════════════════════════════════════════════════════════════════
#  4. PLANIFICADOR (SCHEDULER)
# ══════════════════════════════════════════════════════════════════════

class Planificador:
    """
    Implementa tres algoritmos:
      - Round Robin
      - FCFS (First Come First Served)
      - Prioridad (no expulsivo)
    """
    QUANTUM = 2  # ticks por turno en Round Robin

    def __init__(self, gestor_mem):
        self.cola_listos    = deque()
        self.procesos       = {}      # pid -> Proceso
        self.proceso_actual = None
        self.gestor_mem     = gestor_mem
        self.tick           = 0
        self.algoritmo      = "RR"    # RR | FCFS | PRIORIDAD
        self.historial      = []

    def crear_proceso(self, nombre, prioridad=1, tiempo_cpu=None, memoria_mb=8):
        if tiempo_cpu is None:
            tiempo_cpu = random.randint(3, 10)
        p = Proceso(nombre, prioridad, tiempo_cpu, memoria_mb)
        ok = self.gestor_mem.asignar(p.pid, nombre, memoria_mb)
        if not ok:
            print(c(f"  ✘ Sin memoria para '{nombre}'", Color.RED))
            return None
        self.procesos[p.pid] = p
        self.cola_listos.append(p)
        print(f"  {c('✔', Color.GREEN)} Proceso creado: {p}")
        return p

    def terminar_proceso(self, pid):
        if pid in self.procesos:
            p = self.procesos[pid]
            p.estado = "TERMINADO"
            self.gestor_mem.liberar(p.pid, p.nombre)
            del self.procesos[pid]
            self.cola_listos = deque(x for x in self.cola_listos if x.pid != pid)
            print(f"  {c('✔', Color.GREEN)} Proceso PID {pid} terminado.")
            return True
        print(c(f"  ✘ PID {pid} no encontrado.", Color.RED))
        return False

    def _siguiente_rr(self):
        if self.cola_listos:
            return self.cola_listos.popleft()
        return None

    def _siguiente_fcfs(self):
        # El primer elemento es el más antiguo
        if self.cola_listos:
            return self.cola_listos.popleft()
        return None

    def _siguiente_prioridad(self):
        if not self.cola_listos:
            return None
        mejor = max(self.cola_listos, key=lambda p: p.prioridad)
        self.cola_listos.remove(mejor)
        return mejor

    def tick_cpu(self):
        """Ejecuta un ciclo de CPU (un tick)."""
        self.tick += 1

        # Seleccionar proceso si no hay uno ejecutando
        if self.proceso_actual is None or self.proceso_actual.estado == "TERMINADO":
            if   self.algoritmo == "RR":        self.proceso_actual = self._siguiente_rr()
            elif self.algoritmo == "FCFS":      self.proceso_actual = self._siguiente_fcfs()
            elif self.algoritmo == "PRIORIDAD": self.proceso_actual = self._siguiente_prioridad()

        if self.proceso_actual is None:
            print(c(f"  Tick {self.tick:>3}: CPU idle (sin procesos)", Color.WHITE))
            return

        p = self.proceso_actual
        p.estado = "EJECUTANDO"
        p.tiempo_restante -= 1
        p.cpu_usado += 1

        self.historial.append(f"T{self.tick}:{p.nombre[:6]}")

        print(f"  {c(f'Tick {self.tick:>3}', Color.CYAN)}: "
              f"{c(p.nombre, Color.GREEN)} ejecuta — "
              f"restante: {p.tiempo_restante} ticks")

        if p.tiempo_restante <= 0:
            p.estado = "TERMINADO"
            self.gestor_mem.liberar(p.pid, p.nombre)
            del self.procesos[p.pid]
            print(f"           {c('→ TERMINADO', Color.YELLOW)} ✔")
            self.proceso_actual = None
        elif self.algoritmo == "RR" and p.cpu_usado % self.QUANTUM == 0:
            # Quantum agotado → vuelve a la cola
            p.estado = "LISTO"
            self.cola_listos.append(p)
            self.proceso_actual = None

    def listar_procesos(self):
        todos = list(self.procesos.values())
        if not todos:
            print(c("  (Sin procesos activos)", Color.WHITE))
            return
        print(c("\n┌─── Tabla de Procesos ─────────────────────────────────────────┐", Color.CYAN))
        for p in todos:
            print(f"│  {p}")
        print(c("└───────────────────────────────────────────────────────────────┘", Color.CYAN))

    def diagrama_gantt(self):
        if not self.historial:
            print(c("  Sin historial de ejecución.", Color.WHITE))
            return
        print(c("\n┌─── Diagrama de Gantt ──────────────────────────────────────────┐", Color.CYAN))
        linea = "│  " + " | ".join(c(h, Color.GREEN) for h in self.historial[-20:])
        print(linea)
        print(c("└───────────────────────────────────────────────────────────────┘", Color.CYAN))


# ══════════════════════════════════════════════════════════════════════
#  5. SISTEMA DE ARCHIVOS (FAT simplificado)
# ══════════════════════════════════════════════════════════════════════

class SistemaArchivos:
    """Sistema de archivos tipo FAT en memoria."""

    def __init__(self):
        self.directorio_actual = "/"
        # Árbol: dict de rutas -> {"tipo": "dir"|"file", "contenido": str|dict}
        self.arbol = {
            "/": {"tipo": "dir", "hijos": {
                "bin":  {"tipo": "dir", "hijos": {
                    "shell": {"tipo": "file", "contenido": "#!/bin/sh\n# Shell principal", "tamanio": 32},
                    "ls":    {"tipo": "file", "contenido": "binary", "tamanio": 128},
                }},
                "etc":  {"tipo": "dir", "hijos": {
                    "os.conf": {"tipo": "file", "contenido": "version=PyOS-1.0\nkeyboard=es", "tamanio": 40},
                }},
                "home": {"tipo": "dir", "hijos": {
                    "usuario": {"tipo": "dir", "hijos": {}},
                }},
                "tmp":  {"tipo": "dir", "hijos": {}},
            }}
        }

    def _nodo_actual(self):
        partes = [p for p in self.directorio_actual.split("/") if p]
        nodo = self.arbol["/"]
        for parte in partes:
            nodo = nodo["hijos"][parte]
        return nodo

    def ls(self):
        nodo = self._nodo_actual()
        if not nodo["hijos"]:
            print(c("  (directorio vacío)", Color.WHITE))
            return
        for nombre, info in nodo["hijos"].items():
            if info["tipo"] == "dir":
                print(f"  {c('📁', '')} {c(nombre+'/', Color.BLUE)}")
            else:
                tam = info.get("tamanio", len(info.get("contenido","")))
                print(f"  {c('📄', '')} {nombre:<20} {tam} bytes")

    def cd(self, destino):
        if destino == "..":
            if self.directorio_actual != "/":
                self.directorio_actual = "/".join(self.directorio_actual.rstrip("/").split("/")[:-1]) or "/"
            return
        if destino == "/":
            self.directorio_actual = "/"
            return
        nodo = self._nodo_actual()
        if destino in nodo.get("hijos", {}) and nodo["hijos"][destino]["tipo"] == "dir":
            sep = "" if self.directorio_actual.endswith("/") else "/"
            self.directorio_actual = self.directorio_actual + sep + destino
        else:
            print(c(f"  cd: '{destino}': No es un directorio", Color.RED))

    def cat(self, nombre):
        nodo = self._nodo_actual()
        if nombre in nodo.get("hijos", {}):
            f = nodo["hijos"][nombre]
            if f["tipo"] == "file":
                print(c(f.get("contenido", ""), Color.WHITE))
            else:
                print(c(f"  cat: '{nombre}' es un directorio", Color.RED))
        else:
            print(c(f"  cat: '{nombre}': No existe", Color.RED))

    def touch(self, nombre, contenido=""):
        nodo = self._nodo_actual()
        nodo["hijos"][nombre] = {"tipo":"file","contenido":contenido,"tamanio":len(contenido)}
        print(f"  {c('✔', Color.GREEN)} Archivo '{nombre}' creado.")

    def mkdir(self, nombre):
        nodo = self._nodo_actual()
        if nombre in nodo["hijos"]:
            print(c(f"  mkdir: '{nombre}' ya existe", Color.RED))
        else:
            nodo["hijos"][nombre] = {"tipo":"dir","hijos":{}}
            print(f"  {c('✔', Color.GREEN)} Directorio '{nombre}' creado.")

    def rm(self, nombre):
        nodo = self._nodo_actual()
        if nombre in nodo.get("hijos", {}):
            del nodo["hijos"][nombre]
            print(f"  {c('✔', Color.GREEN)} '{nombre}' eliminado.")
        else:
            print(c(f"  rm: '{nombre}': No existe", Color.RED))

    def pwd(self):
        print(c(f"  {self.directorio_actual}", Color.WHITE))


# ══════════════════════════════════════════════════════════════════════
#  6. MANEJADOR DE INTERRUPCIONES
# ══════════════════════════════════════════════════════════════════════

class ManejadorInterrupciones:
    """Simula la IDT y el manejo de interrupciones del hardware."""

    INTERRUPCIONES = {
        0x00: ("División por cero",       "EXCEPCIÓN"),
        0x06: ("Opcode inválido",          "EXCEPCIÓN"),
        0x0E: ("Page fault",               "EXCEPCIÓN"),
        0x20: ("Timer IRQ0",               "HARDWARE"),
        0x21: ("Teclado IRQ1",             "HARDWARE"),
        0x2E: ("HDD IRQ14",                "HARDWARE"),
        0x80: ("Syscall (int 0x80)",       "SOFTWARE"),
    }

    def __init__(self):
        self.contadores = {k: 0 for k in self.INTERRUPCIONES}

    def disparar(self, numero):
        if numero not in self.INTERRUPCIONES:
            print(c(f"  INT 0x{numero:02X}: Interrupción desconocida", Color.RED))
            return
        desc, tipo = self.INTERRUPCIONES[numero]
        self.contadores[numero] += 1
        col = Color.RED if tipo == "EXCEPCIÓN" else Color.GREEN
        print(f"  {c(f'INT 0x{numero:02X}', Color.CYAN)} [{c(tipo, col)}] → {desc} "
              f"(disparada {self.contadores[numero]}x)")

    def listar(self):
        print(c("\n┌─── Tabla de Interrupciones (IDT) ──────────────────────────────┐", Color.CYAN))
        print(f"│  {'Vector':>8}  {'Tipo':<12} {'Descripción':<30} {'Disparos':>8}")
        print(c("├────────────────────────────────────────────────────────────────┤", Color.CYAN))
        for num, (desc, tipo) in self.INTERRUPCIONES.items():
            col = Color.RED if tipo == "EXCEPCIÓN" else Color.GREEN
            cnt = self.contadores[num]
            print(f"│  {c(f'0x{num:02X}',Color.CYAN):>14}  {c(tipo,col):<22} {desc:<30} {cnt:>8}")
        print(c("└────────────────────────────────────────────────────────────────┘", Color.CYAN))


# ══════════════════════════════════════════════════════════════════════
#  7. SHELL INTERACTIVA
# ══════════════════════════════════════════════════════════════════════

AYUDA = f"""
{c('Comandos del Sistema', Color.BOLD+Color.CYAN)}
{c('─'*50, Color.CYAN)}

{c('━━ PROCESOS ━━', Color.YELLOW)}
  ps                        Lista procesos activos
  run <nombre> [prio] [mb]  Crea un nuevo proceso
  kill <pid>                Termina un proceso
  tick [n]                  Ejecuta n ciclos de CPU (default: 1)
  algoritmo <RR|FCFS|PRIORIDAD>  Cambia el planificador
  gantt                     Muestra diagrama de Gantt

{c('━━ MEMORIA ━━', Color.YELLOW)}
  mem                       Estado de la memoria RAM

{c('━━ ARCHIVOS ━━', Color.YELLOW)}
  ls                        Lista el directorio actual
  cd <dir>                  Cambia de directorio
  pwd                       Ruta actual
  cat <archivo>             Muestra contenido
  touch <nombre> [texto]    Crea un archivo
  mkdir <nombre>            Crea un directorio
  rm <nombre>               Elimina un archivo/directorio

{c('━━ INTERRUPCIONES ━━', Color.YELLOW)}
  idt                       Lista la tabla de interrupciones
  int <hex>                 Dispara una interrupción (ej: int 21)

{c('━━ SISTEMA ━━', Color.YELLOW)}
  info                      Información del sistema
  clear                     Limpia la pantalla
  ayuda                     Muestra esta ayuda
  exit / apagar             Apaga el sistema
"""

class Shell:
    def __init__(self):
        self.mem       = GestorMemoria()
        self.sched     = Planificador(self.mem)
        self.fs        = SistemaArchivos()
        self.idt       = ManejadorInterrupciones()
        self.arranque  = datetime.now()

    def _prompt(self):
        usuario = c("root", Color.RED)
        host    = c("pyos", Color.GREEN)
        ruta    = c(self.fs.directorio_actual, Color.BLUE)
        return f"\n{usuario}@{host}:{ruta}$ "

    def info(self):
        uptime = str(datetime.now() - self.arranque).split(".")[0]
        n_procs = len(self.sched.procesos)
        libre = self.mem._libre_mb()
        print(c("""
┌─── PyOS — Información del Sistema ───────────────────────┐""", Color.CYAN))
        print(f"│  SO       : PyOS 1.0 (Simulador Educativo)")
        print(f"│  Kernel   : monolítico, 32-bit")
        print(f"│  Uptime   : {uptime}")
        print(f"│  Procesos : {n_procs} activos")
        print(f"│  RAM libre: {libre} MB / {self.mem.TAMANIO_TOTAL} MB")
        print(f"│  Planif.  : {self.sched.algoritmo}")
        print(f"│  FS       : PyFAT (memoria)")
        print(c("└──────────────────────────────────────────────────────────┘", Color.CYAN))

    def ejecutar(self, linea):
        partes = linea.strip().split()
        if not partes:
            return True
        cmd, args = partes[0].lower(), partes[1:]

        # ── PROCESOS ──
        if cmd == "ps":
            self.sched.listar_procesos()

        elif cmd == "run":
            nombre = args[0] if args else f"proc_{random.randint(10,99)}"
            prio   = int(args[1]) if len(args) > 1 else 1
            mb     = int(args[2]) if len(args) > 2 else random.randint(4, 32)
            self.sched.crear_proceso(nombre, prio, memoria_mb=mb)

        elif cmd == "kill":
            if not args:
                print(c("  Uso: kill <pid>", Color.RED)); return True
            self.sched.terminar_proceso(int(args[0]))

        elif cmd == "tick":
            n = int(args[0]) if args else 1
            print(c(f"\n  ─── Ejecutando {n} tick(s) de CPU ───", Color.YELLOW))
            for _ in range(n):
                self.sched.tick_cpu()
                self.idt.disparar(0x20)   # Simula interrupción del timer

        elif cmd == "algoritmo":
            if not args or args[0].upper() not in ("RR", "FCFS", "PRIORIDAD"):
                print(c("  Uso: algoritmo <RR|FCFS|PRIORIDAD>", Color.RED)); return True
            self.sched.algoritmo = args[0].upper()
            print(f"  {c('✔', Color.GREEN)} Planificador cambiado a {self.sched.algoritmo}")

        elif cmd == "gantt":
            self.sched.diagrama_gantt()

        # ── MEMORIA ──
        elif cmd == "mem":
            self.mem.estado()

        # ── ARCHIVOS ──
        elif cmd == "ls":
            self.fs.ls()

        elif cmd == "cd":
            destino = args[0] if args else "/"
            self.fs.cd(destino)

        elif cmd == "pwd":
            self.fs.pwd()

        elif cmd == "cat":
            if not args:
                print(c("  Uso: cat <archivo>", Color.RED)); return True
            self.fs.cat(args[0])

        elif cmd == "touch":
            if not args:
                print(c("  Uso: touch <nombre> [texto]", Color.RED)); return True
            contenido = " ".join(args[1:])
            self.fs.touch(args[0], contenido)

        elif cmd == "mkdir":
            if not args:
                print(c("  Uso: mkdir <nombre>", Color.RED)); return True
            self.fs.mkdir(args[0])

        elif cmd == "rm":
            if not args:
                print(c("  Uso: rm <nombre>", Color.RED)); return True
            self.fs.rm(args[0])

        # ── INTERRUPCIONES ──
        elif cmd == "idt":
            self.idt.listar()

        elif cmd == "int":
            if not args:
                print(c("  Uso: int <hex>  (ej: int 21)", Color.RED)); return True
            try:
                num = int(args[0], 16)
                self.idt.disparar(num)
            except ValueError:
                print(c("  Número hexadecimal inválido", Color.RED))

        # ── SISTEMA ──
        elif cmd == "info":
            self.info()

        elif cmd == "ayuda":
            print(AYUDA)

        elif cmd == "clear":
            print("\033c", end="")

        elif cmd in ("exit", "apagar", "shutdown"):
            print(c("\n  Apagando PyOS...", Color.YELLOW))
            time.sleep(0.3)
            print(c("  ¡Hasta luego!\n", Color.GREEN))
            return False

        else:
            print(c(f"  Comando no reconocido: '{cmd}'. Escribe 'ayuda'.", Color.RED))

        return True

    def iniciar(self):
        # Arranque
        bl = Bootloader()
        bl.run()

        print(c("""
██████╗ ██╗   ██╗ ██████╗ ███████╗
██╔══██╗╚██╗ ██╔╝██╔═══██╗██╔════╝
██████╔╝ ╚████╔╝ ██║   ██║███████╗
██╔═══╝   ╚██╔╝  ██║   ██║╚════██║
██║        ██║   ╚██████╔╝███████║
╚═╝        ╚═╝    ╚═════╝ ╚══════╝
        Simulador Educativo de SO
""", Color.CYAN))

        print(c("  Inicializando subsistemas...", Color.YELLOW))
        time.sleep(0.2)
        sistemas = [
            "Gestor de Memoria    ✔",
            "Planificador (RR)    ✔",
            "Sistema de Archivos  ✔",
            "Manejador IDT        ✔",
            "Shell interactiva    ✔",
        ]
        for s in sistemas:
            time.sleep(0.1)
            print(f"  {c(s, Color.GREEN)}")

        # Procesos iniciales del sistema
        print(c("\n  Iniciando procesos del sistema...", Color.YELLOW))
        time.sleep(0.2)
        self.sched.crear_proceso("init",   prioridad=3, tiempo_cpu=99, memoria_mb=4)
        self.sched.crear_proceso("daemon", prioridad=2, tiempo_cpu=99, memoria_mb=8)

        print(c("\n  Sistema listo. Escribe 'ayuda' para ver los comandos.\n", Color.GREEN))

        # Bucle principal de la shell
        while True:
            try:
                entrada = input(self._prompt())
                continuar = self.ejecutar(entrada)
                if not continuar:
                    break
            except (KeyboardInterrupt, EOFError):
                print(c("\n  Usa 'exit' para apagar el sistema.", Color.YELLOW))


# ══════════════════════════════════════════════════════════════════════
#  PUNTO DE ENTRADA
# ══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    shell = Shell()
    shell.iniciar()