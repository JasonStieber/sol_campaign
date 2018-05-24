pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minMoney) public {
        address newCampaign = new Campaign(minMoney, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns(address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
  struct Request {
      string desciption;
      uint value;
      address recipient;
      bool complete;
      uint approvalCount;
      mapping(address => bool) approvalVoteCount;
  }

  Request[] public requests;
  address public manager;
  uint public minimumContribution;
  mapping(address => bool) public approvers;
  uint public approversCount = 0;
  modifier restricted(){
      require(msg.sender == manager);
      _;
  }

  function Campaign(uint minimum, address creator) public {
      manager = creator;
      minimumContribution = minimum;
  }

  function contribute() public payable {
      require(msg.value > minimumContribution);
      approvers[msg.sender] = true;
      approversCount++;
  }

  function createRequest(string desciption, uint value, address recipient)
        public restricted {
    Request memory newRequest = Request({
       desciption: desciption,
       value: value,
       recipient: recipient,
       complete: false,
       approvalCount: 0
    });

    requests.push(newRequest);
  }

  function approveRequest(uint index) public returns(bool){
      Request storage request = requests[index];

      require(approvers[msg.sender]);
      require(!request.approvalVoteCount[msg.sender]);

      request.approvalCount++;
      request.approvalVoteCount[msg.sender] = true;
  }

  function finalizedRequest(uint index) public restricted {
      Request storage request = requests[index];

      require(request.approvalCount > (approversCount/2));
      require(!request.complete);
      request.recipient.transfer(request.value);
      request.complete = true;



  }
}
