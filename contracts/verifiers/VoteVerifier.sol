// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract VoteVerifier {
    /// @dev Base field size
    uint256 public constant BASE_FIELD_SIZE =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @dev Verification Key data
    uint256 public constant ALPHA_X =
        20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 public constant ALPHA_Y =
        9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 public constant BETA_X1 =
        4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 public constant BETA_X2 =
        6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 public constant BETA_Y1 =
        21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 public constant BETA_Y2 =
        10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 public constant GAMMA_X1 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 public constant GAMMA_X2 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 public constant GAMMA_Y1 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 public constant GAMMA_Y2 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 public constant DELTA_X1 =
        11806666136471813271888432226567833876902076838663848832865081359013986789342;
    uint256 public constant DELTA_X2 =
        5629056013244053916720717360772037256572236159777404224071373379450712585889;
    uint256 public constant DELTA_Y1 =
        815958200151960251276124646883218217067112282363786911536925303988846490518;
    uint256 public constant DELTA_Y2 =
        13523136102358251720610300453605370532983345850374607631856067382854811102153;

    uint256 public constant IC0_X =
        4828087125722720463498523105989347775732672256551869515195366945130440153358;
    uint256 public constant IC0_Y =
        16473461020244107062076760585472665843804205426759154081194077400694019179061;
    uint256 public constant IC1_X =
        20754929780074047407867024095211812631009053291358976317215772253409178779119;
    uint256 public constant IC1_Y =
        12760283752147685013044241455796778878056848117926659503436116535702929034394;
    uint256 public constant IC2_X =
        11473290069172532630992292990788862314861309639722773910486746721408405632626;
    uint256 public constant IC2_Y =
        9649754299195895572376814201023183609322847578734515316861951137038113312549;
    uint256 public constant IC3_X =
        15980960165045527352437834313772739720247144480632490141749850926954168695399;
    uint256 public constant IC3_Y =
        15913096542593801259542569023304473360284332760140807395096734639655449695221;
    
    /// @dev Memory data
    uint16 public constant P_VK = 0;
    uint16 public constant P_PAIRING = 128;
    uint16 public constant P_LAST_MEM = 896;

    function verifyProof(
        uint256[2] memory pA_,
        uint256[2][2] memory pB_,
        uint256[2] memory pC_,
        uint256[3] memory pubSignals_
    ) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, BASE_FIELD_SIZE)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            /// @dev G1 function to multiply a G1 value(x,y) to value in an address
            function g1MulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)

                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let pPairing_ := add(pMem, P_PAIRING)
                let pVk_ := add(pMem, P_VK)

                mstore(pVk_, IC0_X)
                mstore(add(pVk_, 32), IC0_Y)

                /// @dev Compute the linear combination vk_x
                g1MulAccC(pVk_, IC1_X, IC1_Y, mload(add(pubSignals, 0)))
                g1MulAccC(pVk_, IC2_X, IC2_Y, mload(add(pubSignals, 32)))
                g1MulAccC(pVk_, IC3_X, IC3_Y, mload(add(pubSignals, 64)))
                
                /// @dev -A
                mstore(pPairing_, mload(pA))
                mstore(
                    add(pPairing_, 32),
                    mod(sub(BASE_FIELD_SIZE, mload(add(pA, 32))), BASE_FIELD_SIZE)
                )

                /// @dev B
                mstore(add(pPairing_, 64), mload(mload(pB)))
                mstore(add(pPairing_, 96), mload(add(mload(pB), 32)))
                mstore(add(pPairing_, 128), mload(mload(add(pB, 32))))
                mstore(add(pPairing_, 160), mload(add(mload(add(pB, 32)), 32)))

                /// @dev alpha1
                mstore(add(pPairing_, 192), ALPHA_X)
                mstore(add(pPairing_, 224), ALPHA_Y)

                /// @dev beta2
                mstore(add(pPairing_, 256), BETA_X1)
                mstore(add(pPairing_, 288), BETA_X2)
                mstore(add(pPairing_, 320), BETA_Y1)
                mstore(add(pPairing_, 352), BETA_Y2)

                /// @dev vk_x
                mstore(add(pPairing_, 384), mload(add(pMem, P_VK)))
                mstore(add(pPairing_, 416), mload(add(pMem, add(P_VK, 32))))

                /// @dev gamma2
                mstore(add(pPairing_, 448), GAMMA_X1)
                mstore(add(pPairing_, 480), GAMMA_X2)
                mstore(add(pPairing_, 512), GAMMA_Y1)
                mstore(add(pPairing_, 544), GAMMA_Y2)

                /// @dev C
                mstore(add(pPairing_, 576), mload(pC))
                mstore(add(pPairing_, 608), mload(add(pC, 32)))

                /// @dev delta2
                mstore(add(pPairing_, 640), DELTA_X1)
                mstore(add(pPairing_, 672), DELTA_X2)
                mstore(add(pPairing_, 704), DELTA_Y1)
                mstore(add(pPairing_, 736), DELTA_Y2)

                let success_ := staticcall(sub(gas(), 2000), 8, pPairing_, 768, pPairing_, 0x20)

                isOk := and(success_, mload(pPairing_))
            }

            let pMem_ := mload(0x40)
            mstore(0x40, add(pMem_, P_LAST_MEM))

            /// @dev Validate that all evaluations ∈ F
            checkField(mload(add(pubSignals_, 0)))
            checkField(mload(add(pubSignals_, 32)))
            checkField(mload(add(pubSignals_, 64)))
            checkField(mload(add(pubSignals_, 96)))
            
            /// @dev Validate all evaluations
            let isValid := checkPairing(pA_, pB_, pC_, pubSignals_, pMem_)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
