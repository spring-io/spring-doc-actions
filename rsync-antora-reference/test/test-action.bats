setup () {
  load 'test_helper/common-setup'
  _common_setup
}

# executed after each test
teardown() {
    _common_teardown
}

@test "no arguments" {
    run action.sh
    assert [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" 'Error: Missing option .*'
    assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "usage" {
    run action.sh
    assert [ "$status" -eq 1 ]
    assert [ "${output}" = "Error: Missing option '--docs-username'
usage: action.sh [OPTION]...

   --docs-username=USERNAME       the username used to connect to ssh
   --docs-host=HOST               the host to connect to ssh
   --docs-ssh-key=KEY             the private key used to connect to ssh
   --docs-ssh-host-key=HOST_KEY   the host key used to connect to ssh
   --dry-run                      signals that rsync should be in dry run mode
   --site-path=PATH               the local directory path to sync to the server. Default build/site
   --github-repository=GH_REPO    the github repository (e.g. spring-projects/spring-security)
   --httpdocs-path=PATH           the optional base httpdocs path (e.g. https://docs.spring.io/spring-security/reference would be /spring-security/reference)
                                  If this is set, then the project must own the directory by ensuring to have a .github-repository file with the
                                  <OWNER>/<REPOSITORY_NAME> as the content. The default is to use /\${REPOSITORY_NAME}/reference
                                  from --github-repository" ]
}

@test "invalid long option" {
    run action.sh --invalid
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "getopt: unrecognized option '--invalid'" ]
    assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

# --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security
@test "missing docs-username" {
    run action.sh --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--docs-username'" ]
    assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "missing docs-host" {
     run action.sh --docs-username USER --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security
     assert [ "$status" -eq 1 ]
     assert [ "${lines[0]}" = "Error: Missing option '--docs-host'" ]
     assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "missing docs-ssh-key" {
     run action.sh --docs-username USER --docs-host HOST --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security
     assert [ "$status" -eq 1 ]
     assert [ "${lines[0]}" = "Error: Missing option '--docs-ssh-key'" ]
     assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "docs-ssh-key with space" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key 'SSH KEY' --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security

    assert_success
    assert_output "" # No warnings due to spaces
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key SSH KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "missing docs-ssh-host-key" {
     run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --site-path SITE_PATH --github-repository spring-projects/spring-security
     assert [ "$status" -eq 1 ]
     assert [ "${lines[0]}" = "Error: Missing option '--docs-ssh-host-key'" ]
     assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "docs-ssh-host-key with space" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key 'SSH_KEY' --docs-ssh-host-key 'HOST KEY' --site-path SITE_PATH --github-repository spring-projects/spring-security

    assert_success
    assert_output "" # No warnings due to spaces
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key SSH_KEY --ssh-known-host HOST KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "missing github-repository" {
     run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH
     assert [ "$status" -eq 1 ]
     assert [ "${lines[0]}" = "Error: Missing option '--github-repository'" ]
     assert [ "${lines[1]}" = 'usage: action.sh [OPTION]...' ]
}

@test "valid arguments" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "missing site-path defaults build/site" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --github-repository spring-projects/spring-security

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path build/site --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
}

# had a bug using -e instead of -z
@test "site-path where path exists does not default build/site" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --site-path "$BATS_TEMP_DIR" --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --github-repository spring-projects/spring-security

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path $BATS_TEMP_DIR --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
}

@test "dry-run=true" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security --dry-run

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --dry-run"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "BUILD_REFNAME set" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    export BUILD_REFNAME=6.1.x
    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security --dry-run
    unset BUILD_REFNAME

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/spring-security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --build-ref-name 6.1.x --dry-run"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "httpdocs-path check httpdocs-path success" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub ssh "$(capture_program "ssh")"
    stub rsync_docs.sh "$(capture_program_args "rsync_docs")"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security --httpdocs-path /security/reference

    assert_success
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "ssh" "-i $HOME/.ssh/spring-projects/spring-security USER@HOST bash -s -- --github-repository \"spring-projects/spring-security\" --ssh-docs-path \"/opt/www/domains/spring.io/docs/htdocs/security/reference/\""
    assert_regex "$(get_program_stdin 'ssh')" 'check_github_repository_owner'
    assert_program_args "rsync_docs" "--ssh-host USER@HOST --ssh-host-path /opt/www/domains/spring.io/docs/htdocs/security/reference/ --local-path SITE_PATH --ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub ssh
    unstub rsync_docs.sh
    unstub cleanup_ssh.sh
}

@test "httpdocs-path check httpdocs-path failed" {
    stub setup_ssh.sh "$(capture_program_args "setup_ssh")"
    stub ssh "$(capture_program_args "ssh"); exit 2"
    stub cleanup_ssh.sh "$(capture_program_args "cleanup_ssh")"

    run action.sh --docs-username USER --docs-host HOST --docs-ssh-key KEY --docs-ssh-host-key HOST_KEY --site-path SITE_PATH --github-repository spring-projects/spring-security --httpdocs-path /security/reference

    assert_failure
    assert_program_args "setup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security --ssh-private-key KEY --ssh-known-host HOST_KEY"
    assert_program_args "ssh" "-i $HOME/.ssh/spring-projects/spring-security USER@HOST bash -s -- --github-repository \"spring-projects/spring-security\" --ssh-docs-path \"/opt/www/domains/spring.io/docs/htdocs/security/reference/\""
    assert_program_args "cleanup_ssh" "--ssh-private-key-path $HOME/.ssh/spring-projects/spring-security"

    unstub --allow-missing setup_ssh.sh
    unstub ssh
    unstub cleanup_ssh.sh
}