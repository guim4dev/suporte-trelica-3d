// Suporte em treliça — 3 peças com encaixe comum (colar macho / soquete fêmea)
// Unidades: mm. Escolha a peça com -D 'peca="torre"' | "espeto" | "tampa" | "montagem".
//
// Encaixe: a torre tem colar macho embaixo e soquete fêmea no anel do topo.
// O espeto tem soquete fêmea no anel. A tampa tem colar macho.
// Logo: torre -> espeto, tampa -> topo da torre (ou tampa -> espeto).

/* [Peça] */
peca = "torre"; // [torre, espeto, tampa, montagem]

/* [Medidas gerais] */
altura_torre    = 250;  // altura total da torre, colar incluído
diametro        = 60;   // diâmetro externo dos anéis (topo, espeto, tampa)
parede          = 2.5;  // espessura das paredes sólidas
folga           = 0.25; // folga radial do encaixe (aumente se ficar justo)

/* [Treliça] */
n_losangos      = 8;    // losangos na volta (hélices em cada sentido)
n_linhas        = 5;    // fileiras de losangos na altura
espessura_barra = 4;    // diâmetro das barras da treliça
recuo_trelica   = 1;    // a treliça fica este tanto para dentro do anel do topo (raio)

/* [Anéis e encaixe] */
altura_anel_topo = 15;  // anel liso do topo (soquete fêmea)
altura_flange    = 6;   // anel da base da torre, apoia na borda do soquete
altura_colar     = 10;  // colar macho (deve ser < profundidade do soquete)
friso_prof       = 0.6; // profundidade dos 2 frisos do colar
friso_larg       = 1.5;

/* [Espeto] */
altura_espeto    = 130; // da base do anel até a ponta
altura_anel_esp  = 15;  // anel-soquete do espeto
n_aletas         = 3;
espessura_aleta  = 4;
juncao_aletas    = 0.55; // fração da altura onde as aletas se juntam no centro (topo do vão triangular)

/* [Tampa] */
altura_aba_tampa = 8;   // aba superior da tampa, com o funil
furo_tampa       = 24;  // diâmetro do furo central passante

$fn = 96;

// ---------- derivados ----------
d_socket   = diametro - 2*parede;          // diâmetro interno do soquete fêmea
d_colar    = d_socket - 2*folga;           // diâmetro externo do colar macho
d_colar_in = d_colar - 2*parede;           // furo do colar
d_trelica  = diametro - 2*recuo_trelica;   // diâmetro externo da treliça
h_trelica  = altura_torre - altura_colar - altura_flange - altura_anel_topo;
passo      = n_losangos * h_trelica / n_linhas;   // altura de uma volta completa de cada hélice
giro       = 360 * h_trelica / passo;             // graus girados por cada hélice na treliça
eps        = 0.01;

assert(altura_colar < altura_anel_topo && altura_colar < altura_anel_esp,
       "colar maior que o soquete");
assert(h_trelica > 0, "altura_torre pequena demais");
echo(str("treliça: altura=", h_trelica, " passo=", passo, " giro=", giro,
         "° ângulo da barra com a vertical=", atan(PI*d_trelica/passo), "°"));

// ---------- partes comuns ----------
module anel(d_ext, d_int, h) {
    difference() {
        cylinder(d = d_ext, h = h);
        translate([0, 0, -eps]) cylinder(d = d_int, h = h + 2*eps);
    }
}

// Colar macho com 2 frisos; z = 0 na ponta do colar.
module colar() {
    difference() {
        anel(d_colar, d_colar_in, altura_colar);
        for (z = [altura_colar/3, 2*altura_colar/3])
            translate([0, 0, z - friso_larg/2])
                anel(d_colar + 1, d_colar - 2*friso_prof, friso_larg);
    }
}

// Degrau colar -> aba com chanfro de 45° (imprime sem suporte com o colar na mesa).
module aba_chanfrada(d_ext, h, r_in = d_colar_in/2) {
    rotate_extrude()
        polygon([[r_in, 0], [d_colar/2, 0],
                 [d_ext/2, min(h, d_ext/2 - d_colar/2)],
                 [d_ext/2, h], [r_in, h]]);
}

// ---------- torre ----------
module helices(sentido) {
    r = d_trelica/2 - espessura_barra/2;
    for (i = [0 : n_losangos - 1])
        // sentido -1 defasado meio losango: as pontas dos dois sentidos não coincidem
        rotate([0, 0, (i + (sentido < 0 ? 0.5 : 0)) * 360 / n_losangos])
            linear_extrude(height = h_trelica + 2, twist = sentido * giro * (h_trelica + 2) / h_trelica,
                           slices = ceil(giro / 3), convexity = 10)
                translate([r, 0]) circle(d = espessura_barra, $fn = 16);
}

module torre() {
    colar();
    translate([0, 0, altura_colar]) aba_chanfrada(d_trelica, altura_flange);
    translate([0, 0, altura_colar + altura_flange - 1]) {
        helices(+1);
        helices(-1);
    }
    translate([0, 0, altura_torre - altura_anel_topo])
        anel(diametro, d_socket, altura_anel_topo);
}

// ---------- espeto ----------
// Anel-soquete aberto embaixo (recebe o colar); aletas radiais sobem até a ponta.
module espeto() {
    anel(diametro, d_socket, altura_anel_esp);
    z_j = altura_espeto * juncao_aletas;
    for (i = [0 : n_aletas - 1])
        rotate([0, 0, i * 360 / n_aletas])
            rotate([90, 0, 0])
                linear_extrude(height = espessura_aleta, center = true)
                    // pé da aleta desce pela parede até logo acima do colar (vira batente)
                    polygon([[0, z_j], [diametro/2 - parede, altura_colar + 0.5],
                             [diametro/2, altura_colar + 0.5], [diametro/2, altura_anel_esp],
                             [0, altura_espeto]]);
    // nó central onde as aletas se juntam
    translate([0, 0, z_j])
        cylinder(d1 = espessura_aleta, d2 = eps, h = altura_espeto - z_j);
}

// ---------- tampa ----------
// Colar macho + aba; por dentro um funil que desce até o furo passante.
module tampa() {
    difference() {
        union() {
            difference() {
                cylinder(d = d_colar, h = altura_colar);
                for (z = [altura_colar/3, 2*altura_colar/3])
                    translate([0, 0, z - friso_larg/2])
                        anel(d_colar + 1, d_colar - 2*friso_prof, friso_larg);
            }
            translate([0, 0, altura_colar]) aba_chanfrada(diametro, altura_aba_tampa, 0);
        }
        translate([0, 0, -eps]) cylinder(d = furo_tampa, h = 2);       // furo reto no fundo
        translate([0, 0, 1.5])                                         // funil
            cylinder(d1 = furo_tampa, d2 = diametro - 2*parede,
                     h = altura_colar + altura_aba_tampa - 1.5 + eps);
    }
}

// ---------- montagem (só para conferir, não imprimir) ----------
module montagem() {
    // espeto de ponta pra baixo, torre encaixada nele, tampa no topo
    color("olivedrab") translate([0, 0, altura_anel_esp]) rotate([180, 0, 0]) espeto();
    color("darkolivegreen") translate([0, 0, altura_anel_esp - altura_colar]) torre();
    color("yellowgreen") translate([0, 0, altura_anel_esp - altura_colar + altura_torre - altura_colar])
        tampa();
}

if (peca == "torre")         torre();
else if (peca == "espeto")   espeto();
else if (peca == "tampa")    tampa();
else if (peca == "montagem") montagem();
