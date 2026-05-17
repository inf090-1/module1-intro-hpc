# Putting it All Together: End-to-End HPC Workflow with WRF

Welcome to the final practical exercise of the **Introduction to HPC** module. This directory serves as a synthesis of the entire curriculum, moving from theoretical concepts to a real-world application: the **Weather Research and Forecasting (WRF)** model.

This capstone integrates the core pillars of the course:
* **Data Orchestration:** Managing complex input/output (I/O) within a high-performance environment.
* **Software Ecosystems:** Utilizing **Spack** for dependency management and environment modules for dynamic loading.
* **Workload Management:** Interacting with the **Slurm** scheduler to execute multi-step scientific pipelines.
* **Interactive Science:** Leveraging Jupyter Notebooks as a frontend for large-scale cluster computation.

## Technical Objectives

Through these notebooks, you will demonstrate mastery of the following:
* **The WPS/WRF Pipeline:** Understanding the sequential dependency between terrestrial data (Geogrid), meteorological unpacking (Ungrib), and horizontal/vertical interpolation (Metgrid/Real).
* **Simulation Continuity:** Utilizing **Restart Files** to resume high-performance simulations without redundant computation.
* **Hybrid Workflows:** Comparing rapid, interactive troubleshooting (Small-Case) against full production-scale execution (Complete-Case).
* **Scientific Post-Processing:** Bridging the gap between raw binary output and insightful visualization.

## Directory Roadmap

| Notebook | Focus | Use Case |
| :--- | :--- | :--- |
| [**small-case/main.ipynb**](./small-case/main.ipynb) | **Execution & Restarting** | A lightweight "fast-track" focused on resuming an existing simulation from a restart point. Ideal for testing execution parameters. |
| [**complete-case/main.ipynb**](./complete-case/main.ipynb) | **End-to-End Pipeline** | The comprehensive workflow. Covers Spack installation, full WPS preprocessing, the primary WRF execution, and final visualization. |

### Suggested Learning Path
1.  **Exploration:** Start with the **Small-Case** to familiarize yourself with the WRF runtime environment and basic file requirements with minimal overhead.
2.  **Mastery:** Proceed to the **Complete-Case** to build the entire simulation from the ground up, simulating the full lifecycle of a Hurricane Matthew forecast.


**Congratulations on reaching the final stage of the module. You are now ready to apply these HPC skills to real-world scientific challenges.**