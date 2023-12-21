#!/bin/bash

#Compiles and copies the binaries to bin/
OUT_FILE=bin/default make fuzz

OUT_FILE=bin/asans AFL_USE_ASAN=1 AFL_USE_UBSAN=1 AFL_USE_CFISAN=1 make fuzz
OUT_FILE=bin/laf AFL_LLVM_LAF_ALL=1 make fuzz
OUT_FILE=bin/cmplog AFL_LLVM_CMPLOG=1 make fuzz
