;; jabber-modeline.el - display jabber status in modeline

;; Copyright (C) 2004 - Magnus Henoch - mange@freemail.hu

;; This file is a part of jabber.el.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

(require 'jabber-presence)
(require 'jabber-alert)
(eval-when-compile (require 'cl))

(defgroup jabber-mode-line nil
  "Display Jabber status in mode line"
  :group 'jabber)

(defvar jabber-mode-line-string nil)
(defvar jabber-mode-line-presence nil)
(defvar jabber-mode-line-contacts nil)

(defadvice jabber-send-presence (after jsp-update-mode-line
				       (show status priority))
  (jabber-mode-line-presence-update))

(defun jabber-mode-line-presence-update ()
  (setq jabber-mode-line-presence (if *jabber-connected*
				      (cdr (assoc *jabber-current-show* jabber-presence-strings))
				    "Offline")))

(defun jabber-mode-line-count-contacts (&rest ignore)
  (let ((count (list (cons "chat" 0)
		     (cons "" 0)
		     (cons "away" 0)
		     (cons "xa" 0)
		     (cons "dnd" 0)
		     (cons nil 0))))
    (dolist (buddy *jabber-roster*)
      (when (assoc (get buddy 'show) count)
	(incf (cdr (assoc (get buddy 'show) count)))))
    (setq jabber-mode-line-contacts
	  (apply 'format "(%d/%d/%d/%d/%d/%d)"
		 (mapcar 'cdr count)))))

(define-minor-mode jabber-mode-line-mode
  "Toggle display of Jabber status in mode lines.
Display consists of your own status, and six numbers
meaning the number of chatty, online, away, xa, dnd
and offline contacts, respectively."
  :global t :group 'jabber-mode-line
  (setq jabber-mode-line-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (if jabber-mode-line-mode
      (progn
	(or (memq 'jabber-mode-line-string global-mode-string)
	    (setq global-mode-string
		  (append global-mode-string '(jabber-mode-line-string))))

	(setq jabber-mode-line-string (list "" 
					    'jabber-mode-line-presence
					    " "
					    'jabber-mode-line-contacts))
	(jabber-mode-line-presence-update)
	(jabber-mode-line-count-contacts)
	(ad-activate 'jabber-send-presence)
	(add-hook 'jabber-disconnect-hook
		  'jabber-mode-line-presence-update)
	(add-hook 'jabber-alert-presence-hooks
		  'jabber-mode-line-count-contacts))))

(provide 'jabber-modeline)

;;; arch-tag: c03a7d3b-8811-49d4-b0e0-7ffd661d7925
