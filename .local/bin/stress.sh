#!/bin/sh

stress-ng --cpu 16 --cpu-method matrixprod  --metrics-brief --perf -t 300
