# Project: alr_environment

Ada 2022 monorepo managed with Alire (alr) and GNAT. Uses git submodules for component isolation.

## Repository Layout

```
alr_environment/         ← top-level repo (this CLAUDE.md lives here)
├── ada_lib/             ← shared Ada library (submodule)
│   ├── ada_lib_tests/   ← library unit tests
│   └── ada_lib_test_lib/
├── applications/        ← applications (video/camera) (submodule)
│   └── video/camera/
│       ├── driver/unit_test/
│       └── unit_test/
├── aunit/               ← forked AUnit test framework (submodule)
├── gnoga_lib/           ← Gnoga Ada web library (submodule)
│   ├── gnoga_ada_lib/
│   └── gnoga_options/
├── vendor/github.com/gnoga/  ← Gnoga framework (submodule)
├── src/                 ← top-level library source
├── IDE/SlickEdit/       ← SlickEdit IDE config
├── alire.toml           ← Alire crate manifest
├── alr_environment.gpr  ← root GPR project file
└── default_config.gpr   ← shared GNAT compiler switches
```

## Language & Toolchain

- **Language**: Ada 2022 (`-gnat2022` switch)
- **Compiler**: GNAT (GCC Ada)
- **Package manager**: Alire (`alr`) — crates defined in `alire.toml`
- **Project files**: GNAT Project (`.gpr`) — define source dirs, library type, switches
- **IDE**: SlickEdit (`.vtg` / `.vpj` project files)
- **Testing**: AUnit framework (custom fork in `aunit/` submodule)
- **Web UI**: Gnoga framework (Ada-to-JavaScript bridge)

## Build System

### Build modes (`BUILD_MODE` external variable)
- `execute` — normal application/library build
- `help_test` — builds help-test variant (skipped for libraries)

### Library types (`LIBRARY_TYPE` / `ALR_ENVIRONMENT_LIBRARY_TYPE`)
- `static` (default), `relocatable`, `static-pic`

### Key build commands

```bash
# Build this crate
./build.sh execute          # or: help_test | both | all

# Build all submodules in correct dependency order
./global_build.sh all library

# Direct alr invocation (from within a submodule dir)
alr build -- -j10 -s -k -gnatE -vl -v -XBUILD_MODE=execute
```

### Submodule build order (enforced by `global_build.sh`)
1. `aunit`
2. `ada_lib`
3. `ada_lib/aunit`
4. `ada_lib/ada_lib_test_lib`
5. `ada_lib/ada_lib_tests`
6. `applications/video/camera`
7. `applications/video/camera/driver`
8. `applications/video/camera/driver/unit_test`
9. `applications/video/camera/test_lib`
10. `applications/video/camera/unit_test`
11. `gnoga_lib/gnoga_ada_lib`
12. `gnoga_lib/gnoga_options`
13. `vendor/github.com/gnoga`
14. `.` (top-level)

## GNAT Compiler Flags (from `default_config.gpr`)

Always enabled:
- `-gnat2022` — Ada 2022 standard
- `-gnatE` — dynamic elaboration checks
- `-gnata` — enable Assert, Pre/Post conditions
- `-gnatwa` — all warnings
- `-gnatVa` — all validity checks
- `-gnatyO` — overriding subprograms must be marked `overriding`
- `-gnatyx` — check extra parentheses
- `-U -gnatu` — unit-by-unit compilation
- `-Og -g` — optimize for debug, include debug info
- `-Es` (binder) — symbolic traceback on exceptions

Style checks enabled: `-gnatyA`, `-gnatyB`, `-gnatype`, `-gnatyf`, `-gnatyp`, `-gnatyS`

## Testing

```bash
# Run all unit tests
./run_all_tests.sh

# Run specific test suites
cd ada_lib/ada_lib_tests && ./run.sh local all all
cd applications/video/camera/unit_test && ./driver_test.sh test
cd applications/video/camera/driver/unit_test && ./run.sh

# Run help tests only
./run_help_tests.sh
```

Tests use AUnit. Test directories follow `*_tests` or `*_test` naming.

## Version Control

All submodules are committed together using `check_in.sh`:

```bash
# Commit all submodules + top-level with same message
./check_in.sh "your commit message"

# Pull all submodules
./pull_all.sh

# Tag all submodules at once
./global_tag.sh <tag>

# Switch all submodules to a branch
./global_branch.sh <branch>
```

Submodule remotes use SSH: `git@github.com:wbullaughey/<name>`

Default branch: `master` (top-level), `main` (submodules)

## Ada Code Conventions

- Package hierarchy uses dot notation: `Ada_Lib.Strings`, `Ada_Lib.Strings.Bounded`, etc.
- Separate spec (`.ads`) and body (`.adb`) files
- Access types named with `_Access` suffix (e.g., `String_Access`, `String_Access_All`)
- Stream attributes explicitly set with `for Type'Read use ...`
- Unchecked_Deallocation wrapped in named `Free` procedures
- `Debug : Boolean := False;` package-level debug flag pattern
- Pre/Post conditions on subprograms (enforced at runtime via `-gnata`)
- Dynamic elaboration — beware of elaboration order; `pragma Elaborate_All` or `pragma Elaborate` may be needed

## Code Review Checklist (Ada-specific)

When reviewing Ada code in this repo:
- Check elaboration order — dynamic elaboration (`-gnatE`) means runtime checks, not compile-time
- Verify `overriding` keyword on all dispatching subprogram overrides (enforced by `-gnatyO`)
- Check access type use — prefer named `Free` procedures over inline deallocation
- Assert Pre/Post conditions are meaningful and tested
- Confirm new packages follow `Ada_Lib.*` hierarchy if they belong in `ada_lib`
- Check that new GPR source dirs are added to the correct `.gpr` file
- Verify `alire.toml` is updated if new external dependencies are added
- Confirm submodule pins (`alr_environment.gpr` `with` statements) are correct

## Debugging Notes

- Symbolic tracebacks enabled (`-Es`) — exceptions print full Ada call stack
- Build output logged to `list-*.txt` files in each directory
- Trace output written to `TRACE.txt` by build scripts
- `DO_TRACE=TRUE` in build scripts enables verbose tracing
- `DEBUG_OPTIONS="-vv -d"` in `global_build.sh` for alr verbose mode (uncomment to enable)
- Object files in `obj/<build_profile>/`, libraries in `lib/<build_profile>/`

## Architecture Notes

- **ada_lib**: Core reusable library — strings, streams, data structures, Gnoga bindings
- **aunit**: Custom AUnit fork — may diverge from upstream AdaCore AUnit
- **gnoga_lib**: Ada abstractions over Gnoga (HTML/CSS/JS web framework in Ada)
- **applications**: End-user programs; `video/camera` is the main application
- Top-level `alr_environment` is a library crate that `with`s `default_config.gpr` globally

## macOS-specific

- Linker option `-Wl,-ld_classic` applied on macOS versions other than 12.7.6
- `OS_VERSION` external variable used to conditionally set linker options
- `~/.zshrc` sourced at start of build scripts (tool paths, environment)
- Project stored at `/Volumes/wayne/Project/git/alr/alr_environment/`
