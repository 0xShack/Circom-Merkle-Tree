pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template Merkle(n) {

    // signal declarations
    signal input leaves[n];
    signal output root;

    // variable declarations
    var k = 0;
    var nodeCount = 2 * n - 1;

    // array declarations
    component node[nodeCount];
    var hash[nodeCount];

    // compute hash for each leaf
    for (var i = 0; i < n; i++) {
        node[i] = MiMCSponge(1, 220, 1);
        node[i].ins[0] <== leaves[i];
        node[i].k <== k;
        hash[i] = node[i].outs[0];
    }

    // compute root node
    for (var i = 2; i < nodeCount; i += 2) {
        var parent = i / 2 + n - 1;
        node[parent] = MiMCSponge(2, 220, 1);
        node[parent].ins[0] <== hash[i - 2];
        node[parent].ins[1] <== hash[i - 1];
        node[parent].k <== k;
        hash[parent] = node[parent].outs[0];
    }

    // output root hash
    root <== hash[nodeCount - 1];

}

component main { public [leaves] } = Merkle(8);