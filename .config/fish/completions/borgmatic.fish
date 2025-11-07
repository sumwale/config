            function __borgmatic_check_version
                set -fx this_filename (status current-filename)
                fish -c '
                    if test -f "$this_filename"
                        set this_script (cat $this_filename 2> /dev/null)
                        set installed_script (borgmatic --fish-completion 2> /dev/null)
                        if [ "$this_script" != "$installed_script" ] && [ "$installed_script" != "" ]
                            echo "
Your fish completions script is from a different version of borgmatic than is
currently installed. Please upgrade your script so your completions match the
command-line flags in your installed borgmatic! Try this to upgrade:

    borgmatic --fish-completion | sudo tee $this_filename
    source $this_filename
"
                        end
                    end
                ' &
            end
            __borgmatic_check_version

            function __borgmatic_current_arg --description 'Check if any of the given arguments are the last on the command line before the cursor'
                set -l all_args (commandline -poc)
                # premature optimization to avoid iterating all args if there aren't enough
                # to have a last arg beyond borgmatic
                if [ (count $all_args) -lt 2 ]
                    return 1
                end
                for arg in $argv
                    if [ "$arg" = "$all_args[-1]" ]
                        return 0
                    end
                end
                return 1
            end

            set --local action_parser_condition "not __fish_seen_subcommand_from repo-create rcreate init -I transfer prune -p compact create -C check -k delete extract -x config export-tar mount -m umount -u repo-delete rdelete restore -r repo-list rlist list -l repo-info rinfo info -i break-lock key recreate borg"
            set --local exact_option_condition "not __borgmatic_current_arg --source-repository -a --match-archives --glob-archives --sort-by --first --last -a --match-archives --glob-archives -a --match-archives --glob-archives --threshold -a --match-archives --glob-archives --only -a --match-archives --glob-archives --only --checkpoint-interval -a --match-archives --glob-archives --sort-by --first --last --archive --path --restore-path --destination --strip-components --archive --path --restore-path --destination --strip-components  --archive --path --destination --strip-components --mount-point --path --first --last --mount-point --path --first --last --mount-point --mount-point --archive --original-port --archive --original-port -a --match-archives --glob-archives --sort-by --first --last -a --match-archives --glob-archives --sort-by --first --last --path --find -a --match-archives --glob-archives --sort-by --first --last -e --exclude --exclude-from --patterns-from --path --find -a --match-archives --glob-archives --sort-by --first --last -e --exclude --exclude-from --patterns-from -a --match-archives --glob-archives --sort-by --first --last -a --match-archives --glob-archives --sort-by --first --last  -a --match-archives --glob-archives -- -c --config --after-actions[0] --after-actions --after-backup[0] --after-backup --after-check[0] --after-check --after-compact[0] --after-compact --after-everything[0] --after-everything --after-extract[0] --after-extract --after-prune[0] --after-prune --apprise.fail.body --apprise.fail.title --apprise.finish.body --apprise.finish.title --apprise.log.body --apprise.log.title --apprise.logs-size-limit --apprise.services[0].label --apprise.services[0].url --apprise.services --apprise.start.body --apprise.start.title --apprise.states[0] --apprise.states --archive-name-format --before-actions[0] --before-actions --before-backup[0] --before-backup --before-check[0] --before-check --before-compact[0] --before-compact --before-everything[0] --before-everything --before-extract[0] --before-extract --before-prune[0] --before-prune --borg-base-directory --borg-cache-directory --borg-config-directory --borg-exit-codes[0].code --borg-exit-codes[0].treat-as --borg-exit-codes --borg-files-cache-ttl --borg-key-file --borg-keys-directory --borg-security-directory --borgmatic-source-directory --btrfs.btrfs-command --btrfs.findmnt-command --check-last --check-repositories[0] --check-repositories --checkpoint-interval --checkpoint-volume --checks[0].frequency --checks[0].count-tolerance-percentage --checks[0].name --checks[0].max-duration --checks[0].data-sample-percentage --checks[0].only-run-on[0] --checks[0].only-run-on --checks[0].data-tolerance-percentage --checks[0].xxh64sum-command --checks --chunker-params --commands[0].before --commands[0].after --commands[0].run[0] --commands[0].run --commands[0].when[0] --commands[0].when --commands[0].states[0] --commands[0].states --commands --compact-threshold --compression --constants --container.secrets-directory --cronhub.ping-url --cronitor.ping-url --encryption-passcommand --encryption-passphrase --exclude-from[0] --exclude-from --exclude-if-present[0] --exclude-if-present --exclude-patterns[0] --exclude-patterns --extra-borg-options.break-lock --extra-borg-options.check --extra-borg-options.compact --extra-borg-options.create --extra-borg-options.delete --extra-borg-options.export-tar --extra-borg-options.extract --extra-borg-options.info --extra-borg-options.init --extra-borg-options.key-change-passphrase --extra-borg-options.key-export --extra-borg-options.key-import --extra-borg-options.list --extra-borg-options.mount --extra-borg-options.prune --extra-borg-options.recreate --extra-borg-options.rename --extra-borg-options.repo-create --extra-borg-options.repo-delete --extra-borg-options.repo-info --extra-borg-options.repo-list --extra-borg-options.transfer --extra-borg-options.umount --files-cache --healthchecks.ping-body-limit --healthchecks.ping-url --healthchecks.states[0] --healthchecks.states --keep-13weekly --keep-3monthly --keep-daily --keep-hourly --keep-minutely --keep-monthly --keep-secondly --keep-weekly --keep-within --keep-yearly --keepassxc.keepassxc-cli-command --keepassxc.key-file --keepassxc.yubikey --local-path --lock-wait --log-file --log-file-format --log-file-verbosity --loki.labels --loki.url --lvm.lsblk-command --lvm.lvcreate-command --lvm.lvremove-command --lvm.lvs-command --lvm.mount-command --lvm.snapshot-size --lvm.umount-command --mariadb-databases[0].container --mariadb-databases[0].format --mariadb-databases[0].hostname --mariadb-databases[0].label --mariadb-databases[0].list-options --mariadb-databases[0].mariadb-command --mariadb-databases[0].mariadb-dump-command --mariadb-databases[0].name --mariadb-databases[0].options --mariadb-databases[0].password --mariadb-databases[0].password-transport --mariadb-databases[0].port --mariadb-databases[0].restore-container --mariadb-databases[0].restore-hostname --mariadb-databases[0].restore-options --mariadb-databases[0].restore-password --mariadb-databases[0].restore-port --mariadb-databases[0].restore-username --mariadb-databases[0].skip-names[0] --mariadb-databases[0].skip-names --mariadb-databases[0].username --mariadb-databases --mongodb-databases[0].authentication-database --mongodb-databases[0].container --mongodb-databases[0].format --mongodb-databases[0].hostname --mongodb-databases[0].label --mongodb-databases[0].mongodump-command --mongodb-databases[0].mongorestore-command --mongodb-databases[0].name --mongodb-databases[0].options --mongodb-databases[0].password --mongodb-databases[0].port --mongodb-databases[0].restore-container --mongodb-databases[0].restore-hostname --mongodb-databases[0].restore-options --mongodb-databases[0].restore-password --mongodb-databases[0].restore-port --mongodb-databases[0].restore-username --mongodb-databases[0].username --mongodb-databases --monitoring-verbosity --mysql-databases[0].container --mysql-databases[0].format --mysql-databases[0].hostname --mysql-databases[0].label --mysql-databases[0].list-options --mysql-databases[0].mysql-command --mysql-databases[0].mysql-dump-command --mysql-databases[0].name --mysql-databases[0].options --mysql-databases[0].password --mysql-databases[0].password-transport --mysql-databases[0].port --mysql-databases[0].restore-container --mysql-databases[0].restore-hostname --mysql-databases[0].restore-options --mysql-databases[0].restore-password --mysql-databases[0].restore-port --mysql-databases[0].restore-username --mysql-databases[0].skip-names[0] --mysql-databases[0].skip-names --mysql-databases[0].username --mysql-databases --ntfy.access-token --ntfy.fail.message --ntfy.fail.priority --ntfy.fail.tags --ntfy.fail.title --ntfy.finish.message --ntfy.finish.priority --ntfy.finish.tags --ntfy.finish.title --ntfy.password --ntfy.server --ntfy.start.message --ntfy.start.priority --ntfy.start.tags --ntfy.start.title --ntfy.states[0] --ntfy.states --ntfy.topic --ntfy.username --on-error[0] --on-error --pagerduty.integration-key --patterns[0] --patterns --patterns-from[0] --patterns-from --postgresql-databases[0].analyze-options --postgresql-databases[0].compression --postgresql-databases[0].container --postgresql-databases[0].format --postgresql-databases[0].hostname --postgresql-databases[0].label --postgresql-databases[0].list-options --postgresql-databases[0].name --postgresql-databases[0].options --postgresql-databases[0].password --postgresql-databases[0].pg-dump-command --postgresql-databases[0].pg-restore-command --postgresql-databases[0].port --postgresql-databases[0].psql-command --postgresql-databases[0].restore-container --postgresql-databases[0].restore-hostname --postgresql-databases[0].restore-options --postgresql-databases[0].restore-password --postgresql-databases[0].restore-port --postgresql-databases[0].restore-username --postgresql-databases[0].ssl-cert --postgresql-databases[0].ssl-crl --postgresql-databases[0].ssl-key --postgresql-databases[0].ssl-mode --postgresql-databases[0].ssl-root-cert --postgresql-databases[0].username --postgresql-databases --prefix --pushover.fail.device --pushover.fail.expire --pushover.fail.message --pushover.fail.priority --pushover.fail.retry --pushover.fail.sound --pushover.fail.title --pushover.fail.ttl --pushover.fail.url --pushover.fail.url-title --pushover.finish.device --pushover.finish.expire --pushover.finish.message --pushover.finish.priority --pushover.finish.retry --pushover.finish.sound --pushover.finish.title --pushover.finish.ttl --pushover.finish.url --pushover.finish.url-title --pushover.start.device --pushover.start.expire --pushover.start.message --pushover.start.priority --pushover.start.retry --pushover.start.sound --pushover.start.title --pushover.start.ttl --pushover.start.url --pushover.start.url-title --pushover.states[0] --pushover.states --pushover.token --pushover.user --recompress --remote-path --repositories[0].encryption --repositories[0].label --repositories[0].path --repositories[0].storage-quota --repositories --retries --retry-wait --sentry.data-source-name-url --sentry.environment --sentry.monitor-slug --sentry.states[0] --sentry.states --skip-actions[0] --skip-actions --source-directories[0] --source-directories --sqlite-databases[0].label --sqlite-databases[0].name --sqlite-databases[0].path --sqlite-databases[0].restore-path --sqlite-databases[0].sqlite-command --sqlite-databases[0].sqlite-restore-command --sqlite-databases --ssh-command --syslog-verbosity --systemd.encrypted-credentials-directory --systemd.systemd-creds-command --temporary-directory --umask --upload-buffer-size --upload-rate-limit --uptime-kuma.push-url --uptime-kuma.states[0] --uptime-kuma.states --user-runtime-directory --user-state-directory -v --verbosity --working-directory --zabbix.api-key --zabbix.fail.value --zabbix.finish.value --zabbix.host --zabbix.itemid --zabbix.key --zabbix.password --zabbix.server --zabbix.start.value --zabbix.states[0] --zabbix.states --zabbix.username --zfs.mount-command --zfs.umount-command --zfs.zfs-command"

# action_parser completions
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'repo-create' -d 'Create a new, empty Borg repository (also known as "init")'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'rcreate' -d 'Create a new, empty Borg repository (also known as "init")'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'init' -d 'Create a new, empty Borg repository (also known as "init")'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-I' -d 'Create a new, empty Borg repository (also known as "init")'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'transfer' -d 'Transfer archives from one repository to another, optionally upgrading the transferred data [Borg 2.0+ only]'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'prune' -d 'Prune archives according to the retention policy (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-p' -d 'Prune archives according to the retention policy (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'compact' -d 'Compact segments to free space [Borg 1.2+, borgmatic 1.5.23+ only]'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'create' -d 'Create an archive (actually perform a backup)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-C' -d 'Create an archive (actually perform a backup)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'check' -d 'Check archives for consistency'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-k' -d 'Check archives for consistency'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'delete' -d 'Delete an archive from a repository or delete an entire repository (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'extract' -d 'Extract a named archive to the current directory'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-x' -d 'Extract a named archive to the current directory'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'config' -d 'Perform configuration file related operations'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'export-tar' -d 'Export an archive to a tar-formatted file or stream'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'mount' -d 'Mount a named archive as a FUSE filesystem'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-m' -d 'Mount a named archive as a FUSE filesystem'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'umount' -d 'Unmount a mounted FUSE filesystem'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-u' -d 'Unmount a mounted FUSE filesystem'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'repo-delete' -d 'Delete an entire repository (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'rdelete' -d 'Delete an entire repository (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'restore' -d 'Restore data source (e.g. database) dumps from a named archive. (To extract files instead, use "borgmatic extract".)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-r' -d 'Restore data source (e.g. database) dumps from a named archive. (To extract files instead, use "borgmatic extract".)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'repo-list' -d 'List the archives in a repository'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'rlist' -d 'List the archives in a repository'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'list' -d 'List the files in an archive or search for a file across archives'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-l' -d 'List the files in an archive or search for a file across archives'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'repo-info' -d 'Show repository summary information such as disk space used'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'rinfo' -d 'Show repository summary information such as disk space used'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'info' -d 'Show archive summary information such as disk space used'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a '-i' -d 'Show archive summary information such as disk space used'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'break-lock' -d 'Break Borg repository and cache locks left behind by Borg aborting'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'key' -d 'Perform repository key related operations'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'recreate' -d 'Recreate an archive in a repository (with Borg 1.2+, you must run compact afterwards to actually free space)'
complete -c borgmatic -f -n "$action_parser_condition" -n "$exact_option_condition" -a 'borg' -d 'Run an arbitrary Borg command based on borgmatic'"'"'s configuration'

# global flags
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'show this help message and exit'
complete -c borgmatic -f -n "$exact_option_condition" -a '-c --config' -d 'Configuration filename or directory, can specify flag multiple times, defaults to: -c /etc/borgmatic/config.yaml -c /etc/borgmatic.d -c $HOME/.config/borgmatic/config.yaml -c $HOME/.config/borgmatic.d'
complete -c borgmatic -Fr -n "__borgmatic_current_arg -c --config"
complete -c borgmatic -f -n "$exact_option_condition" -a '-n --dry-run' -d 'Go through the motions, but do not actually write to any repositories'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-environment-interpolation' -d 'Do not resolve environment variables in configuration files'
complete -c borgmatic -f -n "$exact_option_condition" -a '--bash-completion' -d 'Show bash completion script and exit'
complete -c borgmatic -f -n "$exact_option_condition" -a '--fish-completion' -d 'Show fish completion script and exit'
complete -c borgmatic -f -n "$exact_option_condition" -a '--version' -d 'Display installed version number of borgmatic and exit'
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-actions[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-actions[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-backup[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-backup[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-check[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-check[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-compact[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-compact[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-everything[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-everything[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-extract[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-extract[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--after-prune[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --after-prune[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.fail.body' -d 'Specify the message body.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.fail.body"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.fail.title' -d 'Specify the message title. If left unspecified, no
title is sent.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.fail.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.finish.body' -d 'Specify the message body.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.finish.body"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.finish.title' -d 'Specify the message title. If left unspecified, no
title is sent.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.finish.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.log.body' -d 'Specify the message body.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.log.body"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.log.title' -d 'Specify the message title. If left unspecified, no
title is sent.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.log.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.logs-size-limit' -d 'Number of bytes of borgmatic logs to send to Apprise
services. Set to 0 to send all logs and disable this
truncation. Defaults to 1500.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.logs-size-limit"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.send-logs' -d 'Send borgmatic logs to Apprise services as part of the
"finish", "fail", and "log" states. Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.no-send-logs' -d 'Set the --apprise.send-logs value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.services[0].label' -d 'Label used in borgmatic logs for this Apprise
service.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.services[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.services[0].url' -d 'URL of this Apprise service.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.services[0].url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.services' -d 'A list of Apprise services to publish to with URLs and
labels. The labels are used for logging. A full list of
services and their configuration can be found at
https://github.com/caronc/apprise/wiki.
 Example value: "[{label: kodi, url: '"'"'kodi://user@hostname'"'"'}, {label: line, url: '"'"'line://Token@User'"'"'}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.services"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.start.body' -d 'Specify the message body.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.start.body"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.start.title' -d 'Specify the message title. If left unspecified, no
title is sent.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.start.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--apprise.states' -d 'List of one or more monitoring states to ping for:
"start", "finish", "fail", and/or "log". Defaults to
pinging for failure only. For each selected state,
corresponding configuration for the message title and body
should be given. If any is left unspecified, a generic
message is emitted instead.
 Example value: "[start, finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --apprise.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive-name-format' -d 'Name of the archive to create. Borg placeholders can be used. See
the output of "borg help placeholders" for details. Defaults to
"{hostname}-{now:%%Y-%%m-%%dT%%H:%%M:%%S.%%f}" with Borg 1 and
"{hostname}" with Borg 2, as Borg 2 does not require unique
archive names; identical archive names form a common "series" that
can be targeted together. When running actions like repo-list,
info, or check, borgmatic automatically tries to match only
archives created with this name format.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --archive-name-format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--atime' -d 'Store atime into archive. Defaults to true in Borg < 1.2, false in
Borg 1.2+.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-atime' -d 'Set the --atime value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-actions[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-actions[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-backup[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-backup[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-check[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-check[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-compact[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-compact[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-everything[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-everything[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-extract[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-extract[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--before-prune[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --before-prune[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--birthtime' -d 'Store birthtime (creation date) into archive. Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-birthtime' -d 'Set the --birthtime value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--bootstrap.store-config-files' -d 'Store configuration files used to create a backup inside the
backup itself. Defaults to true. Changing this to false
prevents "borgmatic bootstrap" from extracting configuration
files from the backup.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--bootstrap.no-store-config-files' -d 'Set the --bootstrap.store-config-files value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-base-directory' -d 'Base path used for various Borg directories. Defaults to $HOME,
~$USER, or ~.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-base-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-cache-directory' -d 'Path for Borg cache files. Defaults to
$borg_base_directory/.cache/borg
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-cache-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-config-directory' -d 'Path for Borg configuration files. Defaults to
$borg_base_directory/.config/borg
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-config-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-exit-codes[0].code' -d 'The exit code for an existing Borg warning or error.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-exit-codes[0].code"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-exit-codes[0].treat-as' -d 'Whether to consider the exit code as an error or as a
warning in borgmatic.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-exit-codes[0].treat-as"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-exit-codes' -d 'A list of Borg exit codes that should be elevated to errors or
squashed to warnings as indicated. By default, Borg error exit codes
(2 to 99) are treated as errors while warning exit codes (1 and
100+) are treated as warnings. Exit codes other than 1 and 2 are
only present in Borg 1.4.0+.
 Example value: "[{code: 13, treat_as: warning}, {code: 100, treat_as: error}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-exit-codes"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-files-cache-ttl' -d 'Maximum time to live (ttl) for entries in the Borg files cache.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-files-cache-ttl"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-key-file' -d 'Path for the Borg repository key file, for use with a repository
created with "keyfile" encryption.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-key-file"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-keys-directory' -d 'Path for Borg encryption key files. Defaults to
$borg_config_directory/keys
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-keys-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--borg-security-directory' -d 'Path for Borg security and encryption nonce files. Defaults to
$borg_config_directory/security
'
complete -c borgmatic -x -n "__borgmatic_current_arg --borg-security-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--btrfs.btrfs-command' -d 'Command to use instead of "btrfs".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --btrfs.btrfs-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--check-i-know-what-i-am-doing' -d 'Bypass Borg confirmation about check with repair option. Defaults to
false and an interactive prompt from Borg.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-check-i-know-what-i-am-doing' -d 'Set the --check-i-know-what-i-am-doing value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--check-last' -d 'Restrict the number of checked archives to the last n. Applies only
to the "archives" check. Defaults to checking all archives.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --check-last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--check-repositories[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --check-repositories[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--check-repositories' -d 'Paths or labels for a subset of the configured "repositories" (see
above) on which to run consistency checks. Handy in case some of
your repositories are very large, and so running consistency checks
on them would take too long. Defaults to running consistency checks
on all configured repositories.
 Example value: "['"'"'user@backupserver:sourcehostname.borg'"'"']"'
complete -c borgmatic -x -n "__borgmatic_current_arg --check-repositories"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checkpoint-interval' -d 'Number of seconds between each checkpoint during a long-running
backup. See https://borgbackup.readthedocs.io/en/stable/faq.html for
details. Defaults to checkpoints every 1800 seconds (30 minutes).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --checkpoint-interval"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checkpoint-volume' -d 'Number of backed up bytes between each checkpoint during a
long-running backup. Only supported with Borg 2+. See
https://borgbackup.readthedocs.io/en/stable/faq.html for details.
Defaults to only time-based checkpointing (see
"checkpoint_interval") instead of volume-based checkpointing.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --checkpoint-volume"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].frequency' -d 'How frequently to run this type of consistency
check (as a best effort). The value is a number
followed by a unit of time. E.g., "2 weeks" to
run this consistency check no more than every
two weeks for a given repository or "1 month" to
run it no more than monthly. Defaults to
"always": running this check every time checks
are run.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].frequency"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].count-tolerance-percentage' -d 'The percentage delta between the source
directories file count and the most recent backup
archive file count that is allowed before the
entire consistency check fails. This can catch
problems like incorrect excludes, inadvertent
deletes, etc. Required (and only valid) for the
"spot" check.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].count-tolerance-percentage"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].name' -d 'Name of the consistency check to run:
 * "repository" checks the consistency of the
repository.
 * "archives" checks all of the archives.
 * "data" verifies the integrity of the data
within the archives and implies the "archives"
check as well.
 * "spot" checks that some percentage of source
files are found in the most recent archive (with
identical contents).
 * "extract" does an extraction dry-run of the
most recent archive.
 * See "skip_actions" for disabling checks
altogether.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].max-duration' -d 'How many seconds to check the repository before
interrupting the check. Useful for splitting a
long-running repository check into multiple
partial checks. Defaults to no interruption. Only
applies to the "repository" check, does not check
the repository index and is not compatible with
the "--repair" flag.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].max-duration"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].data-sample-percentage' -d 'The percentage of total files in the source
directories to randomly sample and compare to
their corresponding files in the most recent
backup archive. Required (and only valid) for the
"spot" check.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].data-sample-percentage"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].only-run-on[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].only-run-on[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].only-run-on' -d 'After the "frequency" duration has elapsed, only
run this check if the current day of the week
matches one of these values (the name of a day of
the week in the current locale). "weekday" and
"weekend" are also accepted. Defaults to running
the check on any day of the week.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[Saturday, Sunday]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].only-run-on"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].data-tolerance-percentage' -d 'The percentage of total files in the source
directories that can fail a spot check comparison
without failing the entire consistency check. This
can catch problems like source files that have
been bulk-changed by malware, backups that have
been tampered with, etc. The value must be lower
than or equal to the "contents_sample_percentage".
Required (and only valid) for the "spot" check.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].data-tolerance-percentage"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks[0].xxh64sum-command' -d 'Command to use instead of "xxh64sum" to hash
source files, usually found in an OS package named
"xxhash". Do not substitute with a different hash
type (SHA, MD5, etc.) or the check will never
succeed. Only valid for the "spot" check.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks[0].xxh64sum-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checks' -d 'List of one or more consistency checks to run on a periodic basis
(if "frequency" is set) or every time borgmatic runs checks (if
"frequency" is omitted).
 Example value: "[{frequency: 2 weeks, name: archives}, {name: repository}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --checks"
complete -c borgmatic -f -n "$exact_option_condition" -a '--chunker-params' -d 'Specify the parameters passed to the chunker (CHUNK_MIN_EXP,
CHUNK_MAX_EXP, HASH_MASK_BITS, HASH_WINDOW_SIZE). See
https://borgbackup.readthedocs.io/en/stable/internals.html for
details. Defaults to "19,23,21,4095".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --chunker-params"
complete -c borgmatic -f -n "$exact_option_condition" -a '--color' -d 'Apply color to console output. Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-color' -d 'Set the --color value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].before' -d 'Name for the point in borgmatic'"'"'s execution that
the commands should be run before (required if
"after" isn'"'"'t set):
 * "action" runs before each action for each
repository.
 * "repository" runs before all actions for each
repository.
 * "configuration" runs before all actions and
repositories in the current configuration file.
 * "everything" runs before all configuration
files.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].before"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].after' -d 'Name for the point in borgmatic'"'"'s execution that
the commands should be run after (required if
"before" isn'"'"'t set):
 * "action" runs after each action for each
repository.
 * "repository" runs after all actions for each
repository.
 * "configuration" runs after all actions and
repositories in the current configuration file.
 * "everything" runs after all configuration
files.
 * "error" runs after an error occurs.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].after"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].run[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].run[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].run' -d 'List of one or more shell commands or scripts to
run when this command hook is triggered. Required.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[echo Doing stuff.]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].run"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].when[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].when[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].when' -d 'Only trigger the hook when borgmatic is run with
particular actions listed here. Defaults to
running for all actions.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[create, prune, compact, check]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].when"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands[0].states' -d 'Only trigger the hook if borgmatic encounters one
of the states (execution results) listed here,
where:
 * "finish": No errors occurred.
 * "fail": An error occurred.
This state is evaluated only for the scope of the
configured "action", "repository", etc., rather
than for the entire borgmatic run. Only available
for "after" hooks. Defaults to running the hook
for all states.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands[0].states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--commands' -d 'List of one or more command hooks to execute, triggered at
particular points during borgmatic'"'"'s execution. For each command
hook, specify one of "before" or "after", not both.
 Example value: "[{before: action, run: [echo Backing up.], when: [create]}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --commands"
complete -c borgmatic -f -n "$exact_option_condition" -a '--compact-threshold' -d 'Minimum saved space percentage threshold for compacting a segment,
defaults to 10.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --compact-threshold"
complete -c borgmatic -f -n "$exact_option_condition" -a '--compression' -d 'Type of compression to use when creating archives. (Compression
level can be added separated with a comma, like "zstd,7".) See
http://borgbackup.readthedocs.io/en/stable/usage/create.html for
details. Defaults to "lz4".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --compression"
complete -c borgmatic -f -n "$exact_option_condition" -a '--constants' -d 'Constants to use in the configuration file. Within option values,
all occurrences of the constant name in curly braces will be
replaced with the constant value. For example, if you have a
constant named "app_name" with the value "myapp", then the string
"{app_name}" will be replaced with "myapp" in the configuration
file.
 Example value: "{app_name: myapp, user: myuser}"'
complete -c borgmatic -x -n "__borgmatic_current_arg --constants"
complete -c borgmatic -f -n "$exact_option_condition" -a '--container.secrets-directory' -d 'Secrets directory to use instead of "/run/secrets".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --container.secrets-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cronhub.ping-url' -d 'Cronhub ping URL to notify when a backup begins,
ends, or errors.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --cronhub.ping-url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cronitor.ping-url' -d 'Cronitor ping URL to notify when a backup begins,
ends, or errors.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --cronitor.ping-url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ctime' -d 'Store ctime into archive. Defaults to true.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-ctime' -d 'Set the --ctime value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--debug-passphrase' -d 'When set true, display debugging information that includes 
passphrases used and passphrase related environment variables set. 
Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-debug-passphrase' -d 'Set the --debug-passphrase value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--default-actions' -d 'Whether to apply default actions (create, prune, compact and check)
when no arguments are supplied to the borgmatic command. If set to
false, borgmatic displays the help message instead.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-default-actions' -d 'Set the --default-actions value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--display-passphrase' -d 'When set true, always shows passphrase and its hex UTF-8 byte
sequence. Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-display-passphrase' -d 'Set the --display-passphrase value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--encryption-passcommand' -d 'The standard output of this command is used to unlock the encryption
key. Only use on repositories that were initialized with
passcommand/repokey/keyfile encryption. Note that if both
encryption_passcommand and encryption_passphrase are set, then
encryption_passphrase takes precedence. This can also be used to
access encrypted systemd service credentials. Defaults to not set.
For more details, see:
https://torsion.org/borgmatic/how-to/provide-your-passwords/
'
complete -c borgmatic -x -n "__borgmatic_current_arg --encryption-passcommand"
complete -c borgmatic -f -n "$exact_option_condition" -a '--encryption-passphrase' -d 'Passphrase to unlock the encryption key with. Only use on
repositories that were initialized with passphrase/repokey/keyfile
encryption. Quote the value if it contains punctuation, so it parses
correctly. And backslash any quote or backslash literals as well.
Defaults to not set. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --encryption-passphrase"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-caches' -d 'Exclude directories that contain a CACHEDIR.TAG file. See
http://www.brynosaurus.com/cachedir/spec.html for details. Defaults
to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-exclude-caches' -d 'Set the --exclude-caches value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-from[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-from[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-from' -d 'Read exclude patterns from one or more separate named files, one
pattern per line. See the output of "borg help patterns" for more
details.
 Example value: "[/etc/borgmatic/excludes]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-if-present[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-if-present[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-if-present' -d 'Exclude directories that contain a file with the given filenames.
Defaults to not set.
 Example value: "[.nobackup]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-if-present"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-nodump' -d 'Exclude files with the NODUMP flag. Defaults to false. (This option
is supported for Borg 1.x only.)
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-exclude-nodump' -d 'Set the --exclude-nodump value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-patterns[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-patterns[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-patterns' -d 'Any paths matching these patterns are excluded from backups. Globs
and tildes are expanded. Note that a glob pattern must either start
with a glob or be an absolute path. Do not backslash spaces in path
names. See the output of "borg help patterns" for more details.
 Example value: "['"'"'*.pyc'"'"', /home/*/.cache, '"'"'*/.vim*.tmp'"'"', /etc/ssl, /home/user/path with spaces]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --exclude-patterns"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.break-lock' -d 'Extra command-line options to pass to "borg break-lock".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.break-lock"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.check' -d 'Extra command-line options to pass to "borg check".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.check"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.compact' -d 'Extra command-line options to pass to "borg compact".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.compact"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.create' -d 'Extra command-line options to pass to "borg create".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.delete' -d 'Extra command-line options to pass to "borg delete".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.export-tar' -d 'Extra command-line options to pass to "borg export-tar".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.export-tar"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.extract' -d 'Extra command-line options to pass to "borg extract".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.extract"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.info' -d 'Extra command-line options to pass to "borg info".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.key-change-passphrase' -d 'Extra command-line options to pass to "borg key
change-passphrase".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.key-change-passphrase"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.key-export' -d 'Extra command-line options to pass to "borg key export".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.key-export"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.key-import' -d 'Extra command-line options to pass to "borg key import".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.key-import"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.list' -d 'Extra command-line options to pass to "borg list".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.mount' -d 'Extra command-line options to pass to "borg mount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.prune' -d 'Extra command-line options to pass to "borg prune".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.recreate' -d 'Extra command-line options to pass to "borg recreate".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.rename' -d 'Extra command-line options to pass to "borg rename".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.rename"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.repo-create' -d 'Extra command-line options to pass to "borg init" / "borg
repo-create".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.repo-delete' -d 'Extra command-line options to pass to "borg repo-delete".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.repo-info' -d 'Extra command-line options to pass to "borg repo-info".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.repo-info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.repo-list' -d 'Extra command-line options to pass to "borg repo-list".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.transfer' -d 'Extra command-line options to pass to "borg transfer".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--extra-borg-options.umount' -d 'Extra command-line options to pass to "borg umount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --extra-borg-options.umount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--files-cache' -d 'Mode in which to operate the files cache. See
http://borgbackup.readthedocs.io/en/stable/usage/create.html for
details. Defaults to "ctime,size,inode".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --files-cache"
complete -c borgmatic -f -n "$exact_option_condition" -a '--flags' -d 'Record filesystem flags (e.g. NODUMP, IMMUTABLE) in archive.
Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-flags' -d 'Set the --flags value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.create-slug' -d 'Create the check if it does not exist. Only works with
the slug URL scheme (https://hc-ping.com/<ping-key>/<slug>
as opposed to https://hc-ping.com/<uuid>).
Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.no-create-slug' -d 'Set the --healthchecks.create-slug value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.ping-body-limit' -d 'Number of bytes of borgmatic logs to send to Healthchecks,
ideally the same as PING_BODY_LIMIT configured on the
Healthchecks server. Set to 0 to send all logs and disable
this truncation. Defaults to 100000.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --healthchecks.ping-body-limit"
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.ping-url' -d 'Healthchecks ping URL or UUID to notify when a backup
begins, ends, errors, or to send only logs.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --healthchecks.ping-url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.send-logs' -d 'Send borgmatic logs to Healthchecks as part of the "finish",
"fail", and "log" states. Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.no-send-logs' -d 'Set the --healthchecks.send-logs value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --healthchecks.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.states' -d 'List of one or more monitoring states to ping for: "start",
"finish", "fail", and/or "log". Defaults to pinging for all
states.
 Example value: "[finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --healthchecks.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.verify-tls' -d 'Verify the TLS certificate of the ping URL host. Defaults to
true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--healthchecks.no-verify-tls' -d 'Set the --healthchecks.verify-tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-13weekly' -d 'Number of quarterly archives to keep (13 week strategy).'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-13weekly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-3monthly' -d 'Number of quarterly archives to keep (3 month strategy).'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-3monthly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-daily' -d 'Number of daily archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-daily"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-exclude-tags' -d 'If true, the exclude_if_present filename is included in backups.
Defaults to false, meaning that the exclude_if_present filename is
omitted from backups.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-keep-exclude-tags' -d 'Set the --keep-exclude-tags value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-hourly' -d 'Number of hourly archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-hourly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-minutely' -d 'Number of minutely archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-minutely"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-monthly' -d 'Number of monthly archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-monthly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-secondly' -d 'Number of secondly archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-secondly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-weekly' -d 'Number of weekly archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-weekly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-within' -d 'Keep all archives within this time interval. See "skip_actions" for
disabling pruning altogether.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-within"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-yearly' -d 'Number of yearly archives to keep.'
complete -c borgmatic -x -n "__borgmatic_current_arg --keep-yearly"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keepassxc.keepassxc-cli-command' -d 'Command to use instead of "keepassxc-cli".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --keepassxc.keepassxc-cli-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keepassxc.key-file' -d 'Path to a key file for unlocking the KeePassXC database.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --keepassxc.key-file"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keepassxc.yubikey' -d 'YubiKey slot and optional serial number used to access the
KeePassXC database. The format is "<slot[:serial]>", where:
 * <slot> is the YubiKey slot number (e.g., `1` or `2`).
 * <serial> (optional) is the YubiKey'"'"'s serial number (e.g.,
   `7370001`).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --keepassxc.yubikey"
complete -c borgmatic -f -n "$exact_option_condition" -a '--local-path' -d 'Alternate Borg local executable. Defaults to "borg".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --local-path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lock-wait' -d 'Maximum seconds to wait for acquiring a repository/cache lock.
Defaults to 1.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lock-wait"
complete -c borgmatic -f -n "$exact_option_condition" -a '--log-file' -d 'Write log messages to the file at this path.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --log-file"
complete -c borgmatic -f -n "$exact_option_condition" -a '--log-file-format' -d 'Python format string used for log messages written to the log file.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --log-file-format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--log-file-verbosity' -d 'Log verbose output to file: -2 (disabled), -1 (errors only), 0
(warnings and responses to actions), 1 (info about steps borgmatic
is taking, the default), or 2 (debug).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --log-file-verbosity"
complete -c borgmatic -f -n "$exact_option_condition" -a '--log-json' -d 'Write Borg log messages and console output as one JSON object per
log line instead of formatted text. Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-log-json' -d 'Set the --log-json value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--loki.labels' -d 'Allows setting custom labels for the logging stream. At
least one label is required. "__hostname" gets replaced by
the machine hostname automatically. "__config" gets replaced
by the name of the configuration file. "__config_path" gets
replaced by the full path of the configuration file.
 Example value: "{app: borgmatic, config: __config, hostname: __hostname}"'
complete -c borgmatic -x -n "__borgmatic_current_arg --loki.labels"
complete -c borgmatic -f -n "$exact_option_condition" -a '--loki.url' -d 'Grafana loki log URL to notify when a backup begins,
ends, or fails.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --loki.url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.lsblk-command' -d 'Command to use instead of "lsblk".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.lsblk-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.lvcreate-command' -d 'Command to use instead of "lvcreate".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.lvcreate-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.lvremove-command' -d 'Command to use instead of "lvremove".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.lvremove-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.lvs-command' -d 'Command to use instead of "lvs".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.lvs-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.mount-command' -d 'Command to use instead of "mount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.mount-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.snapshot-size' -d 'Size to allocate for each snapshot taken, including the
units to use for that size. Defaults to "10%%ORIGIN" (10%%
of the size of logical volume being snapshotted). See the
lvcreate "--size" and "--extents" documentation for more
information:
https://www.man7.org/linux/man-pages/man8/lvcreate.8.html
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.snapshot-size"
complete -c borgmatic -f -n "$exact_option_condition" -a '--lvm.umount-command' -d 'Command to use instead of "umount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --lvm.umount-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].add-drop-database' -d 'Use the "--add-drop-database" flag with mariadb-dump,
causing the database to be dropped right before restore.
Defaults to true.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].no-add-drop-database' -d 'Set the --mariadb-databases[0].add-drop-database value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].container' -d 'Container name/id to connect to. When specified the
hostname is ignored. Requires docker/podman CLI.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].format' -d 'Database dump output format. Currently only "sql" is
supported. Defaults to "sql" for a single database. Or,
when database name is "all" and format is blank, dumps
all databases to a single file. But if a format is
specified with an "all" database name, dumps each
database to a separate file of that format, allowing
more convenient restores of individual databases.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].hostname' -d 'Database hostname to connect to. Defaults to connecting
via local Unix socket.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].label' -d 'Label to identify the database dump in the backup.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].list-options' -d 'Additional options to pass directly to the mariadb
command that lists available databases, without
performing any validation on them. See mariadb command
documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].list-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].mariadb-command' -d 'Command to run instead of "mariadb". This can be used to
run a specific mariadb version (e.g., one inside a
running container). Defaults to "mariadb".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].mariadb-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].mariadb-dump-command' -d 'Command to use instead of "mariadb-dump". This can be
used to run a specific mariadb_dump version (e.g., one
inside a running container). If you run it from within a
container, make sure to mount the path in the
"user_runtime_directory" option from the host into the
container at the same location. Defaults to
"mariadb-dump".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].mariadb-dump-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].name' -d 'Database name (required if using this hook). Or "all" to
dump all databases on the host. Note that using this
database hook implicitly enables read_special (see
above) to support dump and restore streaming.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].options' -d 'Additional mariadb-dump options to pass directly to the
dump command, without performing any validation on them.
See mariadb-dump documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].password' -d 'Password with which to connect to the database. Omitting
a password will only work if MariaDB is configured to
trust the configured username without a password.
Supports the "{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].password-transport' -d 'How to transmit database passwords from borgmatic to the
MariaDB client, one of:
 * "pipe": Securely transmit passwords via anonymous
   pipe. Only works if the database client is on the
   same host as borgmatic. (The server can be
   somewhere else.) This is the default value.
 * "environment": Transmit passwords via environment
   variable. Potentially less secure than a pipe, but
   necessary when the database client is elsewhere, e.g.
   when "mariadb_dump_command" is configured to "exec"
   into a container and run a client there.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].password-transport"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].port' -d 'Port to connect to. Defaults to 3306.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-container' -d 'Container name/id to restore to. Defaults to the
"container" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-hostname' -d 'Database hostname to restore to. Defaults to the
"hostname" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-options' -d 'Additional options to pass directly to the mariadb
command that restores database dumps, without
performing any validation on them. See mariadb command
documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-password' -d 'Password with which to connect to the restore database.
Defaults to the "password" option. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-port' -d 'Port to restore to. Defaults to the "port" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-tls' -d 'Whether to TLS-encrypt data transmitted between the
client and restore server. The default varies based on
the MariaDB version.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].no-restore-tls' -d 'Set the --mariadb-databases[0].restore-tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].restore-username' -d 'Username with which to restore the database. Defaults to
the "username" option. Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].restore-username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].skip-names[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].skip-names[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].skip-names' -d 'Database names to skip when dumping "all" databases.
Ignored when the database name is not "all".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[cache]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].skip-names"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].tls' -d 'Whether to TLS-encrypt data transmitted between the
client and server. The default varies based on the
MariaDB version.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].no-tls' -d 'Set the --mariadb-databases[0].tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases[0].username' -d 'Username with which to connect to the database. Defaults
to the username of the current user. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases[0].username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mariadb-databases' -d 'List of one or more MariaDB databases to dump before creating a
backup, run once per configuration file. The database dumps are
added to your source directories at runtime and streamed directly
to Borg. Requires mariadb-dump/mariadb commands. See
https://mariadb.com/kb/en/library/mysqldump/ for details.
 Example value: "[{hostname: database.example.org, name: users}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --mariadb-databases"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].authentication-database' -d 'Authentication database where the specified username
exists. If no authentication database is specified, the
database provided in "name" is used. If "name" is "all",
the "admin" database is used.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].authentication-database"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].container' -d 'Container name/id to connect to. When specified the
hostname is ignored. Requires docker/podman CLI.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].format' -d 'Database dump output format. One of "archive", or
"directory". Defaults to "archive". See mongodump
documentation for details. Note that format is ignored
when the database name is "all".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].hostname' -d 'Database hostname to connect to. Defaults to connecting
to localhost.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].label' -d 'Label to identify the database dump in the backup.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].mongodump-command' -d 'Command to use instead of "mongodump". This can be used
to run a specific mongodump version (e.g., one inside a
running container). If you run it from within a
container, make sure to mount the path in the
"user_runtime_directory" option from the host into the
container at the same location.  Defaults to
"mongodump".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].mongodump-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].mongorestore-command' -d 'Command to run when restoring a database instead of
"mongorestore". This can be used to run a specific
mongorestore version (e.g., one inside a running
container). Defaults to "mongorestore".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].mongorestore-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].name' -d 'Database name (required if using this hook). Or "all" to
dump all databases on the host. Note that using this
database hook implicitly enables read_special (see
above) to support dump and restore streaming.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].options' -d 'Additional mongodump options to pass directly to the
dump command, without performing any validation on them.
See mongodump documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].password' -d 'Password with which to connect to the database. Skip it
if no authentication is needed. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].port' -d 'Port to connect to. Defaults to 27017.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-container' -d 'Container name/id to restore to. Defaults to the
"container" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-hostname' -d 'Database hostname to restore to. Defaults to the
"hostname" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-options' -d 'Additional mongorestore options to pass directly to the
dump command, without performing any validation on them.
See mongorestore documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-password' -d 'Password with which to connect to the restore database.
Defaults to the "password" option. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-port' -d 'Port to restore to. Defaults to the "port" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].restore-username' -d 'Username with which to restore the database. Defaults to
the "username" option. Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].restore-username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases[0].username' -d 'Username with which to connect to the database. Skip it
if no authentication is needed. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases[0].username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mongodb-databases' -d 'List of one or more MongoDB databases to dump before creating a
backup, run once per configuration file. The database dumps are
added to your source directories at runtime and streamed directly
to Borg. Requires mongodump/mongorestore commands. See
https://docs.mongodb.com/database-tools/mongodump/ and
https://docs.mongodb.com/database-tools/mongorestore/ for details.
 Example value: "[{hostname: database.example.org, name: users}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --mongodb-databases"
complete -c borgmatic -f -n "$exact_option_condition" -a '--monitoring-verbosity' -d 'When a monitoring integration supporting logging is configured, log
verbose output to it: -2 (disabled), -1 (errors only), 0 (warnings
and responses to actions), 1 (info about steps borgmatic is taking,
the default), or 2 (debug).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --monitoring-verbosity"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].add-drop-database' -d 'Use the "--add-drop-database" flag with mysqldump,
causing the database to be dropped right before restore.
Defaults to true.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].no-add-drop-database' -d 'Set the --mysql-databases[0].add-drop-database value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].container' -d 'Container name/id to connect to. When specified the
hostname is ignored. Requires docker/podman CLI.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].format' -d 'Database dump output format. Currently only "sql" is
supported. Defaults to "sql" for a single database. Or,
when database name is "all" and format is blank, dumps
all databases to a single file. But if a format is
specified with an "all" database name, dumps each
database to a separate file of that format, allowing
more convenient restores of individual databases.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].hostname' -d 'Database hostname to connect to. Defaults to connecting
via local Unix socket.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].label' -d 'Label to identify the database dump in the backup.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].list-options' -d 'Additional options to pass directly to the mysql
command that lists available databases, without
performing any validation on them. See mysql command
documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].list-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].mysql-command' -d 'Command to run instead of "mysql". This can be used to
run a specific mysql version (e.g., one inside a running
container). Defaults to "mysql".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].mysql-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].mysql-dump-command' -d 'Command to use instead of "mysqldump". This can be used
to run a specific mysql_dump version (e.g., one inside a
running container). If you run it from within a
container, make sure to mount the path in the
"user_runtime_directory" option from the host into the
container at the same location. Defaults to "mysqldump".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].mysql-dump-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].name' -d 'Database name (required if using this hook). Or "all" to
dump all databases on the host. Note that using this
database hook implicitly enables read_special (see
above) to support dump and restore streaming.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].options' -d 'Additional mysqldump options to pass directly to the
dump command, without performing any validation on them.
See mysqldump documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].password' -d 'Password with which to connect to the database. Omitting
a password will only work if MySQL is configured to
trust the configured username without a password.
Supports the "{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].password-transport' -d 'How to transmit database passwords from borgmatic to the
MySQL client, one of:
 * "pipe": Securely transmit passwords via anonymous
   pipe. Only works if the database client is on the
   same host as borgmatic. (The server can be
   somewhere else.) This is the default value.
 * "environment": Transmit passwords via environment
   variable. Potentially less secure than a pipe, but
   necessary when the database client is elsewhere, e.g.
   when "mysql_dump_command" is configured to "exec"
   into a container and run a client there.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].password-transport"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].port' -d 'Port to connect to. Defaults to 3306.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-container' -d 'Container name/id to restore to. Defaults to the
"container" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-hostname' -d 'Database hostname to restore to. Defaults to the
"hostname" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-options' -d 'Additional options to pass directly to the mysql
command that restores database dumps, without
performing any validation on them. See mysql command
documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-password' -d 'Password with which to connect to the restore database.
Defaults to the "password" option. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-port' -d 'Port to restore to. Defaults to the "port" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-tls' -d 'Whether to TLS-encrypt data transmitted between the
client and restore server. The default varies based on
the MySQL installation.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].no-restore-tls' -d 'Set the --mysql-databases[0].restore-tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].restore-username' -d 'Username with which to restore the database. Defaults to
the "username" option. Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].restore-username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].skip-names[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].skip-names[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].skip-names' -d 'Database names to skip when dumping "all" databases.
Ignored when the database name is not "all".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.). Example value: "[cache]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].skip-names"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].tls' -d 'Whether to TLS-encrypt data transmitted between the
client and server. The default varies based on the
MySQL installation.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].no-tls' -d 'Set the --mysql-databases[0].tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases[0].username' -d 'Username with which to connect to the database. Defaults
to the username of the current user. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases[0].username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mysql-databases' -d 'List of one or more MySQL databases to dump before creating a
backup, run once per configuration file. The database dumps are
added to your source directories at runtime and streamed directly
to Borg. Requires mysqldump/mysql commands. See
https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html for
details.
 Example value: "[{hostname: database.example.org, name: users}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --mysql-databases"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.access-token' -d 'An ntfy access token to authenticate with instead of
username/password. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.access-token"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.fail.message' -d 'The message body to publish.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.fail.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.fail.priority' -d 'The priority to set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.fail.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.fail.tags' -d 'Tags to attach to the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.fail.tags"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.fail.title' -d 'The title of the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.fail.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.finish.message' -d 'The message body to publish.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.finish.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.finish.priority' -d 'The priority to set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.finish.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.finish.tags' -d 'Tags to attach to the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.finish.tags"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.finish.title' -d 'The title of the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.finish.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.password' -d 'The password used for authentication. Supports the
"{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.server' -d 'The address of your self-hosted ntfy.sh instance.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.server"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.start.message' -d 'The message body to publish.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.start.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.start.priority' -d 'The priority to set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.start.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.start.tags' -d 'Tags to attach to the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.start.tags"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.start.title' -d 'The title of the message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.start.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.states' -d 'List of one or more monitoring states to ping for: "start",
"finish", and/or "fail". Defaults to pinging for failure
only.
 Example value: "[start, finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.topic' -d 'The topic to publish to. See https://ntfy.sh/docs/publish/
for details.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.topic"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ntfy.username' -d 'The username used for authentication. Supports the
"{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ntfy.username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--numeric-ids' -d 'Only store/extract numeric user and group identifiers. Defaults to
false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-numeric-ids' -d 'Set the --numeric-ids value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--on-error[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --on-error[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--one-file-system' -d 'Stay in same file system; do not cross mount points beyond the given
source directories. Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-one-file-system' -d 'Set the --one-file-system value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pagerduty.integration-key' -d 'PagerDuty integration key used to notify PagerDuty when a
backup errors. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pagerduty.integration-key"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pagerduty.send-logs' -d 'Send borgmatic logs to PagerDuty when a backup errors.
Defaults to true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pagerduty.no-send-logs' -d 'Set the --pagerduty.send-logs value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --patterns[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns' -d 'Any paths matching these patterns are included/excluded from
backups. Recursion root patterns ("R ...") are effectively the same
as "source_directories"; they tell Borg which paths to backup
(modulo any excludes). Globs are expanded. (Tildes are not.) See
the output of "borg help patterns" for more details. Quote any value
if it contains leading punctuation, so it parses correctly.
 Example value: "[R /, '"'"'- /home/*/.cache'"'"', + /home/susan, '"'"'- /home/*'"'"']"'
complete -c borgmatic -x -n "__borgmatic_current_arg --patterns"
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns-from[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --patterns-from[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns-from' -d 'Read include/exclude patterns from one or more separate named files,
one pattern per line. See the output of "borg help patterns" for
more details.
 Example value: "[/etc/borgmatic/patterns]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --patterns-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].analyze-options' -d 'Additional psql options to pass directly to the analyze
command run after a restore, without performing any
validation on them. See psql documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].analyze-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].compression' -d 'Database dump compression level (integer) or method
("gzip", "lz4", "zstd", or "none") and optional
colon-separated detail. Defaults to moderate "gzip" for
"custom" and "directory" formats and no compression for
the "plain" format. Compression is not supported for the
"tar" format. Be aware that Borg does its own
compression as well, so you may not need it in both
places.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].compression"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].container' -d 'Container name/id to connect to. When specified the
hostname is ignored. Requires docker/podman CLI.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].format' -d 'Database dump output format. One of "plain", "custom",
"directory", or "tar". Defaults to "custom" (unlike raw
pg_dump) for a single database. Or, when database name
is "all" and format is blank, dumps all databases to a
single file. But if a format is specified with an "all"
database name, dumps each database to a separate file of
that format, allowing more convenient restores of
individual databases. See the pg_dump documentation for
more about formats.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].format"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].hostname' -d 'Database hostname to connect to. Defaults to connecting
via local Unix socket.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].label' -d 'Label to identify the database dump in the backup.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].list-options' -d 'Additional psql options to pass directly to the psql
command that lists available databases, without
performing any validation on them. See psql
documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].list-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].name' -d 'Database name (required if using this hook). Or "all" to
dump all databases on the host. (Also set the "format"
to dump each database to a separate file instead of one
combined file.) Note that using this database hook
implicitly enables read_special (see above) to support
dump and restore streaming.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].no-owner' -d 'Do not output commands to set ownership of objects to
match the original database. By default, pg_dump and
pg_restore issue ALTER OWNER or SET SESSION
AUTHORIZATION statements to set ownership of created
schema elements. These statements will fail unless the
initial connection to the database is made by a
superuser.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].owner' -d 'Set the --postgresql-databases[0].no-owner value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].options' -d 'Additional pg_dump/pg_dumpall options to pass directly
to the dump command, without performing any validation
on them. See pg_dump documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].password' -d 'Password with which to connect to the database. Omitting
a password will only work if PostgreSQL is configured to
trust the configured username without a password or you
create a ~/.pgpass file. Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].pg-dump-command' -d 'Command to use instead of "pg_dump" or "pg_dumpall".
This can be used to run a specific pg_dump version
(e.g., one inside a running container). If you run it
from within a container, make sure to mount the path in
the "user_runtime_directory" option from the host into
the container at the same location. Defaults to
"pg_dump" for single database dump or "pg_dumpall" to
dump all databases.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].pg-dump-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].pg-restore-command' -d 'Command to use instead of "pg_restore". This can be used
to run a specific pg_restore version (e.g., one inside a
running container). Defaults to "pg_restore".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].pg-restore-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].port' -d 'Port to connect to. Defaults to 5432.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].psql-command' -d 'Command to use instead of "psql". This can be used to
run a specific psql version (e.g., one inside a running
container). Defaults to "psql".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].psql-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-container' -d 'Container name/id to restore to. Defaults to the
"container" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-container"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-hostname' -d 'Database hostname to restore to. Defaults to the
"hostname" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-hostname"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-options' -d 'Additional pg_restore/psql options to pass directly to
the restore command, without performing any validation
on them. See pg_restore/psql documentation for details.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-options"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-password' -d 'Password with which to connect to the restore database.
Defaults to the "password" option. Supports the
"{credential ...}" syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-port' -d 'Port to restore to. Defaults to the "port" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].restore-username' -d 'Username with which to restore the database. Defaults to
the "username" option. Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].restore-username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].ssl-cert' -d 'Path to a client certificate.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].ssl-cert"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].ssl-crl' -d 'Path to a certificate revocation list.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].ssl-crl"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].ssl-key' -d 'Path to a private client key.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].ssl-key"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].ssl-mode' -d 'SSL mode to use to connect to the database server. One
of "disable", "allow", "prefer", "require", "verify-ca"
or "verify-full". Defaults to "disable".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].ssl-mode"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].ssl-root-cert' -d 'Path to a root certificate containing a list of trusted
certificate authorities.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].ssl-root-cert"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases[0].username' -d 'Username with which to connect to the database. Defaults
to the username of the current user. You probably want
to specify the "postgres" superuser here when the
database name is "all". Supports the "{credential ...}"
syntax.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases[0].username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--postgresql-databases' -d 'List of one or more PostgreSQL databases to dump before creating a
backup, run once per configuration file. The database dumps are
added to your source directories at runtime and streamed directly
to Borg. Requires pg_dump/pg_dumpall/pg_restore commands. See
https://www.postgresql.org/docs/current/app-pgdump.html and
https://www.postgresql.org/docs/current/libpq-ssl.html for
details.
 Example value: "[{hostname: database.example.org, name: users}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --postgresql-databases"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.device' -d 'The name of one of your devices to send just to 
that device instead of all devices.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.device"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.expire' -d 'How many seconds your notification will continue 
to be retried (every retry seconds). Defaults to
600. This settings only applies to priority 2
notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.expire"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.html' -d 'Set to True to enable HTML parsing of the message.
Set to false for plain text.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.no-html' -d 'Set the --pushover.fail.html value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.message' -d 'Message to be sent to the user or group. If omitted
the default is the name of the state.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.priority' -d 'A value of -2, -1, 0 (default), 1 or 2 that 
indicates the message priority.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.retry' -d 'The retry parameter specifies how often 
(in seconds) the Pushover servers will send the 
same notification to the user. Defaults to 30. This
settings only applies to priority 2 notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.retry"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.sound' -d 'The name of a supported sound to override your 
default sound choice. All options can be found 
here: https://pushover.net/api#sounds 
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.sound"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.title' -d 'Your message'"'"'s title, otherwise your app'"'"'s name is 
used.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.ttl' -d 'The number of seconds that the message will live, 
before being deleted automatically. The ttl 
parameter is ignored for messages with a priority.
value of 2.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.ttl"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.url' -d 'A supplementary URL to show with your message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.fail.url-title' -d 'A title for the URL specified as the url parameter,
otherwise just the URL is shown.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.fail.url-title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.device' -d 'The name of one of your devices to send just to 
that device instead of all devices.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.device"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.expire' -d 'How many seconds your notification will continue 
to be retried (every retry seconds). Defaults to
600. This settings only applies to priority 2
notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.expire"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.html' -d 'Set to True to enable HTML parsing of the message.
Set to false for plain text.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.no-html' -d 'Set the --pushover.finish.html value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.message' -d 'Message to be sent to the user or group. If omitted
the default is the name of the state.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.priority' -d 'A value of -2, -1, 0 (default), 1 or 2 that 
indicates the message priority.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.retry' -d 'The retry parameter specifies how often 
(in seconds) the Pushover servers will send the 
same notification to the user. Defaults to 30. This
settings only applies to priority 2 notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.retry"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.sound' -d 'The name of a supported sound to override your 
default sound choice. All options can be found 
here: https://pushover.net/api#sounds 
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.sound"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.title' -d 'Your message'"'"'s title, otherwise your app'"'"'s name is 
used.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.ttl' -d 'The number of seconds that the message will live, 
before being deleted automatically. The ttl 
parameter is ignored for messages with a priority.
value of 2.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.ttl"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.url' -d 'A supplementary URL to show with your message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.finish.url-title' -d 'A title for the URL specified as the url parameter,
otherwise just the URL is shown.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.finish.url-title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.device' -d 'The name of one of your devices to send just to 
that device instead of all devices.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.device"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.expire' -d 'How many seconds your notification will continue 
to be retried (every retry seconds). Defaults to
600. This settings only applies to priority 2
notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.expire"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.html' -d 'Set to True to enable HTML parsing of the message.
Set to false for plain text.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.no-html' -d 'Set the --pushover.start.html value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.message' -d 'Message to be sent to the user or group. If omitted
the default is the name of the state.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.message"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.priority' -d 'A value of -2, -1, 0 (default), 1 or 2 that 
indicates the message priority.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.priority"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.retry' -d 'The retry parameter specifies how often 
(in seconds) the Pushover servers will send the 
same notification to the user. Defaults to 30. This
settings only applies to priority 2 notifications.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.retry"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.sound' -d 'The name of a supported sound to override your 
default sound choice. All options can be found 
here: https://pushover.net/api#sounds 
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.sound"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.title' -d 'Your message'"'"'s title, otherwise your app'"'"'s name is 
used.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.ttl' -d 'The number of seconds that the message will live, 
before being deleted automatically. The ttl 
parameter is ignored for messages with a priority.
value of 2.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.ttl"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.url' -d 'A supplementary URL to show with your message.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.start.url-title' -d 'A title for the URL specified as the url parameter,
otherwise just the URL is shown.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.start.url-title"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.states' -d 'List of one or more monitoring states to ping for: "start",
"finish", and/or "fail". Defaults to pinging for failure
only.
 Example value: "[start, finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.token' -d 'Your application'"'"'s API token. Supports the "{credential
...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.token"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pushover.user' -d 'Your user/group key (or that of your target user), viewable
when logged into your dashboard: often referred to as
USER_KEY in Pushover documentation and code examples.
Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --pushover.user"
complete -c borgmatic -f -n "$exact_option_condition" -a '--read-special' -d 'Use Borg'"'"'s --read-special flag to allow backup of block and other
special devices. Use with caution, as it will lead to problems if
used when backing up special devices such as /dev/zero. Defaults to
false. But when a database hook is used, the setting here is ignored
and read_special is considered true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-read-special' -d 'Set the --read-special value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--recompress' -d 'Mode for recompressing data chunks according to MODE. 
Possible modes are:
 * "if-different": Recompress if the current compression
is with a different compression algorithm.
 * "always": Recompress even if the current compression
is with the same compression algorithm. Use this to change
the compression level.
 * "never": Do not recompress. Use this option to explicitly
prevent recompression.
See https://borgbackup.readthedocs.io/en/stable/usage/recreate.html
for details. Defaults to "never".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --recompress"
complete -c borgmatic -f -n "$exact_option_condition" -a '--relocated-repo-access-is-ok' -d 'Bypass Borg error about a repository that has been moved. Defaults
to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-relocated-repo-access-is-ok' -d 'Set the --relocated-repo-access-is-ok value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--remote-path' -d 'Alternate Borg remote executable. Defaults to "borg".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --remote-path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].append-only' -d 'Whether the repository should be created append-only,
only used for the repo-create action. Defaults to false.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].no-append-only' -d 'Set the --repositories[0].append-only value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].encryption' -d 'The encryption mode with which to create the repository,
only used for the repo-create action. To see the
available encryption modes, run "borg init --help" with
Borg 1 or "borg repo-create --help" with Borg 2.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --repositories[0].encryption"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].label' -d 'An optional label for the repository, used in logging
and to make selecting the repository easier on the
command-line.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --repositories[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].make-parent-directories' -d 'Whether any missing parent directories of the repository
path should be created, only used for the repo-create
action. Defaults to false. (This option is supported 
for Borg 1.x only.)
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].no-make-parent-directories' -d 'Set the --repositories[0].make-parent-directories value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].path' -d 'The local path or Borg URL of the repository.  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -Fr -n "__borgmatic_current_arg --repositories[0].path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories[0].storage-quota' -d 'The storage quota with which to create the repository,
only used for the repo-create action. Defaults to no
quota.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --repositories[0].storage-quota"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repositories' -d 'A required list of local or remote repositories with paths and
optional labels (which can be used with the --repository flag to
select a repository). Tildes are expanded. Multiple repositories are
backed up to in sequence. Borg placeholders can be used. See the
output of "borg help placeholders" for details. See ssh_command for
SSH options like identity file or port. If systemd service is used,
then add local repository paths in the systemd service file to the
ReadWritePaths list.
 Example value: "[{label: backupserver, path: '"'"'ssh://user@backupserver/./sourcehostname.borg'"'"'}, {label: local,
    path: /mnt/backup}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --repositories"
complete -c borgmatic -f -n "$exact_option_condition" -a '--retries' -d 'Number of times to retry a failing backup before giving up. Defaults
to 0 (i.e., does not attempt retry).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --retries"
complete -c borgmatic -f -n "$exact_option_condition" -a '--retry-wait' -d 'Wait time between retries (in seconds) to allow transient issues
to pass. Increases after each retry by that same wait time as a
form of backoff. Defaults to 0 (no wait).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --retry-wait"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sentry.data-source-name-url' -d 'Sentry Data Source Name (DSN) URL, associated with a
particular Sentry project. Used to construct a cron URL,
notified when a backup begins, ends, or errors.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --sentry.data-source-name-url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sentry.environment' -d 'Sentry monitor environment used in the call to Sentry. If
not set, the Sentry default is used.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --sentry.environment"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sentry.monitor-slug' -d 'Sentry monitor slug, associated with a particular Sentry
project monitor. Used along with the data source name URL to
construct a cron URL.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --sentry.monitor-slug"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sentry.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sentry.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sentry.states' -d 'List of one or more monitoring states to ping for: "start",
"finish", and/or "fail". Defaults to pinging for all states.
 Example value: "[start, finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --sentry.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--skip-actions[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --skip-actions[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--skip-actions' -d 'List of one or more actions to skip running for this configuration
file, even if specified on the command-line (explicitly or
implicitly). This is handy for append-only configurations where you
never want to run "compact" or checkless configuration where you
want to skip "check". Defaults to not skipping any actions.
 Example value: "[compact]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --skip-actions"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-directories[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --source-directories[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-directories' -d 'List of source directories and files to back up. Globs and tildes
are expanded. Do not backslash spaces in path names. Be aware that
by default, Borg treats missing source directories as warnings
rather than errors. If you'"'"'d like to change that behavior, see
https://torsion.org/borgmatic/how-to/customize-warnings-and-errors/
or the "source_directories_must_exist" option.
 Example value: "[/home, /etc, /var/log/syslog*, /home/user/path with spaces]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --source-directories"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-directories-must-exist' -d 'If true, then source directories (and root pattern paths) must
exist. If they don'"'"'t, an error is raised. Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-source-directories-must-exist' -d 'Set the --source-directories-must-exist value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].label' -d 'Label to identify the database dump in the backup.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases[0].label"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].name' -d 'This is used to tag the database dump file with a name.
It is not the path to the database file itself. The name
"all" has no special meaning for SQLite databases.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases[0].name"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].path' -d 'Path to the SQLite database file to dump. If relative,
it is relative to the current working directory. Note
that using this database hook implicitly enables
read_special (see above) to support dump and restore
streaming.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -Fr -n "__borgmatic_current_arg --sqlite-databases[0].path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].restore-path' -d 'Path to the SQLite database file to restore to. Defaults
to the "path" option.
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases[0].restore-path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].sqlite-command' -d 'Command to use instead of "sqlite3". This can be used to
run a specific sqlite3 version (e.g., one inside a
running container). If you run it from within a
container, make sure to mount the path in the
"user_runtime_directory" option from the host into the
container at the same location. Defaults to "sqlite3".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases[0].sqlite-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases[0].sqlite-restore-command' -d 'Command to run when restoring a database instead
of "sqlite3". This can be used to run a specific 
sqlite3 version (e.g., one inside a running container). 
Defaults to "sqlite3".
  To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases[0].sqlite-restore-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sqlite-databases' -d 'List of one or more SQLite databases to dump before creating a
backup, run once per configuration file. The database dumps are
added to your source directories at runtime and streamed directly to
Borg. Requires the sqlite3 command. See https://sqlite.org/cli.html
for details.
 Example value: "[{name: users, path: /var/lib/db.sqlite}]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --sqlite-databases"
complete -c borgmatic -f -n "$exact_option_condition" -a '--ssh-command' -d 'Command to use instead of "ssh". This can be used to specify ssh
options. Defaults to not set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --ssh-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--syslog-verbosity' -d 'Log verbose output to syslog: -2 (disabled, the default), -1 (errors
only), 0 (warnings and responses to actions), 1 (info about steps
borgmatic is taking), or 2 (debug).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --syslog-verbosity"
complete -c borgmatic -f -n "$exact_option_condition" -a '--systemd.encrypted-credentials-directory' -d 'Directory containing encrypted credentials for
"systemd-creds" to use instead of
"/etc/credstore.encrypted".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --systemd.encrypted-credentials-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--systemd.systemd-creds-command' -d 'Command to use instead of "systemd-creds". Only used as a
fallback when borgmatic is run outside of a systemd service.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --systemd.systemd-creds-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--temporary-directory' -d 'Directory where temporary Borg files are stored. Defaults to
$TMPDIR. See "Resource Usage" at
https://borgbackup.readthedocs.io/en/stable/usage/general.html for
details.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --temporary-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--umask' -d 'Umask used for when executing Borg or calling hooks. Defaults to
0077 for Borg or the umask that borgmatic is run with for hooks.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --umask"
complete -c borgmatic -f -n "$exact_option_condition" -a '--unknown-unencrypted-repo-access-is-ok' -d 'Bypass Borg error about a previously unknown unencrypted repository.
Defaults to false.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-unknown-unencrypted-repo-access-is-ok' -d 'Set the --unknown-unencrypted-repo-access-is-ok value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--upload-buffer-size' -d 'Size of network upload buffer in MiB. Defaults to no buffer.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --upload-buffer-size"
complete -c borgmatic -f -n "$exact_option_condition" -a '--upload-rate-limit' -d 'Remote network upload rate limit in kiBytes/second. Defaults to
unlimited.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --upload-rate-limit"
complete -c borgmatic -f -n "$exact_option_condition" -a '--uptime-kuma.push-url' -d 'Uptime Kuma push URL without query string (do not include the
question mark or anything after it).
'
complete -c borgmatic -x -n "__borgmatic_current_arg --uptime-kuma.push-url"
complete -c borgmatic -f -n "$exact_option_condition" -a '--uptime-kuma.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --uptime-kuma.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--uptime-kuma.states' -d 'List of one or more monitoring states to push for: "start",
"finish", and/or "fail". Defaults to pushing for all
states.
 Example value: "[start, finish, fail]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --uptime-kuma.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--uptime-kuma.verify-tls' -d 'Verify the TLS certificate of the push URL host. Defaults to
true.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--uptime-kuma.no-verify-tls' -d 'Set the --uptime-kuma.verify-tls value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--use-chunks-archive' -d 'Enables or disables the use of chunks.archive.d for faster cache
resyncs in Borg. If true, value is set to "yes" (default) else
it'"'"'s set to "no", reducing disk usage but slowing resyncs.
'
complete -c borgmatic -f -n "$exact_option_condition" -a '--no-use-chunks-archive' -d 'Set the --use-chunks-archive value to false.'
complete -c borgmatic -f -n "$exact_option_condition" -a '--user-runtime-directory' -d 'Path for storing temporary runtime data like streaming database
dumps and bootstrap metadata. borgmatic automatically creates and
uses a "borgmatic" subdirectory here. Defaults to $XDG_RUNTIME_DIR
or $TMPDIR or $TEMP or /run/user/$UID.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --user-runtime-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--user-state-directory' -d 'Path for storing borgmatic state files like records of when checks
last ran. borgmatic automatically creates and uses a "borgmatic"
subdirectory here. If you change this option, borgmatic must
create the check records again (and therefore re-run checks).
Defaults to $XDG_STATE_HOME or ~/.local/state.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --user-state-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '-v --verbosity' -d 'Display verbose output to the console: -2 (disabled), -1 (errors
only), 0 (warnings and responses to actions, the default), 1 (info
about steps borgmatic is taking), or 2 (debug).
'
complete -c borgmatic -x -n "__borgmatic_current_arg -v --verbosity"
complete -c borgmatic -f -n "$exact_option_condition" -a '--working-directory' -d 'Working directory to use when running actions, useful for backing up
using relative source directory paths. Does not currently apply to
borgmatic configuration file paths or includes. Tildes are expanded.
See http://borgbackup.readthedocs.io/en/stable/usage/create.html for
details. Defaults to not set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --working-directory"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.api-key' -d 'The API key used for authentication. Not needed if using an
username/password. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.api-key"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.fail.value' -d 'The value to set the item to on fail.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.fail.value"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.finish.value' -d 'The value to set the item to on finish.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.finish.value"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.host' -d 'Host name where the item is stored. Required if "itemid"
is not set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.host"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.itemid' -d 'The ID of the Zabbix item used for collecting data.
Unique across the entire Zabbix system.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.itemid"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.key' -d 'Key of the host where the item is stored. Required if
"itemid" is not set.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.key"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.password' -d 'The password used for authentication. Not needed if using
an API key. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.password"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.server' -d 'The API endpoint URL of your Zabbix instance, usually ending
with "/api_jsonrpc.php". Required.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.server"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.start.value' -d 'The value to set the item to on start.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.start.value"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.states[0]' -d ' To specify a different list element, replace the "[0]" with another array index ("[1]", "[2]", etc.).'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.states[0]"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.states' -d 'List of one or more monitoring states to ping for: "start",
"finish", and/or "fail". Defaults to pinging for failure
only.
 Example value: "[start, finish]"'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.states"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zabbix.username' -d 'The username used for authentication. Not needed if using
an API key. Supports the "{credential ...}" syntax.
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zabbix.username"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zfs.mount-command' -d 'Command to use instead of "mount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zfs.mount-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zfs.umount-command' -d 'Command to use instead of "umount".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zfs.umount-command"
complete -c borgmatic -f -n "$exact_option_condition" -a '--zfs.zfs-command' -d 'Command to use instead of "zfs".
'
complete -c borgmatic -x -n "__borgmatic_current_arg --zfs.zfs-command"

# action_parser flags
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --encryption' -d 'Borg repository encryption mode' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-repository --other-repo' -d 'Path to an existing Borg repository whose key material should be reused [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of the new repository to create (must be already specified in a borgmatic configuration file), defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--copy-crypt-key' -d 'Copy the crypt key used for authenticated encryption from the source repository, defaults to a new random key [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--append-only' -d 'Create an append-only repository' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--storage-quota' -d 'Create a repository with a fixed storage quota' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--make-parent-dirs' -d 'Create any missing parent directories of the repository directory [Borg 1.x only]' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from repo-create"
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --encryption' -d 'Borg repository encryption mode' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-repository --other-repo' -d 'Path to an existing Borg repository whose key material should be reused [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of the new repository to create (must be already specified in a borgmatic configuration file), defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--copy-crypt-key' -d 'Copy the crypt key used for authenticated encryption from the source repository, defaults to a new random key [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--append-only' -d 'Create an append-only repository' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--storage-quota' -d 'Create a repository with a fixed storage quota' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--make-parent-dirs' -d 'Create any missing parent directories of the repository directory [Borg 1.x only]' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from rcreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --encryption' -d 'Borg repository encryption mode' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-repository --other-repo' -d 'Path to an existing Borg repository whose key material should be reused [Borg 2.x+ only]' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of the new repository to create (must be already specified in a borgmatic configuration file), defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--copy-crypt-key' -d 'Copy the crypt key used for authenticated encryption from the source repository, defaults to a new random key [Borg 2.x+ only]' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--append-only' -d 'Create an append-only repository' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--storage-quota' -d 'Create a repository with a fixed storage quota' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '--make-parent-dirs' -d 'Create any missing parent directories of the repository directory [Borg 1.x only]' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from init"
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --encryption' -d 'Borg repository encryption mode' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-repository --other-repo' -d 'Path to an existing Borg repository whose key material should be reused [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of the new repository to create (must be already specified in a borgmatic configuration file), defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--copy-crypt-key' -d 'Copy the crypt key used for authenticated encryption from the source repository, defaults to a new random key [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--append-only' -d 'Create an append-only repository' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--storage-quota' -d 'Create a repository with a fixed storage quota' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--make-parent-dirs' -d 'Create any missing parent directories of the repository directory [Borg 1.x only]' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -I"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of existing destination repository to transfer archives to, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--source-repository' -d 'Path of existing source repository to transfer archives from' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -x -n "__borgmatic_current_arg --source-repository"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to transfer (or "latest"), defaults to transferring all archives' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--upgrader' -d 'Upgrader type used to convert the transferred data, e.g. "From12To20" to upgrade data from Borg 1.2 to 2.0 format, defaults to no conversion' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress as each archive is transferred' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only transfer archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Only transfer first N archives after other filters are applied' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Only transfer last N archives after other filters are applied' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Transfer archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Transfer archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Transfer archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Transfer archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from transfer"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to prune (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'When pruning, only consider archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--stats' -d 'Display statistics of the pruned archive [Borg 1 only]' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'List archives kept/pruned' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Prune archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Prune archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Prune archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Prune archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from prune"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to prune (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'When pruning, only consider archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--stats' -d 'Display statistics of the pruned archive [Borg 1 only]' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'List archives kept/pruned' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Prune archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Prune archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Prune archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Prune archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -p"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to compact (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from compact"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress as each segment is compacted' -n "__fish_seen_subcommand_from compact"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cleanup-commits' -d 'Cleanup commit-only 17-byte segment files left behind by Borg 1.1 [flag in Borg 1.2 only]' -n "__fish_seen_subcommand_from compact"
complete -c borgmatic -f -n "$exact_option_condition" -a '--threshold' -d 'Minimum saved space percentage threshold for compacting a segment, defaults to 10' -n "__fish_seen_subcommand_from compact"
complete -c borgmatic -x -n "__borgmatic_current_arg --threshold"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from compact"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to backup to (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is backed up' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--stats' -d 'Display statistics of archive' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list --files' -d 'Show per-file details' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--comment' -d 'Add a comment text to the archive' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from create"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to backup to (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is backed up' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--stats' -d 'Display statistics of archive' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list --files' -d 'Show per-file details' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--comment' -d 'Add a comment text to the archive' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -C"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to check (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is checked' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repair' -d 'Attempt to repair any inconsistencies found (for interactive use)' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '--max-duration' -d 'How long to check the repository before interrupting the check, defaults to no interruption' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only check archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--only' -d 'Run a particular consistency check (repository, archives, data, extract, or spot) instead of configured checks (subject to configured frequency, can specify flag multiple times)' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -a 'repository archives data extract spot' -n "__borgmatic_current_arg --only"
complete -c borgmatic -f -n "$exact_option_condition" -a '--force' -d 'Ignore configured check frequencies and run checks unconditionally' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from check"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of specific existing repository to check (must be already specified in a borgmatic configuration file), quoted globs supported' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is checked' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repair' -d 'Attempt to repair any inconsistencies found (for interactive use)' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '--max-duration' -d 'How long to check the repository before interrupting the check, defaults to no interruption' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only check archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--only' -d 'Run a particular consistency check (repository, archives, data, extract, or spot) instead of configured checks (subject to configured frequency, can specify flag multiple times)' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -a 'repository archives data extract spot' -n "__borgmatic_current_arg --only"
complete -c borgmatic -f -n "$exact_option_condition" -a '--force' -d 'Ignore configured check frequencies and run checks unconditionally' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -k"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to delete or delete archives from, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Archive name, hash, or series to delete' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'Show details for the deleted archives' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--stats' -d 'Display statistics for the deleted archives' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cache-only' -d 'Delete only the local cache for the given repository' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--force' -d 'Force deletion of corrupted archives, can be given twice if once does not work' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-security-info' -d 'Do not delete the local security info when deleting a repository' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--save-space' -d 'Work slower, but using less space [Not supported in Borg 2.x+]' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--checkpoint-interval' -d 'Write a checkpoint at the given interval, defaults to 1800 seconds (30 minutes)' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -x -n "__borgmatic_current_arg --checkpoint-interval"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only delete archives with names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Delete first N archives after other filters are applied' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Delete last N archives after other filters are applied' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Delete archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Delete archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Delete archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Delete archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to extract, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to extract (or "latest")' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -x -n "__borgmatic_current_arg --archive"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path --restore-path' -d 'Path to extract from archive, can specify flag multiple times, defaults to the entire archive' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path --restore-path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--destination' -d 'Directory to extract files into, defaults to the current directory' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --destination"
complete -c borgmatic -f -n "$exact_option_condition" -a '--strip-components' -d 'Number of leading path components to remove from each extracted path or "all" to strip all leading path components. Skip paths with fewer elements' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -x -n "__borgmatic_current_arg --strip-components"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is extracted' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from extract"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to extract, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to extract (or "latest")' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -x -n "__borgmatic_current_arg --archive"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path --restore-path' -d 'Path to extract from archive, can specify flag multiple times, defaults to the entire archive' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path --restore-path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--destination' -d 'Directory to extract files into, defaults to the current directory' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --destination"
complete -c borgmatic -f -n "$exact_option_condition" -a '--strip-components' -d 'Number of leading path components to remove from each extracted path or "all" to strip all leading path components. Skip paths with fewer elements' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -x -n "__borgmatic_current_arg --strip-components"
complete -c borgmatic -f -n "$exact_option_condition" -a '--progress' -d 'Display progress for each file as it is extracted' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -x"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from config"
complete -c borgmatic -f -n "$exact_option_condition" -a '' -d '' -n "__fish_seen_subcommand_from config"
complete -c borgmatic -f -a 'bootstrap generate validate' -n "__borgmatic_current_arg "
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to export from, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to export (or "latest")' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -x -n "__borgmatic_current_arg --archive"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path' -d 'Path to export from archive, can specify flag multiple times, defaults to the entire archive' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--destination' -d 'Path to destination export tar file, or "-" for stdout (but be careful about dirtying output with --verbosity or --list)' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --destination"
complete -c borgmatic -f -n "$exact_option_condition" -a '--tar-filter' -d 'Name of filter program to pipe data through' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list --files' -d 'Show per-file details' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -f -n "$exact_option_condition" -a '--strip-components' -d 'Number of leading path components to remove from each exported path. Skip paths with fewer elements' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -x -n "__borgmatic_current_arg --strip-components"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from export-tar"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to use, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to mount (or "latest")' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mount-point' -d 'Path where filesystem is to be mounted' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --mount-point"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path' -d 'Path to mount from archive, can specify multiple times, defaults to the entire archive' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--foreground' -d 'Stay in foreground until ctrl-C is pressed' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Mount first N archives after other filters are applied' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Mount last N archives after other filters are applied' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Mount archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Mount archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Mount archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Mount archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--options' -d 'Extra Borg mount options' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from mount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to use, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to mount (or "latest")' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mount-point' -d 'Path where filesystem is to be mounted' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --mount-point"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path' -d 'Path to mount from archive, can specify multiple times, defaults to the entire archive' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--foreground' -d 'Stay in foreground until ctrl-C is pressed' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Mount first N archives after other filters are applied' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Mount last N archives after other filters are applied' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Mount archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Mount archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Mount archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Mount archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--options' -d 'Extra Borg mount options' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -m"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mount-point' -d 'Path of filesystem to unmount' -n "__fish_seen_subcommand_from umount"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --mount-point"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from umount"
complete -c borgmatic -f -n "$exact_option_condition" -a '--mount-point' -d 'Path of filesystem to unmount' -n "__fish_seen_subcommand_from -u"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --mount-point"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -u"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to delete, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'Show details for the archives in the given repository' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--force' -d 'Force deletion of corrupted archives, can be given twice if once does not work' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cache-only' -d 'Delete only the local cache for the given repository' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-security-info' -d 'Do not delete the local security info when deleting a repository' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from repo-delete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to delete, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'Show details for the archives in the given repository' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--force' -d 'Force deletion of corrupted archives, can be given twice if once does not work' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--cache-only' -d 'Delete only the local cache for the given repository' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--keep-security-info' -d 'Do not delete the local security info when deleting a repository' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from rdelete"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to restore from, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to restore from (or "latest")' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -x -n "__borgmatic_current_arg --archive"
complete -c borgmatic -f -n "$exact_option_condition" -a '--data-source --database' -d 'Name of data source (e.g. database) to restore from the archive, must be defined in borgmatic'"'"'s configuration, can specify the flag multiple times, defaults to all data sources in the archive' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--schema' -d 'Name of schema to restore from the data source, can specify flag multiple times, defaults to all schemas. Schemas are only supported for PostgreSQL and MongoDB databases' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--hostname' -d 'Database hostname to restore to. Defaults to the "restore_hostname" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--port' -d 'Database port to restore to. Defaults to the "restore_port" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--container' -d 'Container to restore to. Defaults to the "restore_container" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--username' -d 'Username with which to connect to the database. Defaults to the "restore_username" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--password' -d 'Password with which to connect to the restore database. Defaults to the "restore_password" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--restore-path' -d 'Path to restore SQLite database dumps to. Defaults to the "restore_path" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-label' -d 'The label where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-hostname' -d 'The hostname where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-container' -d 'The container where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-port' -d 'The port where the dump to restore came from (if that port is in borgmatic'"'"'s configuration), only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -x -n "__borgmatic_current_arg --original-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--hook' -d 'The name of the data source hook for the dump to restore, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from restore"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to restore from, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to restore from (or "latest")' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -x -n "__borgmatic_current_arg --archive"
complete -c borgmatic -f -n "$exact_option_condition" -a '--data-source --database' -d 'Name of data source (e.g. database) to restore from the archive, must be defined in borgmatic'"'"'s configuration, can specify the flag multiple times, defaults to all data sources in the archive' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--schema' -d 'Name of schema to restore from the data source, can specify flag multiple times, defaults to all schemas. Schemas are only supported for PostgreSQL and MongoDB databases' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--hostname' -d 'Database hostname to restore to. Defaults to the "restore_hostname" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--port' -d 'Database port to restore to. Defaults to the "restore_port" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--container' -d 'Container to restore to. Defaults to the "restore_container" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--username' -d 'Username with which to connect to the database. Defaults to the "restore_username" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--password' -d 'Password with which to connect to the restore database. Defaults to the "restore_password" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--restore-path' -d 'Path to restore SQLite database dumps to. Defaults to the "restore_path" option in borgmatic'"'"'s configuration' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-label' -d 'The label where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-hostname' -d 'The hostname where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-container' -d 'The container where the dump to restore came from, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--original-port' -d 'The port where the dump to restore came from (if that port is in borgmatic'"'"'s configuration), only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -x -n "__borgmatic_current_arg --original-port"
complete -c borgmatic -f -n "$exact_option_condition" -a '--hook' -d 'The name of the data source hook for the dump to restore, only necessary if you need to disambiguate dumps' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -r"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to list, defaults to the configured repositories, quoted globs supported' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--short' -d 'Output only archive names' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--format' -d 'Format for archive listing' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only list archive names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'List first N archives after other filters are applied' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'List last N archives after other filters are applied' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'List archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'List archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'List archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'List archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--deleted' -d 'List only deleted archives that haven'"'"'t yet been compacted [Borg 2.x+ only]' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from repo-list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to list, defaults to the configured repositories, quoted globs supported' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--short' -d 'Output only archive names' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--format' -d 'Format for archive listing' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only list archive names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'List first N archives after other filters are applied' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'List last N archives after other filters are applied' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'List archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'List archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'List archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'List archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--deleted' -d 'List only deleted archives that haven'"'"'t yet been compacted [Borg 2.x+ only]' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from rlist"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository containing archive to list, defaults to the configured repositories, quoted globs supported' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to list (or "latest")' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path' -d 'Path or pattern to list from a single selected archive (via "--archive"), can specify flag multiple times, defaults to listing the entire archive' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--find' -d 'Partial path or pattern to search for and list across multiple archives, can specify flag multiple times' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --find"
complete -c borgmatic -f -n "$exact_option_condition" -a '--short' -d 'Output only path names' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--format' -d 'Format for file listing' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only list archive names matching this pattern' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'List first N archives after other filters are applied' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'List last N archives after other filters are applied' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --exclude' -d 'Exclude paths matching the pattern' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -x -n "__borgmatic_current_arg -e --exclude"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-from' -d 'Exclude paths from exclude file, one per line' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --exclude-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pattern' -d 'Include or exclude paths matching a pattern' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns-from' -d 'Include or exclude paths matching patterns from pattern file, one per line' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --patterns-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from list"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository containing archive to list, defaults to the configured repositories, quoted globs supported' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Name or hash of a single archive to list (or "latest")' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--path' -d 'Path or pattern to list from a single selected archive (via "--archive"), can specify flag multiple times, defaults to listing the entire archive' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --path"
complete -c borgmatic -f -n "$exact_option_condition" -a '--find' -d 'Partial path or pattern to search for and list across multiple archives, can specify flag multiple times' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --find"
complete -c borgmatic -f -n "$exact_option_condition" -a '--short' -d 'Output only path names' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--format' -d 'Format for file listing' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only list archive names matching this pattern' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'List first N archives after other filters are applied' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'List last N archives after other filters are applied' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '-e --exclude' -d 'Exclude paths matching the pattern' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -x -n "__borgmatic_current_arg -e --exclude"
complete -c borgmatic -f -n "$exact_option_condition" -a '--exclude-from' -d 'Exclude paths from exclude file, one per line' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --exclude-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '--pattern' -d 'Include or exclude paths matching a pattern' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--patterns-from' -d 'Include or exclude paths matching patterns from pattern file, one per line' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -Fr -n "__borgmatic_current_arg --patterns-from"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -l"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to show info for, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from repo-info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from repo-info"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from repo-info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to show info for, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from rinfo"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from rinfo"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from rinfo"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository containing archive to show info for, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Archive name, hash, or series to show info for (or "latest")' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only show info for archive names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Show info for first N archives after other filters are applied' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Show info for last N archives after other filters are applied' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Show info for archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Show info for archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Show info for archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Show info for archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from info"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository containing archive to show info for, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Archive name, hash, or series to show info for (or "latest")' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--json' -d 'Output results as JSON' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only show info for archive names, hashes, or series matching this pattern' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '--sort-by' -d 'Comma-separated list of sorting keys' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -x -n "__borgmatic_current_arg --sort-by"
complete -c borgmatic -f -n "$exact_option_condition" -a '--first' -d 'Show info for first N archives after other filters are applied' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -x -n "__borgmatic_current_arg --first"
complete -c borgmatic -f -n "$exact_option_condition" -a '--last' -d 'Show info for last N archives after other filters are applied' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -x -n "__borgmatic_current_arg --last"
complete -c borgmatic -f -n "$exact_option_condition" -a '--oldest' -d 'Show info for archives within a specified time range starting from the timestamp of the oldest archive (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newest' -d 'Show info for archives within a time range that ends at timestamp of the newest archive and starts a specified time range ago (e.g. 7d or 12m) [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--older' -d 'Show info for archives that are older than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--newer' -d 'Show info for archives that are newer than the specified time range (e.g. 7d or 12m) from the current time [Borg 2.x+ only]' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from -i"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to break the lock for, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from break-lock"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from break-lock"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from key"
complete -c borgmatic -f -n "$exact_option_condition" -a '' -d '' -n "__fish_seen_subcommand_from key"
complete -c borgmatic -f -a 'export import change-passphrase' -n "__borgmatic_current_arg "
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository containing archive to recreate, defaults to the configured repository if there is only one, quoted globs supported' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Archive name, hash, or series to recreate' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--list' -d 'Show per-file details' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--target' -d 'Create a new archive from the specified archive (via --archive), without replacing it' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--comment' -d 'Add a comment text to the archive or, if an archive is not provided, to all matching archives' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--timestamp' -d 'Manually override the archive creation date/time (UTC)' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '-a --match-archives --glob-archives' -d 'Only consider archive names, hashes, or series matching this pattern [Borg 2.x+ only]' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -x -n "__borgmatic_current_arg -a --match-archives --glob-archives"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from recreate"
complete -c borgmatic -f -n "$exact_option_condition" -a '--repository' -d 'Path of repository to pass to Borg, defaults to the configured repositories, quoted globs supported' -n "__fish_seen_subcommand_from borg"
complete -c borgmatic -f -n "$exact_option_condition" -a '--archive' -d 'Archive name, hash, or series to pass to Borg (or "latest")' -n "__fish_seen_subcommand_from borg"
complete -c borgmatic -f -n "$exact_option_condition" -a '--' -d 'Options to pass to Borg, command first ("create", "list", etc). "--" is optional. To specify the repository or the archive, you must use --repository or --archive instead of providing them here.' -n "__fish_seen_subcommand_from borg"
complete -c borgmatic -x -n "__borgmatic_current_arg --"
complete -c borgmatic -f -n "$exact_option_condition" -a '-h --help' -d 'Show this help message and exit' -n "__fish_seen_subcommand_from borg"
