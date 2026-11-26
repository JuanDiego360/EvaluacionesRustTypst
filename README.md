# Evaluaciones y Solucionarios Automáticos (Rust + Typst)

Este repositorio está diseñado para la **generación automatizada de evaluaciones y solucionarios para docentes y estudiantes**, cubriendo diversos temas académicos (matemáticas, física, trigonometría, etc.).

Combina la potencia, velocidad y precisión de **Rust** para la lógica generativa y aleatoria, con la elegancia tipográfica y capacidad de gráficos vectoriales de **Typst** (y **CeTZ**).

---

## 🎯 Objetivos del Proyecto

- **Generación masiva y parametrizable:** Crear múltiples versiones o formas de una misma evaluación con valores y parámetros aleatorios pero pedagógicamente coherentes y matemáticamente válidos.
- **Doble salida automática:**
  - **Cuadernillo del Estudiante:** Evaluaciones listas para imprimir con enunciados, diagramas ilustrativos y espacio para desarrollo.
  - **Clave/Solucionario Docente:** Respuestas calculadas con precisión, valores intermedios y teoremas o pasos aplicados.
- **Gráficos vectoriales precisos:** Uso de CeTZ para representar geométricamente figuras a escala (por ejemplo, triángulos con sus ángulos y lados proporcionados).
- **Extensibilidad multi-tema:** Estructura modular para incorporar nuevos generadores de evaluaciones por área temática.

---

## 🏗️ Arquitectura General

```text
EvaluacionesRustTypst/
├── README.md
├── .gitignore
└── generador-triangulos/            # Módulo: Trigonometría (Teorema del Seno y Coseno)
    ├── Cargo.toml
    ├── plantilla.typ                # Plantilla de diseño en Typst (usa CeTZ)
    ├── src/
    │   └── main.rs                  # Generador en Rust (lógica matemática y compilación)
    └── salida/                      # PDFs generados (evaluaciones y solucionarios)
```

### Flujo de Funcionamiento
1. **Rust (`src/main.rs`):**
   - Genera datos aleatorios controlados (ej. casos LAL y ALA sin ambigüedades).
   - Resuelve matemáticamente cada incógnita.
   - Exporta los datos a formato estructurado JSON (`datos_v{N}.json`).
   - Invoca CLI de `typst compile` con los parámetros correspondientes para generar tanto el examen como el solucionario.
2. **Typst (`plantilla.typ`):**
   - Consume los datos del JSON dinámicamente.
   - Dibuja figuras geométricas vectoriales acordes a los datos calculados.
   - Formatea la hoja en tamaño `us-letter` con tipografía limpia.

---

## 📐 Módulos Disponibles

### 1. Generador de Triángulos (`generador-triangulos/`)
Genera evaluaciones sobre resolución de triángulos oblicuángulos mediante:
- **Teorema del Coseno (Caso LAL):** Dados dos lados y el ángulo comprendido, calcula el tercer lado.
- **Teorema del Seno (Caso ALA):** Dados un lado y dos ángulos adyacentes, calcula los lados restantes.
- **Diagramas generados con CeTZ:** Cada problema incluye su triángulo normalizado y dibujado a escala.

#### Cómo usarlo:

```bash
cd generador-triangulos

# Compilar en modo release
cargo build --release

# Ejecutar: ./target/release/generarEvaluacionTeoSenoCoseno <num_evaluaciones> <preguntas_por_evaluacion>
cargo run --release -- 3 5
```

**Ejemplo de salida:**
- `salida/evaluacion_v1.pdf`: Evaluación para estudiantes (Forma 1, 5 preguntas).
- `salida/clave_respuestas_v1.pdf`: Solucionario con respuestas y triángulos resueltos para el docente.
- `salida/datos_v1.json`: Datos en crudo utilizados para compilar.

---

## 🛠️ Requisitos del Sistema

1. **Rust** (versión 1.85+ o edición 2024):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
2. **Typst** (versión 0.12+):
   ```bash
   cargo install typst-cli
   # o vía gestor de paquetes de tu distribución
   ```
3. Paquete **CeTZ** para Typst (se descarga automáticamente en la primera compilación de Typst mediante `@preview/cetz`).

---

## 🚀 Próximos Temas a Incorporar

- Álgebra lineal (sistemas de ecuaciones, operaciones matriciales).
- Geometría analítica (cónicas, rectas, circunferencias).
- Cálculo diferencial e integral (límites, derivadas, integrales con gráficas de funciones).
- Física clásica (cinemática, diagramas de cuerpo libre).

---

## 👤 Autor
- **Juan Diego** ([@JuanDiego360](https://github.com/JuanDiego360))
