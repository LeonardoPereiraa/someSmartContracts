// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import "@openzeppelin/contracts/access/AccessControl.sol";

contract NFTAirdrop is AccessControl {
  struct Airdrop {
    address nft;
    uint id;
  }

  uint public nextAirdropId;
  address public admin;
  mapping(uint => Airdrop) public airdrops;
  mapping(address => bool) public recipients;

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function addAirdrops(Airdrop[] memory _airdrops) external onlyRole(DEFAULT_ADMIN_ROLE) {
    uint _nextAirdropId = nextAirdropId;
    for(uint i = 0; i < _airdrops.length; i++) {
      airdrops[_nextAirdropId] = _airdrops[i];
      IERC721(_airdrops[i].nft).transferFrom(
        msg.sender, 
        address(this), 
        _airdrops[i].id
      );
      _nextAirdropId++;
    }
  }

  function claim() external {
    require(recipients[msg.sender] == false, 'recipient cannot complain');
    recipients[msg.sender] = true;
    Airdrop storage airdrop = airdrops[nextAirdropId];
    nextAirdropId++;
    IERC721(airdrop.nft).transferFrom(address(this), msg.sender, airdrop.id);
    
  }
}
