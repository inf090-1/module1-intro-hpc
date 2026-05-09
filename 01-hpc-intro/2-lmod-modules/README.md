# Using Lmod modules on HPC systems

HPC systems like INFO090 use lmod modules to manage software. Instead of manual installations, you dynamically load specific versions into your environment. This prevents version conflicts, simplifies switching between toolchains, and ensures research reproducibility through consistent, pre-configured environments. In this guide, we will cover the basics of using lmod modules on INFO090, including how to list, load, unload and troubleshoot them.

## 1. Basic commands

### 1.1 List Modules

List all available software (modules you can load):

```bash
module avail 
# or, more compact:
ml av
```
You will see a long list of software organized in categories. Each entry shows the software name and available versions. The default version (if any) is marked with `(D)`.

List currently loaded modules:

```bash
module list
# or, more compact:
ml
```
You will probably see some default modules already loaded, marked with `(D)`.


### 1.2 Load Modules

To use a specific software, you need to load its module. The syntax is:

```bash
module load <software>/<version>
```

For example:

To load a `python` module version `3.13.1`:

```bash
module load python/3.13.1
# or, more compact:
ml python/3.13.1
```

This updates your environment variables (like `PATH`) so that the selected version of Python is used when you run `python3`. You can check this with:

```bash
which python3
python3 --version
```

### 1.3 Unload Modules

The syntax is similar to loading, but with `unload`:

```bash
module unload python/3.13.1
# or, more compact:
ml -python/3.13.1
```

Now, your environment will revert to the default Python version (if any) or none if there is no default. In INFO090, the default Python is usually a minimal version that may not have all features, so you may want to load a specific version for your work. You can check the current version again with:

```bash
which python3
python3 --version
```

If you want to unload all modules and start with a clean environment, use:

```bash
module purge
```

## 2. Troubleshooting

- `module: command not found`: your shell initialization may not have loaded the module system; re-login or check cluster docs.
- Wrong software version: run `module list` and `which <command>`.
- Conflicts: start clean with `module purge`, then load only what you need.

## 3. Further reading

- Accessing software via Modules: https://carpentries-incubator.github.io/hpc-intro/15-modules.html
- Lmod documentation: https://lmod.readthedocs.io/en/latest/
