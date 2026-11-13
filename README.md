# Suporte em treliça — 3 peças

Modelo paramétrico em OpenSCAD das peças de `refs/ref1.png` e `refs/ref2.png`.

| Peça | Arquivo | Medida (mm) | PLA aprox. |
|---|---|---|---|
| Torre em treliça losangular | `stl/torre.stl` | Ø60 × 250 | ~67 g (sólido) |
| Espeto (3 aletas + anel-soquete) | `stl/espeto.stl` | Ø60 × 130 | ~23 g |
| Tampa / funil (furo Ø24) | `stl/tampa.stl` | Ø60 × 18 | ~29 g |

Previews: `preview/torre.png`, `preview/espeto.png`, `preview/tampa.png`, `preview/montagem.png`.

## Decisões

- **25 cm = altura da torre sozinha** (colar incluído). A torre é a peça principal. Montada no espeto, o conjunto fica com ~36 cm, e o espeto vai enterrado.
- **Ø6 cm = diâmetro externo** dos anéis. A treliça tem Ø58.
- **Um encaixe só para tudo:** colar macho Ø54,5 com 2 frisos (embaixo da torre e na tampa) e soquete fêmea Ø55 (anel do topo da torre e anel do espeto). Folga radial de 0,25 mm.
  - torre → espeto (o colar entra pelo lado aberto do anel do espeto);
  - tampa → topo da torre (ou tampa → espeto).
- Paredes sólidas de 2,5 mm. Barras da treliça com Ø4 mm, 8 losangos na volta e 5 fileiras. A barra fica a 27° da vertical e imprime sem suporte.

## Imprimir na Creality K3

A K3 tem área de 260×260×260 mm. As 3 peças cabem, e a torre de 250 mm fica com 10 mm de folga no Z. Imprima as 3 juntas na mesma mesa ou uma de cada vez.

Configuração sugerida (Creality Print ou Orca, perfil padrão da K3):

- PLA (ou PETG), bico 0,4, camada de 0,2 mm. Uma cor só: a peça não usa o CFS nano.
- **Sem suporte** em nenhuma peça. As 3 já estão na orientação certa: colar (ou anel) na mesa e ponta para cima.
- **Torre:** a K3 vai a 500 mm/s, mas uma peça de 250 mm, alta e fina, balança nessa velocidade. Limite a torre a ~150 mm/s nas paredes externas e baixe a aceleração para ~5000 mm/s². Use brim de 5–8 mm, 3 perímetros e 15% de preenchimento (só os anéis têm preenchimento). Ventoinha a 100%. As barras terminam em 16 pontos sob o anel do topo, e o anel faz pontes de ~11 mm entre eles.
- **Espeto:** 3–4 perímetros e 20% de preenchimento. A ponta é fina: deixe "minimum layer time" ≥ 8 s para não derreter (imprimir junto com a torre também resolve).
- **Tampa:** 3 perímetros e 20% de preenchimento.
- Faça primeiro um teste de encaixe: imprima a tampa e encaixe no espeto. Se ficar justo, aumente `folga` para 0,35. Se ficar solto, diminua para 0,15.

## Mudar medidas

Todas as variáveis ficam no topo de `suporte_trelica.scad`: `altura_torre`, `diametro`, `parede`, `folga`, `n_losangos`, `n_linhas`, `espessura_barra`, as medidas do espeto e da tampa. Abra no OpenSCAD (o Customizer mostra as variáveis) ou use `-D` na linha de comando.

Para exportar tudo de novo:

```
for p in torre espeto tampa; do
  openscad --backend=manifold --export-format binstl -D "peca=\"$p\"" -o stl/$p.stl suporte_trelica.scad
done
```

`peca="montagem"` mostra o conjunto encaixado. Serve só para conferir, não para imprimir.

O OpenSCAD desta máquina é o AppImage em `~/.local/bin/openscad` (snapshot 2026.11.10). Foi instalado sem sudo.
