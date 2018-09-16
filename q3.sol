pragma solidity ^0.4.14;

import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract Ballot 
{
    using strings for *;

    struct request {
        string item;
        uint256 auction_time;
        bool accepted;
        string reqid;
        uint256 create_time;
    }
    
    address seller;
    
    struct auctioner {
        string name;
        string office_address;
    }
    
    mapping (address => auctioner) auctioners;
    mapping (int256 => request) requests;
    mapping (int256 => string) bets;
    mapping (int256 => string) num_to_words;
    mapping (int256 => int256[]) public seller_bets;
    mapping (int256 => string[]) public seller_bets_name;
    
    
    event ItemSold(int256 rideId, string auctioner_add, uint256 price);

    function Ballot()
    {
        num_to_words[int256(1)] = "1";
        num_to_words[int256(2)] = "2";
        num_to_words[int256(3)] = "3";
        num_to_words[int256(4)] = "4";
        num_to_words[int256(5)] = "5";
        num_to_words[int256(6)] = "6";
        seller = msg.sender;
    }
    
    auctioner d1;
    
    
    function Registerauctioner(string name, string office_address) public returns(bool)
    {
        if(msg.sender == seller)
            return false;
        d1.name = name;
        d1.office_address = office_address;
        auctioners[msg.sender] = d1;
        return true;
    }
    
    int256 requestid = 1;
    request r1;
    function NewItem(string item, uint256 auction_time) returns(int256)
    {
        if(msg.sender != seller)
            return -1;
        r1.item = item;
        r1.auction_time = auction_time;
        r1.accepted = false;
        r1.reqid = num_to_words[requestid];
        r1.create_time = now;
        requests[requestid] = r1;
        bets[requestid] = "";
        requestid += 1;
        return requestid - 1;
    }

    function seeItems() public returns(string)
    {
        if(msg.sender == seller)
            return "Only auctioners can see requests.";
        if(keccak256(checkExistenceauctioner()) == keccak256("false"))
            return "You are not an auctioner.";
        string memory output = "";
        for (int i=1;i<requestid;i++)
        {
            if (requests[i].accepted == false)
            {
                output = output.toSlice().concat((requests[i].reqid).toSlice());
                output = output.toSlice().concat("_".toSlice());
                output = output.toSlice().concat((requests[i].item).toSlice());
                output = output.toSlice().concat("~".toSlice());
            }
        }
        return output;
    }
    
    function placeBet(int256 rideId, string name, int256 bet) public returns(string)
    {
        if(msg.sender == seller)
            return "Only auctioners can place bets.";
        if(keccak256(checkExistenceauctioner()) == keccak256("false"))
            return "auctioner does not exist";
        if(keccak256(requests[rideId].item) == keccak256(""))
            return "Request Id does not exist";
        if(requests[rideId].accepted == true)
            return "Request has already been allotted.";
        if(now - requests[rideId].create_time > requests[rideId].auction_time)
            return "Timeout to place bets";
        if(keccak256(auctioners[msg.sender].name) != keccak256(name))
            return "Name does not match";
        
        string memory output = "";
        output = output.toSlice().concat(bets[rideId].toSlice());
        output = output.toSlice().concat(name.toSlice());
        // output = output.toSlice().concat(".".toSlice());
        // output = output.toSlice().concat(bet.toSlice());
        output = output.toSlice().concat("~".toSlice());
        
        bets[rideId] = output;
        seller_bets[rideId].push(bet);
        seller_bets_name[rideId].push(name);
        return output;
    }
    
    function checkExistenceauctioner() private returns(string)
    {
        if(keccak256(auctioners[msg.sender].name) == keccak256(""))
            return "false";
        return "true";
    }
    
    function stringToUint(string s) constant returns (uint result) 
    {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) 
        {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) 
            {
                result = result * 10 + (c - 48);
            }
        }
    }
    
    function update_min(uint256 fare) private returns(uint256 min)
    {
        min = fare;
        return min;
    }
    
    // function getauctionerthree(string[] parts, uint average) private returns(string)
    // {
    //     uint multiplier = uint256(-1);
    //     uint min = 1000;
    //     string memory min_auctioner;
    //     for (uint jt=0;jt<parts.length;jt++)
    //     {
    //         var st = parts[jt].toSlice();
    //         var delimt = ".".toSlice();
    //         var splitt = new string[](2);
    //         for(uint kt = 0; kt < 2; kt++)
    //         {
    //             splitt[kt] = st.split(delimt).toString();
    //         }
    //         uint faret = stringToUint(splitt[1]);
    //         uint diff = faret - average;
    //         if (diff < 0)
    //             diff = diff * multiplier;
    //         if  (diff < min)
    //         {
    //             min = diff;
    //             min_auctioner = splitt[0];
    //         }
    //     }
    //     return min_auctioner;
    // }
    
    // function getauctionertwo(string[] parts) private returns(string)
    // {
    //     uint256 average = 0;
    //     for (uint j=0;j<parts.length;j++)
    //     {
    //         var s2 = parts[j].toSlice();
    //         var delim2 = ".".toSlice();
    //         var split = new string[](2);
    //         for(uint k = 0; k < 2; k++)
    //         {
    //             split[k] = s2.split(delim2).toString();
    //         }
    //         uint fare = stringToUint(split[1]);
    //         average += fare;
    //     }
    //     average /= j;
    //     return  getauctionerthree(parts, average);
    // }
    
    function getauctioner(int256 requestId) returns(string)
    {
        if(keccak256(requests[requestId].item) == keccak256(""))
            return "No such item exists";
        if(keccak256(bets[requestId]) == keccak256(""))
            return "No bets for this item";
        if(seller != msg.sender)
            return "Only the seller can call this function.";
        int256[] temp_array = seller_bets[requestId];
        string[] temp_names = seller_bets_name[requestId];
        uint256 average = 0;
        for(uint i = 0; i < temp_array.length; i++)
        {
            average += uint256(temp_array[i]);
        }
        average /= temp_array.length;
        uint min = 1000;
        uint diff = 0;
        string memory min_auctioner;
        uint min_price;
        for(uint j = 0; j < temp_array.length; j++)
        {
            diff = average - uint(temp_array[j]);
            if(diff < 0)
                diff = diff * uint(-1);
            if(diff < min)
            {
                min = diff;
                min_auctioner = temp_names[j];
                min_price = uint(temp_array[j]);
            }
        }
        ItemSold(requestId, min_auctioner, min_price);
        return min_auctioner;
    }

}