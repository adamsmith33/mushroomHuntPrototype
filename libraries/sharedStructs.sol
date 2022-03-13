pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED

library sharedStructs{
    struct shroomy {
        string name;
        string description;
        string imageURI; 
        uint mushroomNo;
        string species;
        uint accessory;
        uint256 age;
        uint256 experience;
    }

    struct mycolocation {
        string title;
        string description;
        string imageURI;
        uint256 locationNo;
        uint256 xCoord;
        uint256 yCoord;
        uint256[] requiredAccessories;
        uint256 xpValue;
    }

    struct truffleEntry {
        address visitor;
        uint256 shroomId;
        uint256 timestamp;
        string message;
    }
    }