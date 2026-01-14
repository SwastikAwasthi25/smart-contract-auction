pragma solidity ^0.4.1;

contract Auction {

 //Structure to hold details of the item
 struct Item {
     uint itemId;
     uint[] itemTokens;
 }

 //Structure to hold the details of a person
 struct Person {
     uint remainingTokens;
     uint personId;
     address addr;
 }

 mapping(address => Person) tokenDetails;
 Person[4] bidders;

 Item[3] public items;
 address[3] public winners;
 address public beneficiary;

 uint bidderCount = 0;

 // MODIFIER
 modifier onlyOwner() {
     if(msg.sender != beneficiary) throw;
     _;
 }

 // Constructor
 function Auction() public {
     beneficiary = msg.sender;

     uint[] memory emptyArray;
     items[0] = Item({itemId:0,itemTokens:emptyArray});
     items[1] = Item({itemId:1,itemTokens:emptyArray});
     items[2] = Item({itemId:2,itemTokens:emptyArray});
 }

 // Register bidder
 function register() public {
     bidders[bidderCount].personId = bidderCount;
     bidders[bidderCount].addr = msg.sender;
     bidders[bidderCount].remainingTokens = 5;

     tokenDetails[msg.sender] = bidders[bidderCount];
     bidderCount++;
 }

 // Bid function
 function bid(uint _itemId, uint _count) public {

     // Conditions (replacing require)
     if(tokenDetails[msg.sender].remainingTokens < _count) throw;
     if(tokenDetails[msg.sender].remainingTokens == 0) throw;
     if(_itemId > 2) throw;

     // Reduce tokens
     tokenDetails[msg.sender].remainingTokens -= _count;

     bidders[tokenDetails[msg.sender].personId].remainingTokens =
     tokenDetails[msg.sender].remainingTokens;

     Item storage bidItem = items[_itemId];

     for(uint i=0;i<_count;i++){
         bidItem.itemTokens.push(tokenDetails[msg.sender].personId);
     }
 }

 // Reveal winners
 function revealWinners() public onlyOwner {

     for(uint id=0; id<3; id++){
         Item storage currentItem = items[id];

         if(currentItem.itemTokens.length != 0){

             uint randomIndex =
             (block.number / currentItem.itemTokens.length) %
             currentItem.itemTokens.length;

             uint winnerId =
             currentItem.itemTokens[randomIndex];

             winners[id] = bidders[winnerId].addr;
         }
     }
 }

 // Helper function
 function getPersonDetails(uint id)
 public constant returns(uint,uint,address){

     return (
         bidders[id].remainingTokens,
         bidders[id].personId,
         bidders[id].addr
     );
 }
}
