var contract;
var account = null;
var web3;


var actionDesc;
//true for modal main
var modalDecision = true;

var startDate;

var dSModelName = null;

var bModelName = null;

var sStakePromise = null;

var cEnd = null;

var cAdd = null;

var contractAddress = "";
const bc = '0x608060405273a9187c8c9f692fe2ca6b80069e87df23b34157a3600260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555060006005557356dd6586db0d08c6ce7b2f2805af28616e082455600f60006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507f633132386662623031373534343263386261383238303430666464316132356560105567016345785d8a00006011557356dd6586db0d08c6ce7b2f2805af28616e082455601260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055507f323634396663346361383363343031366266643264313537363535393262656560135567016345785d8a0000601455601154600202601454600402016015556000601660006101000a81548160ff0219169083151502179055506000601660016101000a81548160ff0219169083151502179055506001601660026101000a81548160ff0219169083151502179055506001601e553480156101da57600080fd5b504260178190555033600d60006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550610833806102326000396000f3fe60806040526004361061010d5760003560e01c8063a365338411610095578063cf30901211610064578063cf30901214610479578063df38a56a146104a6578063e38d2ec7146104d1578063e6fd48bc14610512578063f63bc0021461053d5761011c565b8063a365338414610368578063ac01495e14610393578063bb1bbc9414610423578063cd45c9581461044e5761011c565b806361eb636d116100dc57806361eb636d146102005780637150d8ae146102905780638534cb24146102d15780638da5cb5b146102fc57806391db3da51461033d5761011c565b8063158ef93e146101265780631df4ccfc1461015357806327cc777f1461017e578063482ada56146101bf5761011c565b3661011c5761011a610568565b005b610124610568565b005b34801561013257600080fd5b5061013b6105a7565b60405180821515815260200191505060405180910390f35b34801561015f57600080fd5b506101686105ba565b6040518082815260200191505060405180910390f35b34801561018a57600080fd5b506101936105c0565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3480156101cb57600080fd5b506101d46105e6565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561020c57600080fd5b5061021561060c565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101561025557808201518184015260208101905061023a565b50505050905090810190601f1680156102825780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561029c57600080fd5b506102a56106aa565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b3480156102dd57600080fd5b506102e66106d0565b6040518082815260200191505060405180910390f35b34801561030857600080fd5b506103116106d6565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561034957600080fd5b506103526106fc565b6040518082815260200191505060405180910390f35b34801561037457600080fd5b5061037d610702565b6040518082815260200191505060405180910390f35b34801561039f57600080fd5b506103a8610708565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156103e85780820151818401526020810190506103cd565b50505050905090810190601f1680156104155780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561042f57600080fd5b506104386107a6565b6040518082815260200191505060405180910390f35b34801561045a57600080fd5b506104636107ac565b6040518082815260200191505060405180910390f35b34801561048557600080fd5b5061048e6107b2565b60405180821515815260200191505060405180910390f35b3480156104b257600080fd5b506104bb6107c5565b6040518082815260200191505060405180910390f35b3480156104dd57600080fd5b506104e66107cb565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561051e57600080fd5b506105276107f1565b6040518082815260200191505060405180910390f35b34801561054957600080fd5b506105526107f7565b6040518082815260200191505060405180910390f35b600073ff61f9fec1935abf8826f9682f5d668114b903fe90503660008037600080366000845af43d6000803e80600081146105a2573d6000f35b3d6000fd5b601660019054906101000a900460ff1681565b60155481565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b601260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60038054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156106a25780601f10610677576101008083540402835291602001916106a2565b820191906000526020600020905b81548152906001019060200180831161068557829003601f168201915b505050505081565b600e60009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60145481565b600d60009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60185481565b60115481565b60048054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561079e5780601f106107735761010080835404028352916020019161079e565b820191906000526020600020905b81548152906001019060200180831161078157829003601f168201915b505050505081565b60195481565b60175481565b601660009054906101000a900460ff1681565b60135481565b600f60009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600c5481565b6010548156fea2646970667358221220ea86389d374ac283458e7fc52b23839c32cee5871574b4e482af31f9cf9a39ec64736f6c634300060c0033';
const abi = JSON.parse('[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"","type":"string"},{"indexed":false,"internalType":"uint256","name":"","type":"uint256"}],"name":"BuyerModelNameRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkCancelled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkFulfilled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"bytes32","name":"id","type":"bytes32"}],"name":"ChainlinkRequested","type":"event"},{"anonymous":false,"inputs":[],"name":"Claimed","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"","type":"string"},{"indexed":false,"internalType":"uint256","name":"","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"","type":"uint256"}],"name":"Constructed","type":"event"},{"anonymous":false,"inputs":[],"name":"Contested","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"","type":"string"}],"name":"Kicked","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"","type":"string"},{"indexed":false,"internalType":"string","name":"","type":"string"}],"name":"Locked","type":"event"},{"anonymous":false,"inputs":[],"name":"Reused","type":"event"},{"inputs":[],"name":"bensch","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"birthStamp","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"buyer","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"buyerModelName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"b32","type":"bytes32"}],"name":"bytes32ToString","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"claim","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"contest","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"costETH","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"feeBytes32","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"feeInt","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_requestId","type":"bytes32"},{"internalType":"bytes32","name":"_APIresult","type":"bytes32"}],"name":"fulfillBytes32","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_requestId","type":"bytes32"},{"internalType":"int256","name":"_APIresult","type":"int256"}],"name":"fulfillInt","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"getHour","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"getMinute","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"getSecond","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"getWeekday","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"string","name":"_sellerModelName","type":"string"},{"internalType":"uint256","name":"_costETH","type":"uint256"},{"internalType":"uint256","name":"_sellerStakePromise","type":"uint256"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"initialized","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"jobIdBytes32","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"jobIdInt","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"kick","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"lock","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"locked","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"oracleBytes32","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"oracleInt","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"reclaim","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"_buyerModelName","type":"string"}],"name":"registerBuyerModelName","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"reuse","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"sellerModelName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"sellerStakePromise","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"startTimestamp","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalFee","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"it","type":"uint256"}],"name":"uintToStr","outputs":[{"internalType":"string","name":"_uintAsString","type":"string"}],"stateMutability":"pure","type":"function"}]');

function modalPrimary() {
    modalDecision = true;
    console.log(modalDecision);
    $('#gasEstimationFailedModal').modal('toggle');
}

function modalSecondary() {
    modalDecision = false;
    console.log(modalDecision);
    $('#gasEstimationFailedModal').modal('toggle');
}

function setup() {
    console.log("SETUP");
    console.log(window.ethereum);
    if (window.ethereum) {

        console.log("E");
        window.ethereum.enable();

        web3 = new Web3(window.ethereum);
        console.log(web3.eth.accounts.length);
        console.log("A");
        console.log(web3);
        if (!web3) {
            console.log("NW3");
            $('#metaMaskRequiredModal').modal('toggle');
            return;
        }

        console.log("IF REACHED");
        console.log(web3.eth.accounts[0]);
        console.log(account);
        if (web3.eth.accounts[0] !== account) {
            console.log("IF REACHED2");
            console.log("F");
            web3.eth.getAccounts(function(err, accounts) {
                if (err != null) {
                    console.log("D2");
                    //alert("Error retrieving accounts.");
                    $('#metaMaskRequiredModal').modal();
                    return;

                }
                if (accounts.length == 0) {
                    console.log("D");
                    $('#metaMaskRequiredModal').modal();
                    return;
                }

                account = accounts[0];

                console.log('Account: ' + account);
                web3.eth.defaultAccount = account;
            });

        } else {
            console.log("IF12 REACHED");
        }


    } else {
        console.log("IF3 REACHED");
        console.log("No metamask");

        $('#metaMaskRequiredModal').modal('toggle');
        return;
    }


} //, 100);


function setUpCheck(viewB) {
    console.log(viewB);
    if (!web3) {
        console.log("not web3");
        $('#metaMaskRequiredModal').modal('toggle');
        return false;
    }
    if (window.ethereum) {
        console.log("wind eth");
        console.log("webeth");
    } else {
        console.log("not wind eth");
        $('#metaMaskRequiredModal').modal('toggle');
        return false;
    }
    if (!viewB && !contract) {

      console.log(viewB);
        console.log("not view not cont");
        $('#contractRequiredModal').modal('toggle');
        return false;
    }
    console.log("true ret");
    return true;
}

function retreiveContract() {

    console.log("true retA");
    if (!setUpCheck(true)) {
        return;
    }
    console.log("true retB");
    contractAddress = $("#newInfo").val().trim();
    contract = new web3.eth.Contract(abi, $("#newInfo").val().trim());
    console.log(contract);
    document.getElementById("addressLabel").innerHTML = "Contract Address: " + '<a target="_blank" href = "https://kovan.etherscan.io/address/' + $("#newInfo").val() + '">' + $("#newInfo").val().trim() + "</a>" + '<a data-container="body" data-toggle="tooltip" data-placement="top" title="Copy Shareable Steak View Link" style = "float:right;verical-algin:center"  onclick ="shareableLink()"><svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-link" viewBox="0 0 16 16"><path d="M6.354 5.5H4a3 3 0 0 0 0 6h3a3 3 0 0 0 2.83-4H9c-.086 0-.17.01-.25.031A2 2 0 0 1 7 10.5H4a2 2 0 1 1 0-4h1.535c.218-.376.495-.714.82-1z"/><path d="M9 5.5a3 3 0 0 0-2.83 4h1.098A2 2 0 0 1 9 6.5h3a2 2 0 1 1 0 4h-1.535a4.02 4.02 0 0 1-.82 1H12a3 3 0 1 0 0-6H9z"/></svg></a>';
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      });

    contract.methods.sellerModelName().call().then(function(info) {
        
        if(info.length > 0)
        {
            document.getElementById('sellerModelNameLabel').innerHTML = "Data Scientist Model Name: " + '<a target="_blank" href = "https://numer.ai/' + String(info) + '">' + String(info) + "</a>";
        }
        else
        {
            document.getElementById('sellerModelNameLabel').innerHTML = "Data Scientist Model Name: Not Determined";
        }
    });


    contract.methods.sellerModelName().call().then(function(info) {
        
        dSModelName = info;
        document.getElementById('sellerModelNameLabel').innerHTML = "Data Scientist Model Name: " + '<a target="_blank" href = "https://numer.ai/' + String(info) + '">' + String(info) + "</a>";
    });



    contract.methods.costETH().call().then(function(info) {
        

        document.getElementById('costETHLabel').innerHTML = "Contract Cost: " + (new BigNumber(info)).shiftedBy(-18).toString() + " ETH";
        //document.getElementById('costETHLabel').className = document.getElementById('costETHLabel').className +  " text-success";
    });
    contract.methods.sellerStakePromise().call().then(function(info) {
        
        sStakePromise = (new BigNumber(info)).shiftedBy(-18).toString();
        document.getElementById('sellerStakePromiseLabel').innerHTML = "Promised Data Scientist Stake: " + (new BigNumber(info)).shiftedBy(-18).toString() + " NMR";
    });

    contract.methods.locked().call().then(function(info) {
        

        document.getElementById('lockedLabel').innerHTML = "Locked: " + String(info);
    });

    contract.methods.birthStamp().call().then(function(info) {
        
        var dateT = new Date(0);
        dateT.setUTCSeconds(info);
        document.getElementById('birthStampLabel').innerHTML = "Birth Date: " + String(dateT.toUTCString().replace("GMT","UTC"));
    });

    contract.methods.startTimestamp().call().then(function(info) {
        
        
        var dateT = new Date(0);

        infoBigNum = new BigNumber(info);

        infoEndBigNum =BigNumber.sum(infoBigNum,7257600);

        dateT.setUTCSeconds(infoBigNum.toString());
        dateTEnd = new Date(0);
        
        dateTEnd.setUTCSeconds(infoEndBigNum.toString());
        console.log(info, typeof info,"INFO TYPE");
        startDate = dateT;

        cEnd = infoEndBigNum.toString()
        if(info != 0 )
        {
         document.getElementById('startStampLabel').innerHTML = "Start Date: " + String(dateT.toUTCString().replace("GMT","UTC"));
         document.getElementById('endStampLabel').innerHTML = "End Date: " + String(dateTEnd.toUTCString().replace("GMT","UTC"));
        }
        else
        {
            document.getElementById('startStampLabel').innerHTML = "Start Date: Not Determined";
        }
    });

    contract.methods.buyerModelName().call().then(function(info) {
        
        if(info.length > 0)
        {
            document.getElementById('buyerModelNameLabel').innerHTML = "Buyer Model Name: " + '<a target="_blank" href = "https://numer.ai/' + String(info) + '">' + String(info) + "</a>";
            bModelName = info;
        }
        else
        {
            document.getElementById('buyerModelNameLabel').innerHTML = "Buyer Model Name: Not Determined";
            //Cause serverside API fail if no model name
            bModelName = "";
        }
    });
    console.log($("#newInfo").val().trim());
    if(!window.location.toString().includes("?"))
    {
        window.location +="?"+ $("#newInfo").val().trim();
    }


    /*contract.methods.payoutPending(1).call().then(function(info) {
        

            document.getElementById('sellerModelPendingPayoutLabel').innerHTML = "Seller Model Live Pending Payout: " + (new BigNumber(info)).shiftedBy(-18).toString();

    });*/


}

function sendWrapper(method, options) {
    console.log(options);
    txTemp = document.createElement("li");
    //{from: account, value: info }
    method.send(options, function(error, transactionHash) {

        txTemp.className = "list-group-item";
        txTemp.innerHTML = '<a target="_blank" href = "https://kovan.etherscan.io/tx/' + transactionHash + '">' + actionDesc + " " + String(new Date()) + "</a>";

        //alert(transactionHash);

    }).catch(function(e) {
        console.log(e.message);
        if (!(String(e.message) === String("MetaMask Tx Signature: User denied transaction signature."))) {
            document.getElementById("transactionLog").appendChild(txTemp);
        }
        return e;
    }).then(function(e) {
        console.log(e.message);
        if (!(String(e.message) === String("MetaMask Tx Signature: User denied transaction signature."))) {
            document.getElementById("transactionLog").appendChild(txTemp);
        }
    });
}

function gasEstimateCheckModalWrapper(method, runIfAlternate) {
     var caught = false;
    method.estimateGas(function(error,result) {
        console.log("ERROR!");
        console.log(error);
        console.log("ERROR!");
        caught = true;
        console.log(result);
        if (!error || result < 1180000) 
        {
            runIfAlternate();
        }
        
        else
        {
        $('#gasEstimationFailedModal').modal().on('hidden.bs.modal', function(e) {
            console.log("closed");
            if (!modalDecision) {
                runIfAlternate();

            }
            modalDecision = true;
        });
        }

    })
}



function registerBuyerName() {
    if (!setUpCheck(false)) {
        return;
    }

    actionDesc = "Register Buyer Name.";
    print(contract,"IMPORTANT CONTRACT");
    toTransact = contract.methods.registerBuyerModelName($("#buyerModelNameInput").val().trim().toLowerCase());
    gasEstimateCheckModalWrapper(toTransact, function() {
        contract.methods.costETH().call().then(function(info) {
            sendWrapper(toTransact, {
                from: account,
                value: info
            }, actionDesc);



            //document.getElementById('costETHLabel').className = document.getElementById('costETHLabel').className +  " text-success";
        });

    });



}

function reclaim() {
    if (!setUpCheck(false)) {
        return;
    }
    actionDesc = "Reclaim.";
    toTransact = contract.methods.reclaim();
    gasEstimateCheckModalWrapper(toTransact, function() {
            sendWrapper(toTransact, {
                from: account
            }, actionDesc);
        }


    );
}

function contest() {
    if (!setUpCheck(false)) {
        return;
    }
    actionDesc = "Contest.";
    toTransact = contract.methods.contest();
    gasEstimateCheckModalWrapper(toTransact, function() {
            sendWrapper(toTransact, {
                from: account
            }, actionDesc);
        }


    );
}

function kick() {
    if (!setUpCheck(false)) {
        return;
    }
    actionDesc = "Kick.";
    toTransact = contract.methods.kick();
    gasEstimateCheckModalWrapper(toTransact, function() {
            sendWrapper(toTransact, {
                from: account
            }, actionDesc);
        }


    );
}

function lock() {
    if (!setUpCheck(false)) {
        return;
    }
    actionDesc = "Lock.";
    toTransact = contract.methods.lock();
    gasEstimateCheckModalWrapper(toTransact, function() {
            sendWrapper(toTransact, {
                from: account
            }, actionDesc);
        }


    );
}

function claim() {
    if (!setUpCheck(false)) {
        return;
    }
    console.log("contract");
    console.log(contract);
    console.log("account");
    console.log(account);
    actionDesc = "Claim.";
    toTransact = contract.methods.claim();
    gasEstimateCheckModalWrapper(toTransact, function() {
            sendWrapper(toTransact, {
                from: account
            }, actionDesc);
        }


    );
}

function deploy() {
    if (!setUpCheck(true)) {
        return;
    }
    txTemp = document.createElement("li");
    var bcr = bc;
    toDeploy = new web3.eth.Contract(abi, {
        from: account,
        data: bcr
    });
    toDeploy.deploy({
        data: bcr,
    }).send({
        from: account
    }).then(

        function(newContractInstance) {

            txTemp = document.createElement("li");
            txTemp.className = "list-group-item";
            txTemp.innerHTML = '<a target="_blank" href = "https://kovan.etherscan.io/address/' + newContractInstance.options.address + '">' + "Deploy." + " " + String(new Date()) + "</a>";
            document.getElementById("transactionLog").appendChild(txTemp);
            $("#newInfo").val(newContractInstance.options.address);
            retreiveContract();
        }
    );
}

function initialize() {
    if (!setUpCheck(false)) {
        return;
    }
    if($("#dataScientistModelNameInput").val().trim().length < 1 && $("#costETHInput").val().trim().length < 1 && $("#dataScientistStakePromiseInput").val().trim().length < 1)
    {
        actionDesc = "Reuse Contract.";
        //print(contract,"IMPORTANT CONTRACT");
        toTransact = contract.methods.reuse();
        gasEstimateCheckModalWrapper(toTransact, function() {
            
                sendWrapper(toTransact, {
                    from: account,
                }, actionDesc);



                //document.getElementById('costETHLabel').className = document.getElementById('costETHLabel').className +  " text-success";


        });
    }
    else
    {
        actionDesc = "Initialize Contract.";
        //print(contract,"IMPORTANT CONTRACT");
        toTransact = contract.methods.initialize($("#dataScientistModelNameInput").val().trim().toLowerCase(), new BigNumber($("#costETHInput").val().trim()).shiftedBy(18),new BigNumber($("#dataScientistStakePromiseInput").val().trim()).shiftedBy(18));
        gasEstimateCheckModalWrapper(toTransact, function() {

                sendWrapper(toTransact, {
                    from: account,
                }, actionDesc);



                //document.getElementById('costETHLabel').className = document.getElementById('costETHLabel').className +  " text-success";


        });
    }



}

function highlightCalendarColumn(selectedCol)
{
    
    var allTd = document.getElementsByTagName("td");

    for(var i = 0;i < allTd.length;i++)
    {

                allTd[i].style = ""; 

    }
    allTd = document.getElementsByTagName("th");
    for(var i = 0;i < allTd.length;i++)
    {

                allTd[i].style = ""; 

    }

    allTd = document.getElementsByTagName("td");

    for(var i = 0;i < allTd.length;i++)
    {
        if(allTd[i].getAttribute("calendarColumn") !== null && allTd[i].getAttribute("calendarColumn").includes(selectedCol))
        {
            allTd[i].style = "border-style:solid;border-width:2px";
            if(allTd[i].getAttribute("calendarColumn").includes("nb"))
            {
                allTd[i].style = "border-style:solid;border-width:2px;border-bottom:none"; 
            }
        }
    }
    allTd = document.getElementsByTagName("th");
    for(var i = 0;i < allTd.length;i++)
    {
        if(allTd[i].getAttribute("calendarColumn") !== null && allTd[i].getAttribute("calendarColumn").includes(selectedCol))
        {
            allTd[i].style = "border-style:solid;border-width:2px";
            if(allTd[i].getAttribute("calendarColumn").includes("nb"))
            {
                allTd[i].style = "border-style:solid;border-width:2px;border-bottom:none"; 
            }
        }
    }
}

function shareableLink()
{
    
    navigator.clipboard.writeText(window.location.href.slice(0,window.location.href.lastIndexOf("/") + 1) + "?" + contractAddress);
}

function requestSubscribe()
{
    if(!contract)
    {
        $('#contractRequiredModal').modal('toggle')
    }
    else
    {
        window.location='http://bensch.pythonanywhere.com' + "/" + dSModelName + "," + bModelName + "," + sStakePromise + "," + cEnd + "," + document.getElementById("email").value+","+$("#newInfo").val().trim();
    }
    
}


window.addEventListener('load', () => {
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      });
    setup();
    //$("#metaMaskRequiredModal").on("hidden.bs.modal",setup);

    console.log("ABC",window.location.href.slice(window.location.href.indexOf("?")+1).length);
    if(window.location.href.slice(window.location.href.indexOf("?")+1).length > 0 && window.location.href.toString().includes("?"))
    {
        console.log("ABC",window.location.href.slice(window.location.href.indexOf("?")+1));
        document.getElementById("newInfo").value = (window.location.href.slice(window.location.href.indexOf("?")+1));
        retreiveContract();
    }

    var calendarInterval = setInterval(
    function()
    {
        var d = new Date();



        var n = d.toUTCString();
        console.log(n);
        document.getElementById("UTCclock").innerHTML = n.replace("GMT","UTC");
        if(startDate !== undefined && startDate.getTime() !== 0)
        {
            console.log("have startdate",startDate);
            console.log(startDate.getTime(),d.getTime());
            
            var elapsed = (d.getTime() - startDate.getTime())/3600000;

            //highlightCalendarColumn("" + (d.getDay() + 1))
            console.log("UTC DEB HOURS",typeof d.getUTCHours());
            if(elapsed > 198)
            {
                highlightCalendarColumn("9");
            }
            else
            {
                switch(d.getUTCDay())
            {
                case 0:
                    if(elapsed > 48)
                    {
                        highlightCalendarColumn("8");
                    }
                    else
                    {
                        highlightCalendarColumn("1");
                    }
                    break;

                case 1:
                    console.log("UTC HOURS",d.getUTCHours());
                     if(d.getUTCHours() <=13)
                    {
                        highlightCalendarColumn("2");
                    }
                    break;

                case 2:
                    highlightCalendarColumn("3");
                    break;

                case 3:
                    highlightCalendarColumn("4");
                    break;
                
                case 4:
                    highlightCalendarColumn("5");
                    break;

                case 5:
                    highlightCalendarColumn("6");
                    break;
                
                case 6:

                    if(elapsed > 48)
                    {
                        highlightCalendarColumn("7");
                    }
                    else
                    {

                        if(d.getUTCHours() >= 18)
                        {

                            highlightCalendarColumn("0");
                        }
                    }
                    break;
                


            }
            }
            


        }
    },500);


});
