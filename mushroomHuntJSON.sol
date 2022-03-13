pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; //For handling strings
import {sharedStructs} from "./libraries/sharedStructs.sol";

import "./mushroomHunt.sol";

contract mushroomHuntJSON is Ownable {
    address mushHuntContract;

    constructor(address addr){
        setMushHuntContract(addr);
    }

    function setMushHuntContract(address addr) public onlyOwner{
        mushHuntContract = addr;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
}

function char(bytes1 b) internal pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
}

    function getMycolocationJSON(uint256 _Id) public view returns(string memory) {
        sharedStructs.mycolocation memory m = ImushroomHunt(mushHuntContract).getMycolocation(_Id);
        string memory required;

        if(m.requiredAccessories.length > 0) {
            string memory arrayStart = '[';
            string memory arrayEnd = ']';
            string memory first = Strings.toString(m.requiredAccessories[0]);
        if(m.requiredAccessories.length > 1){
                string memory middle;
                

            for(uint i= 1; i < m.requiredAccessories.length; i++) {
                middle = string(abi.encodePacked(middle,",",Strings.toString(m.requiredAccessories[i])));
                }

            required = string(abi.encodePacked(arrayStart, first, middle, arrayEnd));
            } else {
                required = string(abi.encodePacked(arrayStart, first, arrayEnd));
            }

        }


        return string(abi.encodePacked('{"title": "',m.title,'", "description": "', m.description,'", "locationNo": ', Strings.toString(m.locationNo),', "xCoord": "', Strings.toString(m.xCoord),'", "yCoord": ', Strings.toString(m.yCoord),', "requiredAcessories": ', required,', "xpValue": ', Strings.toString(m.xpValue),'}'));
    }

    function getAllLocationJSON() public view returns (string memory){
        sharedStructs.mycolocation[] memory m = ImushroomHunt(mushHuntContract).getAllLocations();

        string memory start = '{"mycolocations": [';
        string memory first = getMycolocationJSON(0);
        string memory middle;
        string memory last = ']}';

        for(uint i=1; i < m.length; i++){
            middle = string(abi.encodePacked(middle, ",", getMycolocationJSON(i)));
        }

        return(string(abi.encodePacked(start, first, middle, last)));
    }

    function getTruffleBoxJSON(uint _tokenId) public view returns(string memory){
        sharedStructs.truffleEntry[] memory t = ImushroomHunt(mushHuntContract).getTruffleBox(_tokenId);

        console.log("ok");

        string memory start = '{"truffles": [';
        string memory first = string(abi.encodePacked('{"visitor": "',toAsciiString(t[0].visitor),'", "shroomId": ', Strings.toString(t[0].shroomId),', "timestamp": ', Strings.toString(t[0].timestamp),', "message": "', t[0].message,'"}'));
        string memory middle;
        string memory last = ']}';

        for(uint i = 1; i < t.length; i++){
            console.log("ok");
            string memory temp = string(abi.encodePacked('{"visitor": "', toAsciiString(t[0].visitor),'", "shroomId": ', Strings.toString(t[i].shroomId),', "timestamp": ', Strings.toString(t[i].timestamp),', "message": "', t[i].message,'"}'));
          middle = string(abi.encodePacked(middle, ",", temp));  
          console.log("ok");
        }

    console.log("all packed");

        return(string(abi.encodePacked(start, first, middle, last)));
    }

}
/*
    function getMycolocation(uint256 locationId) external view returns(sharedStructs.mycolocation memory);

    function getAllLocations() external view returns(sharedStructs.mycolocation[] memory);

    function getTruffleBox(uint256 LocationId) external view returns(sharedStructs.truffleEntry[] memory);

    struct truffleEntry {
        address visitor;
        uint256 shroomId;
        uint256 timestamp;
        string message;
    }
    */