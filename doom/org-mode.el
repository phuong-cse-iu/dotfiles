(after! org
  (setq evil-org-key-theme '(navigation insert textobjects additional calendar todo))
  ;; (set-company-backend! 'org-mode '(company-org-roam company-yasnippet company-dabbrev))
  (set-company-backend! 'org-mode 'company-org-roam)

  (setq org-capture-templates
    `(
       ("v"
         "Vocabulary"
         entry
         (file "~/org-modes/flashcards.org")
         "* %i%^{prompt} :vocabulary:\n:PROPERTIES:\n:ANKI_DECK: Vocabulary\n:ANKI_NOTE_TYPE: Basic\n:END:\n** Front\n%\\1\n\n** Back\n\n")
       ("L"
         "Notes"
         entry
         (file "~/org-modes/notes.org")
         "* %:description\n\nSource: %:link\nCaptured On:%U\n\n%:initial\n\n"
         :immediate-finish
         :prepend)
       ("c"
         "Code Review"
         entry
         (file ,(format-time-string "~/org-modes/roam/%Y-%m-%d.org" (current-time) t))
         "* %?\n:PROPERTIES:\n:Source: %F\n:Captured_On: %U\n:END:\n\n#+BEGIN_SRC ruby\n%:initial\n#+END_SRC\n")
       ("n"
         "Notes"
         entry
         (file ,(format-time-string "~/org-modes/roam/%Y-%m-%d.org" (current-time) t))
         "* %?\n\nCaptured On: %U\n\n%c")
       ("N"
         "Notes"
         entry
         (file ,(format-time-string "~/org-modes/roam/%Y-%m-%d.org" (current-time) t))
         ;; "* %?\n\nSource: %:link\nCaptured On:%U\n\n%:description\n\n%:initial\n\n")
         "* %?\n:PROPERTIES:\n:Source: %:link\n:Captured_On: %U\n:END:\n\n%:description\n\n%:initial\n\n")
       ("E"
         "Employment Hero Task"
         entry
         (file ,(format-time-string "~/org-modes/roam/%Y-%m-%d.org" (current-time) t))
         "* TODO %:description\n\nGit Branch: %(git-branch-by-title \"%:description\" \"%:link\")\nSource: %:link\nCaptured On: %U\n\n")
       ("e"
         "Employment Hero Task"
         entry
         (file "~/org-modes/employmenthero.org")
         "* TODO %?")))

  (require 'org-download))

(defun org-agenda-only-window ()
  (interactive)
  (let ((org-agenda-window-setup 'only-window))
    (org-agenda nil "a")
    (call-interactively 'org-agenda-day-view)))

(defun git-branch-by-title (title link)
  "Auto generate git branch by title"
  (let* ((dashed-title (s-dashed-words title))
          (card-id (car (last (s-split "/" link)))))
    (message "title %s link %s" title link)
    (message "%s/%s--%s"
      (if (or (s-contains? "refactor" dashed-title)
            (s-contains? "chore" dashed-title))
        "chore" "ft")
      dashed-title
      card-id)))

(defun add-card-id-to-title (title link)
  "Auto add prefix card it to task name"
  (let ((card-id (car (last (s-split "/" link)))))
    (message "[%s] %s" card-id title)))

(after! org-download
  (setq
    org-download-image-org-width 750
    org-download-delete-image-after-download t
    org-download-link-format "[[file:./images/%s]]\n"
    org-download-method 'directory)
  (setq-default org-download-image-dir "./images"))

(after! ob-tmux
  (setq org-babel-tmux-terminal "iterm")
  (setq org-babel-default-header-args:tmux
    '((:results . "silent")
       (:session . "default")
       (:socket  . nil)))
  (setq org-babel-tmux-session-prefix "ob-")
  (setq org-babel-tmux-location "/usr/local/bin/tmux"))

(after! ob-mermaid
  (setq ob-mermaid-cli-path "~/.asdf/shims/mmdc"))

(after! org-pomodoro
  ;; (setq org-pomodoro-long-break-sound (concat doom-private-dir "/assets/bell.wav"))
  ;; (setq org-pomodoro-ticking-sound (concat doom-private-dir "/assets/bell.wav"))
  (setq org-pomodoro-start-sound (concat doom-private-dir "/assets/bell.wav"))
  (setq org-pomodoro-finished-sound (concat doom-private-dir "/assets/bell.wav"))
  (setq org-pomodoro-overtime-sound  (concat doom-private-dir "/assets/bell.wav"))
  (setq org-pomodoro-short-break-sound (concat doom-private-dir "/assets/bell.wav")))

(after! org-roam
  (setq org-roam-directory "~/Dropbox/org-modes/roam")
  (setq org-roam-graph-viewer "/Applications/Firefox.app/Contents/MacOS/firefox-bin")
  (setq deft-directory "~/Dropbox/org-modes/roam")
  (setq org-roam-graph-exclude-matcher '("2020-"))

  (setq org-roam-capture-templates
    '(("d" "default" plain
        #'org-roam-capture--get-point
        "%?" :file-name "%<%Y%m%d%H%M%S>-${slug}"
        :head "#+TITLE: ${title}\n\n* What is ${title}?\n\n* Why is ${title}?\n\n* References"
        :unnarrowed t
        :immediate-finish t)))

  (setq org-roam-dailies-capture-templates
    '(("d" "daily" plain (function org-roam-capture--get-point)
        ""
        :immediate-finish t
        :file-name "%<%Y-%m-%d>"
        :head "#+TITLE: %<%Y-%m-%d>\n#+TODO: TODO IN-PROGRESS | DONE\n\n* Check Calendar"))))

(after! org-journal
  (setq org-journal-enable-agenda-integration t)
  (setq org-journal-date-prefix "#+TITLE: ")
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-journal-dir "~/Dropbox/org-modes/roam")
  (setq org-journal-date-format "%A, %d %B %Y")
  ;; (setq org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'")
  ;; (add-to-list 'org-agenda-files org-journal-dir)
  )

(use-package! org-roam-server
  :config
  (setq org-roam-server-port 8081))

(defun org-protocol-capture-frame (info)
  "Opens the org-capture window in a floating frame that cleans itself up once
you're done. This can be called from an external shell script."
  (interactive)
  (require 'org-protocol)
  (let* ((frame-title-format "")
          (frame (if (+org-capture-frame-p)
                   (selected-frame)
                   (make-frame +org-capture-frame-parameters))))
    (select-frame-set-input-focus frame)  ; fix MacOS not focusing new frames
    (with-selected-frame frame
      (require 'org-capture)
      (condition-case ex
        (letf! ((#'pop-to-buffer #'switch-to-buffer))
          (switch-to-buffer (doom-fallback-buffer))
          (let ((info (org-protocol-parse-parameters (s-replace "org-protocol://capture?" "" info) t)))
            (org-protocol-capture info))
          )
        ('error
          (message "org-capture: %s" (error-message-string ex))
          (delete-frame frame))))))
