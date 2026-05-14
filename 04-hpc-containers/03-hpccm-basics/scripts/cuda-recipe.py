#!/usr/bin/env python
from packaging.version import Version

cuda_version = USERARG.get('cuda', '12.4')

if Version(cuda_version) < Version('12.0'):
    raise RuntimeError(f'Invalid CUDA version: {cuda_version}. Must be >= 12.0')

Stage0 += baseimage(image=f'nvidia/cuda:{cuda_version}-devel-ubuntu24.04')
