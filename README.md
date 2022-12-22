# svlint

SystemVerilog linter

[![Actions Status](https://github.com/dalance/svlint/workflows/Regression/badge.svg)](https://github.com/dalance/svlint/actions)
[![codecov](https://codecov.io/gh/dalance/svlint/branch/master/graph/badge.svg)](https://codecov.io/gh/dalance/svlint)

[![Crates.io](https://img.shields.io/crates/v/svlint.svg)](https://crates.io/crates/svlint)
[![svlint](https://snapcraft.io/svlint/badge.svg)](https://snapcraft.io/svlint)

![svlint](https://user-images.githubusercontent.com/4331004/67759664-377b5480-fa83-11e9-895f-7deef6dde516.png)

## Installation

### Download binary

Download from [release page](https://github.com/dalance/svlint/releases/latest), and extract to the directory in PATH.

### snapcraft

You can install from [snapcraft](https://snapcraft.io/svlint)

```
sudo snap install svlint
```

### Cargo

You can install by [cargo](https://crates.io/crates/svlint).

```
cargo install svlint
```

## Usage

### Configuration

First of all, you must put a configuration file `.svlint.toml` to specify enabled rules.
Configuration file is searched to the upper directory until `/`.
So you can put configuration file (`.svlint.toml`) on the repository root
alongside `.gitignore`.
Alternatively, for project-wide rules you can set the environment variable
`SVLINT_CONFIG` to something like `/cad/projectFoo/teamBar.svlint.toml`.

The example of configuration file is below:

```toml
[option]
exclude_paths = ["ip/.*"]
prefix_label = ""

[rules]
non_ansi_module = true
keyword_forbidden_wire_reg = true
```

The complete example can be generated by `svlint --example`

#### `[option]` section

- `exclude_paths` is a list of regular expressions.
  If a file path is matched with the list, the file is skipped to check.
- `prefix_(inout|input|output)` are strings which port identifiers must begin
  with.
  Only used when the corresponding rule is enabled.
  Defaults to `"b_"`, `"i_"`, and `"o_"` respectively.
- `prefix_label` is a string which generate labels must begin with.
  Applicable to `if/else`, `for`, and `case` generate constructs when the
  corresponding `generate_*_with_label` rule is enabled.
  Defaults to `"l_"`.
  To check only that a label exists, set this to `""`.
- `prefix_instance` is a string which instances must begin with.
  Defaults to `"u_"`.
- `prefix_(interface|module|package)` are strings which definitions must begin
  with.
  An alternative naming convention for interface, module, and package names is
  uppercase/lowercase first letter.
  This is similar to Haskell where types begin with uppercase and variables
  begin with lowercase.
  These alternative rules are called
  `(lower|upper)camelcase_(interface|module|package)`.
- `re_(forbidden|required)_*` are regular expressions for detailed naming
  conventions, used only when the corresponding rules are enabled.
  The defaults for `re_required_*` are either uppercase, lowercase, or
  mixed-case starting with lowercase, i.e. just vaguely sensible.
  The defaults for `re_forbidden_*` are to forbid all strings, except those
  starting with "X", i.e. not at all sensible (configuration required).

#### `[rules]` section

By default, all rules are disabled.
To enable a rule, assign `true` to its name, e.g. `case_default = true`.

#### Configuration update

If svlint is updated, `.svlint.toml` can be updated to the latest version with
`svlint --update`.

### Rules

All rules are documented [here](./RULES.md).
You are welcome to suggest a new rule through
[Issues](https://github.com/dalance/svlint/issues) or
[Pull Requests](https://github.com/dalance/svlint/pulls).
Some example rulesets, are available [here](https://github.com/DaveMcEwan/svlint-rulesets).

If you need to turn off specific rules for a section, then you can use special comments:
```systemverilog
/* svlint off keyword_forbidden_always */
always @* foo = bar;                      // <-- This line is special.
/* svlint on keyword_forbidden_always */
```

### Plugin rules

svlint supports plugin rules, an example of which is available
[here](https://github.com/dalance/svlint-plugin-sample).

### Filelist

svlint supports filelist like major EDA tools.
The following features are supported.

* Substitute environment variables
* Specify include directories by `+incdir`
* Define Verilog define by `+define`
* Include other filelists by `-f`

An example is below:

```
xxx.sv
${XXX_DIR}/yyy.sv
$(XXX_DIR)/zzz.sv
+incdir+$PWD/header/src
+define+SYNTHESIS
-f other.f
```

### Command Line Interface

```
svlint 0.6.0

USAGE:
    svlint [OPTIONS] [--] [FILES]...

ARGS:
    <FILES>...    Source file

OPTIONS:
    -1                           Print results by single line
    -c, --config <CONFIG>        TOML configuration file [default: .svlint.toml]
    -d, --define <DEFINES>       Define
        --dump-filelist          Print data from filelists
        --dump-syntaxtree        Print syntax trees
    -E                           Print preprocessor output instead of performing checks
        --example                Print TOML configuration example
    -f, --filelist <FILELIST>    File list
        --github-actions         Print message for GitHub Actions
    -h, --help                   Print help information
    -i, --include <INCLUDES>     Include directory path
        --ignore-include         Ignore any include
    -p, --plugin <PLUGINS>       Plugin file
    -s, --silent                 Suppress messages
        --update                 Update configuration
    -v, --verbose                Print verbose messages
    -V, --version                Print version information
```

## Rulesets

Some pre-configured rulesets are provided in `rulesets/*.toml`.
A pre-configured ruleset can be used in the three standard ways (rename to
`.svlint.toml` and place in the project root, the `--config` argument, or via
the `SVLINT_CONFIG` environment variable).
Pre-configured rulesets reside in `rulesets/*.toml`.
There are two methods of specifying those TOML files:
1. Simply copy your existing `.svlint.toml` configuration into that directory.
  Ideally, add some comments to explain the background of the configuration and
  open a [pull request](https://github.com/dalance/svlint/pulls) to have it
  included as part of this project.
  This is the (initially) low-effort approach, best suited to small personal
  projects with low requirements for documentation.
2. Create a definition in Markdown to compose a ruleset from a sequence of
  TOML fragments , i.e. write `md/ruleset-foo.md` to describe how the
  configuration in `rulesets/foo.toml` should be formed.
  Again, please open a [pull request](https://github.com/dalance/svlint/pulls)
  to have it included as part of this project.
  This approach is initially high-effort but on larger projects, users will
  appreciate a good explanation of why configurations are necessary.
The rest of this section refers to the second method.

If you only use one configuration, there isn't much benefit in having wrapper
scripts, i.e. the benefits appear when you regularly use several
configurations.
For example, say you work on two projects called "A" and "B", and each project
has its own preferences for naming conventions.
This situation can be troublesome because there are many ways to get confused
about which configuration file should be used on which files.
Wrapper scripts help this situation by providing convenient commands like
`svlint-A` and `svlint-B`.
Another case for convenient access to specific rulesets is where you want to
check that some files adhere to a particular set of rules, e.g. rules to
reduce synthesis/simulation mismatches should apply to `design/*.sv` but not
apply to `verif/*.sv`.

Each ruleset specification (in `md/ruleset-*.md`) is processed individually.
A ruleset specification is freeform Markdown containing codeblocks with TOML
(toml), POSIX shell (sh), or Windows batch (winbatch) language markers.
Each ruleset specifies exactly one TOML configuration, one POSIX shell script,
and one Windows batch script.
For example, let this ruleset specification be placed in
`md/ruleset-an-example.md`:

    This is freeform Markdown.

    Some explanation of how the **foo** and **bar** rules work together and the
    associated option **blue**.
    ```toml
    rules.foo = true
    rules.bar = true
    option.blue = "ABC"
    ```

    Next, some text about the **baz** rule and another option **red**.
    ```toml
    # A comment here.
    rules.baz = true
    option.red = "DEF"
    ```

    Maybe some more Markdown text here.

This example will produce three files under `rulesets/` when cargo builds this
crate: `an-example` (a POSIX shell script), `an-example.cmd` (a Windows batch
script), and `an-example.toml`.
A ruleset's TOML configuration is generated by concatenating all TOML
codeblocks into one file, so the above example will produce this TOML file:
```toml
rules.foo = true
rules.bar = true
option.blue = "ABC"
# A comment here.
rules.baz = true
option.red = "DEF"
```

POSIX shell scripts begin with this header, where "an-example" is replaced by
the ruleset's name:
```sh
#!/usr/bin/env sh -e
SVLINT_CONFIG="$(dirname $(which svlint-an-example))/an-example.toml"
```
Next, any codeblocks with the `sh` language marker are concatenated to
the header in order before, finally, this footer is appended:
```sh
env SVLINT_CONFIG="$SVLINT_CONFIG" svlint $*
```

Windows batch scripts begin with this header, where "an-example" is replaced by
the ruleset's name:
```winbatch
@echo off
for /f %f in ('where.exe an-example') do set "WHERE=%f"
set "SVLINT_CONFIG=%WHERE%\an-example.toml"
```
Next, any codeblocks with the `winbatch` language marker are then concatenated
to the header in order before, finally, this footer is appended:
```winbatch
svlint %*
```

These wrapper scripts can then be used with svlint's usual arguments like
`svlint-foo path/to/design/*.sv`.
Note that this style of wrapper script allows you to use `PATH` environment
variable in the usual way, and that the wrapper scripts will simply use the
first version of `svlint` found on your `PATH`.

This method of generating a configuration and wrapper scripts enables full
flexibility for each ruleset's requirements, while encouraging full and open
documentation about their construction.
The process, defined in `build.rs`, is deterministic so both the Markdown
specifications and the TOML configurations are tracked by versions control.
However, wrapper scripts are not installed alongside the `svlint` binary
created via `cargo install svlint` (or similar).
Instead, you must either add `rulesets/` to your `PATH` environment variable,
or copy the wrapper scripts to somewhere already on your `PATH`.

Convenient [documentation](./RULESETS.md) is created by applying a template to
the ruleset specifications in a similar way to how `RULES.md` is created, i.e.
via `src/mdgen.rs`.
