#!/usr/bin/python3
"""Agrupa os SVGs em capitulos APB e RSA, preservando os vetores."""
import argparse
import json
from pathlib import Path

import cairo
import gi

gi.require_version("Rsvg", "2.0")
from gi.repository import Rsvg


HERE = Path(__file__).resolve().parent
POINTS_PER_PIXEL = 72 / 96
CHAPTER_SIZE = (841.89, 595.28)  # A4 paisagem, em pontos PDF.


def load_sheets(top, prefix=None):
    folder = HERE / "saida" / top
    sheets = json.loads((folder / "sheets.json").read_text())
    if prefix:
        sheets = [sheet for sheet in sheets if sheet["id"].startswith(prefix)]
    if not sheets:
        raise ValueError(f"Nenhuma folha encontrada em {folder}")
    for sheet in sheets:
        if sheet["check"]["errors"]:
            raise ValueError(f"Folha com erros de conferencia: {sheet['file']}")
        sheet["svg_path"] = folder / sheet["file"]
        if not sheet["svg_path"].is_file():
            raise FileNotFoundError(sheet["svg_path"])
    return sheets


def module_title(sheet):
    title = sheet["id"]
    if title == "kogge_stone_adder":
        title += f" ({sheet['params']})"
    return title


def text(ctx, x, y, content, size=12, bold=False, color=(0.12, 0.16, 0.23)):
    ctx.select_font_face("DejaVu Sans", cairo.FONT_SLANT_NORMAL,
                         cairo.FONT_WEIGHT_BOLD if bold else cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(size)
    ctx.set_source_rgb(*color)
    ctx.move_to(x, y)
    ctx.show_text(content)


def chapter_page(surface, ctx, number, name, sheets, first_page):
    surface.set_size(*CHAPTER_SIZE)
    surface.set_page_label(name)
    ctx.set_source_rgb(1, 1, 1)
    ctx.paint()
    ctx.set_source_rgb(0.12, 0.31, 0.75)
    ctx.rectangle(48, 50, 64, 5)
    ctx.fill()
    text(ctx, 48, 90, f"CAPÍTULO {number:02d}", 13, bold=True)
    text(ctx, 48, 150, name, 46, bold=True)
    text(ctx, 48, 182, f"Esquemáticos RTL · {len(sheets)} folhas · Yosys / ELK", 12)
    text(ctx, 48, 208, "Módulo", 10, bold=True)
    text(ctx, 746, 208, "Página", 10, bold=True)
    for index, sheet in enumerate(sheets):
        y = 238 + index * 26
        page = first_page + index
        ctx.tag_begin(cairo.TAG_LINK,
                      f"page={page} rect=[48 {y - 16} 744 23]")
        text(ctx, 48, y, module_title(sheet), 12)
        text(ctx, 755, y, str(page), 12)
        ctx.tag_end(cairo.TAG_LINK)
    text(ctx, 48, 553, "Clique em um módulo ou use os marcadores do PDF para navegar.", 10)
    text(ctx, 48, 572, "As páginas dos diagramas preservam as proporções de cada SVG.", 10)
    ctx.show_page()


def generate(output):
    chapters = [
        ("APB", load_sheets("amba_3_apb_rsa_apb_top", "amba_3_apb_")),
        ("RSA", load_sheets("rsa_core")),
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    with cairo.PDFSurface(str(output), *CHAPTER_SIZE) as surface:
        surface.set_metadata(cairo.PDF_METADATA_TITLE, "Esquemáticos RTL — APB e RSA")
        surface.set_metadata(cairo.PDF_METADATA_SUBJECT,
                             "Diagramas vetoriais dos módulos APB e RSA32 v2")
        surface.set_metadata(cairo.PDF_METADATA_CREATOR, "Yosys / ELK / librsvg / Cairo")
        ctx = cairo.Context(surface)
        page = 1
        for number, (name, sheets) in enumerate(chapters, 1):
            parent = surface.add_outline(cairo.PDF_OUTLINE_ROOT, name,
                                         f"page={page}", cairo.PDF_OUTLINE_FLAG_OPEN)
            chapter_page(surface, ctx, number, name, sheets, page + 1)
            page += 1
            for index, sheet in enumerate(sheets, 1):
                surface.set_size(sheet["width"] * POINTS_PER_PIXEL,
                                 sheet["height"] * POINTS_PER_PIXEL)
                surface.set_page_label(f"{name} {index:02d}")
                surface.add_outline(parent, module_title(sheet), f"page={page}", 0)
                viewport = Rsvg.Rectangle()
                viewport.x = viewport.y = 0
                viewport.width = sheet["width"] * POINTS_PER_PIXEL
                viewport.height = sheet["height"] * POINTS_PER_PIXEL
                handle = Rsvg.Handle.new_from_file(str(sheet["svg_path"]))
                if not handle.render_document(ctx, viewport):
                    raise RuntimeError(f"Falha ao converter {sheet['svg_path']}")
                ctx.show_page()
                print(f"Página {page:02d}: {name} / {module_title(sheet)}")
                page += 1
    print(f"PDF: {output} ({page - 1} páginas)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path,
                        default=HERE / "saida" / "esquematicos_apb_rsa.pdf")
    generate(parser.parse_args().out.resolve())
