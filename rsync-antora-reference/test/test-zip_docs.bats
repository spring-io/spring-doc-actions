setup () {
  load 'test_helper/common-setup'
  _common_setup
}

# executed after each test
teardown() {
    _common_teardown
}

@test "no arguments" {
    run zip_docs.sh
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--zip-name' must end with .zip but got ''" ]
    assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

@test "usage" {
    run zip_docs.sh
    assert [ "$status" -eq 1 ]
    assert [ "${output}" = "Error:  '--zip-name' must end with .zip but got ''
usage: zip_docs.sh [OPTION]...

   --zip-name=NAME                the name of the zip file to be created
   --ssh-docs-path=PATH           the full path that the docs that should be included in the zip file (e.g. https://docs.spring.io/spring-security/reference/ is \${HTTP_DOCS}/spring-security/reference)" ]
}

@test "invalid long option" {
    run zip_docs.sh --invalid
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "getopt: unrecognized option '--invalid'" ]
    assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

# --zip-name spring-security-docs.zip --ssh-docs-path /spring-security/reference
@test "missing github-repository" {
    run zip_docs.sh --ssh-docs-path /spring-security/reference
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--zip-name' must end with .zip but got ''" ]
    assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

@test "invalid zip-name ZIP" {
  run zip_docs.sh --zip-name ZIP --ssh-docs-path /spring-security/reference
  assert [ "$status" -eq 1 ]
  assert [ "${lines[0]}" = "Error:  '--zip-name' must end with .zip but got 'ZIP'" ]
  assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

@test "missing ssh-docs-path" {
    run zip_docs.sh --zip-name spring-security-docs.zip
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--ssh-docs-path' must start with / but got ''" ]
    assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

@test "invalid ssh-docs-path spring-security/reference" {
    run zip_docs.sh --zip-name spring-security-docs.zip --ssh-docs-path spring-security/reference
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--ssh-docs-path' must start with / but got 'spring-security/reference'" ]
    assert [ "${lines[1]}" = 'usage: zip_docs.sh [OPTION]...' ]
}

@test "missing --ssh-docs-path" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/MISSING"
  run zip_docs.sh --zip-name spring-security-docs.zip --ssh-docs-path "$dir"
  assert_failure
  assert_output "Error: Directory --ssh-docs-path '$dir' cannot be zipped because it does not exist"
}

@test "success" {
  stub zip "$(capture_program_args "zip")"

  local dir="${BATS_RESOURCE_TEMP_DIR}/spring-security"
  run zip_docs.sh --zip-name spring-security-docs.zip --ssh-docs-path "$dir"

  assert_success
  assert_output "Zipping content in '$dir' to 'spring-security-docs.zip'
$(pwd)"
  assert_program_args "zip" "-r spring-security-docs.zip . *"

  unstub zip
}