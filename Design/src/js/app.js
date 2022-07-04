$(function(){
    $(window).load(function(){
        PrepareNetwork();
    })
})


var JsonContract = null;
var web3 = null;
var MyContract = null;
var Owner = null;
var NFTName = null;
var NFTSymbol = null;
var Balance_CurrentAccount = 0;
var CurrentAccount = null;
var NFTCounterMint = null;
var IPFS_Hash = null;
var Host_Name = 'https://ipfs.infura.io/ipfs/';
var Content = null;
var flag = 0;


const ipfs = new IPFS({host:'ipfs.infura.io', port:5001, portocol:'https'});


async function PrepareNetwork(){
    await loadWeb3();
    await LoadDataSmartContract();
}


async function loadWeb3(){

    if(window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        await ethereum.request({method: "eth_requestAccounts"}).then(function(account){
            CurrentAccount = account[0];
            web3.eth.defaultAccount = CurrentAccount;
            console.log(" current account: " + CurrentAccount);
            setCurrentAccount();
        });
    }else if(window.web3){
        window.web3 = new Web3(window.web3.currentProvider);
    }else{
        window.alert(" Non-Ethereum browser detected")
    }

    ethereum.on("accountsChanged", handleAccountChanged);
    ethereum.on("chainChanged", handleChainChanged);
}


function setCurrentAccount(){
    $("#Address").text(CurrentAccount);
}



async function handleAccountChanged() {
    await  ethereum.request({method: 'eth_requestAccounts'}).then(function (accounts) {
        CurrentAccount = accounts[0];
        web3.eth.defaultAccount = CurrentAccount;
        console.log('current account: ' + CurrentAccount);
        setCurrentAccount();
        window.location.reload();
    });
}

async function handleChainChanged(_chainId) {
    window.location.reload();
    console.log('Chain Changed: ', _chainId);
}



async function LoadDataSmartContract() {
    await $.getJSON('ERC721.json', function(contractData) {
        JsonContract = contractData;
      });

    web3 = await window.web3;

    const networkId = await web3.eth.net.getId();

    const networkData = JsonContract.networks[networkId];
    console.log(networkData);

    if(networkData) {
        MyContract = new web3.eth.Contract(JsonContract.abi, networkData.address);
        NFTName = await  MyContract.methods.name().call();
        NFTSymbol = await  MyContract.methods.symbol().call();
        Balance_CurrentAccount = await  MyContract.methods.balanceOf(CurrentAccount).call();
        console.log('Balance_CurrentAccount : ' + Balance_CurrentAccount);

        NFTCounterMint = await  MyContract.methods.tokenIdCounter().call();
        console.log('NFTCounterMint : ' + NFTCounterMint);
    
        $('#NFTName').text(NFTName);
        $('#NFTSymbol').text(NFTSymbol);
        $('#balanceOf_CurrentAccount').text(Balance_CurrentAccount);  

     }

     $(document).on('click', '#mint', mint);
     $(document).on('click', '#Owner', OwnerNFT);
     $(document).on('click', '#Approve', approve);
     $(document).on('click', '#GetApprove',GetApprove);
     $(document).on('click', '#setApprovalForAll', setApprovalForAll);
     $(document).on('click', '#isApproved',isApproved);
     $(document).on('click', '#TransfeFrom',TransfeFrom);
     $(document).on('click', '#Burn',Burn);
     $(document).on('click', '#ShowNFT', ShowNFT);
}



function makeHttpObject() {
    if ("XMLHttpRequest" in window) return new XMLHttpRequest();
    else if ("ActiveXObject" in window) return new ActiveXObject("Msxml2.XMLHTTP");
}


async function ShowNFT() {

   var tokenID = $('#tokenidShow').val();
   if (tokenID.trim() == '') {
       alert('Please Fill Text...');
       return;
   }
   // console.log('test2');
   var HashIMG = await MyContract.methods.ShowNft(tokenID).call();
   alert('HashIMG : ' + HashIMG);


   var msg = Host_Name + HashIMG;
   console.log(msg);
    if (flag == 0) {
        var br = '<br>';
        $('#showimgnft').append(br);
        var newElemn = '<img id="nftimg" src="#" width=150>' + '</img >';
        $('#showimgnft').append(newElemn);
        $("#nftimg").css("margin-left", "43%");
    }

    flag = 1;

    var request = makeHttpObject();
    request.open("GET", msg, true);
    request.send(null);
    request.onreadystatechange = function () {
        if (request.readyState == 4) {
            Content = request.responseText;
        
            $('#nftimg').attr('src', Content);
        }
    };

}


function previewFile() {

   const preview = document.querySelector('#imgnft');
   const file = document.querySelector('input[type=file]').files[0];

   const reader = new FileReader();
   reader.readAsDataURL(file);

   reader.addEventListener("load", async function () {
       console.log(reader.result);

       preview.src = reader.result;
       await ipfs.add(reader.result, function (err, hash) {

           if (err) {
               alert('Error To IPFS Add...');
               return false;
           } else {
               IPFS_Hash = hash;
               console.log('IPFS_Hash = ', IPFS_Hash);
           }
       });

   });
}


function Burn() {
    
    var TokenID = $("#tokenidburn").val();
    if (TokenID.trim() == '') {
        alert("Please Fill TextBox");
    }

    MyContract.methods.burn(TokenID).send({from:CurrentAccount}).then(function (Instance) {
        
        alert(Instance.events.Transfer.returnValues[0] + " Burn TokenID {" + 
        Instance.events.Transfer.returnValues[2] + "} ");
       // window.location.reload();
    }).catch(function (error) {
        var msg = error.message;

        var idxbigin = msg.indexOf("ERC721");
        var idxend = msg.indexOf(",",idxbigin);
        var result = msg.slice(idxbigin, idxend-1);

        alert('ERROR ========>' + result);
      //  alert(error.message);
    });

}



async function TransfeFrom() {
    
    var Addressfrom = $("#AdressFromTransfeFrom").val();
    var AddressTO = $("#AdressToTransfeFrom").val();
    var TokenId = $("#IDAdressToTransfeFrom").val();
    if (Addressfrom.trim() == '' || AddressTO.trim() == '' || TokenId.trim() == '') {
        alert("Please Fill TextBox");
    }

    MyContract.methods.safeTransferFrom(Addressfrom, AddressTO, TokenId).send({from:CurrentAccount}).then(function (Instance) {
        
        alert(Instance.events.Transfer.returnValues[0] + " Transfer TokenID {" + 
        Instance.events.Transfer.returnValues[2] + "} TO " + Instance.events.Transfer.returnValues[1]);
       // window.location.reload();
    }).catch(function (error) {
        var msg = error.message;

        var idxbigin = msg.indexOf("ERC721");
        var idxend = msg.indexOf(",",idxbigin);
        var result = msg.slice(idxbigin, idxend-1);

        alert('ERROR ========>' + result);
      //  alert(error.message);
    });

}





async function isApproved() {
    var Addressfrom = $("#AddressfromToApprove").val();
    var AddressTO = $("#AddressToToApprove").val();
    if (Addressfrom.trim() == '' || AddressTO.trim() == '') {
        alert("Please Fill TextBox");
    }


    var isapproved = await  MyContract.methods.isApprovedForAll(Addressfrom, AddressTO).call();
    alert('isapproved: ' + isapproved);  


}



async function setApprovalForAll() {
    
    var boolItem = $("#boolApprovalForAll").val();
    var AddressTO = $("#AdressApprovalForAll").val();
    if (boolItem.trim() == '' || AddressTO.trim() == '') {
        alert("Please Fill TextBox");
    }

    if (boolItem == "false") {
        boolItem = Boolean(0);
    } else if(boolItem == "true"){
        boolItem = Boolean(boolItem);
    }else{
        alert("Please Fill TextBox correct");
    }

    MyContract.methods.setApprovalForAll(AddressTO, boolItem).send({from:CurrentAccount}).then(function (Instance) {
        alert(Instance.events.ApprovalForAll.returnValues[0] + " Approved ForAll {" + 
        Instance.events.ApprovalForAll.returnValues[2] + "} TO " + Instance.events.ApprovalForAll.returnValues[1]);
       // window.location.reload();
    }).catch(function (error) {
        var msg = error.message;

        var idxbigin = msg.indexOf("ERC721: approve to caller");
        var idxend = msg.indexOf(",",idxbigin);
        var result = msg.slice(idxbigin, idxend-1);

        alert('ERROR ========>' + result);
      //  alert(error.message);
    });

}





async function GetApprove() {

    var TokenID = $("#tokenidGetApprove").val();
    if (TokenID.trim() == '') {
        alert("Please Fill TextBox");
    }

    var ApprovedNFT = await  MyContract.methods.getApproved(TokenID).call();
    alert('getApproved: ' + ApprovedNFT);  
}


async function approve(){
    var TokenID = $("#tokenIDApprove").val();
    var AddressTO = $("#AddressToApprove").val();

    if(TokenID.trim() == " " || AddressTO.trim() == " "){
        alert("plz fill textbox");
    }

    await MyContract.methods.approve(AddressTO, TokenID).send({from:CurrentAccount}).then(function (Instance) {
        alert("address " + Instance.events.Approval.returnValues[0] + " approved token ID " + 
        Instance.events.Approval.returnValues[2]+ " to " + Instance.events.Approval.returnValues[1]);
        window.location.reload();
    }).catch(function (error) {
        var msg = error.message;
        var indexbigin =  msg.indexOf("apploval");
        var indexend = msg.indexOf(",", indexbigin);
        var result = msg.slice(indexbigin, indexend-1);
        alert('error ===> '+ result);
        // alert(error.message);
    });

}



async function OwnerNFT(){
    var TokenID = $("#tokenidowner").val();

    if(TokenID.trim() == " "){
        alert("plz fill textbox");
    }

    var OwnerNFT = await MyContract.methods.ownerOf(TokenID).call();
    alert(`owner of this NFT is: ${OwnerNFT}`)
}


async function mint() {
    

    if (IPFS_Hash == null) {
        alert('Please Select Image...');
        return;
    }

    await MyContract.methods.mint(CurrentAccount, IPFS_Hash).send({from:CurrentAccount}).then(function (Instance) {
        alert("new NFT minted By " + Instance.events.Transfer.returnValues[1] + " With TokenId " + 
        Instance.events.Transfer.returnValues[2]);
        window.location.reload();
    }).catch(function (error) {
        alert(error.message);
    });

}



