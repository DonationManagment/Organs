pragma solidity ^0.4.0; 
// Donor Recipient Matching Smart Contract 

contract DonorRecipientMatching {
address public ProcurementOrganizer;
address public OrganMatchingOrganizer;
mapping(address => bool) TransplantTeamMember; // only authorized Hospital Transplant Team Members are allowed
mapping(address => bool) PatientDoctor; 
uint Donor_ID;
uint Donor_BloodType;
uint Donor_OrganType;
uint Min_Age;
uint Max_Age;
uint Donor_MinBMI;
uint Donor_MaxBMI;
uint Patient_ID; // address Patient_EA; 
uint Patient_Age;
uint Patient_BMI;
mapping(uint => bool) PatientValidity; //Used to ensure that patient selection is not repeated
uint [] NeededOrganType;
uint [] public PatientsID;
uint []   Patients_age;
uint [] Blood_type;
uint []  BMI;
uint [] public Matched; 
uint startTime;
enum Bloodtype {A, B, AB, O}
Bloodtype public Bloodtype_;
enum OrganType {Heart, Lung, Liver, Kidney}
OrganType public _OrganType_;

// Events
event MatchingProcessStarted (address PatientDoctor);
event NewPatient_AddedOnTheWaitingList (address PatientDoctor, uint Patient_ID, uint Patient_Age, uint Patient_BMI, Bloodtype Bloodtype_ , OrganType _OrganType_); 
event MedicalTestApproval (address TransplantTeamMember, uint Donor_ID); 
event DonatedHeartisAvailable (address ProcurementOrganizer, uint Donor_ID, OrganType _OrganType_);
event NewMatchedOrgan (address ProcurementOrganizer);

constructor() public {
    ProcurementOrganizer = msg.sender;
    OrganMatchingOrganizer= 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    startTime = block.timestamp;
    emit MatchingProcessStarted(ProcurementOrganizer);
}
// Hospital Transplant Team Members Authorization Function
     function AssigningTransplantTeamMember (address user) public onlyProcurementOrganizer {
        TransplantTeamMember [user]=true;
    } 

function AssigningPatientDoctors (address user) public onlyProcurementOrganizer {
        PatientDoctor [user]=true;
    }

//Defining Modifiers 
modifier onlyPatientDoctor() {
    require(PatientDoctor[msg.sender], "The sender is not eligible to run this function");
    _;
}
modifier onlyTransplantTeamMember() {
    require(TransplantTeamMember[msg.sender], "The sender is not eligible to run this function");
    _;
}
modifier onlyProcurementOrganizer() {
    require(ProcurementOrganizer == msg.sender, "The sender is not eligible to run this function");
    _;
}
modifier onlyOrganMatchingOrganizer() {
    require(OrganMatchingOrganizer == msg.sender, "The sender is not eligible to run this function");
    _;
}

    function AddingNewPatient(uint ID, uint _age, uint _BMI, uint _BloodType, uint _OrganType) public onlyPatientDoctor{
    Patient_ID = ID;
    Patient_Age = _age;
    Patient_BMI= _BMI;
    Bloodtype_ = Bloodtype(_BloodType);
    _OrganType_ = OrganType(_OrganType);
    PatientsID.push(Patient_ID);
    NeededOrganType.push(_OrganType);
    Patients_age.push(Patient_Age);    
    Blood_type.push(_BloodType);
    BMI.push(Patient_BMI);
        emit NewPatient_AddedOnTheWaitingList(msg.sender, Patient_ID, Patient_Age, Patient_BMI, Bloodtype_ , _OrganType_);
    
    }
    
    function TestApproval(uint DonorID) public onlyTransplantTeamMember{
        Donor_ID = DonorID;
        emit MedicalTestApproval(msg.sender, Donor_ID); 
    }
    function RegisteringNewDonor (uint DonorID, OrganType _OrganType ) public onlyProcurementOrganizer{
        Donor_ID = DonorID;
        _OrganType_ = OrganType(_OrganType);
        emit DonatedHeartisAvailable(msg.sender, Donor_ID,  _OrganType_ );
    }

    function MatchingProcess (uint _MinAge, uint _MaxAge, uint _BloodType, uint _MinBMI, uint _MaxBMI, uint _OrganType) public onlyOrganMatchingOrganizer{
        Min_Age = _MinAge;
        Max_Age = _MaxAge;
        Donor_BloodType = _BloodType;
        Donor_OrganType = _OrganType;
        Donor_MinBMI = _MinBMI;
        Donor_MaxBMI = _MaxBMI;
        
         for (uint i = 0; i < PatientsID.length; i++ ) {
             require(PatientValidity[PatientsID[i]]==false, "The patient has already been matched with a donor");
            if ( 
            NeededOrganType[i] == _OrganType &&
            Patients_age[i]> Min_Age &&
            Patients_age[i] < Max_Age &&
            Blood_type[i] == _BloodType &&
            BMI[i]> Donor_MinBMI &&
            BMI[i] < Donor_MaxBMI) 
            { 
              Matched.push(PatientsID[i]);
              PatientValidity[PatientsID[i]]=true; 
            }
         }
    emit NewMatchedOrgan (msg.sender);          
    }}
        
        
        contract OrganTransplantation{
        address public DonorSurgeon;
        address public TransplantSurgeon; 
        mapping(address => bool) transporter; 
        enum OrganStatus {NotReady, ReadyforDelivery, StartDelivery, onTrack, EndDelivery, OrganReceived}
        OrganStatus public Organstate;
        uint startTime;
        uint Donor_ID;
        uint PatientID;
        uint Removing_time;
        uint Removing_date;
        uint TransplantationDate;
        uint  TransplantationTime;
        enum OrganType {Heart, Lung, Liver, Kidney}
        OrganType public DonatedOrganType;
        
        //Events
        event TransplantationProcessStarted (address indexed DonorSurgeon);
        event DonatedHeartisRemoved(address DonorSurgeon, uint Donor_ID);
        event DonatedLiverisRemoved(address DonorSurgeon, uint Donor_ID);
        event DonatedkidneyisRemoved(address DonorSurgeon, uint Donor_ID);
        event DonatedlungisRemoved(address DonorSurgeon, uint Donor_ID);
        event DeliveryStart (address transporter); 
        event DeliveryEnd(address transporter); 
        event DonatedOrganisReceived (address indexed TransplantSurgeon);
        event Transplantationend(address TransplantSurgeon, uint PatientID, uint TransplantationTime, uint TransplantationDate);
        
    constructor() public {
    TransplantSurgeon = msg.sender;
    DonorSurgeon =0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;
    startTime = block.timestamp;
    Organstate = OrganStatus.NotReady;
    emit TransplantationProcessStarted(msg.sender);
}

modifier onlyDonorSurgeon() {
    require(DonorSurgeon == msg.sender, "The sender is not eligible to run this function");
    _;
}
modifier onlyTransplantSurgeon() {
    require(TransplantSurgeon == msg.sender, "The sender is not eligible to run this function");
    _;
}

modifier onlytransporter() {
    require(transporter[msg.sender], "The sender is not eligible to run this function");
    _;
}
// Transporter Authorization Function

     function assigningtransporter (address user) public onlyDonorSurgeon{
        transporter [user]=true;
    }
       function RemovingDonatedOrgan(uint donorID, OrganType _DonatedOrganType, uint date, uint time ) public onlyDonorSurgeon{
        Donor_ID= donorID;
        Removing_date = date;
        Removing_time = time; 
        require(Organstate == OrganStatus.NotReady, "Donated Organ is already removed");
        Organstate = OrganStatus.ReadyforDelivery;
         if (_DonatedOrganType == OrganType.Heart){
        
        emit DonatedHeartisRemoved(msg.sender, Donor_ID);
    }
       
         if (_DonatedOrganType == OrganType.Lung){
        
        emit DonatedlungisRemoved(msg.sender,Donor_ID);
    }
            
         if (_DonatedOrganType == OrganType.Liver){
        
        emit DonatedLiverisRemoved(msg.sender,Donor_ID);
    }
         
         if (_DonatedOrganType == OrganType.Kidney){
        
        emit DonatedkidneyisRemoved(msg.sender,Donor_ID);
    }
    
    }
       function StartDelivery() public onlytransporter{
        require(Organstate == OrganStatus.ReadyforDelivery, "Can't start delivery before removing the organ");
         Organstate = OrganStatus.onTrack;
        emit DeliveryStart(msg.sender);
    }
    
    function EndDelivery() public onlytransporter{
        require(Organstate == OrganStatus.onTrack, "Can't end delivery before announcing the start of it");
        Organstate = OrganStatus.EndDelivery;
        emit DeliveryEnd(msg.sender);
        
    }
    function ReceiveDonatedOrgan() public onlyTransplantSurgeon{
        require(Organstate == OrganStatus.EndDelivery, "Can't receive the donated Organ unit before announcing the end of the delivery");
        Organstate = OrganStatus.OrganReceived;
        emit DonatedOrganisReceived(msg.sender);
    }
        function Organ_Transplantation(uint ID, uint Date, uint Time) public onlyTransplantSurgeon{
         PatientID = ID;
         TransplantationDate = Date; 
         TransplantationTime = Time;
        emit Transplantationend(msg.sender, PatientID, TransplantationTime, TransplantationDate);
    }
    
    }
    
    
        

    
