# ~/.zshrc — إعدادات zsh في Zool OS (عدّلها كما تشاء)

# ── السجل ──
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt AUTO_CD INTERACTIVE_COMMENTS NO_BEEP

# ── الإكمال التلقائي (Tab) ──
[ -d ~/.cache ] || mkdir -p ~/.cache
autoload -Uz compinit && compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'      # تجاهل حالة الأحرف
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── المفاتيح ──
bindkey -e
bindkey '^[[H' beginning-of-line;  bindkey '^[[F' end-of-line;  bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word;    bindkey '^[[1;5D' backward-word
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search; bindkey '^[[B' down-line-or-beginning-search   # ↑↓ يبحثان في السجل بما كتبته

# ── المحث: المستخدم@الجهاز المجلد (فرع git) — بألوان الثيم الحالي ──
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{yellow}%n%f@%F{cyan}%m%f %F{blue}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '

# ── اختصارات ──
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lAh --color=auto'
alias grep='grep --color=auto'
alias update='zool-update'
alias install='zool-pkg-install'

# ── اقتراحات وتلوين الأوامر أثناء الكتابة (إن وُجدت) ──
for f in /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
         /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [ -r "$f" ] && source "$f"
done
