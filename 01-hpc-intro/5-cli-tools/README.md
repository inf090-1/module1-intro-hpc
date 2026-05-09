# CLI Tools for HPC

This guide introduces a small set of terminal tools that are useful on HPC clusters. It starts with basic text editors for quick file edits, then shows how `tmux` keeps your shell sessions alive during long interactive work.

## 1. Text Editors in the Terminal

When you are editing scripts or configuration files on a login node, a terminal editor is often the simplest option. The two most common choices are `nano` and `vim`.

### 1.1 `nano` for quick edits

`nano` is the easiest editor to start with. The key commands are shown at the bottom of the screen, so you do not need to memorize much to get started.

Open a file:

```bash
nano my_script.sh
```

Basic actions:

- `Ctrl+O` saves the file.
- `Enter` confirms the filename when saving.
- `Ctrl+X` exits `nano`.
- `Ctrl+W` searches inside the file.
- `Ctrl+K` cuts the current line.
- `Ctrl+U` pastes the last cut text.

Useful when:

- You need to edit a job script quickly.
- You want a low-friction editor with visible shortcuts.
- You are new to terminal editing.

### 1.2 `vim` for more control

`vim` is more powerful, but it uses modes. At first, this can feel unusual, but it becomes very efficient once you learn the basics.

Open a file:

```bash
vim my_script.sh
```

Basic actions:

- Press `i` to enter insert mode and type text.
- Press `Esc` to return to normal mode.
- Type `:w` to save.
- Type `:q` to quit.
- Type `:wq` to save and quit.
- Type `:q!` to quit without saving.
- Use `/word` to search for text.

Helpful movement keys in normal mode:

- `h` move left
- `j` move down
- `k` move up
- `l` move right

Useful when:

- You edit files often and want faster navigation.
- You need a tool that is widely available on cluster systems.
- You want to work comfortably over SSH from any machine.

If you are new to terminal editors, start with `nano`. Once you are comfortable, `vim` gives you more speed and flexibility.

## 2. Terminal multiplexer with `tmux`

Terminal multiplexer `tmux` helps you keep your work organized and persistent. It lets you create terminal sessions that survive network disconnects and can host multiple windows and panes.

- Keep long-running interactive tasks alive across SSH disconnects.
- Run multiple terminals inside one SSH session.
- Reattach to sessions from different machines or locations.

### 2.1 Basic `tmux` Commands

Start a new session:

```bash
# create and attach to a session named mysess
tmux new -s mysess
```

Detach from a session, but keep it running:

- Press `Ctrl-b` then `d`.

List sessions:

```bash
tmux ls
```

Attach to an existing session:

```bash
tmux attach -t mysess
# or
tmux a -t mysess
```

Kill a session:

```bash
tmux kill-session -t mysess
```

### 2.2 Windows and Panes

- New window inside a session: `Ctrl-b c`
- Switch window: `Ctrl-b n` for next, `Ctrl-b p` for previous, or `Ctrl-b <number>`
- Split pane vertically: `Ctrl-b %`
- Split pane horizontally: `Ctrl-b "`
- Navigate panes: `Ctrl-b` plus the arrow keys
- Resize panes from command prompt: `Ctrl-b :resize-pane -R 10`

### 2.3 Copy and Paste

- Enter copy mode: `Ctrl-b [`
- Move with arrow keys or `vi` keys, press `Space` to start selection, then `Enter` to copy.
- Paste: `Ctrl-b ]`

### 2.4 Using `tmux` in Slurm Jobs

- Start a `tmux` session on the login node and do small interactive tasks there.
- For interactive nodes allocated by Slurm with `salloc` or `srun --pty`, start `tmux` on the allocated node so the session can use node-local resources.

Example: reserve an interactive job and start `tmux`

```bash
srun -N 1 -n 1 --time=01:00:00 --pty bash
# on the allocated node
tmux new -s myinteractive
```

### 2.5 Sharing Sessions

`tmux` supports attaching multiple clients to the same session for collaborative debugging. This usually requires shared socket permissions or an admin-provided setup. Check with your sysadmin before using shared sessions.

### 2.6 Tips and Best Practices

- Name sessions with `tmux new -s name` to avoid confusion.
- Use `tmux ls` to check running sessions before creating a new one.
- Keep important logs and results on shared storage such as `HOME` or `SCRATCH`, not only inside a session.
- If you cannot attach, check `tmux ls` and kill stale sessions with `tmux kill-session`.

### 2.7 Further Customization

Create a `~/.tmux.conf` file to set keybindings, the status bar, and history size.

Example minimal `~/.tmux.conf`:

```text
set -g history-limit 10000
setw -g mode-keys vi
bind r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"
```

`tmux` is a small tool with a big payoff on clusters: it keeps your interactive work persistent, organized, and easy to resume.
