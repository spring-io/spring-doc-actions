setup () {
  load 'test_helper/common-setup'
  _common_setup
}

# executed after each test
teardown() {
    _common_teardown
}

@test "no arguments" {
    run rsync_docs.sh
    assert [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" 'Error: Missing option .*'
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}

@test "usage" {
    run rsync_docs.sh
    assert [ "$status" -eq 1 ]
    assert [ "${output}" = "Error: Missing option '--ssh-host'
usage: rsync_docs.sh [OPTION]...

   --ssh-host=SSH_HOST              the ssh host in the format USER@HOST to connect to ssh
   --ssh-private-key-path=KEY_PATH  the path to the private key used to connect to ssh
   --ssh-host-path=HOST_PATH        the path of the ssh server to sync the documentation to
   --dry-run                        signals that rsync should be in dry run mode
   --local-path=PATH                the local directory path to sync to the server
   --build-ref-name=REF_NAME        the build_ref_name" ]
}

@test "invalid long option" {
    run rsync_docs.sh --invalid
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "getopt: unrecognized option '--invalid'" ]
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}

# --ssh-host HOST --ssh-host-path HOST_PATH --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
@test "missing ssh-host" {
    run rsync_docs.sh --ssh-host-path HOST_PATH --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-host'" ]
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}

@test "missing ssh-host-path" {
    run rsync_docs.sh --ssh-host HOST --local-path LOCAL_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-host-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}

@test "missing local-path" {
    run rsync_docs.sh --ssh-host HOST --ssh-host-path HOST_PATH --ssh-private-key-path PRIVATE_KEY_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--local-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}

@test "missing ssh-private-key-path" {
    run rsync_docs.sh --ssh-host HOST --ssh-host-path HOST_PATH --local-path LOCAL_PATH
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error: Missing option '--ssh-private-key-path'" ]
    assert [ "${lines[1]}" = 'usage: rsync_docs.sh [OPTION]...' ]
}