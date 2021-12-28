//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BlockchainSplitwise {
    // Key is user's address, value is list of IOU.
    // IOU map contains owed user as key, owed amount as value.
    mapping(address => mapping(address => uint32)) public balances;

    address[] public users;
    mapping(address => bool) unique_users;

    function lookup(address debtor, address creditor) public view returns (uint32 ret) {
        return balances[debtor][creditor];
    }
    
    event test_value(uint256 indexed value1);

    // Informs the contract that msg.sender now owes amount more dollars to creditor.
    function add_IOU(address creditor, uint32 amount, address[] memory path) public {
        require(msg.sender != creditor, "You can not owe yourself money");
        
        // solve loop issue
        if (path.length > 0) {
        // we got a loop. From all the paths, find the minimal value
            uint32 min_val = amount;
            address cur = path[0];
            for (uint32 i = 1; i < path.length; i++) {
                uint32 cur_val = lookup(cur, path[i]); // save gas
                require(cur_val != 0);
                if (cur_val < min_val) {
                    min_val = cur_val;
                }
                cur = path[i];
            }

            emit test_value(min_val);

            // do a reverse IOU to subtract this minimal
            cur = path[0];
            for (uint32 i = 1; i < path.length; i++) {
                balances[cur][path[i]] -= min_val;
                cur = path[i];
            }
            
            // Set amount -= min, if 0, return early
            amount -= min_val;
            if (amount == 0) {
                return;
            }
        }


        if (balances[msg.sender][creditor] == 0) {
            balances[msg.sender][creditor] = amount;
        } else {
            balances[msg.sender][creditor] += amount;
        }

        // Add users if not visited
        if (unique_users[msg.sender] == false) {
            unique_users[msg.sender] = true;
            users.push(msg.sender);
        }

        if (unique_users[creditor] == false) {
            unique_users[creditor] = true;
            users.push(creditor);
        }
    }

    function all_users() public view returns(address [] memory){
        return users;
    }
}
