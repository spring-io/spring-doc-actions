setup () {
  load 'test_helper/common-setup'
  _common_setup
}

# executed after each test
teardown() {
    _common_teardown
}

@test "no arguments" {
    run check_github_repository_owner.sh
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--github-repository' must be in the form of <owner>/<name> but got ''" ]
    assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

@test "usage" {
    run check_github_repository_owner.sh
    assert [ "$status" -eq 1 ]
    assert [ "${output}" = "Error:  '--github-repository' must be in the form of <owner>/<name> but got ''
usage: check_github_repository_owner.sh [OPTION]...

   --github-repository=REPO       the github repository (e.g. spring-projects/spring-security)
   --ssh-docs-path=PATH           the full path that the docs will be deployed to (e.g. https://docs.spring.io/spring-security/reference/ is \${HTTP_DOCS}/spring-security/reference)" ]
}

@test "invalid long option" {
    run check_github_repository_owner.sh --invalid
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "getopt: unrecognized option '--invalid'" ]
    assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

# --github-repository spring-projects/spring-security --ssh-docs-path /spring-security/reference
@test "missing github-repository" {
    run check_github_repository_owner.sh --ssh-docs-path /spring-security/reference
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--github-repository' must be in the form of <owner>/<name> but got ''" ]
    assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

@test "invalid github-repository REPO" {
  run check_github_repository_owner.sh --github-repository REPO --ssh-docs-path /spring-security/reference
  assert [ "$status" -eq 1 ]
  assert [ "${lines[0]}" = "Error:  '--github-repository' must be in the form of <owner>/<name> but got 'REPO'" ]
  assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

@test "missing ssh-docs-path" {
    run check_github_repository_owner.sh --github-repository spring-projects/spring-security
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--ssh-docs-path' must start with and not equal / but got ''" ]
    assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

@test "invalid ssh-docs-path spring-security/reference" {
    run check_github_repository_owner.sh --github-repository spring-projects/spring-security --ssh-docs-path spring-security/reference
    assert [ "$status" -eq 1 ]
    assert [ "${lines[0]}" = "Error:  '--ssh-docs-path' must start with and not equal / but got 'spring-security/reference'" ]
    assert [ "${lines[1]}" = 'usage: check_github_repository_owner.sh [OPTION]...' ]
}

# https://github.com/spring-io/spring-doc-actions/issues/20
@test "Allow httpdocs-path that does not end in /reference" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/antora"
  run check_github_repository_owner.sh --github-repository spring-projects/spring-security  --ssh-docs-path "$dir"
  assert_success
  assert_output "Owner is verified"
}

@test "existing project with valid marker file" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/spring-security/reference"
  run check_github_repository_owner.sh --github-repository spring-projects/spring-security  --ssh-docs-path "$dir"
  assert_success
  assert_output "Owner is verified"
}

@test "existing project with invalid marker file" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/spring-security/reference"
  run check_github_repository_owner.sh --github-repository spring-projects/spring-security2  --ssh-docs-path "$dir"
  assert_failure
  assert_output "Failed to verify that $dir is owned by spring-projects/spring-security2 because the file $dir/.github-repository contains spring-projects/spring-security"
}

@test "new-project" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/new-project/reference"
  run check_github_repository_owner.sh --github-repository spring-projects/new-project  --ssh-docs-path "$dir"
  assert_success
  assert_output "Directory $dir does not exist. Marking as owned by spring-projects/new-project"
  assert [ "spring-projects/new-project" = "$(cat $dir/.github-repository)" ]
}

@test "no-reference" {
  local dir="${BATS_RESOURCE_TEMP_DIR}/no-reference/reference"
  run check_github_repository_owner.sh --github-repository spring-projects/no-reference --ssh-docs-path "$dir"
  assert_success
  assert_output "Directory $dir does not exist. Marking as owned by spring-projects/no-reference"
  assert [ "spring-projects/no-reference" = "$(cat $dir/.github-repository)" ]
}