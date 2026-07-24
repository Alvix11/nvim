# Practical Guide: OdooLS in Neovim/NvChad for Odoo

This guide documents a stable setup of **Odoo Language Server (OdooLS)** for Neovim/NvChad with Python and XML support, including downloading the executable, extracting `typeshed.zip`, creating the virtual environment, an example `odools.toml`, an example `pyrightconfig.json`, and LSP configuration using `selectedProfile = "main"`.

## Prerequisites

Before starting, make sure you have the following ready:

* Python 3 and `venv`.
* The Odoo source code repository in a local path.
* Neovim or NvChad.
* Files from the [OdooLS Releases page](https://github.com/odoo/odoo-ls/releases):
  - The server archive corresponding to your system (e.g., `odoo-linux-x86_64-X.X.X.tar.gz`).
  - The **`typeshed.zip`** file.



---

## 1. Create the language virtual environment

Creating a separate virtual environment for OdooLS helps the server resolve Odoo imports and dependencies using a controlled Python instance. OdooLS uses `python_path` from `odools.toml`, so this path must point to the correct interpreter within the virtual environment.

```bash
python3 -m venv ~/dev/odoo_env

```

## 2. Make the Odoo repo visible inside the environment

If the virtual environment cannot "see" the Odoo source code, the server might start but fail on imports or contextual analysis. A practical method is to create a `.pth` file inside the environment's `site-packages` directory to add the Odoo repository to the Python path.

```bash
~/dev/odoo_env/bin/python -c "import site; open(site.getsitepackages()[0] + '/odoo.pth', 'w').write('$HOME/odoo\n')"

```

## 3. Install Odoo dependencies in the environment

Installing the requirements from the Odoo repository inside the same virtual environment improves import resolution and reduces false positives. This is especially important when the project depends on libraries that Odoo imports directly from its own modules.

```bash
~/dev/odoo_env/bin/pip install -r ~/odoo/requirements.txt

```

## 4. Download `odoo_ls_server` and `typeshed.zip` from Releases

Both the binary and the typing stubs come from the official release assets.

1. Go to [OdooLS Releases](https://github.com/odoo/odoo-ls/releases).
2. Download the archive for your platform (for example, `odoo-linux-x86_64-1.4.0.tar.gz`).
3. Download **`typeshed.zip`**.

Create the target directory and extract both files there:

```bash
# Create container directory
mkdir -p ~/.local/share/nvim/odoo

# Extract the OdooLS server (extracts the odoo_ls_server executable)
tar -xvf odoo-linux-x86_64-1.4.0.tar.gz -C ~/.local/share/nvim/odoo/
chmod +x ~/.local/share/nvim/odoo/odoo_ls_server

# Extract typeshed.zip
unzip typeshed.zip -d ~/.local/share/nvim/odoo/typeshed

```

With this layout, the path for `additional_stubs` in your configuration will be:

```text
${userHome}/.local/share/nvim/odoo/typeshed/stubs/

```

## 5. Create `odools.toml`

OdooLS is configured via an `odools.toml` file. This file defines `odoo_path`, `python_path`, `addons_paths`, and configuration profiles.

Recommended example:

```toml
[[config]]
name = "main"
odoo_path = "${userHome}/odoo"
python_path = "${userHome}/dev/odoo_env/bin/python"
addons_paths = [
    "${workspaceFolder}/internal",
    "${workspaceFolder}/custom",
    "${workspaceFolder}/third-party",
    "${workspaceFolder}/enterprise",
    # "${workspaceFolder}/addons",
    # "${workspaceFolder}/custom-modules",
]
additional_stubs = ["${userHome}/.local/share/nvim/odoo/typeshed/stubs/"]

```

### Notes on this file

* `name = "main"` must match the profile selected in the LSP client (`selectedProfile = "main"`).
* `${userHome}` avoids hardcoding the system username in the file.
* `${workspaceFolder}` allows reusing the file across different projects.
* `additional_stubs` points to the `stubs/` directory extracted from `typeshed.zip`.

## 6. Complement with `pyrightconfig.json`

Although OdooLS provides Odoo-specific autocompletion and navigation, a `pyrightconfig.json` file helps with general Python imports and diagnostics.

Example:

```json
{
  "venvPath": "${HOME}/dev",
  "venv": "odoo_env",
  "extraPaths": [
    "${HOME}/odoo",
    "${HOME}/odoo/odoo",
    "${HOME}/odoo/odoo/addons",
    "${HOME}/odoo/addons",
    "${HOME}/enterprise"
  ],
  "typeCheckingMode": "off"
}

```

## 7. Configure Neovim/NvChad

Neovim configuration pointing to the downloaded binary and selecting the `main` profile:

```lua
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("odoo_ls", {
  cmd = {
    vim.fn.expand("$HOME/.local/share/nvim/odoo/odoo_ls_server"),
  },
  filetypes = { "python", "xml" },
  capabilities = capabilities,
  root_markers = { "odools.toml", ".git" },
  workspace_folders = {
    {
      uri = vim.uri_from_fname(vim.fn.getcwd()),
      name = "main_folder",
    },
  },
  settings = {
    Odoo = {
      selectedProfile = "main",
    },
  },
})

vim.lsp.enable("odoo_ls")

```

## 8. Example project structure

```text
my-odoo-project/
├── .git/
├── odools.toml
├── pyrightconfig.json
├── custom/
├── internal/
├── third-party/
└── enterprise/

```
# 9. Common issues

### The server says it cannot find the profile

Occurs if `selectedProfile` in Neovim does not match `name` inside `odools.toml`.

### `self.env[""]` autocompletion is not working well

Check that `addons_paths` is correctly declared in `odools.toml`, that each module has its `__manifest__.py`, and that you open Neovim from the project root (`nvim .`).

### Python imports show up in red

Ensure that `pyrightconfig.json` has the correct paths in `extraPaths` pointing to your Odoo source code.
