const { POSEIDON_C, POSEIDON_M, POSEIDON_P, POSEIDON_S } = require('./poseidon_constants.js');
const modul = BigInt("21888242871839275222246405745257275088548364400416034343698204186575808495617");

function Sigma(input) {
    return input ** BigInt(5) % modul;
}

function Ark(t, C, r, input) {
    const out = new Array(t).fill(0n);
    for (let i = 0; i < t; i++) {

        out[i] = (input[i] + C[i + r]) % modul;
    }
    return out;
}

function Mix(t, M, input) {
    const out = new Array(t).fill(0n);
    for (let i = 0; i < t; i++) {
        let lc = 0n;
        for (let j = 0; j < t; j++) {
            lc = (lc + M[j][i] * input[j]) % modul;
        }
        out[i] = lc;
    }
    return out;
}

function MixLast(t, M, s, input) {
    let lc = 0n;
    for (let j = 0; j < t; j++) {
        lc = (lc + M[j][s] * input[j]) % modul;
    }
    return lc;
}

function MixS(t, S, r, input) {
    const out = new Array(t).fill(0n);

    let lc = 0n;
    for (let i = 0; i < t; i++) {
        lc = (lc + S[(t * 2 - 1) * r + i] * input[i]) % modul;
    }

    out[0] = lc;
    for (let i = 1; i < t; i++) {
        out[i] = (input[i] + input[0] * S[(t * 2 - 1) * r + t + i - 1]) % modul;
    }
    return out;
}

function PoseidonEx(nOuts, inputs, initialState) {
    const out = new Array(nOuts).fill(0n);
    const nInputs = inputs.length;
    const N_ROUNDS_P = [56, 57, 56, 60, 60, 63, 64, 63, 60, 66, 60, 65, 70, 60, 64, 68];
    const t = nInputs + 1;
    const nRoundsF = 8;
    const nRoundsP = N_ROUNDS_P[t - 2];
    let C = new Array(t * nRoundsF + nRoundsP).fill(0n);
    C = POSEIDON_C(t);
    let S = new Array(N_ROUNDS_P[t - 2] * (t * 2 - 1)).fill(0n);
    S = POSEIDON_S(t);
    let M = Array.from({ length: t }, () => new Array(t).fill(0n));
    M = POSEIDON_M(t);
    let P = Array.from({ length: t }, () => new Array(t).fill(0n));
    P = POSEIDON_P(t);

    const ark = new Array(nRoundsF).fill(0n);
    const sigmaF = Array.from({ length: nRoundsF }, () => new Array(t).fill(0n));
    const sigmaP = new Array(nRoundsP).fill(0n);
    const mix = new Array(nRoundsF - 1).fill(0n);
    const mixS = new Array(nRoundsP).fill(0n);
    const mixLast = new Array(nOuts).fill(0n);

    let input = [0n].concat(inputs)

    ark[0] = Ark(t, C, 0, input);

    for (let r = 0; r < nRoundsF / 2 - 1; r++) {
        for (let j = 0; j < t; j++) {
            input = r === 0 ? ark[0][j] : mix[r - 1][j];
            sigmaF[r][j] = Sigma(input);
        }
        input = sigmaF[r];
        ark[r + 1] = Ark(t, C, (r + 1) * t, input);
        input = ark[r + 1];
        mix[r] = Mix(t, M, input);
    }

    for (let j = 0; j < t; j++) {
        sigmaF[nRoundsF / 2 - 1][j] = Sigma(mix[nRoundsF / 2 - 2][j]);
    }

    input = sigmaF[nRoundsF / 2 - 1];
    ark[nRoundsF / 2] = Ark(t, C, nRoundsF / 2 * t, input);
    input = ark[nRoundsF / 2];
    mix[nRoundsF / 2 - 1] = Mix(t, P, input);

    for (let r = 0; r < nRoundsP; r++) {
        sigmaP[r] = r === 0 ? Sigma(mix[nRoundsF / 2 - 1][0]) : Sigma(mixS[r - 1][0]);
        input = new Array(t).fill(0n);
        for (let j = 0; j < t; j++) {
            if (j === 0) {
                input[j] = (sigmaP[r] + C[(nRoundsF / 2 + 1) * t + r]) % modul;
            } else {
                input[j] = r === 0 ? mix[nRoundsF / 2 - 1][j] : mixS[r - 1][j];
            }
        }
        mixS[r] = MixS(t, S, r, input);
    }

    for (let r = 0; r < nRoundsF / 2 - 1; r++) {
        for (let j = 0; j < t; j++) {
            sigmaF[nRoundsF / 2 + r][j] = r === 0 ? Sigma(mixS[nRoundsP - 1][j]) : Sigma(mix[nRoundsF / 2 + r - 1][j]);
        }
        input = sigmaF[nRoundsF / 2 + r];
        ark[nRoundsF / 2 + r + 1] = Ark(t, C, (nRoundsF / 2 + 1) * t + nRoundsP + r * t, input);
        input = ark[nRoundsF / 2 + r + 1];
        mix[nRoundsF / 2 + r] = Mix(t, M, input);
    }

    for (let j = 0; j < t; j++) {
        sigmaF[nRoundsF - 1][j] = Sigma(mix[nRoundsF - 2][j]);
    }

    for (let i = 0; i < nOuts; i++) {
        input = sigmaF[nRoundsF - 1];
        mixLast[i] = MixLast(t, M, i, input);
    }

    return mixLast;
}

function poseidon(inputs) {
    const pEx = PoseidonEx(1, inputs, 0n);
    return pEx[0];
}

module.exports.poseidon = poseidon;