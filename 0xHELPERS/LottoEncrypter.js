    // "cd 0xHELPERS", "node LottoEncrypter.js"
    
    const ethers = require('ethers');
    
    // values for the quiz factory contract
    question = 'Test 1';
    salt = 'changeThisBeforeDeploying';
    answer = '69';
    encryptedAnswer = null;
    async function encryptAnswer() {
        // encrypt the answer using the same salt as the contract
        encryptedAnswer = ethers.utils.keccak256(
            ethers.utils.solidityPack(
                ['bytes32', 'string'],
                [ethers.utils.formatBytes32String(salt), answer]
            )
        );
        console.log(encryptedAnswer);
    }
    encryptAnswer()

    // 0xc234ab96c3ca06ed28529b16706d110e15db4485950c4f0e76ed6930ded72e77