namespace BHT_algorithm {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation init():Unit{
        Message("BHT algorithm.");
        //Oracles for collisioin and non-collision need to be creatd. In our case :
        // qubitsCollisionOracle - Collision
        // nonCollisionOracle - no collision

        //for collision
        let oracle = qubitsCollisionOracle;
        let collisionDetected = BHT(2,oracle);
        Message($"Has collided={collisionDetected}");
        
        //for non collision.
        let noCollisionOracle = nonCollisionOracle;
        let noCollision = BHT(2,noCollisionOracle);
        Message($"Has collided={noCollision}");
        
    }

    //Creating an oracle function for collisions
    operation qubitsCollisionOracle(q:Qubit[]):Unit{
        if(M(q[0])==One){
            X(q[1]);
        }
    }

    operation nonCollisionOracle(q:Qubit[]):Unit{}

    operation BHT(n:Int,oracle:((Qubit[])=>Unit)):Bool{
        use inputQubits = Qubit[n];
        mutable inGoodState = false;

        //Performing phase kickback by applying Hadamand gate to all but the last quit
        for i in 0..n-1{
            //ApplyToEach(H,inputQubits[0..n-i-2]);
            //Controlled H(inputQubits[0..n-i-2],inputQubits[n-i-2]);
            ApplyToEach(H,inputQubits);
            //Applying the oracle function
            qubitsCollisionOracle(inputQubits);

            //Applying Grovers diffusion

            ApplyGroverDiffusion(inputQubits);

            let measurements = MultiM(inputQubits);
            mutable count = 0;
            for j in 0..Length(measurements)
            {
                if(measurements[j] == Zero){
                    set count += 1;
                }
            }

            if(count>=n-2){
                set inGoodState = true;
            }
            
        }

        ResetAll(inputQubits);
        
        return inGoodState;
    }

    operation ApplyGroverDiffusion(qubits:Qubit[]):Unit{
        let length = Length(qubits);
        ApplyToEachA(H, qubits);
        Z(qubits[length-1]);
        Controlled H(qubits[0..length-2], qubits[length-1]);
        Z(qubits[length-1]);
        ApplyToEachA(H, qubits);
    }

}
