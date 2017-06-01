# zypher.jl
**zypher**: is a package developed in julia to perform side channel analysis on various encryption systems.

## Introduction
The zypher package is developed to provide side channel analysis tool to people working in the areas such as cryptography.
The structure is designed in an intuitive manner which may be extended and customised to meet one's own cipher apart from some pre loaded ciphers such as AES-128. One can also extend the package by including files (or function) of thier own versions of attacks apart from what is provided such as *Correlation Power Analysis (CPA)*, *Template Attacks (TA)* (coming soon). The API is designed to accept traces in *.csv* in the  following format: <br>
* First column is of plaintexts in hexadecimal format (without 0x prefix and L/l suffix)
* Second column is of ciphertexts in hexadecimal format (without 0x prefix and L/l suffix)
* Rest of the columns contain trace values

## API
Currently the follwoing methods are provided in the package, (users can extend this list to include their own methods):
* <code>loadSPNtrace("\<path_to_file\>", unitSize)</code> : This method is to load the traces corresponding to cipher which is a S-P Network like PRESENT, AES, etc. the unitSize refers to the number of bits which are to be calculated/guessed at a time. This method returns a *type* SPNdata which has the necessary information
* <code>cpa(\<loaded_trace\>)</code> : This method performs cpa on the *type* returned by the loadSPNtrace() and returns another *type* cpaResults which has all the final statistics about the attack and the recovered keys
* <code>display_cpa(\<result_type\>)</code>: This function is to display the result of the cpa function, it also creates a direcorty to store all the graphs generatedd and displayed as a result of the attack

## Usage Direct example

