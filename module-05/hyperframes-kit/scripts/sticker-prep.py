#!/usr/bin/env python3
"""
sticker-prep.py — подготовка сгенерированного стикера для банка assets/stickers/.

Запуск:  /usr/bin/python3 scripts/sticker-prep.py вход.png assets/stickers/имя.png

Что делает: срезает фон ЗАЛИВКОЙ ОТ КРАЁВ и обрезает по альфе.

Почему именно заливкой, а не нейромоделью remove-background: модель портит
светлые заливки — делает их полупрозрачными, и стикер на светлом фоне темы
выглядит грязным. Заливка от краёв работает предсказуемо: она идёт снаружи
внутрь и останавливается на контуре рисунка.

Заливка идёт «по градиенту»: пиксель считается фоном, если он близок к
СОСЕДУ, из которого мы в него пришли. Так съедается и плавный серый фон, и
мягкое свечение вокруг объекта, а резкий тёмный контур стикера её держит.
Генератор редко отдаёт ровно белый фон (в 2026-08 отдавал серый градиент с
ореолом), поэтому опираться на конкретный цвет нельзя.
"""
import sys
from collections import deque
from PIL import Image

STEP_TOL = 26    # допуск на шаг между соседями (плавный градиент проходим)
GLOBAL_TOL = 96  # допуск на отклонение от цвета краёв (защита от протечки внутрь)
FEATHER = 1      # сглаживание края, px


def dist(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]), abs(a[2] - b[2]))


def main():
    if len(sys.argv) < 3:
        print("Использование: sticker-prep.py вход.png выход.png")
        sys.exit(1)
    src, dst = sys.argv[1], sys.argv[2]

    im = Image.open(src).convert("RGBA")
    w, h = im.size
    px = im.load()

    # опорный цвет фона — медиана по рамке в 1px
    edge = []
    for x in range(0, w, max(1, w // 200)):
        edge.append(px[x, 0][:3])
        edge.append(px[x, h - 1][:3])
    for y in range(0, h, max(1, h // 200)):
        edge.append(px[0, y][:3])
        edge.append(px[w - 1, y][:3])
    edge.sort()
    base = edge[len(edge) // 2]

    bg = bytearray(w * h)          # 1 = фон
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if not bg[y * w + x] and dist(px[x, y][:3], base) <= GLOBAL_TOL:
                bg[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if not bg[y * w + x] and dist(px[x, y][:3], base) <= GLOBAL_TOL:
                bg[y * w + x] = 1
                q.append((x, y))

    while q:
        x, y = q.popleft()
        cur = px[x, y][:3]
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not bg[ny * w + nx]:
                c = px[nx, ny][:3]
                if dist(c, cur) <= STEP_TOL and dist(c, base) <= GLOBAL_TOL:
                    bg[ny * w + nx] = 1
                    q.append((nx, ny))

    for y in range(h):
        row = y * w
        for x in range(w):
            if bg[row + x]:
                px[x, y] = (0, 0, 0, 0)

    # мягкий край: полупрозрачные пиксели на границе с фоном
    if FEATHER:
        src_px = im.copy().load()
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                if px[x, y][3] == 0:
                    continue
                near_bg = any(
                    bg[(y + dy) * w + (x + dx)]
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                )
                if near_bg:
                    r, g, b, a = src_px[x, y]
                    px[x, y] = (r, g, b, int(a * 0.55))

    im = im.crop(im.getbbox())
    im.save(dst)
    removed = sum(bg) * 100 // (w * h)
    print(f"✓ {dst}: {im.size[0]}×{im.size[1]}, фон снят с {removed}% площади")


if __name__ == "__main__":
    main()
