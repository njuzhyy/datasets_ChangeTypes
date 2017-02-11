#!/bin/bash
grep -rn '^\s*#' allfunc/ > result/jingresult.txt
grep -rn 'while\s*(' allfunc/ > result/whileresult.txt
