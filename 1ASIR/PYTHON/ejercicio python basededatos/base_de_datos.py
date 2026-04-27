import sqlite3
from contextlib import contextmanager
from datetime import date

DB = "ministerio_naval.db"


@contextmanager
def db():
    con = sqlite3.connect(DB)
    try:
        yield con.cursor()
        con.commit()
    finally:
        con.close()


# ── Crear tablas ──────────────────────────────────────────────────────────────

def crear_bd():
    with db() as cur:
        cur.executescript("""
            CREATE TABLE IF NOT EXISTS naves (
                id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,
                tipo TEXT, año_construccion INTEGER, epoca TEXT);
            CREATE TABLE IF NOT EXISTS agentes (
                id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,
                año_nacimiento INTEGER, especialidad TEXT, activo INTEGER DEFAULT 1);
            CREATE TABLE IF NOT EXISTS misiones (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                id_agente INTEGER REFERENCES agentes(id),
                id_nave INTEGER REFERENCES naves(id),
                fecha_partida TEXT, fecha_regreso TEXT,
                exito INTEGER DEFAULT 0, incidencias TEXT);
        """)


# ── Funciones principales ─────────────────────────────────────────────────────

def registrar_nave(nombre, tipo, año, epoca):
    with db() as cur:
        cur.execute("INSERT INTO naves (nombre,tipo,año_construccion,epoca) VALUES (?,?,?,?)",
                    (nombre, tipo, año, epoca))
        return cur.lastrowid


def enviar_agente(id_agente, id_nave, fecha_partida):
    with db() as cur:
        cur.execute("SELECT nombre FROM agentes WHERE id=?", (id_agente,))
        nombre = cur.fetchone()[0]
        cur.execute("SELECT id FROM misiones WHERE id_agente=? AND fecha_regreso IS NULL", (id_agente,))
        if cur.fetchone():
            print(f"❌ Error: El agente {nombre} ya está en misión. ¿Paradoja temporal detectada?")
            return None
        cur.execute("INSERT INTO misiones (id_agente,id_nave,fecha_partida) VALUES (?,?,?)",
                    (id_agente, id_nave, fecha_partida))
        return cur.lastrowid


def cerrar_mision(id_mision, exito, incidencias=None):
    with db() as cur:
        cur.execute("UPDATE misiones SET fecha_regreso=?,exito=?,incidencias=? WHERE id=?",
                    (str(date.today()), exito, incidencias, id_mision))


def naves_sin_capitan():
    with db() as cur:
        cur.execute("""SELECT nombre, tipo, epoca FROM naves
                       WHERE id NOT IN (SELECT id_nave FROM misiones WHERE fecha_regreso IS NULL)""")
        return cur.fetchall()


def historial_agente(id_agente):
    with db() as cur:
        cur.execute("""SELECT a.nombre, n.nombre, m.fecha_partida, m.fecha_regreso, m.exito, m.incidencias
                       FROM misiones m JOIN agentes a ON a.id=m.id_agente JOIN naves n ON n.id=m.id_nave
                       WHERE m.id_agente=? ORDER BY m.fecha_partida""", (id_agente,))
        return cur.fetchall()


def misiones_fallidas():
    with db() as cur:
        cur.execute("""SELECT n.nombre, a.nombre, m.incidencias FROM misiones m
                       JOIN agentes a ON a.id=m.id_agente JOIN naves n ON n.id=m.id_nave
                       WHERE m.exito=0 AND m.fecha_regreso IS NOT NULL""")
        return cur.fetchall()


# ── Datos de prueba ───────────────────────────────────────────────────────────

def insertar_datos():
    with db() as cur:
        cur.execute("SELECT COUNT(*) FROM naves")
        if cur.fetchone()[0]: return  # ya insertados

    for args in [
        ("Santa María", "nao", 1491, "Siglo de Oro"),
        ("San Martín", "galeón", 1567, "Siglo de Oro"),
        ("La Victoria", "bergantín", 1519, "Siglo de Oro"),
        ("El Pelícano", "fragata", 1577, "Era Isabelina"),
        ("La Bretaña", "galeón", 1634, "Edad Moderna"),
        ("Drakkar del Norte", "drakkar", 900, "Edad Media"),
    ]: registrar_nave(*args)

    with db() as cur:
        cur.executemany("INSERT INTO agentes (nombre,año_nacimiento,especialidad) VALUES (?,?,?)", [
            ("Elena Ruiz de la Vega", 1985, "infiltración"),
            ("Rodrigo Sancho Palacios", 1978, "combate"),
            ("Sofía Medina Torres", 1990, "diplomacia"),
            ("Álvaro Quintero Leal", 1982, "navegación"),
        ])

    misiones = [
        (1, 1, "1492-08-03", (1, "Sin incidencias. Misión completada con éxito.")),
        (2, 2, "1588-07-21", (0, "Tormenta inesperada. Interferencia de agentes ingleses del futuro.")),
        (3, 3, "1519-09-20", (1, "Primera circunnavegación asegurada. Paradoja menor neutralizada.")),
        (4, 4, "1577-12-13", (0, "El agente alteró el rumbo. Drake llegó un año tarde. Expediente abierto.")),
        (2, 5, "1634-03-15", None),  # en curso
        (1, 6, "0999-06-01", (0, "Descubierta por los vikingos. Huida temporal de emergencia activada.")),
    ]
    for ag, nave, partida, cierre in misiones:
        mid = enviar_agente(ag, nave, partida)
        if mid and cierre:
            cerrar_mision(mid, *cierre)

    print("\n── Prueba de paradoja ──")
    enviar_agente(2, 1, "1805-10-21")  # Rodrigo sigue en misión → debe fallar


# ── Informe ───────────────────────────────────────────────────────────────────

def mostrar_informe():
    print("\n" + "═" * 55)
    print("   INFORME DEL MINISTERIO DEL TIEMPO — DIVISIÓN NAVAL")
    print("═" * 55)

    sin_cap = naves_sin_capitan()
    print(f"\n🚢 Naves sin capitán asignado: {len(sin_cap)}")
    for nombre, tipo, epoca in sin_cap:
        print(f"   • {nombre} ({tipo}) — {epoca}")

    historial = historial_agente(1)
    print(f"\n📜 Historial de {historial[0][0]}:")
    for _, nave, partida, regreso, exito, incidencia in historial:
        estado = "✅ Éxito" if exito else "❌ Fallida"
        print(f"   [{partida} → {regreso or 'En curso'}] {nave} — {estado}")
        if incidencia: print(f"      ↳ {incidencia}")

    fallidas = misiones_fallidas()
    print(f"\n⚠️  Misiones fallidas registradas: {len(fallidas)}")
    for nave, agente, incidencia in fallidas:
        print(f"   - {nave} | {agente} | Incidencia: {incidencia}")

    print("\n" + "═" * 55 + "\n")


# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    crear_bd()
    insertar_datos()
    mostrar_informe()

