# Synopsis

Smart tab over is an Emacs minor mode that, when enabled, causes TAB to "jump over" closing
parentheses, braces, quotes, and some other punctuation.

I use Emacs' `electric-pair-mode` which means entering an open parenthesis causes the closing one
to be entered also.  When I finish typing the contents, the cursor is now inside the
parentheses and I want to move out.  With `electric-pair-mode`, the standard way is to type the
closing parenthesis which causes the cursor to move past it:

With this mode, pressing TAB will do the same thing.  It sounds small, and it is, but there is
something very pleasing about it for me.  Some of the closing characters require holding shift
or moving off the home row, but TAB is easy to hit.

The characters it will jump over are:

    } ] ) > : ; ` ' "

Single and double quotes have some special handling so the mode will ignore an opening quote.
This only works in programming modes that define strings with those characters.  The mode will
ask Emacs if it starts a character and will ignore opening quotes.  The purpose is to allow
easy indenting of lines that start with a string.

If you need to indent a line that starts with one of these characters, remember that Emacs'
will indent the entire line if you press TAB anywhere on the line in most programming modes.
If pressing TAB jumps over a character and you wanted to indent, just press TAB again.  In
modes that do not support this, you may need to toggle the mode off or use the spacebar.

# Installation

The smart-tab-over package is available on MELPA so you can install with:

    M-x package-install [RET] smart-tab-over [RET]

If you are using `use-package`, use this:

    (use-package smart-tab-over
      ;; Causes TAB to jump over quotes and closing braces and brackets.
      :ensure t
      :demand t
      :config (smart-tab-over 1))

When the mode is enabled, the minor mode's keymap will process the tab key.  If point is not at
a character that needs to be jumped over, smart-tab-over will temporarily disable itself and
reprocess the tab key so the original function will be called.
