# Creating a Spack Package

This guide shows how to create a real Spack package recipe for software that is not already available in the Spack repository. We will use **vnStat** as the example and walk through the full workflow: inspecting the upstream source, writing a package recipe, creating a local Spack repository, and installing the package.

## 1. What a Spack package is

In Spack, a package is a Python class that describes how to fetch, configure, build, and install software. A package recipe typically includes:

- Source URL and versions
- Build system type (Autotools, CMake, Make, etc.)
- Dependencies (build-time and runtime)
- Build and install methods

This is useful when you want to:

- Package custom or third-party software not in official Spack repositories
- Install a specific upstream version with known compiler settings
- Reproduce builds across different machines with exact dependency versions
- Pin software versions for reproducibility

We can check how a package is defined in Spack by looking at an existing package. For example, to look at the `gmake` package:

```bash
spack edit gmake
```

This will open the `package.py` file for `gmake` in your default editor, showing you how it is defined. You can use this as a template for creating your own package.

## 2. Choose your software: `vnstat` example

For this guide, we will package[ **vnStat**](https://github.com/vergoh/vnstat), a console-based network traffic monitor for Linux and BSD.

**Why vnStat?** It is a real C project that uses Autotools, depends on SQLite, and optionally supports image output through libgd. That makes it a good teaching example for a Spack package.

### 2.1 Inspect the upstream project

First, examine the source code to understand its build system and dependencies:

```bash
# Clone and inspect
git clone https://github.com/vergoh/vnstat.git
cd vnstat
ls -la

# Look for Autotools files and install instructions
ls -la configure.ac Makefile.am
cat INSTALL.md
```

You will see:
- `configure.ac` and `Makefile.am` - Autotools build files
- `src/` - source code for `vnstat` and `vnstatd`
- `examples/` - service and integration examples
- `cfg/` - configuration files

From the install guide, vnStat requires:
- **Build tools:** a C compiler, `make`, and Autotools helpers when regenerating files
- **Dependencies:** SQLite development libraries
- **Optional dependencies:** `libgd` for image output, `check` for the test suite, and `pkg-config` for detection

## 3. Create the package file

Based on your inspection, create a Spack package file named `package.py`:

```python
class Vnstat(AutotoolsPackage):
    """vnStat is a console-based network traffic monitor for Linux and BSD."""

    homepage = "https://github.com/vergoh/vnstat"
    git = "https://github.com/vergoh/vnstat.git"
    url = "https://github.com/vergoh/vnstat/releases/download/v2.13/vnstat-2.13.tar.gz"

    version("2.13", sha256="c9fe19312d1ec3ddfbc4672aa951cf9e61ca98dc14cad3d3565f7d9803a6b187")

    depends_on("autoconf", type="build")
    depends_on("automake", type="build")
    depends_on("libtool", type="build")
    depends_on("m4", type="build")

    variant("image", default=False, description="Enable image output via libgd")

    depends_on("sqlite@3.6.11:")
    depends_on("libgd", when="+image")
    depends_on("pkgconfig", type="build")

    force_autoreconf = True

    def configure_args(self):
        # Using self.prefix.etc is correct for Spack's layout
        args = ["--sysconfdir={0}".format(self.prefix.etc)]

        if "+image" in self.spec:
            args.append("--enable-image-output")
        else:
            args.append("--disable-image-output")

        return args
```

### Key parts explained:

- **`AutotoolsPackage`** - Base class for Autotools-based projects; handles the standard `./configure && make && make install` flow
- **`git`** - Git repository for development builds
- **`version(..., tag=...)`** - Stable release from a specific git tag
- **`depends_on("sqlite")`** - Required runtime and link dependency
- **`depends_on("libgd", when="+image")`** - Optional image output support
- **`variant("image")`** - Lets users enable or disable image output
- **`configure_args()`** - Passes the configuration directory and disables image output when the variant is off

## 4. Add the package to your Spack repository

Spack packages live in a repository tree. Create a local repository structure with both the `packages` directory and a `repo.yaml` metadata file:

```bash
# Create a directory for your custom packages
mkdir -p my-spack-repo/packages/vnstat

# Copy your package.py into the package directory
cp package.py my-spack-repo/packages/vnstat/package.py
```

### 4.1 Create the `repo.yaml` file

Every Spack repository requires a `repo.yaml` file in the root directory. If you create the repository manually, create it at `my-spack-repo/repo.yaml`:

```yaml
repo:
  namespace: my-spack-repo
```

The `namespace` is a unique identifier for your repository and should not conflict with other repositories.

The complete repository layout should now look like this:

```txt
my-spack-repo/
├── repo.yaml
└── packages/
    └── vnstat/
        └── package.py
```

### 4.2 Register the repository with Spack

Register the repository with Spack:

```bash
# Tell Spack about your custom repository
spack repo add my-spack-repo

# Verify it was added
spack repo list
```

## 5. Build and install the package

With the package registered, you can now build and install vnStat:

```bash
# See available versions and dependencies
spack info vnstat

# Show the install plan without building
spack spec vnstat

# Install with default compiler and dependencies
spack install vnstat

# Install with image output enabled
spack install vnstat +image
```

Spack will:
1. Fetch the source from the selected git tag or branch
2. Resolve and build dependencies such as SQLite
3. Configure the build with the appropriate `--sysconfdir`
4. Build the binaries with `make`
5. Install them into a unique Spack prefix

## 6. Use the installed package

Once installed, load vnStat into your environment:

```bash
# Load the package
spack load vnstat

# Verify it works
vnstat --help
vnstat --version
vnstatd --help
```

To see where it was installed:

```bash
spack location -i vnstat
```

### Create a modulefile for easier loading:

```bash
# Generate a module file (LUA format)
spack module lmod refresh vnstat

# Then load it like any other module
module load vnstat
```

## 7. Common debugging and inspection

If your package fails to build or install, use these commands:

```bash
# View the full build output
spack install -v vnstat  # Verbose
spack install -vvv vnstat  # Very verbose

# Inspect what Spack is about to do
spack spec vnstat@2.13 %gcc@11

# Check if the package was installed correctly
spack find vnstat

# Clean up failed builds
spack clean vnstat
spack remove vnstat  # Remove all versions
```

## 8. Next: Customize your package further

Once your package is working, you can extend it with:

### Add optional features (variants):

```python
class Vnstat(AutotoolsPackage):
    """..."""

    variant("image", default=False, description="Enable image output via libgd")

    def configure_args(self):
        args = []
        if not self.spec.satisfies("+image"):
            args.append("--disable-image-output")
        return args
```

### Build with different compilers:

```bash
spack install vnstat%intel
spack install vnstat%clang
spack install vnstat%gcc@12
```

## 9. Practical checklist for packaging your own software

When creating a Spack package, follow this workflow:

1. Examine the upstream source code and identify:
   - Build system type (Autotools, CMake, Meson, etc.)
   - External dependencies
   - Supported versions
   - Installation directories and binaries

2. Choose a Spack base class:
   - `AutotoolsPackage` - for `./configure && make` projects
   - `CMakePackage` - for CMake-based projects
   - `MakefilePackage` - for simple Makefiles
   - `PythonPackage` - for Python packages
   - `Package` - for custom or unusual build systems

3. Write the package recipe:
   - Set `homepage`, `git`, and a stable version source
   - Define versions clearly
   - List `depends_on()` for each dependency
   - Override build methods if needed (`configure_args()`, `install()`, etc.)

4. Create a local repository and register it with Spack:
   ```bash
   mkdir -p my-repo/packages/<name>
   cp package.py my-repo/packages/<name>/package.py
   cat > my-repo/repo.yaml << 'EOF'
   repo:
     namespace: my-repo
   EOF
   spack repo add my-repo
   ```

5. Test the package:
   ```bash
   spack spec <name>           # Dry run
   spack install -v <name>     # Build with verbose output
   spack load <name>           # Load into environment
   <command> --version         # Verify it works
   ```

6. Iterate on failures:
   - Read build logs carefully
   - Use `spack dev-build` for interactive debugging
   - Update `depends_on()` or `configure_args()` as needed
   - Re-test until installation succeeds

## Further Reading

- Spack packaging tutorial: https://spack-tutorial.readthedocs.io/en/latest/tutorial_packaging.html
- Spack packages reference: https://spack.readthedocs.io/en/latest/packages.html
- Spack developer guide: https://spack.readthedocs.io/en/latest/developer_guide.html
- Autotools documentation: https://www.gnu.org/software/autoconf/
- vnStat repository: https://github.com/vergoh/vnstat
