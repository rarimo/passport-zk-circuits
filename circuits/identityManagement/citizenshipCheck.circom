pragma circom 2.1.6;

include "../lib/circuits/bitify/bitify.circom";
include "../lib/circuits/bitify/comparators.circom";

template CitizenshipCheck(){
    signal input citizenship;
    signal input blacklist;

    var COUNTRY_COUNT = 240;

    var COUNTRY_ARR[COUNTRY_COUNT] = [
        4276823, //ABW
        4277831, //AFG
        4278095, //AGO
        4278593, //AIA
        4279362, //ALB
        4279876, //AND
        4279892, //ANT
        4280901, //ARE
        4280903, //ARG
        4280909, //ARM
        4281165, //ASM
        4281409, //ATA
        4281415, //ATG
        4281683, //AUS
        4281684, //AUT
        4282949, //AZE
        4342857, //BDI
        4343116, //BEL
        4343118, //BEN
        4343361, //BFA
        4343620, //BGD
        4343634, //BGR
        4343890, //BHR
        4343891, //BHS
        4344136, //BIH
        4344909, //BLM
        4344914, //BLR
        4344922, //BLZ
        4345173, //BMU
        4345676, //BOL
        4346433, //BRA
        4346434, //BRB
        4346446, //BRN
        4346958, //BTN
        4347713, //BWA
        4407622, //CAF
        4407630, //CAN
        4408139, //CCK
        4409413, //CHE
        4409420, //CHL
        4409422, //CHN
        4409686, //CIV
        4410706, //CMR
        4411204, //COD
        4411207, //COG
        4411211, //COK
        4411212, //COL
        4411213, //COM
        4411478, //CPV
        4411977, //CRI
        4412738, //CUB
        4412759, //CUW
        4413522, //CXR
        4413773, //CYM
        4413776, //CYP
        4414021, //CZE
        4474197, //DEU
        4475465, //DJI
        4476225, //DMA
        4476491, //DNK
        4476749, //DOM
        4479553, //DZA
        4539221, //ECU
        4540249, //EGY
        4543049, //ERI
        4543304, //ESH
        4543312, //ESP
        4543316, //EST
        4543560, //ETH
        4606286, //FIN
        4606537, //FJI
        4607051, //FLK
        4608577, //FRA
        4608591, //FRO
        4608845, //FSM
        4669762, //GAB
        4670034, //GBR
        4670799, //GEO
        4671321, //GGY
        4671553, //GHA
        4671810, //GIB
        4671822, //GIN
        4672834, //GMB
        4673090, //GNB
        4673105, //GNQ
        4674115, //GRC
        4674116, //GRD
        4674124, //GRL
        4674637, //GTM
        4674893, //GUM
        4674905, //GUY
        4737863, //HKG
        4738628, //HND
        4739670, //HRV
        4740169, //HTI
        4740430, //HUN
        4801614, //IDN
        4803918, //IMN
        4804164, //IND
        4804436, //IOT
        4805196, //IRL
        4805198, //IRN
        4805201, //IRQ
        4805452, //ISL
        4805458, //ISR
        4805697, //ITA
        4866381, //JAM
        4867417, //JEY
        4869970, //JOR
        4870222, //JPN
        4931930, //KAZ
        4932942, //KEN
        4933466, //KGZ
        4933709, //KHM
        4933970, //KIR
        4935233, //KNA
        4935506, //KOR
        4937556, //KWT
        4997455, //LAO
        4997710, //LBN
        4997714, //LBR
        4997721, //LBY
        4997953, //LCA
        4999493, //LIE
        5000001, //LKA
        5002063, //LSO
        5002325, //LTU
        5002584, //LUX
        5002817, //LVA
        5062979, //MAC
        5062982, //MAF
        5062994, //MAR
        5063503, //MCO
        5063745, //MDA
        5063751, //MDG
        5063766, //MDV
        5064024, //MEX
        5064780, //MHL
        5065540, //MKD
        5065801, //MLI
        5065812, //MLT
        5066066, //MMR
        5066309, //MNE
        5066311, //MNG
        5066320, //MNP
        5066586, //MOZ
        5067348, //MRT
        5067602, //MSR
        5068115, //MUS
        5068617, //MWI
        5069139, //MYS
        5069140, //MYT
        5128525, //NAM
        5129036, //NCL
        5129554, //NER
        5130049, //NGA
        5130563, //NIC
        5130581, //NIU
        5131332, //NLD
        5132114, //NOR
        5132364, //NPL
        5132885, //NRU
        5134924, //NZL
        5197134, //OMN
        5259595, //PAK
        5259598, //PAN
        5260110, //PCN
        5260626, //PER
        5261388, //PHL
        5262423, //PLW
        5262919, //PNG
        5263180, //POL
        5263945, //PRI
        5263947, //PRK
        5263956, //PRT
        5263961, //PRY
        5264197, //PSE
        5265734, //PYF
        5325140, //QAT
        5391701, //REU
        5394261, //ROU
        5395795, //RUS
        5396289, //RWA
        5456213, //SAU
        5456974, //SDN
        5457230, //SEN
        5457744, //SGP
        5457998, //SHN
        5458509, //SJM
        5459010, //SLB
        5459013, //SLE
        5459030, //SLV
        5459282, //SMR
        5459789, //SOM
        5460045, //SPM
        5460546, //SRB
        5460804, //SSD
        5461072, //STP
        5461330, //SUR
        5461579, //SVK
        5461582, //SVN
        5461829, //SWE
        5461850, //SWZ
        5462093, //SXM
        5462339, //SYC
        5462354, //SYR
        5522241, //TCA
        5522244, //TCD
        5523279, //TGO
        5523521, //THA
        5524043, //TJK
        5524300, //TKL
        5524301, //TKM
        5524563, //TLS
        5525326, //TON
        5526607, //TTO
        5526862, //TUN
        5526866, //TUR
        5526870, //TUV
        5527374, //TWN
        5528129, //TZA
        5588801, //UGA
        5589842, //UKR
        5591641, //URY
        5591873, //USA
        5593666, //UZB
        5652820, //VAT
        5653332, //VCT
        5653838, //VEN
        5654338, //VGB
        5654866, //VIR
        5656141, //VNM
        5657940, //VUT
        5721158, //WLF
        5722957, //WSM
        5786456, //XKX
        5850445, //YEM
        5914950, //ZAF
        5918018, //ZMB
        5920581 //ZWE
    ];
    
    component isEqual[COUNTRY_COUNT];
    component isEqual2[COUNTRY_COUNT];
    signal validCheck[COUNTRY_COUNT+1];
    validCheck[0] <== 0;
    component num2bits = Num2Bits(COUNTRY_COUNT);
    num2bits.in <== blacklist;

    signal bitmask[COUNTRY_COUNT];
    for (var i = 0; i < COUNTRY_COUNT; i++){
        bitmask[i] <== num2bits.out[COUNTRY_COUNT - 1 - i];
        isEqual[i] = IsEqual();
        isEqual[i].in[0] <== COUNTRY_ARR[i];
        isEqual[i].in[1] <== citizenship;
        isEqual2[i] = IsEqual();
        isEqual2[i].in[0] <== 1;
        isEqual2[i].in[1] <== bitmask[i];
        isEqual[i].out * isEqual2[i].out === 0;
        validCheck[i+1] <== isEqual[i].out + validCheck[i];
    }  
    validCheck[COUNTRY_COUNT] === 1;

}