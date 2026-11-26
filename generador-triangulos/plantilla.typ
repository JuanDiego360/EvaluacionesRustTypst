#import "@preview/cetz:0.3.4"

#let ruta_datos = sys.inputs.at("archivo", default: "salida/datos_v1.json")
#let mostrar_clave = sys.inputs.at("mostrar_clave", default: "false") == "true"
#let datos = json(ruta_datos)

#set page(paper: "us-letter", margin: 2cm)
#set text(lang: "es", size: 11pt)

// Función que dibuja el triángulo a escala real normalizada
#let dibujar-triangulo(p, revelar: false) = {
  let a = p.lado_a
  let b = p.lado_b
  let c = p.lado_c
  let ang_a = p.angulo_a * 1deg

  // Coordenadas reales (A en origen, lado c en eje X)
  let cx = b * calc.cos(ang_a)
  let cy = b * calc.sin(ang_a)

  // Normalizamos para que el triángulo tenga un tamaño fijo en la hoja (~3.8 cm)
  let max_x = calc.max(c, cx)
  let min_x = calc.min(0.0, cx)
  let ancho_real = max_x - min_x
  let alto_real = cy
  let escala = calc.min(3.8 / ancho_real, 2.4 / alto_real)

  let A = (0.0, 0.0)
  let B = (c * escala, 0.0)
  let C = (cx * escala, cy * escala)

  // Determinamos qué etiquetas mostrar según el caso (LAL o ALA)
  let es_coseno = p.teorema.contains("Coseno")

  let etiq_a = if revelar or not es_coseno {
    if not es_coseno and not revelar { "" } else { $#a$ }
  } else { [$c = ?$] } // Ajuste abajo por lado exacto

  // Etiquetas limpias según qué se conoce en cada caso:
  // Caso Coseno (LAL): se conocen a, b y ángulo C. Incógnita: lado c.
  // Caso Seno (ALA): se conocen lado c y ángulos A, B. Incógnita: lado a.
  let lbl_lado_a = if es_coseno { $#a$ } else if revelar { text(fill: rgb("#2e7d32"))[*$a = #a$*] } else {
    text(fill: blue)[*$a = ?$*]
  }
  let lbl_lado_b = if es_coseno { $#b$ } else if revelar { $#b$ } else { "" }
  let lbl_lado_c = if es_coseno {
    if revelar { text(fill: rgb("#2e7d32"))[*$c = #c$*] } else { text(fill: blue)[*$c = ?$*] }
  } else { $#c$ }

  let lbl_ang_A = if not es_coseno or revelar { $#p.angulo_a degree$ } else { "" }
  let lbl_ang_B = if not es_coseno or revelar { $#p.angulo_b degree$ } else { "" }
  let lbl_ang_C = if es_coseno or revelar { $#p.angulo_c degree$ } else { "" }

  cetz.canvas(length: 1cm, {
    import cetz.draw: *

    // Triángulo relleno suave
    line(A, B, C, close: true, fill: rgb("#f4f7fb"), stroke: 1.1pt + black)

    // Vértices A, B, C
    content(A, [$A$], anchor: "north-east", padding: 3pt)
    content(B, [$B$], anchor: "north-west", padding: 3pt)
    content(C, [$C$], anchor: "south", padding: 4pt)

    // Etiquetas de los lados en los puntos medios
    let mid_c = ((A.at(0) + B.at(0)) / 2, 0)
    let mid_b = ((A.at(0) + C.at(0)) / 2, (A.at(1) + C.at(1)) / 2)
    let mid_a = ((B.at(0) + C.at(0)) / 2, (B.at(1) + C.at(1)) / 2)

    content(mid_c, lbl_lado_c, anchor: "north", padding: 4pt)
    content(mid_b, lbl_lado_b, anchor: "south-east", padding: 3pt)
    content(mid_a, lbl_lado_a, anchor: "south-west", padding: 3pt)

    // Etiquetas de ángulos internos
    if lbl_ang_A != "" {
      content((A.at(0) + 0.45, A.at(1) + 0.18), text(size: 8.5pt, lbl_ang_A))
    }
    if lbl_ang_B != "" {
      content((B.at(0) - 0.48, B.at(1) + 0.18), text(size: 8.5pt, lbl_ang_B))
    }
    if lbl_ang_C != "" {
      content((C.at(0), C.at(1) - 0.35), text(size: 8.5pt, lbl_ang_C))
    }
  })
}

// --- ENCABEZADO ---
#rect(width: 100%, inset: 12pt, stroke: 0.8pt, radius: 4pt)[
  #grid(
    columns: (1fr, auto),
    [
      *EVALUACIÓN DE TRIGONOMETRÍA: TEOREMA DEL SENO Y DEL COSENO* \
      #text(size: 9.5pt)[
        Nombre: #box(width: 6.5cm, line(length: 100%, stroke: 0.5pt))
        Fecha: #box(width: 2.5cm, line(length: 100%, stroke: 0.5pt))
      ]
    ],
    align(right)[
      #box(fill: luma(230), inset: 6pt, radius: 3pt)[
        *Forma #datos.version* \
        #if mostrar_clave { text(fill: red, weight: "bold")[CLAVE DOCENTE] }
      ]
    ],
  )
]

#v(0.5cm)
*Instrucciones:* Resuelve cada triángulo aplicando el teorema correspondiente. Redondea tus resultados finales a dos cifras decimales.
#v(0.4cm)

// --- PREGUNTAS CON DIAGRAMA AL LADO ---
#for p in datos.problemas [
  #block(breakable: false, below: 1.4em)[
    #grid(
      columns: (1fr, auto),
      column-gutter: 14pt,
      align: top,
      [
        *#p.numero.* #eval(p.enunciado, mode: "markup")

        #if mostrar_clave [
          #v(0.3cm)
          #box(fill: rgb("#eef9f0"), stroke: 0.5pt + rgb("#2e7d32"), inset: 8pt, radius: 4pt, width: 100%)[
            *Solución (#p.teorema):* *#p.incognita_nombre = #p.respuesta_correcta cm* \
            #text(size: 8.5pt, fill: luma(80))[
              Valores completos: $a = #p.lado_a$, $b = #p.lado_b$, $c = #p.lado_c$ |
              $A = #p.angulo_a degree$, $B = #p.angulo_b degree$, $C = #p.angulo_c degree$
            ]
          ]
        ] else [
          #v(2.6cm)
        ]
      ],
      dibujar-triangulo(p, revelar: mostrar_clave),
    )
  ]
]
