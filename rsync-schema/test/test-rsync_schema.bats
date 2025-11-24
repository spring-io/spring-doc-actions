setup () {
  load 'test_helper/common-setup'
  _common_setup
}

# executed after each test
teardown() {
    _common_teardown
}

@test "no arguments" {
    run rsync_schema.sh
    assert [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" 'Error: Missing option .*'
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

@test "usage" {
    run rsync_schema.sh
    assert [ "$status" -eq 1 ]
    assert [ "${output}" = "Error: Missing option '--ssh-host'
usage: rsync_schema.sh [OPTION]...

   --ssh-host=SSH_HOST              the ssh host in the format USER@HOST to connect to ssh
   --ssh-private-key-path=KEY_PATH  the path to the private key used to connect to ssh
   --ssh-host-path=HOST_PATH        the path of the ssh server to sync the documentation to
   --dry-run                        signals that rsync should be in dry run mode
   --local-path=PATH                the local directory path to sync to the server" ]
}

@test "invalid long option" {
    run rsync_schema.sh --invalid
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "getopt: unrecognized option '--invalid'" ]
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

# --ssh-host HOST --ssh-host-path HOST_PATH --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
@test "missing ssh-host" {
    run rsync_schema.sh --ssh-host-path HOST_PATH --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-host'" ]
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

@test "missing ssh-host-path" {
    run rsync_schema.sh --ssh-host HOST --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-host-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

@test "missing local-path" {
    run rsync_schema.sh --ssh-host HOST --ssh-host-path HOST_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--local-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

@test "missing ssh-private-key-path" {
    run rsync_schema.sh --ssh-host HOST --ssh-host-path HOST_PATH --local-path LOCAL_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-private-key-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_schema.sh [OPTION]...' ]
}

@test "when exists .htaccess included before any excludes" {
    local dir="${BATS_RESOURCE_TEMP_DIR}/htaccess"
    stub rsync "$(capture_program_args "rsync")"

    run rsync_schema.sh --ssh-host HOST --ssh-host-path HOST_PATH --ssh-private-key-path PRIVATE_KEY_PATH --local-path "$dir"

    local rsync_args=$(get_program_args "rsync")
    assert_success
    assert_regex "$rsync_args" "^-avz --delete --include /.htaccess "
    unstub rsync
}

@test "when does not exists .htaccess not included" {
    local dir="${BATS_RESOURCE_TEMP_DIR}/no-htaccess"
    stub rsync "$(capture_program_args "rsync")"

    run rsync_schema.sh --ssh-host HOST --ssh-host-path HOST_PATH --ssh-private-key-path PRIVATE_KEY_PATH --local-path "$dir"

    local rsync_args=$(get_program_args "rsync")
    assert_success
    refute_regex "$rsync_args" " --include /.htaccess "
    unstub rsync
}

@test "when rsync fails script returns non-zero" {
    local dir="${BATS_RESOURCE_TEMP_DIR}/no-htaccess"
    stub rsync "exit 1"

    run rsync_schema.sh --ssh-host HOST --ssh-host-path HOST_PATH --ssh-private-key-path PRIVATE_KEY_PATH --local-path "$dir"

    assert_failure
    unstub rsync
}