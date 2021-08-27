# bobthefish configuration
set -g theme_display_git yes
set -g theme_display_git_dirty yes
set -g theme_display_git_untracked yes
set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_stashed_verbose yes
set -g theme_display_git_default_branch yes
set -g theme_git_default_branches master main

set -g theme_display_date no
set -g theme_display_jobs_verbose yes
set -g theme_display_sudo_user yes
set -g theme_show_exit_status yes

set -g theme_newline_cursor yes
set -g theme_newline_prompt '> '

set -g fish_prompt_pwd_dir_length 0
#set -g theme_project_dir_length 1
set -g theme_color_scheme dracula
