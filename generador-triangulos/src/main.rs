use rand::Rng;
use serde::Serialize;
use std::env;
use std::f64::consts::PI;
use std::fs;
use std::process::{Command, exit};

#[derive(Serialize)]
struct Problema {
    numero: usize,
    teorema: String,
    enunciado: String,
    lado_a: f64,
    lado_b: f64,
    lado_c: f64,
    angulo_a: f64,
    angulo_b: f64,
    angulo_c: f64,
    incognita_nombre: String,
    respuesta_correcta: f64,
}

#[derive(Serialize)]
struct Evaluacion {
    version: usize,
    total_preguntas: usize,
    problemas: Vec<Problema>,
}

fn redondear(val: f64) -> f64 {
    (val * 100.0).round() / 100.0
}

fn generar_problema_valido(numero: usize, rng: &mut impl Rng) -> Problema {
    // Alternamos entre Teorema del Coseno (0) y Teorema del Seno (1)
    if rng.random_bool(0.5) {
        // --- CASO LAL (Teorema del Coseno) ---
        // Siempre tiene solución única para a > 0, b > 0 y 0 < C < 180
        let a = rng.random_range(6..=25) as f64;
        let b = rng.random_range(6..=25) as f64;
        let ang_c_deg = rng.random_range(30..=125) as f64;
        let ang_c_rad = ang_c_deg * PI / 180.0;

        // c = sqrt(a^2 + b^2 - 2ab*cos(C))
        let c = (a.powi(2) + b.powi(2) - 2.0 * a * b * ang_c_rad.cos()).sqrt();

        // Calculamos los ángulos restantes por ley del coseno para evitar ambigüedad
        let ang_a_deg = ((b.powi(2) + c.powi(2) - a.powi(2)) / (2.0 * b * c))
            .acos()
            * 180.0
            / PI;
        let ang_b_deg = 180.0 - ang_c_deg - ang_a_deg;

        Problema {
            numero,
            teorema: "Teorema del Coseno (Caso LAL)".into(),
            enunciado: format!(
                "En un triángulo $A B C$, se conocen los lados $a = {a} \"cm\"$, $b = {b} \"cm\"$ y el ángulo comprendido entre ellos $C = {ang_c_deg} degree$. Calcula la longitud del lado $c$."
            ),
            lado_a: redondear(a),
            lado_b: redondear(b),
            lado_c: redondear(c),
            angulo_a: redondear(ang_a_deg),
            angulo_b: redondear(ang_b_deg),
            angulo_c: redondear(ang_c_deg),
            incognita_nombre: "Lado c".into(),
            respuesta_correcta: redondear(c),
        }
    } else {
        // --- CASO ALA (Teorema del Seno) ---
        // Garantizamos A + B <= 145° para que C >= 35° y el triángulo sea bien proporcionado
        let ang_a_deg = rng.random_range(25..=75) as f64;
        let ang_b_deg = rng.random_range(25..=70) as f64;
        let ang_c_deg = 180.0 - ang_a_deg - ang_b_deg;

        let c = rng.random_range(8..=30) as f64;

        let rad_a = ang_a_deg * PI / 180.0;
        let rad_b = ang_b_deg * PI / 180.0;
        let rad_c = ang_c_deg * PI / 180.0;

        // a / sin(A) = c / sin(C)
        let a = c * rad_a.sin() / rad_c.sin();
        let b = c * rad_b.sin() / rad_c.sin();

        Problema {
            numero,
            teorema: "Teorema del Seno (Caso ALA)".into(),
            enunciado: format!(
                "En un triángulo $A B C$, el lado $c = {c} \"cm\"$ y sus ángulos adyacentes son $A = {ang_a_deg} degree$ y $B = {ang_b_deg} degree$. Determina la longitud del lado $a$."
            ),
            lado_a: redondear(a),
            lado_b: redondear(b),
            lado_c: redondear(c),
            angulo_a: redondear(ang_a_deg),
            angulo_b: redondear(ang_b_deg),
            angulo_c: redondear(ang_c_deg),
            incognita_nombre: "Lado a".into(),
            respuesta_correcta: redondear(a),
        }
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Uso: {} <num_evaluaciones> <preguntas_por_evaluacion>", args[0]);
        exit(1);
    }

    let num_evals: usize = args[1].parse().expect("El primer argumento debe ser un entero positivo");
    let num_pregs: usize = args[2].parse().expect("El segundo argumento debe ser un entero positivo");

    fs::create_dir_all("salida").expect("No se pudo crear el directorio salida/");
    let mut rng = rand::rng();

    for v in 1..=num_evals {
        let mut problemas = Vec::with_capacity(num_pregs);
        for p in 1..=num_pregs {
            problemas.push(generar_problema_valido(p, &mut rng));
        }

        let eval = Evaluacion {
            version: v,
            total_preguntas: num_pregs,
            problemas,
        };

        let ruta_json = format!("salida/datos_v{v}.json");
        let ruta_pdf = format!("salida/evaluacion_v{v}.pdf");
        let ruta_clave = format!("salida/clave_respuestas_v{v}.pdf");

        let json_str = serde_json::to_string_pretty(&eval).unwrap();
        fs::write(&ruta_json, json_str).expect("Error escribiendo JSON");

        // 1. Compilar versión para el estudiante (sin respuestas)
        let status_est = Command::new("typst")
            .args([
                "compile",
                "plantilla.typ",
                &ruta_pdf,
                "--input",
                &format!("archivo={ruta_json}"),
                "--input",
                "mostrar_clave=false",
            ])
            .status()
            .expect("Fallo al ejecutar typst");

        // 2. Compilar hoja de respuestas para el docente
        let status_doc = Command::new("typst")
            .args([
                "compile",
                "plantilla.typ",
                &ruta_clave,
                "--input",
                &format!("archivo={ruta_json}"),
                "--input",
                "mostrar_clave=true",
            ])
            .status()
            .expect("Fallo al ejecutar typst");

        if status_est.success() && status_doc.success() {
            println!("Generada Evaluación #{v}: {ruta_pdf} (y clave {ruta_clave})");
        }
    }
}
