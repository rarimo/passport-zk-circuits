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

`PhotoVerifier` component:
    The component is responsible for verifying that the user has pass the verification of photo correspondency with some allowed provider. Providers use their key pair to sign a response in case of successful verification. Hashes of their public keys are used to construct a Merkle Tree and generate proofs of verification without disclosing data about photoes being used.

Input signals

`realPhotoHash` - Poseidon Hash of the real photo

`passPhotoHash` -  Poseidon Hash of the passport photo

`providerSignature[5]` - EdDSA signature of *Poseidon(realPhotoHash, passPhotoHash)*.
Presented in the form ***[R8.X, R8.Y, A.X, A.Y, S]***

`providerMerkleRoot` (public) - Merkle Root used to prove that data was verified by an eligble provider;

`providerMerkleBranch[depth]` - Merke Branch (Inclusion Proof)

`providerMerkleOrder[depth]` - Order of leaves hashing 0 - left | 1 - right

-----------
***merkleTree*** - used for inclusion proof verification. Utilizes *dualMux* & *hashLeftRight* components.

***dualMux*** - swaps elements if order is 1:

- input: 2 signals [in[0], in[1]]

- if order == 0 returns [in[0], in[1]]

- if order == 1 returns [in[1], in[0]]

***hashLeftRight*** - hashes two input components:

- input: 2 signals [in[0], in[1]]

- returns Poseidon(in[0], in[1])
