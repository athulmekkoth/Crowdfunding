pragma solidity >= 0.5.0 <0.9.0;
contract crowdfunding
{
    mapping(address=>uint) public contributers;
    address public manager;
    uint public minimumcontribution;
    uint public deadline;
    uint public target;
        uint public raisedamount;
        uint public noofcontributers;
        struct Request
        {
            string description;
            address payable receipent;
            uint value;
            bool completed;
            uint noofvotes;
            mapping(address=>bool) voters;
        }
        mapping(uint =>Request) public requests;
        uint public numRequests;
        constructor(uint _target,uint _deadline)
        {
            target=_target;
            deadline = block.timestamp+_deadline; //10 sec +sec to run
            minimumcontribution =   100 wei;
            manager=msg.sender;
        }
        function sendEth() public payable
        {
            require(block.timestamp < deadline ,"Deadline has passed");
            require(msg.value >= minimumcontribution,"minimmum contrivution is not met");
            if(contributers[msg.sender]==0)
            {
                noofcontributers++;
            }
            contributers[msg.sender] += msg.value;
            raisedamount += msg.value;

        }
        function getbalance() public view returns(uint)
        {
           
            return address(this).balance;
        }
        function refund() public {
            require(block.timestamp > deadline && raisedamount <target,"you are not eligible for refund" );
            require(contributers[msg.sender]>0);
            address payable user=payable(msg.sender);
            user.transfer(contributers[msg.sender ]);
            contributers[msg.sender]=0;  

        }
          modifier onlyManager()
        {
            require(msg.sender == manager ,"only manager can call");
             _;
        }
            function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager{
            Request storage  newRequest=requests[numRequests]; //inside structure and use functu  use storage bcz we use mapping inside strucute
            //REQUEST-<REQUEST[0]
            numRequests++;
            newRequest.description=_description;
   newRequest.receipent=_recipient;
      newRequest.value =_value;
               newRequest.completed=false;
               newRequest.noofvotes=0;
            
        } 
        function voteRequest(uint _requesNo) public {
            require(contributers[msg.sender]>0,"you must be a contributer");
            Request storage thisRequest=requests[_requesNo];
            require(thisRequest.voters[msg.sender] == false,"you already voted");
            thisRequest.voters[msg.sender]=true;
            thisRequest.noofvotes++;

        }
function makepayment(uint _reqno) public onlyManager
{
    require(raisedamount >= target);
    Request storage thisRequest = requests[_reqno];
    require(thisRequest.completed == false,"already paid");
    require(thisRequest.noofvotes > noofcontributers/2,"majority dosent support"); //atleast 50% vote
    thisRequest.receipent.transfer(thisRequest.value);
    thisRequest.completed=true;
}
      
    
}