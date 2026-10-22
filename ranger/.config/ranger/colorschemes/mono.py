# minimal monochrome, matches ghostty (black bg) + tmux (white-on-black status)

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import (
    default, black, red, white, bold, reverse, underline, default_colors,
)

GRAY = 245
DARKGRAY = 240


class Mono(ColorScheme):
    progress_bar_color = white

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        if context.in_browser:
            fg = GRAY
            if context.directory:
                fg = white
                attr |= bold
            if context.executable and not context.directory:
                fg = white
            if context.link:
                fg = GRAY
            if context.bad or context.error:
                fg = red
            if context.marked:
                fg = white
                attr |= bold | underline
            if context.selected:
                fg, bg = black, white
                attr &= ~underline
                if not context.main_column:
                    bg = GRAY
            if context.cut:
                fg = DARKGRAY
            if context.copied:
                attr |= underline
            if context.tag_marker and not context.selected:
                fg = white
                attr |= bold
            if context.border:
                fg = DARKGRAY

        elif context.in_titlebar:
            fg = GRAY
            if context.hostname:
                fg = white
                attr |= bold
            if context.directory:
                fg = white
            if context.tab:
                fg = white
                if context.good:
                    fg, bg = black, white

        elif context.in_statusbar:
            fg = GRAY
            if context.permissions:
                fg = GRAY if context.good else red
            if context.marked:
                fg, bg = black, white
            if context.message:
                fg = white
                if context.bad:
                    fg = red
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = GRAY

        if context.text and context.highlight:
            attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = white
            if context.selected:
                fg, bg = black, white
            if context.loaded:
                bg = self.progress_bar_color

        return fg, bg, attr
