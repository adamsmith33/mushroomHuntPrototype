pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/access/Ownable.sol";
import {sharedStructs} from "./libraries/sharedStructs.sol";

import "./shroomies.sol";

contract shroomJSON is Ownable {

    address shroomiesContract;

    constructor(address addr) {
        setShroomiesContract(addr);
    }

    function setShroomiesContract(address addr) public onlyOwner{
        shroomiesContract = addr;
    }
    
    function getShroomyJSON(uint256 _tokenId) public view returns(string memory) {
        sharedStructs.shroomy memory s = Ishroomies(shroomiesContract).getShroomy(_tokenId);
        return string(abi.encodePacked('{"name": "',s.name,'", "description": "', s.description,'", "mushroomNo": ', Strings.toString(s.mushroomNo),', "species": "', s.species,'", "accessory": ', Strings.toString(s.accessory),', "age": ', Strings.toString(s.age),', "experience": ', Strings.toString(s.experience),'}'));
    }

    function getAllShroomyJSON() public view returns(string memory) {
        sharedStructs.shroomy[] memory s = Ishroomies(shroomiesContract).getAllShrooms();

        string memory start = '{"shrooms": [';
        string memory first = getShroomyJSON(0);
        string memory middle;
        string memory last = ']}';

        for(uint i=1; i < s.length; i++){
            middle = string(abi.encodePacked(middle, ",", getShroomyJSON(i)));
        }

        return(string(abi.encodePacked(start, first, middle, last)));
    }
}
/*
    function getShroomy(uint256 _tokenId) external view returns(shroomy memory);

    function getYourShroomy() external view returns(shroomy memory);

    function getAllShrooms() external view returns(shroomy[] memory);

*/