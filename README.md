# ZkCircuits

Zero-Knowledge Proof Circuits for the Voting system using Circom

Install the `circomlib` package before running the circuits.

```console
npm install circomlib
```

To compile circuit run
```circom *name*.circom```

With these options we generate three types of files:

`--r1cs`: it generates a file that contains the R1CS constraint system of the circuit in binary format.

`--wasm`: it generates a directory that contains the Wasm code (multiplier2.wasm) and other files needed to generate the witness.

`--sym` : it generates a symbols file required for debugging or for printing the constraint system in an annotated mode.

`--c` : it generates a directory that contains several files needed to compile the C code to generate the witness.

## Circuits Architecture

![CircuitsArchitectureImg](imgs/RedSunsetCircuits.png)
