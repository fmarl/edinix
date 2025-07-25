# edinix

**edinix** is a Nix flake that provides preconfigured editor environments for various programming languages using either **Emacs** or **Visual Studio Code**. Each editor environment includes language-specific extensions, tools, and settings, making it easy to spin up a consistent development environment with minimal setup.

## Features

- Predefined editor profiles for multiple languages
- Language-specific extensions and tools included automatically
- Reproducible, flake-based environments
- Supports both Emacs and VSCode
- Easy to extend with new profiles or custom configurations

## Supported Languages

| Language  | Emacs Support | VSCode Support |
|-----------|----------------|----------------|
| Nix       | Yes            | Yes            |
| C         | Yes            | Yes            |
| C++       | Yes            | Yes            |
| Rust      | Yes            | Yes            |
| Go        | —              | Yes            |
| Clojure   | Yes            | Yes            |
| Haskell   | Yes            | Yes            |
| ATS       | Yes            | —              |
| Shell     | —              | Yes            |

## Usage

This flake exposes a set of `devShells` that launch Emacs or VSCode with the appropriate tooling and configuration for a given language profile.

For example:

- `.#code.go` – VSCode with Go extensions and tools
- `.#emacs.cpp` – Emacs with C++ support
- `.#code.nix` – VSCode with Nix support

Each devShell includes:

- The editor with relevant extensions or packages
- Associated tooling such as language servers, linters, and formatters
- Editor settings (e.g. VSCode `settings.json`, Emacs `init.el`)

## Extensibility

To add or customize profiles:

1. Add or edit entries in `lib/emacs/profiles.nix` or `lib/code/profiles.nix`.
2. Define which extensions, tools, and settings should be included.
3. Enable the profile by referencing it in `flake.nix`.

You can also pass `extraExtensions` or override settings per invocation if needed.

## License

MIT or similar permissive license.
