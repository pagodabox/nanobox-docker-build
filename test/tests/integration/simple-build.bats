# source docker helpers
. util/helpers.sh
. util/warehouse.sh

@test "Start Container" {
  start_container
}

@test "Run user Hook" {
  run run_hook "user" "$(payload user)"
  print_output
  [ "$status" -eq 0 ]

  # ensure the keys were installed
  run docker exec build bash -c "[ -f /home/gonano/.ssh/id_rsa ] "
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -f /home/gonano/.ssh/id_rsa.pub ] "
  [ "$status" -eq 0 ]
}

@test "Run configure hook" {
  run run_hook "configure" "$(payload configure)"
  print_output
  [ "$status" -eq 0 ]

  # verify required directories exist
  run docker exec build bash -c "[ -d /data ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /data/etc ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /data/etc/env.d ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/build ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /code ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/live ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache/app ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache/lib_dirs ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /opt/nanobox/engines ]"
  [ "$status" -eq 0 ]

  # todo: what about pkgin?
}

@test "Run fetch hook" {
  run run_hook "fetch" "$(payload fetch)"
  print_output
  [ "$status" -eq 0 ]

  # verify the code was copied over
  run docker exec build bash -c "[ -f /code/package.json ]"
  print_output
  [ "$status" -eq 0 ]

  # verify the nodejs engine is installed
  run docker exec build bash -c "[ -f /opt/nanobox/engines/custom/lib/nodejs.sh ]"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run setup hook" {
  run run_hook "setup" "$(payload setup)"
  print_output
  [ "$status" -eq 0 ]

  # verify? - this engine doesn't have a setup so, it has no verification
}

@test "Run boxfile hook" {
  run run_hook "boxfile" "$(payload boxfile)"
  print_output
  [ "$status" -eq 0 ]

  # verify the output
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build:" ]
  [ "${lines[2]}" = "  engine: nodejs#refactor/v1" ]
  [ "${lines[3]}" = "  image: nanobox/build" ]
  [ "${lines[4]}" = "  lib_dirs:" ]
  [ "${lines[5]}" = "  - node_modules" ]
}

@test "Run prepare hook" {
  run run_hook "prepare" "$(payload prepare)"
  print_output
  [ "$status" -eq 0 ]

  # verify prepare hook ran?
  run docker exec build bash -c "[ -f /data/bin/node ]"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run build hook" {
  run run_hook "build" "$(payload build)"
  print_output
  [ "$status" -eq 0 ]

  # verify build hook?
}

@test "Run pack hook" {
  run run_hook "pack" "$(payload pack)"
  print_output
  [ "$status" -eq 0 ]

  # Verify
  run docker exec build bash -c "[ -f /mnt/live/server.js ]"
  print_output
  [ "$status" -eq 0 ]
}

@test "Start warehouse" {
  start_warehouse
}

@test "Run publish hook" {
  run run_hook "publish" "$(payload publish)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Stop Container" {
  stop_container
  stop_warehouse
}
