// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC20.sol";

contract ERC20 is IERC20Metadata {

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    
    mapping (address => uint256) internal balances;
    // mapping (owner => mapping (spender, amount))
    mapping (address => mapping (address => uint256)) internal allowances;
    address internal immutable owner;

     modifier onlyOwnerCanMint {
        require (msg.sender == owner, "only minter can mint");
        _;
    }

    constructor (string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        totalSupply = 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        emit Approval(msg.sender, spender, amount);
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) override public returns (bool) {
        require(allowances[from][msg.sender] >= amount, "insufficient allowance");
        transfer(from, to, amount);
        allowances[from][msg.sender] -= amount;
        return true;
    }

    function transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(balances[from] >= amount, "insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) onlyOwnerCanMint external {
        balances[to] += amount;
        totalSupply += amount;
    }
}
