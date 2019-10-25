pragma solidity ^0.5.1;

contract AcademicRecords {
    uint256 constant MaxStrLength = 256;
    
    struct record {
        bytes32 ID;
        string name;
        mapping (string => fixed8x4) grades;
        bool graduated;
        bool active;
        bool exist;
    }
    
    mapping (bytes32 => record) StudentRecord;
    uint256 MaxRecordAmount;
    uint256 CurrentAmount;
    bytes32[] StudentIDList;
    string[] SubjectList;
    uint256 SubjectCount;
    
    address Manager;
    string public Organization;
    
    function strLimit(string memory str) private pure returns (bool){
        return bytes(str).length <= MaxStrLength;
    }
    
    constructor(string memory organization, uint256 maxRecordAmount) public {
        require(maxRecordAmount >= 100);
        require(strLimit(organization));
        Manager = msg.sender;
        Organization = organization;
        MaxRecordAmount = maxRecordAmount;
        CurrentAmount = 0;
    }
    
    function addSubject(string memory name) public {
        require(strLimit(name));
        SubjectList.push(name);
        SubjectCount += 1;
    }
    
    function removeSubject(string memory name) public {
        require(strLimit(name));
        bool found = false;
        uint index;
        for (uint i = 0; i < SubjectCount; ++i) {
            if (keccak256(abi.encodePacked(SubjectList[i])) == keccak256(abi.encodePacked(name))) {
                index = i;
                found = true;
                break;
            }
        }
        require(found);
        delete SubjectList[index];
        SubjectCount -= 1;
        for (uint i = index; i < SubjectCount; ++i) {
            SubjectList[i] = SubjectList[i+1];
        }
    }
    
    function queryExist(bytes32 ID) internal view returns (bool) {
        return StudentRecord[ID].exist;
    }
    
    function queryGraduated(bytes32 ID) public view returns (bool) {
        return queryExist(ID) && StudentRecord[ID].graduated; 
    }
    
    function registerStudent(bytes32 ID, string memory name) public {
        require(CurrentAmount < MaxRecordAmount);
        require(queryExist(ID));
        require(strLimit(name));
        record memory newRecord;
        newRecord.ID = ID;
        newRecord.name = name;
        newRecord.graduated = false;
        newRecord.exist = true;
        newRecord.active = true;
        StudentRecord[ID] = newRecord;
        StudentIDList.push(newRecord.ID);
        CurrentAmount += 1;
    }
}