#!/usr/bin/env python
import hpccm

Stage0 = hpccm.Stage()
Stage0 += baseimage(image='ubuntu:24.04')
Stage0 += gnu()
Stage0 += openmpi(cuda=False, infiniband=False)

print(Stage0)
