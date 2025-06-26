pragma circom  2.1.6;

// log matrix m x n
function log_matrix(matrix, m, n){

    assert(n < 40);
    for (var i = 0; i < m; i++){
        if (n == 1)     {
            log(matrix[i][0]);
        }
        if (n == 2)     {
            log(matrix[i][0], matrix[i][1]);
        }
        if (n == 3)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2]);
        }
        if (n == 4)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3]);
        }
        if (n == 5)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4]);
        }
        if (n == 6)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5]);
        }
        if (n == 7)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6]);
        }
        if (n == 8)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7]);
        }
        if (n == 9)     {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8]);
        }
        if (n == 10)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9]);
        }
        if (n == 11)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10]);
        }
        if (n == 12)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11]);
        }
        if (n == 13)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12]);
        }
        if (n == 14)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13]);
        }
        if (n == 15)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14]);
        }
        if (n == 16)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15]);
        }
        if (n == 17)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16]);
        }
        if (n == 18)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17]);
        }
        if (n == 19)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18]);
        }
        if (n == 20)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19]);
        }
        if (n == 21)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20]);
        }
        if (n == 22)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21]);
        }
        if (n == 23)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22]);
        }
        if (n == 24)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23]);
        }
        if (n == 25)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24]);
        }
        if (n == 26)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25]);
        }
        if (n == 27)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26]);
        }
        if (n == 28)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27]);
        }
        if (n == 29)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28]);
        }
        if (n == 30)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29]);
        }
        if (n == 31)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30]);
        }
        if (n == 32)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31]);
        }
        if (n == 33)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32]);
        }
        if (n == 34)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33]);
        }
        if (n == 35)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33], matrix[i][34]);
        }
        if (n == 36)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33], matrix[i][34], matrix[i][35]);
        }
        if (n == 37)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33], matrix[i][34], matrix[i][35], matrix[i][36]);
        }
        if (n == 38)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33], matrix[i][34], matrix[i][35], matrix[i][36], matrix[i][37]);
        }
        if (n == 39)    {
            log(matrix[i][0], matrix[i][1], matrix[i][2], matrix[i][3], matrix[i][4], matrix[i][5], matrix[i][6], matrix[i][7], matrix[i][8], matrix[i][9], matrix[i][10], matrix[i][11], matrix[i][12], matrix[i][13], matrix[i][14], matrix[i][15], matrix[i][16], matrix[i][17], matrix[i][18], matrix[i][19], matrix[i][20], matrix[i][21], matrix[i][22], matrix[i][23], matrix[i][24], matrix[i][25], matrix[i][26], matrix[i][27], matrix[i][28], matrix[i][29], matrix[i][30], matrix[i][31], matrix[i][32], matrix[i][33], matrix[i][34], matrix[i][35], matrix[i][36], matrix[i][37], matrix[i][38]);
        }
    }
    return 0;
}