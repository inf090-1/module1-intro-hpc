# A quick introduction to Spack

This guide provides a quick introduction to using Spack, a powerful package manager for HPC software. You will learn how to discover, install, and manage software packages with Spack. 


**IMPORTANT**: On INFO090 cluster, the system-wide Spack installation is restricted to administrators. Therefore, if you want to follow this guide you must work on your personal computer. 


## 1. Installing Spack

Spack is a ready-to-use package manager, but you need to clone the repository and set up your environment to use it. The installation process is straightforward, and you can have Spack up and running in a few minutes.

For this guide, we will work with the latest Spack version `v1.1` from GitHub. You can also install a specific release or tag if needed. 

Execute the following commands in your terminal to install Spack:
```bash
# Clone the Spack repository
git clone --depth=2 --branch=releases/v1.1 https://github.com/spack/spack.git ~/spack

# Enable Spack commands in current shell
. ~/spack/share/spack/setup-env.sh
```

It's done, Spack is now available in your shell. You can verify the installation with:

```bash
spack --version
```

You will see an output like `1.1.1 (2e2169d5282d166f63e3ee4db8d4446c43cefa8a)
`, confirming that Spack is installed and ready to use.

## 2. Discover Packages

Spack has a large collection of packages available in its repository. You can check it [online](https://packages.spack.io/) or locally search by name, keyword, or pattern.

To do so, we first need to update the Spack package index:
```bash
spack list
```
This ensures we have the latest information about available packages and their versions. It may take some time to fetch the latest package data. When it's done, you can search for packages. For example, to find the `gmake` package, you can use:

```bash
spack list gmake
```

This will show you all packages with "gmake" in their name or description, including `r-pkgmaker`. You can also search by pattern. For example:

```bash
spack list 'py-*'
```

This will list all Python packages available in Spack. 

You can also display information about a specific package, including available versions, variants, and dependencies:

```bash
spack info gmake
```

You can also check the available versions of a package with:

```bash
spack versions gmake
```
## 3. Install Software

Installation with Spack is an straightforward process by specifying a package and its configuration. The simplest way to install a package is to just name it, for example:

```bash
spack install gmake
```
This will install the latest version of `gmake` with default options. Spack will automatically resolve dependencies and build the package from source if necessary.

You can also specify a particular version, variants (optional features), and dependencies. For example, to install `gmake` version 4.1 with the Clang compiler, you can use:

```bash
spack install gmake@4.1 %clang
```

With this command, Spack will handle all the details of finding compatible versions of dependencies and building everything in the correct order.

## 4. Find and Use Installed Packages

You can list all installed packages with:

```bash
spack find
```
This will show you all packages that have been installed in your Spack environment. 
```
-- linux-ubuntu24.04-skylake / %c=clang@20.1.8 ------------------
gmake@4.1

-- linux-ubuntu24.04-skylake / %c=gcc@14.3.0 --------------------
gmake@4.4.1

-- linux-ubuntu24.04-skylake / no compilers ---------------------
compiler-wrapper@1.0  gcc-runtime@14.3.0

-- linux-ubuntu24.04-x86_64 / no compilers ----------------------
gcc@14.3.0  glibc@2.39  llvm@20.1.8
==> 7 installed packages
```

You can also include more details such as the hash, compiler, and install path:
```bash
# Include hash (-l), compiler flags (-f), and install path (-p)
spack find -lfp
```
And you will see something like:

```
-- linux-ubuntu24.04-skylake / %c=clang@20.1.8 ------------------
3nfemom gmake@4.1  /home/yourUser/spack/opt/spack/linux-skylake/gmake-4.1-3nfemomni6hiuhvfiwe7fd452kr5kd4i

-- linux-ubuntu24.04-skylake / %c=gcc@14.3.0 --------------------
xdssgxd gmake@4.4.1  /home/yourUser/spack/opt/spack/linux-skylake/gmake-4.4.1-xdssgxdk5vib5r57k5xxcgta2455bb3s

-- linux-ubuntu24.04-skylake / no compilers ---------------------
yhvkgqt compiler-wrapper@1.0  /home/yourUser/spack/opt/spack/linux-skylake/compiler-wrapper-1.0-yhvkgqt6xoi2uyegjjslmzkg3wyiefzj
5ew55vg gcc-runtime@14.3.0    /home/yourUser/spack/opt/spack/linux-skylake/gcc-runtime-14.3.0-5ew55vgg6vilf2l5x7z5ainky26ibjhg

-- linux-ubuntu24.04-x86_64 / no compilers ----------------------
nkwqeda gcc@14.3.0   /usr
thy5vqo glibc@2.39   /usr
s7dl7q3 llvm@20.1.8  /usr
==> 7 installed packages
```

In a similar way we did with [lmod modules](../../01-hpc-intro/2-lmod-modules/README.md), we can load Spack packages into our current shell environment to use them. For example, to load the `gmake` package:

```bash
spack load gmake
# check version to confirm it's loaded
gmake --version
```

You should see the version of `gmake` that you installed with Spack. 

```txt
GNU Make 4.3
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

You can unload it with:

```bash
spack unload gmake
gmake --version
```
After unloading, you should see the system version of `gmake` or an error if it's not available.

To know what packages are currently loaded in your environment, you can use:

```bash
spack find --loaded
```

To unload all Spack packages at once, you can use:

```bash
spack unload --all
```

## 5. Check Dependencies

Sometimes, you will have the same package installed with different configurations (e.g., different compilers or variants). To check the dependencies of a specific package, you can use:

```bash
spack find -d gmake
```

```txt
-- linux-ubuntu24.04-skylake / %c=clang@20.1.8 ------------------
gmake@4.1
    compiler-wrapper@1.0
    glibc@2.39
    llvm@20.1.8


-- linux-ubuntu24.04-skylake / %c=gcc@14.3.0 --------------------
gmake@4.4.1
    compiler-wrapper@1.0
    gcc@14.3.0
    gcc-runtime@14.3.0
    glibc@2.39

==> 2 installed packages
```

Or, if you want to see as a full dependency graph:
```bash
spack graph gmake
```

```txt
o gmake@4.4.1/xdssgxd
|\
| |\
| | |\
| | | o compiler-wrapper@1.0/yhvkgqt
| | | 
| o | gcc-runtime@14.3.0/5ew55vg
|/| | 
| |/
| o gcc@14.3.0/nkwqeda
| 
o glibc@2.39/thy5vqo

```

## 6. Uninstall and Cleanup

Like a typical package manager, Spack allows you to uninstall packages when they are no longer needed. You can uninstall a specific package by name, version, and configuration, or by its unique hash. Be careful when uninstalling packages that have dependents, as it may break other installed software.

For example, to uninstall `gmake` version 4.1 built with Clang:
```bash
spack uninstall gmake@4.1 %clang
```

We can also uninstall by hash prefix (from `spack find -l`):
```bash
spack uninstall /3nfemom
```

If we want to remove a package and all packages that depend on it, we can use the `-R` or `--dependents` flag:
```bash
spack uninstall -R gmake
```

Package installations can take up a lot of disk space, especially if you have many versions and configurations. To clean up unused packages and free up space, you can use the `spack gc` command, which removes packages that are not needed by any other installed package. You can also clean up build caches and stages with `spack clean -a`.


## 7. Practical Exercise: Install and Benchmark `osu-micro-benchmarks`

In the previous tutorial, we utilized the pre-installed version of `osu-micro-benchmarks` on the INFO090 cluster to measure latency and bandwidth. To deepen your understanding of HPC software management, you will now install the suite yourself using Spack and execute the benchmarks manually. This hands-on exercise will reinforce your skills in using Spack for software installation and give you practical experience in running HPC benchmarks.

Follow these commands to set up and run the benchmarks:
```bash
# Search for the package
spack list osu

# Install the package (it may take some time to build)
spack install osu-micro-benchmarks

# Load the package
spack load osu-micro-benchmarks

# Run the latency benchmark
osu_latency

# Run the bandwidth benchmark
osu_bw
```

## Further Readings

- Spack main documentation: https://spack.readthedocs.io/
- Spack tutorial index: https://spack-tutorial.readthedocs.io/en/latest/
- Spack environments tutorial: https://spack-tutorial.readthedocs.io/en/latest/tutorial_environments.html
- Spack configuration tutorial: https://spack-tutorial.readthedocs.io/en/latest/tutorial_configuration.html

