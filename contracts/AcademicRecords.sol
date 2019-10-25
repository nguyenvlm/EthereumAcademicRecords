pragma solidity ^0.5.3;

contract AcademicRecords {
    uint256 constant MaxStrLength = 256;
    
    struct record {
        string ID;
        string name;
        mapping (string => uint32) grades; // 0 -> 100
        bool graduated;
        bool active;
        bool exist;
    }
    
    mapping (string => record) StudentRecord;
    uint256 MaxRecordAmount;
    uint256 StudentCount;
    string[] StudentIDList;
    
    mapping (string => bool) SubjectExist;
    string[] SubjectList;
    uint256 SubjectCount;
    
    address Manager;
    string public OrganizationName;
    
    function strLimit(string memory str) private pure returns (bool){
        return bytes(str).length <= MaxStrLength;
    }
    
    constructor(string memory organizationName, uint256 maxRecordAmount) public {
        require(maxRecordAmount >= 100);
        require(strLimit(organizationName));
        Manager = msg.sender;
        OrganizationName = organizationName;
        MaxRecordAmount = maxRecordAmount;
        StudentCount = 0;
    }
    
    function addSubject(string memory name) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(name), "String length limit reached!");
        require(!SubjectExist[name], "Subject existed!");
        SubjectExist[name] = true;
        SubjectList.push(name);
        SubjectCount += 1;
    }
    
    function removeSubject(string memory name) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(name), "String length limit reached!");
        require(SubjectExist[name], "Subject not existed!");
        bool found = false;
        uint index;
        for (uint i = 0; i < SubjectCount; ++i) {
            if (keccak256(abi.encodePacked(SubjectList[i])) == keccak256(abi.encodePacked(name))) {
                index = i;
                found = true;
                break;
            }
        }
        require(found, "Can't find subject index! A serious problem happened!");
        SubjectExist[name] = false;
        delete SubjectList[index];
        SubjectCount -= 1;
        for (uint i = index; i < SubjectCount; ++i) {
            SubjectList[i] = SubjectList[i+1];
        }
    }
    
    function getSubjectCount() public view returns (uint256) {
        return SubjectCount;
    }
    
    function getSubjectName(uint256 subjidx) public view returns (string memory) {
        require(subjidx < SubjectCount, "Index out of range!");
        return SubjectList[subjidx];
    }
    
    function getStudentCount() public view returns (uint256) {
        return StudentCount;
    }
    
    function studentExist(string memory ID) internal view returns (bool) {
        require(strLimit(ID), "String length limit reached!");
        return StudentRecord[ID].exist;
    }
    
    function setStudentName(string memory ID, string memory name) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(ID), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        StudentRecord[ID].name = name;
    }
    
    function getStudentName(string memory ID) public view returns (string memory) {
        require(strLimit(ID), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        return StudentRecord[ID].name;
    }
    
    function setGraduated(string memory ID, bool newState) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(ID), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        StudentRecord[ID].graduated = newState;
    }
    
    function getGraduated(string memory ID) public view returns (bool) {
        require(strLimit(ID), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        return StudentRecord[ID].graduated; 
    }
    
    function setGrade(string memory ID, string memory subjectName, uint32 newGrade) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(ID) && strLimit(subjectName), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        require(getGraduated(ID), "Student graduated!");
        require(SubjectExist[subjectName], "Subject not existed!");
        StudentRecord[ID].grades[subjectName] = newGrade;
    }
    
    function getGrade(string memory ID, string memory subjectName) public view returns (uint32) {
        require(strLimit(ID), "String length limit reached!");
        require(studentExist(ID), "Student not existed!");
        require(SubjectExist[subjectName], "Subject not existed!");
        return StudentRecord[ID].grades[subjectName];
    }
    
    function registerStudent(string memory ID, string memory name) public {
        require(msg.sender == Manager, "Sender isn't Manager!");
        require(strLimit(ID) && strLimit(name), "String length limit reached!");
        require(StudentCount < MaxRecordAmount, "MaxRecordAmount reached!");
        require(!studentExist(ID), "StudentID existed!");
        record memory newRecord;
        newRecord.ID = ID;
        newRecord.name = name;
        newRecord.graduated = false;
        newRecord.exist = true;
        newRecord.active = true;
        StudentRecord[ID] = newRecord;
        StudentIDList.push(newRecord.ID);
        StudentCount += 1;
    }
}