;;; smart-tab-over.el --- Allow TAB to jump over closing brackets, quotes, and more  -*- lexical-binding: t -*-

;; Author: Michael Kleehammer <michael@kleehammer.com>
;; Maintainer: Michael Kleehammer <michael@kleehammer.com>
;; URL: https://github.com/mkleehammer/smart-tab-over
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is NOT part of GNU Emacs.
;;
;; MIT License
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:
;;
;; Smart tab over is an Emacs minor mode that, when enabled, causes TAB to "jump over" closing
;; parentheses, braces, quotes, and some other punctuation.
;;
;; I use Emacs' `electric-pair-mode` which means entering an open parenthesis causes the
;; closing one to be entered also.  When I finish typing the contents, the cursor is now inside
;; the parentheses and I want to move out.  With `electric-pair-mode`, the standard way is to
;; type the closing parenthesis which causes the cursor to move past it:
;;
;; With this mode, pressing TAB will do the same thing.  It sounds small, and it is, but there is
;; something very pleasing about it for me.  Some of the closing characters require holding shift
;; or moving off the home row, but TAB is easy to hit.
;;
;; The characters it will jump over are:
;;
;;     } ] ) > : ; ` ' "
;;
;; Single and double quotes have some special handling so the mode will ignore an opening quote.
;; This only works in programming modes that define strings with those characters.  The mode will
;; ask Emacs if it starts a character and will ignore opening quotes.  The purpose is to allow
;; easy indenting of lines that start with a string.
;;
;; If you need to indent a line that starts with one of these characters, remember that Emacs'
;; will indent the entire line if you press TAB anywhere on the line in most programming modes.
;; If pressing TAB jumps over a character and you wanted to indent, just press TAB again.  In
;; modes that do not support this, you may need to toggle the mode off or use the spacebar.
;;
;;; Installation
;;
;; The smart-tab-over package is available on MELPA so you can install with:
;;
;;     M-x package-install [RET] smart-tab-over-mode [RET]
;;
;; If you are using `use-package`, use this:
;;
;;     (use-package smart-tab-over-mode
;;       ;; Causes TAB to jump over quotes and closing braces and brackets.
;;       :ensure t
;;       :demand t
;;       :config (smart-tab-over-mode 1))
;;
;; When the mode is enabled, the minor mode's keymap will process the tab key.  If point is not at
;; a character that needs to be jumped over, smart-tab-over-mode will temporarily disable itself and
;; reprocess the tab key so the original function will be called.

;;; Todo:
;;
;; - I haven't made the characters jumped over a variable yet as building the regexp would
;;   require ensuring the closing square bracket is the first character, and we'd have to
;;   escape the three characters that are special in a character class.


;;; Code:

;;;###autoload
(define-minor-mode smart-tab-over-mode
  "Causes TAB to jump over quotes, braces, and other punctuation."
  :group 'editing
  :lighter " ↦"
  :keymap (let ((map (make-sparse-keymap)))
            ;; Careful: I was using (kbd "TAB") but this would not override the tab key in org
            ;; mode's major mode map.  I don't know why, but using [tab] is different and
            ;; works.  I guess org-mode uses [tab] and Emacs searches twice, first for [tab]
            ;; and then for "TAB"?  I saw something like that but didn't capture it.  Needs
            ;; research.
            ;;
            ;; Here's what clued me in.  See the yasnippet portion.
            ;;
            ;; https://orgmode.org/manual/Conflicts.html
            (define-key map [tab] 'smart-tab-over--tab)
            map))


;;;###autoload
(define-globalized-minor-mode smart-tab-over-global-mode smart-tab-over-mode
  (lambda () (smart-tab-over-mode 1))
  :group 'editing)


(defun smart-tab-over--p ()
  "Is the character at point one we should jump over?"

  ;; This might be more complicated than necessary.  When the mode has the concept of a
  ;; "string", such as programming modes, it only jumps over the ending quote.  This makes
  ;; hopping out of quote pairs that are automatically inserted easy, but also allows you to
  ;; easily re-indent arguments that are strings when you are at the beginning of the string.
  ;;
  ;; To know if a mode has the concept, we check the syntax table for the current quote.  If it
  ;; is mapped to ", it means it it a string delimiter.
  ;;
  ;; When doing this, it means other quotes are ignored, so we also allow jumping over any
  ;; quote in a comment.

  (or (looking-at-p "\\(]\\|[)}>:;`']\\)")
      (and (looking-at-p "['\"]")
           ;; if the mode doesn't have strings, always jump
           (or (not (char-equal ?\" (char-syntax ?\")))
               ;; if we are in a string, we must not be looking at the starting one, so jump
               (nth 3 (syntax-ppss))
               ;; we are in a comment, so we can't tell if we are inside quotes in the comment,
               ;; so always jump
               (nth 4 (syntax-ppss))))))


(defun smart-tab-over--tab()
  "Handles the tab key in `smart-tab-over-mode'."
  (interactive)
  (if (smart-tab-over--p)
      (forward-char 1)
    (progn
      ;; This is not something we'll jump over, so call the original key binding.
      ;;
      ;; I was surprised to find there is no way to tell Emacs to continue searching the
      ;; keymaps.  So, we'll disable our minor mode temporarily, lookup the keybinding again,
      ;; and call the function manually.
      (let* ((smart-tab-over-mode nil)
             (original-func (key-binding (kbd "TAB"))))
        (call-interactively original-func)))))


(provide 'smart-tab-over)
;;; smart-tab-over.el ends here
