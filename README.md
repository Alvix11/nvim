# Practical Guide: OdooLS in Neovim/NvChad for Odoo

This guide documents a stable setup of **Odoo Language Server (OdooLS)** for Neovim/NvChad with Python and XML support. It covers downloading the executable, extracting `typeshed.zip`, creating the virtual environment, configuring `odools.toml` and `pyrightconfig.json`, and setting up Neovim LSP using `selectedProfile = "main"`.

---

## Prerequisites

Before starting, make sure you have the following ready:

* **Python and `venv**`: Ensure you have the Python version compatible with your target Odoo version installed (see Step 1).
* **Odoo source code repository** in a local path.
* **Neovim** or **NvChad**.
* Files from the [OdooLS Releases page](https://github.com/odoo/odoo-ls/releases):
1. The server archive corresponding to your system (e.g., `odoo-linux-x86_64-X.X.X.tar.gz`).
2. The **`typeshed.zip`** file.



---

## 1. Create the language virtual environment

> [!IMPORTANT]
> **Python Version Compatibility:**
> Make sure to create the virtual environment using the exact Python version required by the target Odoo version you are developing for.
> * **Odoo 18 / 17:** Python 3.10 – 3.12 (avoid Python 3.14+ as binary wheels are missing).
> * **Odoo 15 / 16:** Python 3.8 – 3.10.
> 
> 

Creating a separate virtual environment for OdooLS helps the server resolve Odoo imports and dependencies using a controlled Python instance. OdooLS uses `python_path` from `odools.toml`, so this path must point to the correct interpreter within the virtual environment.

```bash
# Example for Odoo 17/18 using Python 3.10
python3.10 -m venv ~/dev/odoo_env

```

---

## 2. Make the Odoo repo visible inside the environment

> [!NOTE]
> Before running this command, ensure your local Odoo repository is checked out to the correct version branch (e.g., `git checkout 17.0`).

If the virtual environment cannot "see" the Odoo source code, the server might start but fail on imports or contextual analysis. A practical method is to create a `.pth` file inside the environment's `site-packages` directory to add the Odoo repository to the Python path.

```bash
~/dev/odoo_env/bin/python -c "import site; open(site.getsitepackages()[0] + '/odoo.pth', 'w').write('$HOME/odoo\n')"

```

---

## 3. Install Odoo dependencies in the environment

Installing the requirements from the Odoo repository inside the same virtual environment improves import resolution and reduces false positives.

> [!WARNING]
> * Ensure your Odoo repository is on the correct branch before installing requirements.
> * **`psycopg2` vs `psycopg2-binary**`: If installing requirements fails due to missing C dependencies (e.g., `pg_config` executable not found), edit `requirements.txt` (or install manually) replacing `psycopg2` with `psycopg2-binary` to use pre-compiled binaries:
> ```bash
> # In case psycopg2 compilation fails:
> ~/dev/odoo_env/bin/pip install psycopg2-binary
> 
> ```
> 
> 
> 
> 

Install the requirements file:

```bash
~/dev/odoo_env/bin/pip install -r ~/odoo/requirements.txt

```

---

## 4. Download `odoo_ls_server` and `typeshed.zip` from Releases

Both the binary and the typing stubs come from the official release assets.

1. Go to [OdooLS Releases](https://github.com/odoo/odoo-ls/releases).
2. Download the archive for your platform (e.g., `odoo-linux-x86_64-1.4.0.tar.gz`).
3. Download **`typeshed.zip`**.
4. Create the target directory and extract both files there:

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
`${userHome}/.local/share/nvim/odoo/typeshed/stubs/`

---

## 5. Create `odools.toml`

OdooLS is configured via an `odools.toml` file in the root of your project directory. This file defines `odoo_path`, `python_path`, `addons_paths`, and configuration profiles.

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

### Notes on this file:

* `name = "main"` must match the profile selected in the LSP client (`selectedProfile = "main"`).
* `${userHome}` avoids hardcoding the system username.
* `${workspaceFolder}` allows reusing the file across different projects.
* `additional_stubs` points to the `stubs/` directory extracted from `typeshed.zip`.

---

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

---

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

---

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

---

## 9. Common issues

### `pg_config` executable not found or compilation error on `pip install`

* You are likely using an unsupported/newer Python version (e.g., Python 3.14) or missing C compilation header libraries.
* **Fix:** Use a supported Python version for your Odoo version (e.g., Python 3.10/3.11/3.12) and swap `psycopg2` with `psycopg2-binary`.

### The server says it cannot find the profile

* Occurs if `selectedProfile` in Neovim does not match `name` inside `odools.toml`.

### `self.env[""]` autocompletion is not working well

* Check that `addons_paths` is correctly declared in `odools.toml`, that each module has its `__manifest__.py`, and that you open Neovim from the project root (`nvim .`).
* Verify that you checked out the correct Odoo git branch prior to generating the `.pth` file.

### Python imports show up in red

* Ensure that `pyrightconfig.json` has the correct paths in `extraPaths` pointing to your Odoo source code.
