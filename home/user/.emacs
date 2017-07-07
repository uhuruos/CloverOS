(custom-set-variables
  '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
  '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

