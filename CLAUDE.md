# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ada language monorepo using [Alire](https://alire.ada.dev/) (Ada's package manager) and GPRbuild. The primary product is `ada_lib`, a general-purpose Ada library used by applications (e.g., `applications/video/camera`).

The repository consists of Git submodules plus local Alire crates pinned to sibling directories:

| Directory | Crate | Purpose |
|---|---|---|
| `ada_lib/ada_lib_base/` | `ada_lib_base` | Core foundational packages: trace, strings, OS, options parsing, help |
| `ada_lib/ada_lib_options/` | `ada_lib_options` | Command-line flag/option registration |
| `ada_lib/` | `ada_lib` | Main library: database, sockets, configuration, templates, timers, GNOGA |
| `ada_lib/aunit/` | `ada_lib_aunit` | AUnit extensions for ada_lib testing |
| `ada_lib/ada_lib_tests/` | `ada_lib_tests` | AUnit test executable for ada_lib |
| `gnoga_lib/` | `gnoga_ada_lib` | Ada extensions for GNOGA (web framework) |
| `aunit/` | `aunit` | Local AUnit framework crate |
| `vendor/github.com/gnoga/` | `gnoga` | GNOGA web framework |
| `applications/` | — | Applications built on ada_lib (video/camera) |

The root `alr_environment.gpr` is an abstract GPR project that provides shared compiler switches, build mode, and linker options to all sub-crates via `[[pins]]` in each `alire.toml`.

## Build System

### BUILD_MODE

All builds take a `BUILD_MODE` environment variable (set via `-XBUILD_MODE=...` in alr):

- `execute` — normal library/program build
- `help_test` — builds `bin/help_test` (tests the `--help`/`-h` option output)
- `aunit` — builds `bin/test_ada_lib` (AUnit test runner)

### Build Commands

Build a single crate from its directory:
```zsh
# From any crate directory (e.g., ada_lib/ada_lib_tests/)
../../global_build.sh execute program test_ada_lib
../../global_build.sh help_test program test_ada_lib
# Or via the local wrapper:
./build.sh execute test_ada_lib
```

Build everything from the repo root:
```zsh
./build_all.sh
# Or individually:
./global_build.sh all library ada_lib      # builds all modes
./global_build.sh execute library ada_lib  # builds only execute mode
```

The core alr invocation inside `global_build.sh`:
```zsh
alr build -- -j10 -s -k -gnatE -vl -v -XBUILD_MODE=<mode>
```

## Testing

### Run All Tests

```zsh
./run_all_tests.sh
```

### Run ada_lib Unit Tests

From `ada_lib/ada_lib_tests/`:
```zsh
# Run all suites
./run.sh local all all

# Run a specific suite
./run.sh local all <SuiteName>

# Run a specific test routine in a suite
./run.sh local <SuiteName> <RoutineName>

# List available suites
./run.sh -@l
```

The `run.sh` script calls `global_run.sh` which launches `bin/test_ada_lib` (or `bin/help_test` for `help_test` mode). The `USE_DBDAEMON` flag controls whether a local/remote DB daemon process is expected.

### Test Architecture

Tests use a custom AUnit wrapper:
- Test types extend `Ada_Lib.Unit_Test.Test_Cases.Test_Case_Type` (which extends `AUnit.Test_Cases.Test_Case`)
- Each test module exports a `Suite` function returning `Access_Test_Suite`
- Suites are registered in `ada_lib/src/unit_test/ada_lib-test-run_suite.adb`
- Suite names (for `-s` flag) come from the `Suite_Name` constant in each test package

## Key Architectural Patterns

### Tracing / Logging

All packages use `Ada_Lib.Trace` for debug output. Standard idiom:
```ada
with Ada_Lib.Trace; use Ada_Lib.Trace;

-- At subprogram entry/exit:
Log_In  (Debug, "message " & value'img);
Log_Out (Debug, "message");

-- Mid-routine:
Log_Here (Debug, "message");

-- `Here` = current source location, `Who` = enclosing entity
Log_Here (Debug, "at " & Here);
```

`Debug` is typically a `Boolean` variable renaming a package-specific trace flag from `Ada_Lib.Trace_Options_Package`.

### Options Processing

Command-line options use a multi-level hierarchy:
1. `Ada_Lib.Options` — base flag/modifier type definitions
2. `Ada_Lib.Options.Runstring` — registration and processing of option letters
3. `Ada_Lib.Options.Program` — `Nested_Program_Options_Type` base for program-specific option records
4. `Ada_Lib.Options.Verification` — validates options before execution
5. `Ada_Lib.Options.AUnit_Lib` — AUnit-specific option type (`Aunit_Program_Options_Type`)

The pattern in `main` programs: `Initialize` → `Process` → `Post_Process`.

### Package Naming

Ada child packages follow `Ada_Lib.*` hierarchy. File names use hyphens for dots: `ada_lib-database-server.adb` = `Ada_Lib.Database.Server`.

### Strings

`Ada_Lib.Strings.Unlimited.String_Type` is the preferred unbounded string type (wraps `Ada.Strings.Unbounded`). Import with `use Ada_Lib.Strings.Unlimited` for operator overloading.

## Compiler Switches

Key switches set in `alr_environment.gpr` (applied to all sub-crates):
- `-gnat2022` — Ada 2022 standard
- `-gnata` — Enable assertions, pre/post conditions
- `-gnatwa` — All warnings enabled
- `-gnatVa` — All validity checks
- `-g` — Debug info
- `-gnatn` — Limited inlining

## IDE

SlickEdit project files (`.vpj`) are in `IDE/SlickEdit/`. The build and run commands in SlickEdit invoke `build.sh` and `global_run.sh` with appropriate parameters.
